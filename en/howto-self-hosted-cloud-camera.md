# OpenIPC Wiki
[Table of Content](../README.md)

Self-hosted cloud camera
========================

Watch your camera from anywhere, in a browser, with no port forwarding, no
dynamic DNS and no vendor account — using a server you control.

### The problem this solves

The app that came with a Chinese camera works from anywhere, and it works
because the camera **dials out** to the manufacturer's server. Nothing has to
be opened on your router, and it survives the kind of internet connection that
gives you no public address of your own.

Flashing OpenIPC removes that server, which is usually the point. But it also
removes the property that made the app convenient: RTSP waits to be connected
*to*, so reaching the camera from outside the house means forwarding a port,
running dynamic DNS, or putting a VPN on every device you want to watch from.
For a camera on mobile broadband or on an internet connection with no public
address, port forwarding is not an option at all.

WHIP gives the dial-out back without giving back the vendor. The camera pushes
its video to a server **you** choose, over an open standard
([RFC 9725](https://www.rfc-editor.org/info/rfc9725/)), and you watch it in a
browser. Latency is typically a few hundred milliseconds, against the several
seconds an HLS-based setup costs you.

### What you'll need

- **A camera running Lite or Ultimate.** The FPV build has WebRTC compiled out,
  so it cannot do this. Check with `majestic -v` on the camera — the first word
  is the flavour. For sound as well as picture you want a build from
  **17 September 2026** or later; before that this path was video only, and an
  older camera will publish a working video stream and no audio.
- **A server with a public address.** The cheapest VPS will do; this is a relay,
  not a transcoder, and the video passes through untouched.
- **A domain name** pointing at that server, if you want the browser to stop
  complaining. Strictly optional for a first test.

Everything below uses [MediaMTX](https://github.com/bluenviron/mediamtx),
which is a single binary with no dependencies and speaks both halves of what
we need. Other servers work too.

## Step 1 — Put a server up

On the VPS:

```yaml
# docker-compose.yml
services:
  mediamtx:
    image: bluenviron/mediamtx:latest
    network_mode: host
    restart: unless-stopped
    volumes:
      - ./mediamtx.yml:/mediamtx.yml:ro
```

`network_mode: host` is worth keeping. WebRTC hands out the addresses it finds
on the machine's own interfaces, and behind Docker's bridge those are addresses
nobody outside can reach.

Open two ports in the VPS firewall:

| Port | Protocol | Carries |
|------|----------|---------|
| 8889 | TCP | the signalling, and the built-in player page |
| 8189 | UDP | the video itself |

The UDP one is the one people forget. Without it the camera connects, reports
success, and sends a picture into a hole.

## Step 2 — Lock it down before you point anything at it

**MediaMTX out of the box lets anyone publish and anyone watch.** Left alone on
a public address, it is an open relay with your camera on it. Write
`mediamtx.yml` before the first start:

```yaml
authInternalUsers:
  # The camera. Allowed to publish to one path and nothing else.
  - user: camera
    pass: a-long-random-string
    permissions:
      - action: publish
        path: frontdoor

  # You, watching. Allowed to read, not to publish.
  - user: viewer
    pass: a-different-long-string
    permissions:
      - action: read
        path: frontdoor

webrtc: yes
webrtcAddress: :8889
webrtcLocalUDPAddress: :8189
webrtcAdditionalHosts: [cam.example.com]

paths:
  frontdoor:
```

`webrtcAdditionalHosts` matters on a VPS whose public address is NATted to it
rather than configured on the interface — a fairly common arrangement. Without
it the server advertises only what it can see locally.

## Step 3 — Turn on TLS

Skip this for a first test; do not skip it for anything permanent.

**If you skip it, every `https://` below becomes `http://`** — the port does
not change, only the scheme. Turning TLS on later means changing it back in two
places: the camera's destination in Step 4, and whatever you have bookmarked
from Step 5.

```yaml
webrtcEncryption: yes
webrtcServerCert: /certs/fullchain.pem
webrtcServerKey: /certs/privkey.pem
```

Mount the certificate directory into the container and the player moves to
`https://cam.example.com:8889/`. See [Let's Encrypt certificates](acme-v2.md)
for getting one.

The camera checks the server's certificate against the usual public
authorities, the same as any other program making an outbound connection. A
server with a self-signed or private-CA certificate is therefore reached over
plain `http://` on a trusted network, or by installing your CA on the camera —
there is no setting that turns the check off.

## Step 4 — Point the camera at it

In the web interface: **Settings → Network & Integrations → Outgoing**, add a
destination. Or in `/etc/majestic.yaml` directly:

```yaml
outgoing:
  servers:
    - url: https://cam.example.com:8889/frontdoor/whip
      token: camera:a-long-random-string
      channel: main
      enabled: true
```

That `token` looks odd and it is worth a sentence. The camera presents its
credential one way — as a bearer token — because that is what the WHIP standard
describes. MediaMTX accepts a username and password through that same header by
writing them `user:pass`, exactly as it does for OBS Studio and anything else
that cannot pop up a login box. So the value above is the `camera` user and its
password from Step 2, joined by a colon.

A server that issues real tokens takes one as-is:

```yaml
      token: eyJhbGciOi...
```

Leave `token` out entirely for an endpoint that wants no credential. An empty
one is not the same thing, and a server that reads a blank credential as a
failed one will turn the camera away.

Four things about that entry:

- **The URL ends in `/whip`.** MediaMTX publishes at
  `http(s)://host:8889/<path>/whip`. Other servers spell it differently —
  OvenMediaEngine, for instance, uses `?direction=whip` on a different port.
- **`channel`** picks which encoder feeds it: `main` (full resolution) or `sub`.
  Absent means main. You can add a second entry for the other channel on its
  own path.
- **`enabled: false`** parks a destination without deleting it, which is handy
  while you are getting the server right.
- **Audio needs no key at all.** A camera with `audio.enabled: true` publishes
  its microphone alongside the video. `audioSource: none` turns that off for
  this destination; `audioCodec: alaw` pins G.711 for a server that will not
  take Opus. There is no talkback — the camera sends, it does not listen.

Each entry in `servers` is its own connection, so the camera can publish here
and to somewhere else at the same time, and can keep its RTSP server running
for the NVR on your LAN.

## Step 5 — Watch it

MediaMTX ships a player. Open:

```
https://cam.example.com:8889/frontdoor
```

and it will ask for the `viewer` credentials. That is the whole thing working.

To put the picture on a page of your own, MediaMTX serves an embeddable version
at `https://cam.example.com:8889/frontdoor/?controls=false` — an `<iframe>`
around that is usually all anyone needs.

## When the camera still cannot get out

The setup above needs no STUN or TURN server: your relay has a public address,
so the camera can always reach *it*, whatever your router is doing. That covers
most homes, and it is why this arrangement is so much less fragile than
peer-to-peer.

A network that permits UDP only to certain destinations is the awkward case.
A relay the camera *is* allowed to reach will carry the video:

```yaml
webrtc:
  iceServers: turn:turn.example.com:3478
  turnUsername: camera
  turnCredential: another-long-string
```

Both credentials are required — a relay named without them is dropped from the
list rather than tried. Give `iceServers` a comma-separated list if you have
more than one. [coturn](https://github.com/coturn/coturn) is the usual server,
and all of your video flows through it, so put it somewhere with bandwidth.

**The camera relays over UDP only.** It has no TCP and no TLS transport for
this, so `turns:` addresses and the `?transport=tcp` suffix are both refused —
the camera declines such a server and carries on without it rather than
spending the session trying. A network that blocks outbound UDP outright
therefore cannot be worked around from the camera's side; you need a route out
for UDP, or this arrangement is not the one for that site.

## Things that will surprise you

**Sound arrives on its own, which may not be what you wanted.** A destination
that never mentions audio publishes the microphone, so a camera with audio
enabled starts carrying sound the moment you update to a firmware that can.
On a metered uplink that is a bill you did not ask for. `audioSource: none`
on the entry keeps it quiet.

**H.265 and browsers do not get along.** These cameras often default to H.265
because it halves the bitrate, and the camera will happily publish it. Browser
support for H.265 over WebRTC is patchy and depends on the machine's hardware —
Safari is generally fine, Chrome is a coin toss. If the player connects and
shows you nothing, this is almost always why. Set the channel you are
publishing to H.264 under **Settings → Video**.

**Three sessions at once.** The camera serves three WebRTC connections in
total, and a publishing destination spends one of them — as does every browser
sitting on the camera's own live page. This is the right way round anyway: let
the camera push one stream to the server and let the server serve the audience,
which is what a server is for. Ten people watching one camera should be ten
people connected to the VPS, not ten people connected to the camera.

**A reboot of the server is not automatic.** The camera retries, but give it a
few seconds after the relay comes back before deciding something is broken.

## Troubleshooting

**Connects, then nothing.** UDP 8189 is closed, or the server is advertising an
address that is not reachable. Check the firewall first, then
`webrtcAdditionalHosts`.

**The camera reports that the relay turned it away.** The `token` does not match
`authInternalUsers` — check the colon is there and that you have the password
from Step 2 — or the user you are publishing as has no `publish` permission for
that exact path. The path in the URL has to match the one in the permission
character for character. MediaMTX logs its side of the same refusal, which is
the quicker place to look.

**The player page loads but the video is black.** Usually the H.265 problem
above. Confirm by pulling the same stream with a player that does not care:

```
ffplay rtsp://viewer:a-different-long-string@cam.example.com:8554/frontdoor
```

Step 1 does not open 8554, because nothing in this guide needs it — run this on
the server itself, or open the port while you are testing and close it after.

If that shows a picture and the browser does not, it is the codec.

**Nothing at all, and you want to know whose fault it is.** Publish to the same
endpoint from a PC with a recent ffmpeg, which speaks WHIP too. Park the
camera's destination first (`enabled: false`) so the two are not both trying to
publish to one path:

```
ffmpeg -re -f lavfi -i testsrc2=size=640x360:rate=25 \
       -c:v libx264 -profile:v baseline -g 25 -pix_fmt yuv420p -an \
       -f whip -authorization "camera:a-long-random-string" \
       "https://cam.example.com:8889/frontdoor/whip"
```

A test pattern that appears in the player proves the server, the firewall and
your credentials are all fine, and points the finger back at the camera.

## See also

- [Majestic configuration](majestic-config.md) — the full `outgoing` section
- [Majestic Streamer](majestic-streamer.md) — Lite, Ultimate and FPV
- [Live streaming to Telegram](howto-streaming-telegram.md) — the RTMP path, for
  broadcasting rather than watching
- [A doorbell from a camera](howto-doorbell-from-camera.md) — two-way audio,
  which this path does not do
