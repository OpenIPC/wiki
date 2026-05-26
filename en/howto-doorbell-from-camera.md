# OpenIPC Wiki
[Table of Content](../README.md)

Build your own doorbell from any OpenIPC camera
================================================

Recent `majestic` builds turn **any OpenIPC camera with a speaker and a
microphone into a fully-featured SIP doorbell**: press a button, the
camera dials a configured destination (your phone, your laptop
softphone, your home PBX), the called side answers, and you get
one-way video + two-way G.711 audio over a regular SIP call. No
cloud, no app, no vendor lock-in.

This article walks you through a working setup end-to-end, starting
from zero SIP experience, and finishes with a **debug technique
(`kill -USR2`)** that lets you simulate button presses without any
physical button wired — handy when you're still bringing the
hardware up.

## What you'll need

- An OpenIPC camera that has a working speaker output and a working
  mic input. Easiest way to confirm both work end-to-end: open
  `http://<camera>/audio.ulaw` to verify the mic capture path (uLaw
  is codec-free and matches the audio format the SIP doorbell uses
  anyway), and POST a short raw-audio payload to
  `http://<camera>/play_audio` (the speaker sink) — for example:

  ```sh
  curl --data-binary @clip.pcm http://<camera>/play_audio
  ```
- One free GPIO pin you can solder a momentary push-button to, with
  the other side of the button going to ground. Any spare pin works
  — the camera's IR-cut driver typically sits on a known pin, the
  status LED on another; pick any input-capable one your board
  exposes. See [GPIO settings](gpio-settings.md) for board-specific
  pinouts.
