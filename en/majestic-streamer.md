# OpenIPC Wiki
[Table of Content](../README.md)

Majestic Streamer
-----------------

### Preamble

Majestic is a video streaming application, the heart of our firmware (in
relation to camera/video surveillance functionality). Majestic is configurable
via /etc/majestic.yaml file, and has many features/services enabled by default.
Unneeded options can be switched off for better security and performance. See /etc/majestic.full for configuration options.

### Lite, Ultimate and FPV

Majestic is published in three flavours. They are one streamer with a different
set of optional parts compiled in, picked for what the camera is *for* rather
than for what it costs:

- **Lite** — the everyday build, and what almost every camera runs. Everything
  a surveillance camera is expected to do, including audio, two-way talk,
  WebRTC in the browser and pushing to YouTube.
- **Ultimate** — Lite plus the extras that only some owners ask for: MP3 audio,
  WebP snapshots, and snapshots that can be cropped, made greyscale or sent
  progressively without a second encoder.
- **FPV** — a latency-first build for flying. Audio, WebRTC, SIP and RTMP are
  compiled out, leaving a binary about half the size of Lite that does one
  thing: put a picture on a radio link and get out of the way.

Which one a camera runs is fixed by the firmware image, not by a setting. Ask
the binary:

```
root@openipc-hi3516ev200:~# majestic -v
Lite HiSilicon (hi3516ev200), 1.0.0, 2026-08-27 09:14
```

The first word is the flavour. It also appears in the first line of the log at
every start, and on the built-in player page at `/hls`.

#### In every build

Nothing in the list below depends on the flavour. FPV has all of it too.

H.264 and H.265 encoding on two channels · MJPEG · JPEG, HEIF and YUV
snapshots · RTSP server, with MJPEG over RTSP · HLS · MP4 recording to a card ·
ONVIF and WS-Discovery · netip and IPEYE · mDNS · RTP push over `udp://` and
`unix:` · OSD with privacy masks · motion detection · night mode ·
the web interface, the HTTP API and HTTPS.

#### What the flavours change