- A SIP destination. The two easiest options for a hobby setup:
  - **Linphone** ([linphone.org](https://www.linphone.org/)) running
    on your laptop or phone — it speaks SIP natively and is free.
  - A small SIP PBX on your home server: **Asterisk** or **FreePBX**
    on a Raspberry Pi work great. We'll use Asterisk in the examples
    below because the config is the smallest.

For internet doorbells (camera at the front door, you on 4G/LTE), you
also want the **audio de-jitter buffer** turned on — it's a one-line
config knob and makes the call usable over real networks. We cover it
in the optional section near the end.

## How a SIP doorbell call looks

```
┌──────────┐ press     ┌──────────┐  INVITE (codec=PCMU+H.264)  ┌──────────┐
│ doorbell │──────────▶│ majestic │ ───────────────────────────▶│   PBX    │
│  button  │  GPIO     │   (UAC)  │◀────────────────── 200 OK ──│ (UAS)    │
└──────────┘           └──────────┘  RTP video out + audio in/out└──────────┘
                                                                       │
                                                                       │ ring
                                                                       ▼
                                                                 ┌──────────┐
                                                                 │ Linphone │
                                                                 │  on you  │
                                                                 └──────────┘
```

When the visitor presses the button, the camera (acting as a SIP UAC
— **U**ser **A**gent **C**lient) sends an `INVITE` to your PBX. The
PBX rings your softphone. You answer, and the camera streams one-way
H.264 (or H.265) video to you and full-duplex G.711 audio so you can
hear the visitor and they can hear you. End the call by hanging up,
or by pressing the doorbell button again (it toggles).

## Step 1 — Set up a SIP destination

If you already have one (your home VoIP provider, an existing
Asterisk box, a Linphone account), skip ahead.

### Option A: Linphone direct (no PBX)

Easiest. Install Linphone Desktop on your laptop. In Linphone:

1. Create a free account at `sip.linphone.org`, or use `Assistant →
   Use SIP account → Without registration` for a pure peer-to-peer
   setup on the LAN.
2. Look at `Settings → SIP accounts` for your local SIP URI. It
   will be something like `sip:alice@linphone.org` or
   `sip:alice@192.168.1.50:5060` for unregistered mode.

### Option B: Asterisk PBX on a Linux server

Minimal `/etc/asterisk/pjsip.conf`:

```ini
[transport-udp]
type=transport
protocol=udp
bind=0.0.0.0:5060

[endpoint-template](!)
type=endpoint
context=internal
disallow=all
allow=ulaw
allow=alaw
allow=h264
allow=h265

[1001](endpoint-template)
auth=1001
aors=1001
[1001](!)
type=auth
auth_type=userpass
username=1001
password=put-a-real-password-here
[1001](!)
type=aor
max_contacts=2

# Repeat the [1001] block for 1002, 1003, ... — one per device.
```

Minimal `/etc/asterisk/extensions.conf`:

```ini
[internal]
exten => _100X,1,Dial(PJSIP/${EXTEN},30)
exten => *43,1,Answer()
 same => n,Echo()
 same => n,Hangup()
```

Reload Asterisk (`asterisk -rx 'core reload'`). The `*43` extension is
a built-in echo test that loops your audio back — invaluable for
verifying the camera's mic + speaker chain end-to-end before you point
the camera at a real destination.

## Step 2 — Wire the doorbell button

One side of the momentary button goes to **GND**, the other side goes
to your chosen GPIO pin. The pin must have a pull-up resistor enabled
(internal or external) so the line reads `1` when the button is
released and `0` when pressed. Most SoC pins have internal pull-ups
that majestic enables for you when you configure the pin as an input
button.

If the pin you picked doesn't have an internal pull-up, add a 10kΩ
resistor between the pin and 3.3V.

## Step 3 — Camera configuration

Edit `/etc/majestic.yaml` on the camera. Add or extend these
sections:

```yaml
audio:
  enabled: true            # mic capture
  codec: ulaw              # PCMU — also try alaw if your PBX prefers
  srate: 8000
  outputEnabled: true      # speaker
  outputVolume: 60         # 0..100; bump until you can hear yourself
  jitterBufferMs: 60       # 0 = LAN-only; see "Going remote" below

sip:
  enabled: true

  # --- where to register / where to send the INVITE ---
  server: 192.168.1.10     # your PBX or Linphone account host
  port: 5060
  username: "1001"
  password: "put-a-real-password-here"
  localUri: "sip:1001@192.168.1.10"
  callTarget: "sip:*43@192.168.1.10:5060"   # *43 = Asterisk echo test
  doRegister: true                          # set false for direct dial only

  # --- where this camera lives on the LAN ---
  localIp: 192.168.1.50    # the camera's own IP
  localPort: 5060
  rtpPortHint: 5004        # RTP/RTCP starts here, allocates pairs

  # --- the doorbell button ---
  buttonPin: 12            # the GPIO you wired the button to
  buttonActiveLow: true    # `true` = button pulls the pin to ground when pressed
```

`killall -HUP majestic` to reload. The interesting log lines:

```
sip uac: bound 192.168.1.50:5060, server 192.168.1.10:5060
sip button: watching pin 12 (active_low)
```

If you see `sip uac: REGISTER failed`, double-check the auth username
/ password and that the server is reachable from the camera
(`nc -zvu 192.168.1.10 5060` from the camera should connect).

## Step 4 — First call

Press the button. The expected log on the camera:

```
sip button: press → originate call
sip uac: call confirmed with sip:*43@192.168.1.10:5060
audio_jitter: pt=0 buffered frame=20 target=60 max=240
audio_jitter: prebuffer reached 3 slots, playing
```

`*43` answers automatically (it's the echo test), so you'll hear
yourself coming back through the camera's speaker about ~60 ms after
you speak. **That round-trip proves both the mic → outgoing RTP and
incoming RTP → speaker paths end-to-end.**

Press the button again to hang up. The camera will log:

```
sip button: press → hangup
audio_jitter: played=925 silence=0 late=0 future_reset=0 final_target=60ms J=202us
sip uac: hung up
```

That last `audio_jitter:` line is a goldmine when debugging — see
"Reading the counters" below.

Now change `callTarget` to your real destination (your Linphone URI,
or another extension like `sip:1002@192.168.1.10`) and you have a
working doorbell.

## Going remote — making it work over 4G/LTE

LAN audio has effectively zero jitter (`J=202us` in the example
above) so the de-jitter buffer is essentially a no-op. Over Wi-Fi
and especially 4G/LTE, inter-arrival jitter routinely hits 30–100 ms
with 200 ms bursts during cell handover. Without buffering, you'd
hear chopped audio.

The `audio.jitterBufferMs` knob controls how much audio the camera
holds in a ring before starting playback. Recommended values:

| Link             | `jitterBufferMs` | Latency penalty |
|------------------|------------------|-----------------|
| Wired LAN        | `0` (passthrough)| `0 ms`          |
| Wi-Fi (good)     | `60`             | `60 ms`         |
| Wi-Fi (busy AP)  | `100`            | `100 ms`        |
| 4G/LTE           | `100–120`        | `100–120 ms`    |
| Roaming / spotty | `200`            | `200 ms`        |

The buffer also **adapts**: if it observes incoming jitter higher than
the configured target, it grows the buffer (one 20 ms slot at a
time, up to `target × 4` or 500 ms whichever is smaller) to absorb
the variance. You'll see this in the log as:

```
audio_jitter: J=50682us → grow target 100 → 120 ms
```

That's the buffer reacting to a measured 50 ms inter-arrival jitter
by stretching to 120 ms of headroom. It never shrinks during a call
(shrinking would risk under-runs), but resets to the configured
target on the next call.

## Debugging without a button (the SIGUSR2 trick)

When you're bringing up new hardware, you usually **don't have a
button soldered yet** — but you want to test that the camera can
dial out. Or your button works but you want to script repeated calls
for soak testing.

Recent `majestic` builds support a **SIGUSR2** toggle that initiates
or ends a SIP call with the exact same semantics as the button:

```sh
ssh root@my-camera

# originate the call configured in callTarget
kill -USR2 $(pidof majestic)

# ...listen, talk to *43, watch the log...

# hang up
kill -USR2 $(pidof majestic)
```

This works on any OpenIPC build of `majestic` with SIP support
enabled. The trigger shares the same code path as a real GPIO button
press, so the behaviour is bit-identical.

Combine it with `tail -f /var/log/messages` (or `logread -f` on
busybox-based OpenIPC) to watch the full call flow live:

```sh
ssh root@my-camera 'logread -f' &
ssh root@my-camera 'kill -USR2 $(pidof majestic)'
sleep 30
ssh root@my-camera 'kill -USR2 $(pidof majestic)'
```

You'll see the full INVITE / 100 Trying / 200 OK / ACK trace plus
the `audio_jitter` counters when the call tears down. If anything
fails (wrong codec offer, auth rejection, RTP port collision,
NAT-related media timeout) it'll be obvious in that log.

### Soak-testing the doorbell

Want to verify the camera holds up over many calls? A trivial loop
from your laptop:

```sh
for i in $(seq 1 50); do
  echo "=== call $i ==="
  ssh root@my-camera 'kill -USR2 $(pidof majestic)'
  sleep 25
  ssh root@my-camera 'kill -USR2 $(pidof majestic)'
  sleep 5
done
```

50 calls of 25 seconds each ≈ 25 minutes of cumulative call time.
Watch `audio_jitter` counters: if `silence` or `late` start
climbing, you've found a network or codec issue worth digging into.

### Reading the audio_jitter counters

Every call ends with a line like:

```
audio_jitter: played=925 silence=0 late=0 future_reset=0 final_target=60ms J=202us
```

What each field means:

| Field            | Healthy value                  | What rising means                                  |
|------------------|--------------------------------|---------------------------------------------------|
| `played`         | ≈ call_duration_s × 50         | Frames successfully delivered to the speaker.     |
| `silence`        | `0` on LAN, low on 4G          | Gaps where no packet arrived in time, filled with 20 ms of silence. High values = audible drop-outs. |
| `late`           | `0`                            | Packets that arrived after their slot's deadline and were dropped. High values = increase `jitterBufferMs`. |
| `future_reset`   | `0`–`2` per call               | The far end's RTP stream jumped by more than one buffer's worth (peer reboot, big network blip). Counted but not fatal. |
| `final_target`   | starts at `jitterBufferMs`     | Where the adaptive buffer settled. If it grew, the link is jittery — bump the configured value. |
| `J`              | < 1000 µs LAN, < 50000 µs 4G   | RFC 3550 inter-arrival jitter estimate. Sanity check: it shouldn't exceed `final_target × 1000 / 2`. |

## Common pitfalls

1. **No audio one direction only.** Check `outputEnabled: true` in
   `majestic.yaml`. The web UI has an audio-output toggle that
   forgets the volume — set `outputVolume` explicitly.
2. **Echo / howl at both ends.** Microphone is picking up the
   speaker. Lower `outputVolume`, or physically separate the mic and
   speaker on the PCB.
3. **`488 Not Acceptable Here` from the PBX.** Codec mismatch. The
   camera advertises `ulaw` (PCMU) by default; if your PBX is
   restricted to a different codec, change `audio.codec` accordingly
   or add `allow=ulaw` to your PBX endpoint config.
4. **Call connects but no audio.** Almost always RTP firewall /
   NAT. Make sure UDP `rtpPortHint`..`rtpPortHint+3` (i.e. four
   ports) is reachable from the called side. For NAT traversal,
   point the camera at a SIP server that does media relay (TURN /
   ICE) or run the PBX on the same LAN as the camera.
5. **Choppy audio on Wi-Fi or 4G.** Set `audio.jitterBufferMs` to
   `60` or higher. See the "Going remote" table above.
6. **`sip uac: REGISTER failed (401)` loop.** Wrong password, or
   the PBX expects a different `realm`. The exact challenge realm
   is in the log; some PBXes require `username` to match the From
   user, others a separate auth ID.

## What's next

- **Multiple buttons / cameras.** Each camera gets its own
  extension on the PBX (1001, 1002, ...). A simple Asterisk
  dialplan can ring all of them at once for a small office.
- **Group ring.** `exten => doorbell,1,Dial(PJSIP/1001&PJSIP/1002&PJSIP/1003,30)`
  rings three softphones in parallel; whichever picks up first gets
  the call.
- **Smart-home integration.** Home Assistant has a SIP integration
  that can act as a UAS endpoint, so the doorbell call appears in
  your HA UI alongside everything else.

Have fun — and if you hit a bug, report it on the OpenIPC channels
with the full `audio_jitter:` counter line and the surrounding
`sip uac:` log. That's enough info to pinpoint most issues.