| | FPV | **Lite** | Ultimate |
|---|:---:|:---:|:---:|
| Microphone, speaker, `/audio.*` endpoints | — | ✅ | ✅ |
| Opus, AAC, G.711 A-law / µ-law, raw PCM | — | ✅ | ✅ |
| [MP3][mp3] audio (`/audio.mp3`, `audio.codec: mp3`) | — | — | ✅ |
| [WebP][webp] snapshots (`/image.webp`) | — | — | ✅ |
| Crop and greyscale snapshots on any SoC, without `jpeg.tuned` ([`/image.jpg?crop=`](#crop-and-gray-on-ultimate)) | — | — | ✅ |
| [Progressive][prog] snapshots (`jpeg.toProgressive`) | — | — | ✅ |
| Audio track in MP4 recordings | — | ✅ | ✅ |
| Play a clip on the speaker (`/play_audio`) | — | ✅ | ✅ |
| RTSP back-channel (ONVIF Profile T talkback) | — | ✅ | ✅ |
| WebRTC — browser preview, adaptive bitrate, talkback | — | ✅ | ✅ |
| Cloud signalling (`cloud.enabled`) | — | ✅ | ✅ |
| SIP client (the doorbell use case) | — | ✅ | ✅ |
| RTMP and RTMPS push (YouTube, Telegram, VK…) | — | ✅ | ✅ |

The one thing FPV gains in exchange is room. Measured on a Goke GK7205V200,
same commit, same toolchain, stripped:

| flavour | binary | vs Lite |
|---|---|---|
| FPV | 500 KB | −45% |
| **Lite** | 913 KB | — |
| Ultimate | 1.37 MB | +54% |

On a camera with 8 MB of flash that difference is the feature.

#### Which cameras get which

Lite is built for every supported SoC. Ultimate is published for GK7205V200,
GK7205V500, Hi3516CV200, Hi3516CV300 and Hi3516EV200. FPV is published for
GK7205V200 and Hi3516EV200 — the two chips the flying builds are actually
flown on.

If a setting or an endpoint from this wiki is missing on your camera, the build
is the first thing to check: a knob absent from the schema is one this binary
was not built with, and the API answers `404` for it rather than accepting a
value nothing would apply. `curl http://localhost/api/v1/config.json` lists
exactly what your build has.

### User levels in the system

Majestic authenticates against the system accounts in `/etc/shadow` — the same
credentials as SSH — and sorts them into two levels:

**root** — full access. The web interface, the API, the terminal and log
sockets, firmware upgrade, everything.

**any other system account** — media only. Such an account can fetch snapshots
and the MJPEG stream, watch over WebSocket video, and work the night-mode
switches, but it cannot log in to the interface or touch the API. Concretely,
the paths it is allowed are `/image*`, `/mjpeg*`, `/night/*`, `/ws/video` and
`/cgi-bin/v*`. It also authenticates for RTSP and for ONVIF.

The conventional name for such an account is `viewer`, and creating one takes a
line:

```
adduser viewer -s /bin/false -D -H ; echo viewer:123456 | chpasswd
```

A "remember me" session cookie is only ever issued to root, so a media account
has to present its credentials on each request.

Authentication can be turned off entirely with `system.unsafe: true`. That
opens every endpoint on the camera to anyone who can reach the port — use it on
an isolated bench, not on a network.

### Control signals

| Signal | What it does |
|---|---|
| `SIGHUP` | Re-read `/etc/majestic.yaml`, tear the media pipeline down and build it again. This is what `killall -HUP majestic` — and the WebUI, and `cli` — use to apply a change. Repeat signals within 3 seconds are ignored. |
| `SIGQUIT` | Release the SDK and the video memory with it, but keep the process running and answering. This is how `sysupgrade` frees RAM for a firmware download. A `SIGHUP` afterwards brings the pipeline back. |
| `SIGINT`, `SIGTERM` | Release the SDK and exit. |
| `SIGUSR2` | Start or end a SIP call — see [SIP](#sip) below. Only in builds with SIP, and only when `sip.enabled` is set. |
| `SIGUSR1` | Reserved by Majestic's thread pool. Do not send it. |

On Ingenic, a `SIGHUP` that arrives while a CGI script is running is postponed
by a second rather than dropped, so a reload during a WebUI action is safe.

```
killall -HUP majestic
```

### Camera related URLs in firmware

Majestic supports multiple audio, video and still image formats, and more.
The full list of endpoints is on the **Majestic Endpoints** page of the camera's
own web interface: open `http://<camera-address>/` in a browser and pick it from
the menu. That page is built from the firmware that is actually running, so it
matches your build rather than whatever was current when a document was written.
It also fills in the camera's own address, uses the right scheme for your setup
(http or https, ws or wss), and says whether the endpoints ask for a password.

A JPEG snapshot can be asked for at a size, quality or crop of its own, rather
than the one `jpeg.*` sets for everybody:

`/image.jpg?width=640&height=360&qfactor=73&gray=1&crop=0x0x1280x720`

| parameter | meaning |
|---|---|
| `crop` | `XxYxWxH` — top-left corner, then size, the same order as `video0.crop`. |
| `gray` | `1` for greyscale. |
| `width`, `height` | Size of this snapshot. |
| `qfactor` | JPEG quality, 1–100. |

They fall into two groups, and which group a parameter is in decides what the
camera has to do to serve it.

#### `crop` and `gray`, on Ultimate

An **Ultimate** build cuts a crop out of the captured frame, or drops its
colour, by rearranging what the encoder already produced instead of encoding
anything again. Nothing has to be switched on first, it works on every SoC, and
it costs no quality — the picture inside the crop is the same picture, to the
byte.

It is also much cheaper than the full snapshot it comes from, which is the point
on a slow link. On a 4K camera, a 1280×720 crop is roughly a seventh of the
bytes and a fraction of the work.

One consequence worth knowing. A JPEG is stored in blocks, so a crop that costs
nothing can only *begin* on a 16-pixel boundary. The corner you ask for is
rounded **outwards** — you always get at least the region you asked for, never
less — and the rectangle actually used comes back in a header:

```
$ curl -sD - -o out.jpg 'http://camera/image.jpg?crop=100x100x1280x720' | grep -i x-crop
X-Crop-Applied: 96x96x1284x724
```

Ask for a corner already on the grid (`0x0`, `96x96`, `640x480`…) and you get
exactly the rectangle you named.

#### `width`, `height` and `qfactor`, and everything on Lite

A different size or a different quality cannot be had without encoding the frame
again, and there is exactly one encoder to do that with. Two conditions apply:

- **HiSilicon and Goke only.** Elsewhere the parameters are refused with `501` —
  set `jpeg.size` and `jpeg.qfactor` in the config instead.
- `jpeg.tuned` must name the largest size you intend to ask for, e.g.
  `jpeg.tuned: 1920x1080`, and Majestic must be restarted after setting it. It
  is `off` by default, because the frame buffers it reserves are paid for
  whether or not anyone ever asks for a snapshot, and nothing shipped on the
  camera does — ONVIF, netip and the web interface all take the plain one. A
  request larger than the cap is refused and says so.

Two clients asking for *different* sizes or qualities at the same time is
answered with `409`; asking for the same ones shares a single capture.

On **Lite and FPV** there is no such rearranging built in, so `crop` and `gray`
are served the same way as the rest, under the same two conditions.

#### When it says no

A `crop` that is malformed, has a negative corner, is empty, or falls outside
the frame is rejected with `400` rather than quietly ignored. A crop or a
greyscale conversion asked for while another one is still running is answered
with `503`: that transformation *is* the request, so the camera says come back
shortly rather than send an uncropped picture as if nothing had happened. A
plain `/image.jpg` with no parameters is unaffected by any of this and always
works.

### Changing parameters via the HTTP API

Parameters can be changed at runtime through Majestic's HTTP API. Setting a
value applies it to the running streamer and saves it to `/etc/majestic.yaml`
in a single step — there is no need to reload or restart Majestic afterwards.

Set a single parameter (the key is the config path *without* the leading dot):
```
curl 'http://localhost/api/v1/set?video0.fps=10'
```

Set several parameters at once by posting a JSON document. Group the keys the
same way they are nested in the config file:
```
curl http://localhost/api/v1/config --data-binary @- <<'EOF'
{
  "video0": {
    "codec": "h264",
    "fps": 10
  }
}
EOF
```

> The older `cli` / `yaml-cli` utility (e.g. `cli -s .video0.fps 10 ; killall
> -HUP majestic`) is deprecated. Prefer the HTTP API above, which applies the
> change live and persists it for you.

### Experimental Control Features (not yet described in endpoints)

`/metrics` returns everything below in Prometheus text format, plus process,
thread-pool, uptime, allocator and HLS counters. The sub-paths return one group
each:

```
/metrics/venc      encoder counters
/metrics/isp       ISP parameters
/metrics/night     day/night state and light level
/metrics/motion    motion detection state
```
```
/night/ircut
/night/light
```
Example for disable and enable night mode
```
root@openipc-ssc377d:~# wget -q -O - http://localhost/night/off
0
root@openipc-ssc377d:~# wget -q -O - http://localhost/night/on
1
root@openipc-ssc377d:~# wget -q -O - http://localhost/night/toggle
*
```

### Auto day/night detection

If these variables are used, it is possible to replace the used sandbox scripts.
Works only for simple day/night schemes with minimal configuration and in the absence of mentions of lightSensorPin in the majestic.yaml configuration file.
If the light sensor gpio is set, it will use the default mode.

The settings work like this:
```day < [minThreshold] | hysteresis | [maxThreshold] < night```

If the sensor gain is 1024 on a bright day the minThreshold could be set to 2000,
if the sensor gain is 32000 on a dark night the maxThreshold could be set to 10000.

```
curl http://localhost/api/v1/config --data-binary @- <<'EOF'
{
  "nightMode": {
    "minThreshold": 10,
    "maxThreshold": 50
  }
}
EOF
```

### On-screen display and privacy masks

Two different things share the `osd` section, and they answer to different
switches.

The **text overlay** is the timestamp, or whatever `osd.template` renders. It is
drawn on each stream separately and sized for that stream's own frame, so the
clock takes up about as much of a 704x576 sub stream as it does of a 2592x1520
main one. Turn it on with `osd.enabled`, then choose which streams carry it:

| Key | Default | Applies to |
| --- | --- | --- |
| `video0.osd` | `true` | the main stream |
| `video1.osd` | `true` | the sub stream |
| `jpeg.osd` | `true` | `/image.jpg` and `/mjpeg` |

All three are on by default, so `osd.enabled: true` alone stamps every stream.
Turning one off leaves the others stamped.

A **privacy mask** is not part of that. It is a rectangle of the picture blacked
out, and it covers every stream that is running — both video channels and the
snapshot — because a stream showing the picture has to hide the same part of it.
Turning the text off on a stream does not uncover the mask.

Masks are written against the main stream's frame and scaled into each of the
others, so one rectangle describes the same part of the scene everywhere:

```
curl http://localhost/api/v1/config --data-binary @- <<'EOF'
{
  "osd": {
    "privacyMasks": "200x200x1200x900"
  }
}
EOF
```

Each rectangle is `left x top x width x height` in main-stream pixels — the same
format as `video0.crop`. A rectangle with no width or height covers nothing and
is ignored.

Masks do not need `osd.enabled`, and they do not follow `video0.osd`,
`video1.osd` or `jpeg.osd`. A camera that has never shown a timestamp can still
hide part of the scene, and turning a clock off never uncovers anything.

#### What each SoC family can do

Privacy masks are implemented on HiSilicon/Goke, SigmaStar and Ingenic, and
behave the same way on all three. Other SoCs draw the text overlay but have no
masks, so `osd.privacyMasks` does nothing there.

One exception is worth knowing. On SigmaStar, `motionDetect.visualize` and
privacy masks cannot both be drawn — they need the same hardware, and each wants
it configured its own way. Masks win: with both set, the picture stays masked and
the motion boxes are not drawn. With no masks configured, `visualize` behaves as
before.

### Motion detection

Motion detect is supported for HiSilicon/Goke, Ingenic and Sigmastar.
When a motion event is detected, `majestic` invokes a predefined script `/usr/sbin/motion.sh` with a parameter specifying the object count:

```
/usr/sbin/motion.sh [count]
```

Enable motion detection in `majestic` configuration:

```
curl http://localhost/api/v1/config --data-binary @- <<'EOF'
{
  "motionDetect": {
    "enabled": true,
    "debug": true
  }
}
EOF
```

Motion detection is set up when the media pipeline is built, so unlike most
settings this one needs a reload to take effect:

```
killall -HUP majestic
```

To watch it work, run Majestic in the foreground instead:

```
killall majestic; sleep 3; majestic
```

You should see the script running after motion detection events:

```
20:37:02  <SED_IVE_DETCTOR> [  motion] motion_update@155             Motion detected: [1163x0] -> [690x475]
20:37:02  <SED_IVE_DETCTOR> [   tools] motion_event@615              Execute motion script: /usr/sbin/motion.sh
```

### Broadcasts using RTMP

To instantly launch a YouTube broadcast, run these commands in the console:
```
curl http://localhost/api/v1/config --data-binary @- <<'EOF'
{
  "video0": {
    "codec": "h264"
  },
  "audio": {
    "enabled": true
  },
  "outgoing": {
    "enabled": true,
    "naluSize": 1200,
    "server": "rtmp://a.rtmp.youtube.com/live2/you-key-here"
  }
}
EOF
```

The API applies this live and saves it; no reboot is needed. RTMP is in Lite
and Ultimate builds, not FPV.

Examples of other addresses for different services:
- YouTube
    - rtmp://a.rtmp.youtube.com/live2/---KEY---
- Telegram
    - rtmps://dc4-1.rtmp.t.me/s/---KEY---
- RuTube
    - rtmp://upload.rutube.ru/live_push/---KEY---
- OK and VK
    - rtmp://ovsu.mycdn.me/input/---KEY---

Important ! Many RTMP services will only work if audio streaming is enabled, so be careful.

The outgoing stream sends an audio codec the RTMP container supports, converting
from `audio.codec` when needed, so `audio.codec` can stay on Opus for RTSP while
the broadcast still carries audio a service accepts. To pin a specific codec set
`outgoing.audioCodec` (`aac`, `alaw`, `ulaw`, `pcm`); leave it empty to follow
`audio.codec`. For A-law and mu-law the RTMP container is fixed at 8 kHz, so set
`audio.srate: 8000` or the audio plays back at the wrong speed.

If the camera has no microphone, `outgoing.audioSource` supplies a track anyway:

```
outgoing:
  audioSource: auto     # auto | mic | silence | file | none
  audioFile: ""         # path to an ADTS .aac file to loop
```

`auto` (the default) uses the microphone when there is one and otherwise sends a
built-in silent track to services that require audio — including YouTube — so a
mic-less camera streams there without enabling audio at all, and nothing changes
for other destinations. `silence` forces the silent track everywhere; `file`
loops audio you supply instead (create one with
`ffmpeg -i music.mp3 -c:a aac -f adts loop.aac`; keep it under a megabyte, it is
held in RAM); `none` sends no audio.

We ask that you add information about other popular services here, thank you.

RTMP reconnection and timeout logic works as follows:

```
    0-200 tries = 10 seconds timeout
  200-500 tries = 60 seconds timeout
 500-1000 tries = 300 seconds timeout
    1000+ tries = 600 seconds timeout
```

### Other outgoing options

A single destination is set with `server`:

```
outgoing:
  enabled: true
  naluSize: 1200
  server: udp://192.168.1.10:5600
```

For several destinations, list them under `servers` (this key is only read from
`/etc/majestic.yaml`, it is not exposed in the WebUI). Every entry is started as
its own connection: `udp://` and `unix:` endpoints are sent as RTP, `rtmp://`
and `rtmps://` as RTMP.

```
outgoing:
  enabled: true
  naluSize: 1200
  servers:
    - udp://IP-1:port
    - udp://IP-2:port
    - unix:/tmp/rtpstream.sock
    - rtmps://dc4-1.rtmp.t.me/s/mykey
```

If both `server` and `servers` are present, they are combined.

### ONVIF

ONVIF is on by default (`onvif.enabled: true`). It authenticates against the
system accounts, so the account an NVR logs in with has to exist:

```
adduser viewer -s /bin/false -D -H
echo viewer:123456 | chpasswd
```

Some clients cannot work that way. WSSE `PasswordDigest` and HTTP Digest both
require the camera to *know* the password rather than just verify it, and a
hash in `/etc/shadow` cannot be used for that — so a client that speaks only
those, such as tinyCam Monitor or ONVIF Device Manager 2.2.x, is refused. For
those, set an ONVIF-only credential pair:

```
curl http://localhost/api/v1/config --data-binary @- <<'EOF'
{
  "onvif": {
    "username": "viewer",
    "password": "123456"
  }
}
EOF
```

It is opt-in and empty by default, and it is stored **in cleartext** in
`/etc/majestic.yaml` — that is the trade being made, so only set it if a client
needs it. When set, it is checked first and the `/etc/shadow` lookup is the
fallback.

Majestic also answers mDNS (`mdns.enabled`, on by default) alongside ONVIF's own
WS-Discovery: `openipc.local` always, and `<hostname>.local` as well, so a
renamed camera stays reachable under both.

### JPEG and MJPEG

`jpeg.size` and `jpeg.qfactor` apply to the MJPEG stream on `/mjpeg` **and** to
still snapshots on `/image.jpg` alike; `jpeg.fps` is the MJPEG stream only,
since a snapshot is taken when it is asked for. Leaving `jpeg.size` unset
follows the `video0` resolution.

`jpeg.enabled` governs JPEG service as a whole, not just the stream. Turning it
off reserves no frame for the snapshot channel — which is the single biggest
memory saving on a small board — but then `/image.jpg` answers **503**, `/mjpeg`
answers "MJPEG is unavailable", and the JPEG track is dropped from the RTSP
description. ONVIF snapshot URIs and the web interface preview both fetch
`/image.jpg`, so they stop working too. See
[Memory tuning](memory-tuning.md#jpegenabled--snapshots-and-the-mjpeg-stream)
for what it frees.

Turning on `jpeg.rtsp` publishes the same MJPEG as an RTSP stream. RFC 2435
caps that at 2040 px per axis, so a larger `jpeg.size` is reduced to 1280x720
with a warning in the log.

On **Ultimate**, `jpeg.toProgressive` changes how `/image.jpg` is written. A
normal JPEG arrives one sharp band at a time, so on a slow link you watch it
fill in from the top; a progressive one arrives as the whole picture, coarse at
first and sharpening as the rest turns up. It is the same image either way — the
same pixels, about 5% fewer bytes.

It is off by default because the camera pays for it in CPU on every snapshot,
and that only buys anything on a link slow enough for the wait to be noticeable
— which is the case it was added for. Asking for a `crop` at the same time costs
far less than converting the whole frame, and sends far less over the link.

###  ROI

Motion detection can be restricted to one or more regions of interest:

`motionDetect.roi: 1854x1304x216x606,1586x1540x482x622`

Only movement inside a listed region raises an event. With no `roi` set the
whole frame is watched.

Coordinate format is the same as in `osd.privacyMasks` and `video0.crop`: x,y
of the top left point, then width and height in pixels.

### How to convert YUV image to a more common image format

Use `convert` command from ImageMagick software. Run it like this:
```
convert -verbose -sampling-factor 4:2:0 -size 1920x1080 -depth 8 image.yuv image.png
```
where `1920x1080` is the picture resolution of video0, and `.png` is the target
image format.

### How to play audio stream

Use [ffplay][ffplay] utility from [ffmpeg][ffmpeg] package.
```
ffplay -ar 48000 -ac 1 -f s16le http://192.168.1.10/audio.pcm
ffplay -ar 48000 -ac 1 -f alaw http://192.168.1.10/audio.alaw
ffplay -ar 48000 -ac 1 -f mulaw http://192.168.1.10/audio.ulaw
ffplay -ar 8000 -ac 1 -f alaw http://192.168.1.10/audio.g711a
```

There are also `/audio.opus` and `/audio.m4a` (AAC), which ffplay reads without
being told the rate, and `/audio.mp3` in Ultimate builds. `/audio.html` is a
small player page for them. All of them answer `501` while `audio.enabled` is
off.

### Enabling the speaker

Audio output needs both switches, not just the second one — the speaker is
brought up as part of the audio block, so `enabled: false` leaves it off no
matter what `outputEnabled` says:

```
audio:
  enabled: true
  outputEnabled: true
  outputVolume: 80
  srate: 8000
```

Many boards gate the amplifier behind a GPIO. Set `audio.speakerPin` (and
`audio.speakerPinInvert` if it is active-low), otherwise the logs look clean and
nothing comes out.

Speaker output is available on HiSilicon/Goke, Ingenic, Sigmastar, Allwinner,
Rockchip and Xiongmai. `audio.srate` is shared by input and output; there is no
separate output rate.

### How to create an audio file to play on camera's speaker over network

Using [sox][sox] program convert any source audio file to raw [PCM][pcm]:
```
sox speech.mp3 -t raw -r 8000 -e signed -b 16 -c 1 test.pcm
```

Or with [ffmpeg][ffmpeg]:
```
ffmpeg -i speech.mp3 -ac 1 -ar 8000 -f s16le -acodec pcm_s16le test.pcm
```

`/play_audio` has no decoder behind it — the bytes you upload are pushed
straight at the speaker as raw signed 16-bit little-endian mono PCM. Uploading a
compressed file (AAC, MP3, Opus) plays it as noise, and a `.wav` clicks at the
start because its header is played as samples. `audio.codec` applies only to the
audio the camera sends out and has no effect here.

The sample rate must match `audio.srate` exactly, or playback comes out at the
wrong pitch and speed.

### How to play audio file on camera's speaker over network

```
curl -u root:12345 --data-binary @test.pcm http://192.168.1.10/play_audio
```

This is a one-shot clip player: a new upload cancels the clip currently playing,
and the clip is capped at roughly 2 MB on most SoCs (about two minutes at
8 kHz). For a live conversation use two-way audio below.

### Two-way audio (talkback)

#### RTSP back-channel, ONVIF Profile T

The interoperable option, understood by ONVIF NVRs, Blue Iris, go2rtc and
Frigate. Enable the speaker as above, then:

```
rtsp:
  backchannel: true
audio:
  jitterBufferMs: 80     # 0 = passthrough, fine on LAN; 80 helps over Wi-Fi/WAN
```

Restart Majestic. To confirm the camera advertises it:

```
printf 'DESCRIBE rtsp://CAM/stream=0 RTSP/1.0\r\nCSeq: 1\r\nAccept: application/sdp\r\nRequire: www.onvif.org/ver20/backchannel\r\n\r\n' | nc CAM 554
```

The SDP gains a second media section:

```
m=audio 0 RTP/AVP 0
a=rtpmap:0 PCMU/8000
a=sendonly
a=control:audio-backchannel
```

The codec is [G.711][g711] mu-law at 8 kHz, as Profile T requires — the client
transcodes. Transport is RTSP-interleaved over TCP only; a UDP `SETUP` is
answered with 461.

#### WebRTC in the browser

Lite and Ultimate builds both carry WebRTC ([see above](#what-the-flavours-change)).
It used to be Ultimate only, because the implementation was a vendored AWS SDK
too large for the smaller boards; Majestic has its own since, and the SDK is
gone.

For **watching**, there is nothing to set up: the WebUI's `Preview` page uses
WebRTC by default, and so does the live preview beside the image controls in
`Settings`. Both fall back to the older MSE path on a browser or camera where
WebRTC cannot be negotiated, so the picture arrives either way. The `WebRTC`
button on `Preview` shows which one is in use and switches between them.

Watching over WebRTC also lets the camera fit the stream to your connection —
useful on a thin link, and worth knowing about, because the encoder is shared
with everything else reading that channel. The preview watches the substream for
that reason. `videoN.adjustBitrate` turns the adaptation off per channel if the
rate is committed to something else, such as a recorder.

For **talking back**, use the debug page at `http://192.168.1.10/webrtc`. Its
`talk` button sends your browser's microphone to the camera speaker. Two things
have to be true or nothing is heard:

- `audio.outputEnabled` must be on, or the camera answers the offer with audio
  in one direction only and says so in its log.
- Browsers only grant microphone access in a secure context, so over plain HTTP
  the button reads "needs HTTPS" — put the camera behind TLS or a
  TLS-terminating reverse proxy.

That page is a diagnostic rather than a viewer: it shows the ICE and DTLS state,
what the camera has sent, and what it has received from you. The WebUI has no
talkback control yet.

#### SIP

Lite and Ultimate builds include a SIP client. Point the `sip.*` settings at a
PBX and the camera can place a call carrying H.264 video and G.711 audio in both
directions, optionally triggered by a GPIO button (`sip.buttonPin`) — the usual
doorbell setup.

A call can also be started and ended from a script, without a button:

```
killall -USR2 majestic
```

The first signal originates the call, the next one hangs it up.

#### Caveat

There is no acoustic echo cancellation. Unless speaker and microphone are
physically isolated, the far end hears itself on a full-duplex call. Half-duplex
push-to-talk is unaffected.

[aac]: https://en.wikipedia.org/wiki/Advanced_Audio_Coding
[alaw]: https://en.wikipedia.org/wiki/A-law_algorithm
[dng]: https://en.wikipedia.org/wiki/Digital_Negative
[g711]: https://en.wikipedia.org/wiki/G.711
[heif]: https://en.wikipedia.org/wiki/High_Efficiency_Image_File_Format
[hls]: https://en.wikipedia.org/wiki/HTTP_Live_Streaming
[jpeg]: https://en.wikipedia.org/wiki/JPEG
[mjpeg]: https://en.wikipedia.org/wiki/Motion_JPEG
[mp3]: https://en.wikipedia.org/wiki/MP3
[mp4]: https://en.wikipedia.org/wiki/MPEG-4_Part_14
[opus]: https://en.wikipedia.org/wiki/Opus_(audio_format)
[pcm]: https://en.wikipedia.org/wiki/Pulse-code_modulation
[prog]: https://en.wikipedia.org/wiki/JPEG#JPEG_compression
[raw]: https://en.wikipedia.org/wiki/Raw_image_format
[rtsp]: https://en.wikipedia.org/wiki/RTSP
[ulaw]: https://en.wikipedia.org/wiki/%CE%9C-law_algorithm
[webp]: https://en.wikipedia.org/wiki/WebP
[yuv]: https://en.wikipedia.org/wiki/YUV
[ffplay]: https://ffmpeg.org/ffplay.html
[ffmpeg]: https://ffmpeg.org/
[sox]: https://en.wikipedia.org/wiki/SoX
