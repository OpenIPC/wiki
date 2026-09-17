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
| [Microphone processing](#microphone-processing-vqe) — noise reduction, AGC, high-pass (`audio.vqe`) | — | — | ✅¹ |
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

¹ Not on every Ultimate camera — the SoC has to have the engines this is
written against. See [Microphone processing (VQE)](#microphone-processing-vqe).

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
and the MJPEG stream, watch over WebSocket video, read what the detectors are
seeing, and work the night-mode switches, but it cannot log in to the interface
or touch the rest of the API. Concretely, the paths it is allowed are
`/image*`, `/mjpeg*`, `/night/*`, `/ws/video`, `/cgi-bin/v*` and
`/api/v1/analytics*` — the last because boxes drawn over a picture the account
may already watch reveal nothing further. It also authenticates for RTSP and
for ONVIF.

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
| `SIGHUP` | Re-read `/etc/majestic.yaml` and apply whatever changed, at the smallest cost that will carry it: most keys are pushed straight at the SDK with the stream untouched, some restart one subsystem or rebuild one encoder channel, and only the rest tear the pipeline down and build it again. This is what `cli` asks for after a write, and what `killall -HUP majestic` does by hand. Repeat signals within 3 seconds collapse into one reload. |
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

On a camera with more than one source, `?channel=N` picks which one the
snapshot comes from — see [A second camera](#a-second-camera).

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
plain `/image.jpg` with no parameters is unaffected by any of this. The one
thing that does stop it is
[idle suspension](#stopping-the-sensor-and-isp-when-nothing-is-watching), which
is off unless you turn it on.

### Changing parameters via the HTTP API

Parameters can be changed at runtime through Majestic's HTTP API. Setting a
value applies it to the running streamer and saves it to `/etc/majestic.yaml`
in a single step — there is no need to reload or restart Majestic afterwards.

> Two endpoints are deliberately the exception and save nothing:
> `/api/v1/records/standdown` and `/api/v1/records/resume`, which pause and
> restart the recorder for as long as a card swap takes. See **Recordings, and
> what survives a power cut** below.

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

> `cli` does the same job from a shell on the camera, and no longer needs a
> `killall` after it:
>
> ```
> cli -s .video0.fps 10
> ```
>
> It writes `/etc/majestic.yaml` and then asks Majestic to reload, so the change
> applies at the same cost the API would charge for it. Use whichever suits the
> job. `cli` is the one that works before Majestic is running — a `customizer.sh`
> seeding a camera on first boot has no API to call — and it can write a key this
> build does not declare. The API is the one that validates: `404` for a key the
> binary does not have, `400` for a value outside its range, and it can be called
> from another machine.

### Experimental Control Features (not yet described in endpoints)

`/metrics` returns everything below in Prometheus text format, plus process,
thread-pool, uptime, allocator and HLS counters. The sub-paths return one group
each:

```
/metrics/venc      encoder counters
/metrics/isp       ISP parameters
/metrics/night     day/night state, decision source, pending switch, lamp duty
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

### Exposure and gain

`isp.exposure` does not mean the same thing on every camera, and nothing in the
name says so. Before copying a number from one platform to another:

| your camera | what `isp.exposure` is | unit | range | does auto-exposure keep running? |
| --- | --- | --- | --- | --- |
| HiSilicon / Goke | the **longest** auto-exposure may use | **milliseconds** | 0–1000 | yes, unless `isp.aeMode: manual` |
| SigmaStar | the **longest** auto-exposure may use | **milliseconds** | 0–200 | yes |
| Ingenic (T31) | **the exposure itself** | **microseconds** | 0–65535 | **no** — setting it stops the metering |

So `isp.exposure: 20` asks for a 20 millisecond limit on a HiSilicon camera and
a 20 **microsecond** fixed shutter on an Ingenic one. Three orders of magnitude
apart, and one of them switches automatic exposure off.

Zero, or leaving the key out, means "leave the sensor default alone" everywhere.

#### Why your exposure sweep looks like it does nothing

This is the most common report about this section, and the setting is usually
working exactly as intended.

On HiSilicon, Goke and SigmaStar these are **limits handed to auto-exposure**,
not the exposure. Auto-exposure goes on metering inside them, and it holds the
picture at its target brightness by spending gain instead. Raise the exposure
limit and it simply uses less gain; the picture barely moves.

Measured on a 5 MP IMX335 attached to a Goke GK7205V300, changing only
`isp.exposure` and reading the camera's own gauges back:

| `isp.exposure` | `isp_exptime` | `isp_again` | picture |
| ---: | ---: | ---: | --- |
| 1 | 1 000 µs | 31.6× | darker — the gain ran out |
| 10 | 10 000 µs | 13.3× | unchanged |
| 100 | 33 304 µs | 4.1× | unchanged |
| 1 000 | 33 304 µs | 4.0× | unchanged |
| 1 000 000 | 33 304 µs | 3.8× | unchanged |

The last row is there to show how flat the curve is, not as something to repeat:
values above the maximum in the table at the top are refused now, which they
were not when this was measured. Anything from about 100 upwards demonstrates
the same thing.

Two things are happening. **Above about 33 ms the exposure stops growing** —
that is the frame period at `video0.fps: 30`, so everything from 100 upwards
asks for something the frame rate cannot give. And **the gain falls to
compensate** for the rest, from 31.6× down to 3.8×, holding the brightness
steady. A sweep from 1 to 1 000 000 is really a sweep from 1 ms to 33 ms, and
auto-exposure absorbs almost all of it.

There is a second trap. Setting `isp.exposure` **on its own** also hands
auto-exposure a 32× analog gain allowance, because `isp.slowShutter` defaults to
`medium` and that mode fills in the limits you did not give. The thing that
cancels the experiment switches on with the experiment.

To make the exposure actually drive the picture, pin the gains as well:

```yaml
isp:
  exposure: 20      # milliseconds
  aGain: 1          # 1x
  dGain: 1
  ispGain: 1
```

With nothing left to spend, auto-exposure runs up against the limit and the raw
signal becomes proportional to the exposure — measured on the same camera as a
straight line through 5, 10, 20 and 33 ms with a correlation of 0.99992.

**That holds only while the scene is too dark to reach the target at those
gains.** Auto-exposure is still choosing; pinning the gains removes what it
would otherwise spend, it does not force it onto the limit. Brighten the scene,
or raise the limit far enough, and it settles below the limit again and the
sweep flattens — on the same camera, limits of 200 and 500 ms both produced
about 135 ms, because that was already bright enough.

`isp_exposureismax` is how you tell which side of that you are on: `1` means
auto-exposure is against the limit and your number is deciding the picture, `0`
means it chose something lower and the limit is not what matters. Watch it while
you sweep. If you want the exposure held regardless of the scene, that is
`isp.aeMode: manual` below rather than a limit.

#### Telling the camera the exposure instead (HiSilicon and Goke)

Since **majestic's September 2026 builds**:

```yaml
isp:
  aeMode: manual
  exposure: 20      # milliseconds, held
  aGain: 1          # and 1x, held
  dGain: 1
  ispGain: 1
```

`manual` makes the same four keys the **values** rather than the limits. The ISP
stops metering and the picture no longer follows the light. `auto` is the
default and is what a camera has always done.

**Set all four.** A key you leave out is not left metering — it takes the ISP's
own value for it. Measured on the Goke camera above: in a dark room with only
`isp.exposure` given, the gain sat at 1× while automatic exposure had been using
about 31× a moment earlier.

The frame period still bounds the shutter. At 30 fps, manual exposures of 50,
100 and 200 ms all delivered the same 33 ms. `isp.slowShutter` is
auto-exposure's mechanism for buying a longer shutter, so it does nothing here.

#### Ingenic: microseconds, and the key is its own switch

On a T31 `isp.exposure` **is** the exposure, in microseconds, and setting it
stops the metering. There is no `isp.aeMode` — `0` is how you switch it back off.

**T31 only.** A T40 does not carry this setting at all, and will not offer it.
The older T20, T21 and T23 do not either.

Measured on a T31 with an SC2332, asking for a value and reading `isp_exptime`
back: 1 000, 10 000, 30 000 and 60 000 gave 986, 9 976, 29 986 and 59 972 µs.
It tracks one-to-one, rounded to whole sensor integration lines. The maximum is
65 535 µs, a little over 65 ms.

#### The gains are multipliers

**This changed in majestic's September 2026 builds, and it will change what an
existing camera does.** `isp.aGain`, `isp.dGain` and `isp.ispGain` are plain
multipliers now: `aGain: 8` means eight times. They previously had to be written
in the sensor's own fixed-point units on HiSilicon and Goke, where eight times
was `8192`.

**If you set any of them by hand, divide your value by 1024.** A camera left
with the old spelling runs at maximum gain until you do — the number is out of
range, and it is clamped rather than ignored. SigmaStar has always used plain
multipliers and is unaffected. Ingenic has none of these three keys.

`isp.ispGain` is worth one note: it is applied after the raw data has been read,
so it brightens the picture and the JPEG but leaves a
[RAW snapshot](#raw-sensor-data-as-adobe-dng) exactly as it was.

#### Reading back what the camera actually did

Do not infer it — the camera reports it:

```
curl -s -u root:PASSWORD http://192.168.1.10/metrics | grep '^isp_'
```

`root`, not a viewer account: `/metrics` is not one of the paths a media-only
account may reach (see [User levels in the system](#user-levels-in-the-system)).

- `isp_exptime` — the exposure in use, in microseconds. This is the number to
  compare against what you asked for.
- `isp_again`, `isp_dgain`, `isp_ispdgain` — the gains in use, in the sensor's
  own units rather than the multipliers you set.
- `isp_avelum` — the brightness auto-exposure is steering towards.
- `isp_exposureismax` — **read this one first.** `1` means auto-exposure is
  pressed against a limit, so your setting is what is deciding the picture. `0`
  means it chose something below the limit and your setting is not what matters
  right now.

If the `isp_` lines are missing altogether, the image pipeline is asleep — see
[Stopping the sensor and ISP when nothing is watching](#stopping-the-sensor-and-isp-when-nothing-is-watching).
Open a stream, or a snapshot, and ask again.

If your camera is a HiSilicon or Goke one, a
[RAW snapshot](#raw-sensor-data-as-adobe-dng) carries the same information in its
own tags, so `exiftool -ExposureTime -ISO shot.dng` says what was used for that
one frame. On builds **before 2026-09-17** that tag was read a moment after the
frame rather than beside it, so on those it can be up to a second out of date —
which matters only if something was moving in that second, but that is exactly
the case when you are sweeping a setting and capturing as you go. It describes
the frame it is in on current firmware. SigmaStar and Ingenic cameras have no
such endpoint and answer 404 — `/metrics` above is the readback for them.

Two cautions if you are measuring from the raw data: subtract the file's
`BlackLevel` first, because the pedestal is a large share of a dark frame; and
do not use the ISO tag to normalise, because it includes the ISP digital gain,
which is not in the raw pixels at all.

### Auto day/night detection

For how the filter itself is wired and driven — and why a swapped pair gives you
a pink daylight picture — see
[How an IR-cut filter is driven](ircut-filter.md).

**Since September 2026, turning on the light monitor is all it takes.** With

```yaml
nightMode:
  lightMonitor: true
```

and nothing else configured, majestic on HiSilicon, Ingenic and SigmaStar
switches day/night from the image sensor's own exposure state: night when the
auto-exposure runs out of shutter and gain — a statement that means the same
thing on every camera, so there is nothing to calibrate — and back to day when
the gain settles at daylight levels. Built-in hysteresis and switching delays
ignore a passing cloud, headlights at night, and the IR lamp's own light, and
an anti-flapping guard slows the cycle down if fog ever drives one.

One `lightMonitor` switch selects between three sources, by what else is
configured:

1. `lightSensorPin` set — the hardware light sensor decides (as always);
2. both `minThreshold` and `maxThreshold` set — the legacy raw-gain
   thresholds decide (below);
3. neither — the automatic exposure-based mode above.

The `night_mode_source` gauge on `/metrics` names which one has the wheel
(1 sensor pin, 2 thresholds, 4 automatic), and **Settings → Day / Night** in
the web interface shows the decision live: the watched value charted with the
switching bands shaded, and a countdown when a switch is pending.

The automatic mode can be tuned, in units that mean the same on every camera
(gain as a multiple of 1x):

| Key | Default | Meaning |
| --- | --- | --- |
| `nightMode.autoNightGain` | empty | Go to night when gain reaches this multiple. Empty = the exposure-based trigger, no number needed. |
| `nightMode.autoDayGain` | 2 | Return to day when gain stays at or below this multiple. |
| `nightMode.autoNightDelay` | 15 | Seconds the scene must stay dark before night. |
| `nightMode.autoDayDelay` | 60 | Seconds it must stay bright before day. |

Two park switches sit beside the pin settings for when an actuator should stay
still without losing its wiring: `nightMode.irCutEnabled` and
`nightMode.backlightEnabled` (both default `true`). Off keeps the pin numbers
configured but stops driving the filter or the lamp; the web interface says
"switched off, wiring kept" instead of accusing the wiring.

#### Legacy raw-gain thresholds

The pre-2026.09 mode, still fully supported: set both thresholds and they take
priority over the automatic mode.

```day < [minThreshold] | hysteresis | [maxThreshold] < night```

**These numbers are per-SoC — read your own camera's `isp_again` before picking
them.** The gauge is in the SDK's own units and they are not comparable between
vendors — even the scale differs (Q10 with 1024 = 1x on HiSilicon and
SigmaStar, log2-gain × 32 on Ingenic), and the ceiling is sensor-specific. A
threshold copied from a HiSilicon example onto an Ingenic camera simply never
trips. The automatic mode exists exactly so nobody has to do this any more.

On a HiSilicon camera reading 1024 on a bright day, minThreshold could be set to
2000; if it reads 32000 on a dark night, maxThreshold could be set to 10000. Watch
`isp_again` at `/metrics` in your own conditions and pick a band inside it, with
minThreshold below maxThreshold so there is hysteresis to sit in.

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

### A lamp wired the other way round

Some boards drive the illuminator **active-low**: the pad has to be held low to
light it. On those, a camera that has been told nothing lights the lamp all day
and switches it off at nightfall — which is the one fault here that looks like
the camera working, because the lamp is plainly under control, just backwards.

```yaml
nightMode:
  backlightPin: 59
  backlightInvert: true       # default false
```

With it on, night holds the pad low and day holds it high. The lamp is also
left **off** rather than on at the moments the camera is not deciding — while a
day/night setting is being applied, and on an orderly shutdown — which for an
active-low board means the pad is held high rather than simply let go. The
setting describes the lamp rather than the pad, so it covers the dimmable lamp
below as well.

It shows up as *Camera light is inverted* on **Settings → Day / Night** and
applies as soon as it is saved; the video stream is not restarted. There is no
equivalent for the two IR-cut coils and none is needed: they are one H-bridge,
and which way the filter moves is decided by which pad you put in `irCutPin1`.
A single-pad filter has `irCutSingleInvert`, and the daylight sensor has
`lightSensorInvert`.

### PWM backlight: a dimmable lamp

On most HiSilicon and Goke cameras, a lamp wired to a PWM pad can be a dimmer
instead of a switch — the in-camera version of the `devmem` backlight scripts
from
[the sandbox](https://github.com/OpenIPC/sandbox/tree/main/scripts/backlight-control):

```yaml
nightMode:
  backlightPwmChannel: pwm1   # none = switched lamp on backlightPin
  backlightPwmFreq: 400       # Hz
  backlightPwmMin: 10         # duty floor, % — LEDs have an ignition threshold
  backlightPwmMax: 100
```

**Which channels your camera offers depends on its SoC**, so the list is not
the same on every board and there is no table of it here that would stay true.
The WebUI's Night mode page shows the ones this camera has, and that is the
answer for almost everyone.

To see the pins behind them, `ipctool reginfo` prints one line per pad with
every function that pad can take, and square brackets around the one it is set
to at the moment:

```
muxctrl_reg4 0x100c0010 0 [GPIO0_4] PWM1 UART1_RXD I2C1_SDA
```

Two things to know before reading that list. `SVB_PWM` and `PMC_PWM` are
**different controllers** — sensor bias supply and power management — so a row
mentioning those is not a lamp channel, however much it looks like one; the
ones that count are named `PWM0`…`PWM7`, or `PWM_OUT0`/`PWM_OUT1` on the older
parts. And the `GPIOx_y` in the same row is the pin that channel takes over,
which majestic numbers eight to a bank: `GPIO0_4` is pin 4, `GPIO2_0` is
pin 16.

A channel is not a pin. Some SoCs bring the same PWM out on two or three
different pads, and then the plain name (`pwm3`) means the usual one while the
others are spelled with the pin they are on (`pwm3@gpio54`). If your lamp is
wired to one of the alternatives, pick that spelling — the plain name would
drive a pin your lamp is not on. Where a channel has only one pad, which is the
common case, there is only the plain name.

The frequency is a real frequency: majestic knows the rate its SoC's PWM block
counts at, so 400 Hz is 400 Hz on a hi3516cv100 as much as on an
hi3516ev300. Anything from 50 Hz to 20 kHz is accepted. If your illuminator
hums or your footage shows banding, move it.

If a channel is set but the lamp cannot be brought up — the wrong pin, or a pin
something else on the board already owns — majestic says so in the log and
falls back to driving `backlightPin` as a plain switch, rather than leaving you
in the dark.

On hi3516cv100 and hi3518ev100, setting a channel here normally also takes it
away from the image processor's own aperture control, which those chips bring
up enabled — unless `isp.iris.type` is `DC`, which reserves it for the lens
instead. See "Iris control, and who owns a PWM channel" below if this camera
has a motorised lens.

With a channel set, `backlightPin` is ignored, but `backlightInvert` is not:
on an active-low driver the duty still reads as brightness, 0 for dark and 100
for full, and the lamp is still left off at the moments the camera is not
deciding.

A duty of 0 is a real off rather than a very low brightness. Dimmer hardware
cannot emit a pulse of no width at all — asked for one it emits its shortest,
which is far too brief to measure and quite bright enough to see on an
illuminator with a driver behind it — so at zero the camera stops driving the
pad instead of asking for an impossible pulse. That applies in day mode and at
start-up, not only at shutdown. On an active-low lamp the same promise is kept
the other way round, by continuing to hold the pad rather than letting go of
it, because there it is releasing the pad that would light the lamp.

At night the lamp lights at the maximum and then trims itself to the ambient
light every couple of seconds — brighter when the scene is starving, dimmer
when the lamp overshoots — between the two duty bounds. The lamp's own light
can never talk the camera back into day: the trim stops dimming well above the
day threshold, so only real dawn ends the night. The current percentage is the
`night_light_duty` gauge on `/metrics`, and the dashboard's day/night line
shows it as "lamp 43%".

### Iris control, and who owns a PWM channel

A DC iris is a motorised aperture: the camera drives a coil through a PWM
channel and the lens opens and closes to follow the light. Most cameras do not
have one — a fixed lens has nothing to drive — and on those the whole subject
would be uninteresting, except on the oldest HiSilicon parts, where it decides
something that has nothing to do with lenses.

```yaml
isp:
  iris:
    type: DC          # none (default) | DC | P
```

`P` is offered by the settings schema and implemented nowhere; asking for it
is refused with a message in the log rather than silently ignored. The PID
terms and duty limits beside `type` shape how the aperture is driven. They
exist from hi3516cv200 upwards but not on the hi3516cv6xx family, and there is
no reason to touch them on a camera that works.

**On hi3516cv100 and hi3518ev100, `type` also decides who gets a PWM channel.**
The image processor on those chips comes up running its own automatic-aperture
controller, and that controller programs a PWM channel for itself whether or
not a lens is attached to it. On a fixed-lens camera there is nothing for it to
move — but if you have wired an illuminator to a PWM pad, there is now
something for it to interfere with, and the two take turns overwriting each
other. The symptom is a lamp that ignores the camera: the reported duty moves,
`night_light_duty` on `/metrics` says 43% or 0%, and the illuminator stays at
whatever brightness it was.

Majestic settles it by ownership, and the rule is read in this order:

1. **`isp.iris.type: DC` wins.** You have said there is a lens to drive, so the
   aperture controller is left alone whatever else is configured. A lamp then
   needs a channel of its own, or a plain switched lamp on `backlightPin` —
   two things cannot share one PWM channel, and which of them matters is the
   one thing the camera cannot work out for itself.
2. **Otherwise, a dimmable lamp takes the channel.** With
   `nightMode.backlightPwmChannel` naming one, the aperture controller is
   switched off at start-up so the lamp has it.
3. **Otherwise nothing is changed.** No `DC`, no dimmable lamp, and the
   controller is left exactly as the chip brought it up — so a camera that
   really does have a motorised lens and never set `isp.iris.type` keeps
   working across an upgrade.

One timing caveat, and it is the exception to this page's general rule that a
setting applies to the running streamer. The lamp itself does start straight
away: save a channel and Night mode restarts with the dimmer in hand. But
switching the aperture controller off is start-up work, so on a camera that
booted *without* a dimmable lamp the two will contend for the channel until
the camera is restarted — the lamp will look erratic rather than dead. Setting
it and rebooting once is the whole of the workaround; a camera that ships with
its lamp configured never sees this.

### Stopping the sensor and ISP when nothing is watching

Turning both video streams off stops the *encoders*, but the sensor and the
image pipeline behind them keep running, and that is where most of the power
goes. On HiSilicon and Goke the camera can stop the sensor and its image
pipeline as well, and not just the encoders:

```yaml
isp:
  suspendWhenIdle: true   # default false
  suspendIdleSeconds: 5   # grace period, 1-300
```

These arrived in the nightly builds of 5 September 2026. A build without them
answers `404` to the API and does not show them in the web interface, so if the
keys are missing the firmware is older than the feature rather than the camera
being unsupported.

Audio, RTSP, the web server and the API keep running throughout, so a camera
stays reachable, keeps answering its API and keeps streaming its microphone
while its sensor is asleep. Enabling a stream brings the picture back.

Measured at the PoE port on a Hi3516EV300 + IMX335, with both streams and audio
configured, averaged over 60 samples per state:

| state | power drawn | die temperature |
| --- | --- | --- |
| both encoders streaming + audio | 2.06 W | 62.1 °C |
| both encoders disabled, sensor and ISP still running | 1.77 W | 56.2 °C |
| **idle-suspended** | **1.01 W** | 49.5 °C |

Suspending halves the draw. Stopping the encoders alone accounts for 0.29 W of
that and stopping the sensor and ISP for a further 0.76 W, which is why the setting
exists at all — the second saving is nearly three times the first, and nothing
before this could reach it. Temperature understates the difference badly, so
judge this by current if you can measure it. The figures are draw at the port,
so they include the losses in the splitter and the cable; the board's own rail
is lower, and the ratio is the part that carries to a battery.

**It is off by default, deliberately.** A camera already in the field should not
begin power-cycling its sensor because somebody switched off a sub-stream.

Four behaviours worth knowing before turning it on:

- **Waking costs about two seconds of picture quality.** The sensor comes back
  with no exposure history, so auto-exposure starts from its default and
  converges. Frames arrive immediately and are correctly formed — they are
  simply overexposed while the loop closes. If you drive the camera from an
  external trigger, enable the stream slightly before the footage matters.
- **A snapshot will not wake it, a viewer will.** `/image.jpg` while suspended
  answers `503` with a message naming the setting, so a monitoring system
  polling for stills cannot keep a battery camera awake for ever. A client that
  stays connected to `/mjpeg`, or to MJPEG over RTSP, *does* wake it, and the
  camera goes back to sleep once that client leaves.
- **The ISP gauges leave `/metrics` while it is asleep.** `isp_again`,
  `isp_exptime` and the rest are readings from a stopped ISP, so they are
  omitted rather than reported stale. `node_hwmon_temp_celsius` and the memory
  gauges stay.
- **It saves power, not memory.** A suspended camera holds the same memory as a
  running one — see [Memory tuning](memory-tuning.md) for what actually frees
  any.

Motion detection counts as wanting frames, so a camera with
`motionDetect.enabled` never suspends.

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

`osd.weight: thin` shaves a pixel off every glyph stroke — with a floor. The
font is sized from the stream it lands on, so on a main stream the strokes
have pixels to spare and Thin visibly thins; on a narrow substream (704 or
800 wide) they are one or two pixels, and shaving there would not thin the
clock but erase it — which is exactly what older builds did. The thinning now
stops where erasure would begin, so **on a narrow stream Thin legitimately
renders at Normal weight**. That is by design, not a broken setting: Thin
means "as thin as this stream can draw without losing letters".

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
When movement starts, `majestic` runs `/usr/sbin/motion.sh` with the bounding
box of everything that moved, in main-stream pixels, as four arguments:

```
/usr/sbin/motion.sh [x] [y] [width] [height]
```

The last two are the box's **size**, not its far corner.

Cameras built before September 2026 sent the far corner there instead —
every make except SigmaStar — and the two readings cannot be told apart from
the numbers alone, since `100 200 500 700` is a plausible box under either. So
if your camera predates that, settle it once rather than guessing: put a
one-line script at that path which logs what it was given, wave at the camera,
and look at the numbers.

```sh
printf '%s\n' "$*" >> /tmp/motion-args.log
```

Small third and fourth numbers, roughly the size of the thing you waved, are a
size. Numbers nearly as large as the frame, and always larger than the first
two, are a far corner — subtract the first two from them and the rest of this
page applies.

The script is run on the transition, not per frame, and no more than once every
five seconds. For the detections themselves — every box rather than one box
round all of them, live over a websocket, inside recordings, over ONVIF, and as
a per-day index — see [What the camera detects](analytics-metadata.md).

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

To watch it work, ask the camera what it is seeing:

```console
$ curl -s -u root:PASSWORD http://CAMERA/api/v1/analytics
{"sources":[{"src":"motion","active":true,"w":3840,"h":2160,"n":3,"total":3,
 "pts":5773196434,"t":1789396178290757,"q":"k",
 "r":[[1200,300,240,180,0,0],[980,520,120,90,0,0],[2360,442,40,56,0,0]]}]}
```

`active` is whether it sees something now, and `r` is one `[x, y, w, h, class,
score]` per detection. Poll that while you wave at the camera, or open
**Settings → Events → Motion detection** in the web interface, which draws the
same boxes over the live picture. `/ws/analytics` streams them instead of
making you poll — see [What the camera detects](analytics-metadata.md).

`roi` says where motion counts. There is no setting for where it does **not** —
an `exclude:` line in the config is accepted by the parser and read by nothing.

`sensitivity` runs 0–8, and higher is more sensitive. Every value on that scale
is usable: the top of it used to ask the detector to treat any difference at
all as movement, which reported the whole frame as moving continuously whatever
was in front of the camera. If you are running firmware from before September
2026 and a camera at sensitivity 7 or 8 never stops reporting motion, that is
what you are seeing — drop it to 6 or update.

### Recording on motion

The script above used to be the only thing a motion event could drive. Since
September 2026 majestic can record a clip per event itself, and start it a few
seconds **before** the detector fires:

```yaml
records:
  enabled: true
  mode: motion            # "continuous" is the default and stays the default
  path: /mnt/mmcblk0p1/%F
  preRollSec: 5           # seconds kept from before the trigger
  postRollSec: 10         # seconds kept after movement stops
motionDetect:
  enabled: true
```

With nothing moving the camera writes no bytes at all. When the detector fires
it opens a clip, writes the seconds it was holding in RAM, and keeps recording
until movement has stopped for `postRollSec`. Two events a minute apart get two
files; two events in the same minute get `14-30.mp4` and `14-30-1.mp4`.

The detector waits two seconds of stillness before it calls movement over, so
something shifting in frame does not chop one event into several clips. A long
event still rotates on `records.split`, so an afternoon of movement does not
become one enormous file.

To have the camera run a script of yours when each clip is finished — or to get
a clip at all on a camera with no card — see
[When something moves](motion-events.md).

#### Don't raise `gopSize` above `preRollSec`

A recording can only begin at a keyframe, and `gopSize` is how many seconds
apart those are. The camera holds the last `preRollSec` of finished video in
RAM — but if there is no keyframe among those seconds, the run-up cannot be
written and the clip starts at the trigger after all.

Out of the box this is not a problem. `gopSize` is `1`, so every second held is
a possible starting point and the whole run-up survives; you do not have to set
anything. It becomes a problem on cameras where `gopSize` has been raised,
which people do to save bitrate — keyframes are the expensive frames.

Measured with someone walking into shot, `preRollSec: 5` throughout: at
`gopSize: 5` the clip opens on four seconds of empty room and the movement
starts at second five. At `gopSize: 30`, three consecutive events kept three
seconds, one second, and nothing at all — a keyframe lands inside the window
only when it happens to, and getting the run-up sometimes is more confusing
than never getting it.

So if you have lengthened `gopSize` for bandwidth and want the run-up back,
bring it back to `preRollSec` or below. Raising `preRollSec` past `gopSize`
works too, but it is the expensive direction: the run-up is held in RAM, and
the limit below applies.

The camera says so when it happens:

```
Motion: no run-up — none of the 5s held opens at a keyframe.
Set video0.gopSize at or below records.preRollSec (5s) to keep it.
```

The run-up is also limited by RAM. It gets the seconds you asked for at the
stream's own bitrate, capped at an eighth of the board's memory and never more
than 8 MB — so five seconds at 4 Mbit, about 2.4 MB, fits comfortably on a
32 MB camera and is trimmed on a 16 MB one, which logs what it could actually
keep. `records_preroll_bytes` reports what it is holding at any moment, and `0`
while nothing is armed: the run-up is kept only while motion recording wants
it, not at all times.

#### Checking it

```
curl -s http://<camera>/metrics | grep records_
```

`records_motion_clips_total` counts clips closed by an event. If that and
`records_fragments_written_total` are both zero, nothing is triggering — start
with `motionDetect.enabled` and `sensitivity`. `records_fragments_skipped_total`
climbing by several per event is the `gopSize` problem above, and
`records_preroll_bytes` says what the run-up is holding right now.

Majestic warns once, when recording is switched on, if `records.mode` is
`motion` while `motionDetect.enabled` is off — a camera that has quietly
stopped recording looks exactly like one where nothing has moved.

### Recordings, and what survives a power cut

Recording writes fragmented MP4 to the card. A few things are worth knowing.

**The card is committed on a timer, not per frame.** `records.syncSeconds`
(default 30) is how often the open clip is flushed, and it bounds what a power
cut costs: the fragment being accumulated, whatever is queued, and whatever the
card had not yet committed. In practice a cut leaves the clip playable to its
last whole second — five sysrq-b cuts on a test camera produced five clips that
played end to end.

**A clip may need trimming.** vfat has no journal, so past the last committed
byte a file can hold whatever a deleted file left in the clusters it grew into.
Majestic checks the most recently written clip when it starts, and there is a
tool for the rest:

```
/etc/init.d/S95majestic stop
majestic --repair /mnt/mmcblk0p1 --dry-run   # report only
majestic --repair /mnt/mmcblk0p1             # trim
/etc/init.d/S95majestic start
```

It refuses to run while majestic is running, because the clip being written has
a "tail" that is simply the recording in progress. It **never** empties a file:
a clip with no header cannot be played, but it is still footage, and it is
reported and left alone rather than deleted.

**Watching the recorder.** `/metrics/records` is majestic's own verdict on the
card, which the filesystem cannot give you — a card can be mounted read-write
with room on it and still be taking nothing:

```
records_state 0                     # 0 ok, 1 degraded, 2 failed, 3 offline
records_stood_down 0                # 1 while recording is deliberately paused
records_fragments_dropped_total 0   # the card could not keep up
records_write_errors_total 0
records_fsync_us_max 18825          # a stalling card shows here first
```

`records_state` is a verdict on the storage, so it cannot tell you the
difference between a card that has gone and a recorder somebody paused on
purpose. `records_stood_down` is what says the pause was deliberate — worth
checking before treating a quiet recorder as a fault.

The Recordings page in the web interface reads the same numbers and says so in
words.

**Pausing the recorder.** Recording can be stopped and started at runtime
without touching `majestic.yaml` and without rebuilding the video pipeline, so
RTSP and WebRTC viewers are not disturbed:

```
curl -X POST http://localhost/api/v1/records/standdown
{"stoodDown":true,"resumesInSec":600}

curl -X POST http://localhost/api/v1/records/resume
```

The pause closes the open clip properly and lets go of it, which is what makes
the card **possible to unmount** — it does not unmount anything itself, and a
paused camera still has the card mounted. Nothing is safe to pull until an
`umount` has actually succeeded. It expires on its own after ten minutes,
because a pause that outlives its reason is a camera quietly not recording.

`stoodDown` in the reply is what actually happened rather than what was asked
for, and it is also how you tell whether this camera has the feature at all: a
build without it answers **200 with an empty body** rather than an error, so
the status code will not tell you and a script that trusts one will think it
paused a camera it did not.

This is what [changing the SD card on a running
camera](sd-card-swap.md) is built on, and that page is the guided version.

### A second camera

Most cameras have one. Some have two, and where they do, everything below
addresses them the same way.

There are two ways a camera comes to have a second source. A few boards carry a
**second sensor** of their own. And on builds with the USB dual-role package, a
**USB (UVC) webcam** plugged into the camera's USB port is published as a second
camera beside the built-in one.

> The USB webcam path is new, and the **Goke gk7205v200/v500** OTG builds are the
> first to carry it. It is deliberately being rolled out one platform at a time,
> after testing on real hardware, so other SoCs will follow rather than having it
> already. If your camera's web interface has no **USB** page and no `usbcam`
> keys in its configuration, its build does not have the feature.

#### Which sources a camera has

Ask it:

```
curl -u root:PASSWORD http://<camera-address>/api/v1/sources
```

```json
{"sources":[
  {"camera":0,"kind":"sensor","streams":[
    {"id":0,"subtype":"main","codec":"h264","fps":20,"width":1920,"height":1080,
     "flowing":true,"configured":true,"present":true,"rtsp":true},
    {"id":2,"subtype":"mjpeg","codec":"mjpeg","fps":5,
     "configured":true,"present":true,"rtsp":false}]},
  {"camera":1,"kind":"external","streams":[
    {"id":5,"subtype":"mjpeg","codec":"mjpeg","fps":30,"width":640,"height":480,
     "configured":true,"present":true,"rtsp":false}]}]}
```

A camera with one source answers with one entry, which is how a page can tell
whether to offer a choice at all.

| field | meaning |
|---|---|
| `camera` | 0 is the built-in sensor. Anything else is a second source. |
| `kind` | `sensor` for a built-in one, `external` for a USB webcam. The camera does not name it in words — the web interface does that, so it can be translated. |
| `id` | The stream id, used in URLs. See the arithmetic below. |
| `subtype` | `main`, `sub` or `mjpeg`. |
| `codec` | What this stream carries. Absent when nothing is behind the id. |
| `configured` | The configuration asks for this stream. |
| `present` | The machinery behind it is up right now. |
| `flowing` | A picture has actually been seen. **Absent on an MJPEG stream**, which has no keyframes to report — absent means "cannot say", not "no". |
| `rtsp` | The RTSP server will serve this stream. The sub track needs `video1.enabled` and the JPEG track needs `jpeg.rtsp`. |

`configured` and `present` are separate on purpose: a stream you switched on
that did not come up reads `configured: true, present: false`, which is the
answer that tells you something is wrong rather than that nothing was asked for.

#### Stream ids

A stream id is `3 * camera + subtype`, where subtype is 0 for the main stream,
1 for the sub stream and 2 for MJPEG. So:

| | main | sub | MJPEG |
|---|---|---|---|
| **camera 0** (built-in) | 0 | 1 | 2 |
| **camera 1** (second) | 3 | 4 | 5 |

That is how the numbers are formed, not a promise that a camera has all six.
Which ids actually exist is what `/api/v1/sources` answers, and it is worth
asking rather than assuming: a **USB webcam publishes exactly one stream** — id
5 when it sends MJPEG, id 3 when `usbcam.codec` is `h264` or `transcode` — and
never a sub stream. Asking for one it does not publish gets you nothing, which
looks like a broken camera and is not.

The stream id is what goes in a URL:

```
rtsp://<camera-address>/stream=3            second camera, H.264
ws://<camera-address>/ws/video?stream=3     the same, low latency (fMP4/MSE)
```

Both of those want a stream the transport can carry, so they are the H.264 case
— a webcam left on MJPEG is reached through the image endpoints below instead.
`/ws/video` refuses an MJPEG stream id outright rather than holding a socket
open that will never carry a frame.

The two HTTP image endpoints take a **camera** rather than a stream, because
there is one MJPEG stream per camera:

```
http://<camera-address>/mjpeg?channel=1       second camera, MJPEG
http://<camera-address>/image.jpg?channel=1   second camera, snapshot
```

Without `?channel=`, both mean the built-in camera. A camera that has no such
source answers 404 rather than quietly handing back the built-in camera's
picture.

#### Watching it in the web interface

With more than one source, the **Live** page grows a chooser beside the
Main/Sub buttons — *Sensor* and *USB camera*. Picking one switches the picture
and remembers the choice for next time.

Two things follow from the source you pick, and they are not faults:

- **The Main/Sub/Auto buttons may go unavailable.** They pick between encoder
  channels, and a webcam in its usual MJPEG mode publishes one stream. There is
  nothing to choose between.
- **The WebRTC/MSE buttons may go unavailable too.** Neither transport can carry
  an MJPEG stream, so such a source plays over plain HTTP instead. Set
  `usbcam.codec` to `h264` or `transcode` and the same webcam moves to stream 3
  as H.264, at which point both transports work on it.

WebRTC serves the built-in camera only. A second camera plays over MSE
(`/ws/video`) when it has an H.264 or H.265 stream, and over HTTP MJPEG when it
does not.

#### Recordings

Each camera records to its own files. A second camera's clips carry a `-cam1`
suffix before the extension, so one directory holds both:

```
12-04.mp4
12-04-cam1.mp4
```

The Recordings page shows one camera's timeline at a time, with a picker when
more than one has written that day. That is not just filtering: gaps, joins and
durations only mean anything within a single camera's footage.

#### Switching the port between the two roles

A camera can consume a webcam or *be* one, and not both at once — there is one
USB controller. The **USB** page in the web interface switches between them and
saves the settings that go with the choice. Doing it by hand means changing the
port's role and the `usbcam`/`uvcgadget` keys together, in that order; the page
exists so that ordering is not yours to get right.

### Live HLS

`hls.enabled` turns on an HLS stream at `/master.m3u8`, with a player page at
`/hls`. It applies immediately — no restart, and recording is not interrupted
while you switch it on or off.

```yaml
hls:
  enabled: true
records:
  enabled: true       # optional, and worth having: see below
```

**HLS and recording used to be mutually exclusive.** They are not any more, and
running both is the better configuration rather than merely a permitted one.

#### Why recording makes HLS cheaper and faster

A recording on the card is already the format HLS serves. When the camera is
recording, the playlist describes byte ranges of the clip it is writing instead
of holding a second copy of every segment in RAM, so:

- **it costs no memory.** `malloc_hls_alloc_bytes` in `/metrics` reads 0 while
  HLS is served this way. With recording off it reads the size of the window
  instead — `hls.segments` multiplied by however much video a GOP is, which at
  a long `gopSize` and a high bitrate is tens of megabytes;
- **the live edge is about a second behind**, not a whole GOP. The playlist
  carries `EXT-X-PART` entries for the part of the stream still being written,
  so a player does not have to wait for the next keyframe before it has
  something to fetch.

HLS falls back to keeping segments in memory whenever there is no clip to
describe, or none a player could use: with recording off, with `records.key`
set — which scrambles the clips, so their bytes are not what a player needs —
and with `records.metadata` on, which adds a track to the clip that some
browsers refuse and that nothing on the HLS path would remove. It still works;
it is just the expensive way round, and `malloc_hls_alloc_bytes` in `/metrics`
goes from 0 to the size of the window when it happens. Size the camera's memory
for that before turning either key on.

`records.mode: motion` is refused rather than served badly. Between detections
nothing is written, so there would be no new byte ranges to describe and the
live edge would simply stop until something moved — which looks like a broken
stream, not like a setting anyone chose. Turning motion recording on therefore
turns `hls.enabled` off, and says so in the log; the settings page explains it
under the HLS switch while the recorder is in motion mode, rather than letting
the two be set against each other and leaving the result to be discovered. A
camera that has to do both is a camera that wants `records.mode: continuous`.

#### Low latency

The stream advertises `CAN-BLOCK-RELOAD=YES`, so a player that supports
Low-Latency HLS can ask for a playlist that does not exist yet and have the
request held until it does, rather than polling for it:

```
GET /video.m3u8?_HLS_msn=<segment>&_HLS_part=<part>
```

The camera answers the moment that part is written, so the wait is one part —
about a second, since a part is `records.fragmentMs` long and that defaults to
1000. A request for something more than one segment ahead is refused with 400
rather than held, and one that waits more than six seconds is answered with
504, which means the stream has stalled rather than that the player asked for
the wrong thing.

Players that do not implement blocking reload simply poll, and still get the
`EXT-X-PART` entries.

#### Segment length follows gopSize

A segment runs from one keyframe to the next, so the recorded stream's
`gopSize` sets it — `video0.gopSize` normally, and `video1.gopSize` when
`records.substream: true`, because HLS describes whichever channel is being
written. At `gopSize: 30` the segments are thirty seconds long, which makes a
player slow to start and each segment large; at `gopSize: 1` they are a second.
Parts make the *live edge* independent of that, but segment size is not, so a
camera serving HLS to players without low-latency support wants a shorter GOP
than one that is only recording.

`hls.segments` sets how many finished segments the playlist offers, 2 to 8. It
is only a memory cost in the fall-back cases above.

#### Offering both streams

`hls.adaptive` puts both encoder channels in the master playlist, as two
variants with their own resolutions and bitrates, and the player picks whichever
its connection can carry and switches between them as that changes. Without it
the playlist has one variant: whichever channel is being recorded.

The second variant is not free, and the price is the memory the recorded one
stopped costing. Only the recorded channel can be described out of the clip on
the card; the other is held in RAM the older way, so `malloc_hls_alloc_bytes`
goes from 0 to roughly `hls.segments` multiplied by a GOP of that channel. On a
camera whose second channel runs a thirty-second GOP that is megabytes, and a
shorter `gopSize` on that channel is what brings it down.

It is also video only. The recorded variant carries the audio; duplicating it in
both would be work for something a player takes from whichever variant it is
playing.

Both settings apply without a restart, `hls.enabled` included.

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
    "servers": [
      { "url": "rtmp://a.rtmp.youtube.com/live2/you-key-here" }
    ]
  }
}
EOF
```

The API applies this live and saves it; no reboot is needed. RTMP is in Lite
and Ultimate builds, not FPV.

`servers` is a list because a camera can publish to several places at once, and
each entry carries its own settings. Older guides set `outgoing.enabled` and
`outgoing.server` here instead; those are deprecated and the API refuses them,
so a copy of the old command fails with 404 and changes nothing. A camera whose
config still has them keeps working — it converts them into the list on its
next start.

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
`audioCodec` on that destination (`aac`, `alaw`, `ulaw`, `pcm`); leave it empty
to follow `audio.codec`. A-law and mu-law are 8 kHz by definition and the encoder
resamples to it from whatever the microphone is capturing, so `audio.srate` can
stay wherever the rest of the camera wants it. Builds before 2026-09 did not
resample and needed `audio.srate: 8000` here, or the audio played back at the
wrong speed.

If the camera has no microphone, a destination's `audioSource` supplies a track
anyway:

```
outgoing:
  servers:
    - url: rtmp://a.rtmp.youtube.com/live2/---KEY---
      audioSource: auto     # auto | mic | silence | file | none
      audioFile: ""         # path to an ADTS .aac file to loop
```

These belong to the destination rather than to the section, so one camera can
send its microphone to one service and a looped file to another. Setting them
once for everything was the older shape; a config still written that way has
them moved onto its destinations on the next start.

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

Every place the camera publishes to is an entry under `servers`. It is editable
in the WebUI under **Settings → Network & Integrations → Outgoing**, which also
shows what each destination is doing.

The address picks the protocol: `udp://` and `unix:` are sent as RTP, `rtmp://`
and `rtmps://` as RTMP, and `http(s)://` is WHIP. An entry is a bare address, or
a mapping carrying that address plus what belongs to that destination alone.

```
outgoing:
  servers:
    - udp://IP-1:port
    - udp://IP-2:port
    - unix:/tmp/rtpstream.sock
    - rtmps://dc4-1.rtmp.t.me/s/mykey
    - url: https://mediamtx.lan:8889/cam/whip
      token: s3cret        # bearer credential, if the endpoint asks for one
    - url: rtmp://a.example/live/key
      enabled: false       # keep the destination without dialling it
      channel: sub         # main | sub; absent means main
      naluSize: 4000       # RTP packet size for this destination alone
```

Each destination switches on and off by itself, so the one that has started
refusing connections can be parked without touching the two that have not.

`thinEnhance` is the one setting that still belongs to the section rather than
to an entry: it drops the SVC-T enhancement layer for everything the camera
sends, so it sits beside `servers`, not inside it.

#### Settings that used to apply to the whole section

`enabled`, `server`, `substream`, `audioSource`, `audioCodec` and `audioFile`
each held **one** value for every destination at once, which stopped making
sense once there was a list of them. Each has the per-destination member that
replaced it — `server` became an entry's address, `substream` became `channel`,
and the three audio settings kept their names on the entry.

They are deprecated, not silently dropped. A camera whose `/etc/majestic.yaml`
still carries any of them reads them once and writes them onto its destinations
on the next start, so nothing has to be entered again and the file settles on
one spelling. Writing one through the API answers 404 instead.

`outgoing.naluSize` moved elsewhere rather than onto the entries: it is
`rtsp.naluSize` now, because the same setting sizes the packets RTSP clients
get. An entry can still override it for itself with the `naluSize` above.

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

`jpeg.enabled` is not the only reason for that `503`. A camera running with
`isp.suspendWhenIdle` answers the same status while its sensor is asleep, with
a different message and a different remedy — enable a video stream. See
[Stopping the sensor and ISP when nothing is watching](#stopping-the-sensor-and-isp-when-nothing-is-watching).

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

### Raw sensor data, as Adobe DNG

`/image.dng` hands over what the sensor actually measured, before any of the
processing that turns it into a picture — no white balance, no demosaicing, no
noise reduction, no sharpening. It is a [raw image][raw] in [Adobe DNG][dng]
format, so ordinary raw software opens it: RawTherapee, darktable, `dcraw`,
Adobe's own tools, or `rawpy` if you would rather script it.

```
curl -u viewer:PASSWORD -o shot.dng http://192.168.1.10/image.dng
```

`/image*` is one of the paths a media-only account may use, so give this a
`viewer` rather than `root` — see [User levels in the
system](#user-levels-in-the-system). Over plain `http` the password crosses the
network in the clear either way, and a media account is the one you can afford
to spend that way.

This is a **HiSilicon and Goke** feature. Cameras on other SoC families do not
serve it, and neither do the oldest HiSilicon parts. It is not tied to a build
flavour — Lite, Ultimate and FPV all serve it wherever the hardware does.

Rather than match your camera against a model list, ask it. A build that does
not have the endpoint answers **404**, the same as any path it does not serve:

```
curl -u viewer:PASSWORD -o /dev/null -w '%{http_code}\n' http://192.168.1.10/image.dng
```

`404` means this firmware has no raw endpoint at all. `501` means it has one and
`isp.rawMode` is `none`. `503` means a capture is already running and this one
was refused — wait for the first to finish and ask again. `200` means you
already have the file.

**It is on by default.** `isp.rawMode` is `slow` unless you changed it, so a
camera that has never been configured for this still answers. `/image.yuv420`
is the other endpoint people find while looking for raw data, and it is a
different thing: that one is the processed picture, after the pipeline has
finished with it, just not yet compressed.

| `isp.rawMode` | what it does |
|---|---|
| `slow` | Default. The raw path is set up when a snapshot is asked for, so switching to it from `none` takes effect on the very next request, with no restart. |
| `fast` | The raw path is kept ready rather than set up for each snapshot. The memory that reserves is claimed when the streamer starts, so switching to `fast` on a running camera does not reserve it until the next restart. |
| `none` | Off. `/image.dng` answers **501**, and the memory the raw frame would have needed is left to the rest of the pipeline. |

On a 5 MP IMX335 attached to a Goke GK7205V300, three snapshots per mode over
the loopback interface on a 2026-09-17 build: `slow` took 0.241 to 0.264 s,
`fast` 0.228 to 0.241 s, for a 7.2 MB file. That difference is inside the noise
of moving it, so on this hardware `fast` bought nothing worth the permanently
reserved frame. Measure before assuming otherwise on yours — [Memory
tuning](memory-tuning.md) explains what that frame competes with.

#### Asking for less than the whole frame

Two query parameters, on builds from **2026-09-17**, and between them they are
the answer to most of the memory and speed trouble below. An older build ignores
them and sends the whole frame, so check what arrived rather than assuming.

```
curl -u viewer:PASSWORD -o roi.dng "http://192.168.1.10/image.dng?crop=0x0x640x480"
curl -u viewer:PASSWORD -o avg.dng "http://192.168.1.10/image.dng?crop=800x600x1024x768&frames=4"
```

- **`crop=LEFTxTOPxWIDTHxHEIGHT`** cuts a rectangle out of the sensor frame.
  The camera snaps it outward to keep the colour filter in phase — cutting at an
  odd column would silently change every pixel's colour — so you may get back a
  slightly larger rectangle than you asked for.
- **`frames=N`**, 2 to 16, averages that many consecutive frames into one file.
  Noise falls as the square root of the count, which is worth having when you
  are measuring a dark scene. It **needs a crop**: averaging whole frames does
  not fit in memory, and the camera refuses with **400** and says so rather than
  failing in some more interesting way.

The reply says what you actually got, so a script never has to guess:

```
X-Frame-Width: 640
X-Frame-Height: 480
X-Frames-Averaged: 1
```

Measured on the 5 MP camera above, a 2026-09-17 build:

| request | file | on the camera | over a LAN |
| --- | ---: | ---: | ---: |
| whole frame | 7 558 767 B | 0.25 s | 1.11 s |
| `crop=0x0x640x480` | 461 295 B | **0.03 s** | **0.37 s** |
| `crop=800x600x1024x768&frames=4` | 1 180 143 B | 0.37 s | 0.73 s |

If you are sampling a fixed region on a timer — a sky patch, a test target, one
corner of a scene — the crop is the difference between an endpoint you have to
be careful with and one you can simply use.

#### On a board with little RAM, read this before you ask for one

A raw frame is not a thumbnail. The uncompressed file is the whole sensor
readout, and the camera needs that much memory *while it is serving the
request*. Ask for two at the same time and it needs it twice over.

How much depends on the frame and on the build. The rise tracks the size of the
frame being served, so a camera in a larger sensor mode costs more than the
figures below: the same 5 MP camera in a 2592x1944 12-bit mode, whose frame is
7.2 MB rather than 4.9 MB, was measured at 7 388 kB. Watching the streamer's
resident memory across one capture:

| build date from `majestic -v` | peak memory rise |
|---|---|
| 2026-09-15 and earlier | about 9 MB |
| after 2026-09-15 | about 4.8 MB |

Check yours with `majestic -v` — the date is the third field. If you are unsure,
budget the larger figure.

That is fine on a 128 MB board and fatal on a small one. Measured on a
Hi3518EV200 with 27 MB of RAM and roughly 10 MB free: several overlapping
requests for `/image.dng` and the kernel killed the streamer outright —

```
Out of memory: Kill process 987 (majestic) score 202
```

The camera then stayed down. The restart got as far as loading the sensor
driver and stopped there, because the process the kernel killed never released
the video hardware, and it took a reboot to clear. Nothing in the request
looked unusual; there were simply more of them in flight than the board had
memory for.

So on anything memory-constrained:

- **Take one at a time.** Wait for each capture to finish before asking for the
  next. Builds after 2026-09-15 refuse an overlapping request with **503** when
  `isp.rawMode` is `slow`, rather than attempting it. Earlier ones attempt it,
  which is where the kill above came from.
- **Do not point a monitoring script at the whole frame.** It is a diagnostic
  endpoint, not a stream, and anything that polls it on a timer will eventually
  overlap with itself. If you do need it on a timer, ask for a
  [crop](#asking-for-less-than-the-whole-frame): a 640x480 region is a
  sixteenth of the memory. Measured on the camera below, peak resident memory
  across a capture rose 7 388 kB for the whole frame and 456 kB for that crop.
- **Set `isp.rawMode` to `none`** when you are not using it, and turn it back
  on for the session you need it in. With `slow` the cost is only paid per
  request, but it is still paid.
- **Do not race the transfer.** What is left of the time is now almost all
  network: a 7.2 MB frame that takes 0.25 s on the camera itself takes about
  1.1 s over a LAN, and browsers have been measured at 4.5 to 5.7 s and once,
  on a loaded camera, 142 s. A client that gives up and retries while the first
  request is still running is how you arrive at the paragraph above. (Builds
  before 2026-09-17 spent about a second longer per capture inside the camera,
  before a single byte left it.)
- **A download that stalls will be cut off.** Builds after 2026-09-15 give a
  raw transfer 15 seconds and then close the connection; the camera will not
  hold a capture open indefinitely for one slow reader. A short `.dng` on a
  congested link is that, not corruption — check the size against
  `Content-Length`, then retry on a better connection, or fetch it on the
  camera itself over the loopback interface, where the same frame takes about a
  quarter of a second.

If the streamer disappears while you are working with raw frames, this is the
first thing to check: `logread | grep -i 'out of memory'`.

#### What you get

The file is uncompressed, so its size is a straight function of the frame: the
same camera produced 2592x1520 at 10 bits per pixel, which is 4 924 800 bytes of
sensor data plus a small header.

Those dimensions are the frame **the sensor is configured to deliver**. They are
not `video0.size`, and not the sensor's full array either — the camera above was
streaming 1920x1080 from a sensor whose full frame is 2592x1944, and the DNG came
out 2592x1520, the mode actually in use. Bit depth follows the sensor in the same
way, commonly 10 or 12.

#### How good the colour is depends on your firmware

This part of the page used to say the colour data were placeholders. On current
firmware they are not, and it is worth checking what your camera actually
writes before you assume either way.

A recent build fills in what it genuinely knows: the black level the sensor is
running at, the white balance the camera's own AWB had settled on, and a model
field naming the sensor rather than just the chip vendor. A 5 MP IMX335 on a
Goke GK7205V300 produced a black level of 50, a white balance of
0.898 : 1.000 : 0.286 and `HiSilicon imx335` — all real values, none of them
placeholders.

Older builds wrote one colour matrix regardless of which sensor was fitted, a
white balance of 1:1:1 and a black level of zero. If that is what you have, a
raw converter has nothing real to work from and the first render will show a
colour cast and milky blacks.

The geometry and the [CFA][cfa] pattern have always been right, and the file
loads without complaint on any firmware. If the colour looks wrong, shoot a grey
card and set the white balance from it, or build a camera profile for your
sensor.

#### 12-bit sensors: check your build date before you trust the numbers

This one is easy to miss because the file opens perfectly and the picture looks
normal. On builds **before 2026-09-17**, a camera whose sensor delivers **12-bit**
raw wrote every second pixel four bits short: the even-numbered pixel of each
pair came back rounded down to a multiple of 16, while the odd one was intact.

It shows up as a faint one-column-in-two pattern worth about a quarter of a
percent — small enough to pass for sensor noise, large enough to matter if you
are measuring. Anything derived from those files carries it: means, noise
figures, flat fields, defective-pixel counts, stacked frames.

Check which kind of camera you have:

```
exiftool -BitsPerSample shot.dng
```

**10-bit sensors were never affected**, so if that says 10 there is nothing to
redo. If it says 12 and the file came off a build older than 2026-09-17, take it
again on current firmware before drawing conclusions from it. On a fixed build
both column parities agree; you can confirm it on your own file by comparing the
mean of the even columns against the odd ones within one colour of the mosaic.

One thing no firmware can give you: a raw frame carries the scene as the sensor
saw it, so if the camera's own white balance was wrong when you took it, the
`AsShotNeutral` it records will be wrong in the same way. That is not a defect
in the file — it is what a raw frame is for.

So this is the endpoint for measurement, sensor evaluation, calibration work and
astrophotography-style stacking — anywhere you want the numbers rather than a
pretty picture. For a picture, `/image.jpg` has had the camera's own tuning
applied and will look far better with no work at all.

To look at one without leaving the browser, the web interface has a
[raw editor](raw-editor.md) under **Camera → Raw**: it develops the frame on
your own machine, measures the sensor, and can calibrate the camera's colour
from a chart.

### How to play audio stream

Use [ffplay][ffplay] utility from [ffmpeg][ffmpeg] package.
```
ffplay -ar 48000 -ac 1 -f s16le http://192.168.1.10/audio.pcm
ffplay -ar 8000 -ac 1 -f alaw http://192.168.1.10/audio.alaw
ffplay -ar 8000 -ac 1 -f mulaw http://192.168.1.10/audio.ulaw
ffplay -ar 8000 -ac 1 -f alaw http://192.168.1.10/audio.g711a
```

`-ar` has to match what the endpoint emits. `/audio.pcm` follows
`audio.srate` — 48000 above is only an example, use whatever the camera is set
to. The G.711 endpoints are always 8 kHz: that is the rate the codec is defined
at, and the encoder resamples to it from whatever the microphone captures.
Builds before 2026-09 passed the capture rate through unchanged, so on those
`-ar` had to match `audio.srate` here too.

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

Where that pin is set, the amplifier is powered only while there is something to
play, and drops again `audio.speakerPinHoldMs` after the last sound (default
2000). An amplifier left powered draws current and passes its own hiss to the
speaker continuously, which is audible in a quiet room. Set it to `0` to keep
the amplifier powered for as long as audio output is enabled, which is what
cameras did before this setting existed — worth doing if your hardware pops on
the transition, or if something other than Majestic drives the speaker.

Expect roughly the first tenth of a second of sound after a silence to be lost
while the amplifier comes up; the exact figure is a property of the board.

Speaker output is available on HiSilicon/Goke, Ingenic, Sigmastar, Allwinner,
Rockchip and Xiongmai. `audio.srate` is shared by input and output; there is no
separate output rate.

On HiSilicon/Goke and Ingenic, `audio.volume` and `audio.outputVolume` take
effect as soon as they are saved, without restarting the video pipeline — so you
can find a level by ear without interrupting anyone watching the stream. On the
other SoCs a volume change still rebuilds the pipeline, which drops every
stream for a moment.

To find one without walking over to the camera, the web interface has a
[soundcheck](audio-soundcheck.md) under **Camera → Settings**, in the **Audio**
section: it plays a test sound through the speaker, measures what the microphone
sends back, and settles on a level from the difference. It needs a camera that
applies a level live, which is the same two families.

### How to create an audio file to play on camera's speaker over network

Using [sox][sox] program convert any source audio file to raw [PCM][pcm]:
```
sox speech.mp3 -t raw -r 8000 -e signed -b 16 -c 1 test.pcm
```

Or with [ffmpeg][ffmpeg]:
```
ffmpeg -i speech.mp3 -ac 1 -ar 8000 -f s16le -acodec pcm_s16le test.pcm
```

The camera decides what you sent from the `Content-Type` header, so the
conversion above is only one of the options:

| `Content-Type` | what the camera does |
| --- | --- |
| absent, or `application/octet-stream` | raw s16le mono at `audio.srate` |
| `application/octet-stream;rate=44100` | raw s16le, resampled for you |
| `audio/L16;rate=44100;channels=2` | the same, and stereo is mixed down |
| `audio/ogg` | an Opus file, decoded on the camera |

The type chooses the container; `rate` and `channels` are read from the
parameters whatever the type is. Sending no header means exactly what it always
did, so existing scripts keep working untouched.

Two consequences worth knowing. **The rate no longer has to match
`audio.srate`** — declare what you are sending and the camera resamples it. If
you declare nothing and the rates differ, playback still comes out at the wrong
pitch and speed, so declare it. And **an audio type the camera cannot decode is
refused** with `501` rather than played as noise: MP3, AAC, FLAC and `audio/wav`
all land there, as does `audio/basic`, which is mu-law rather than PCM. A `.wav`
sent as raw bytes still clicks at the start, because its header is played as
samples.

`audio.codec` applies only to the audio the camera sends out and has no effect
here.

### How to play audio file on camera's speaker over network

```
curl -u root:YOUR_PASSWORD --data-binary @test.pcm http://192.168.1.10/play_audio
```

An Opus file needs no conversion at all — the camera has the decoder:

```
curl -u root:YOUR_PASSWORD -H 'Content-Type: audio/ogg' \
     --data-binary @music.opus http://192.168.1.10/play_audio
```

Either way this is a one-shot clip player: a new upload cancels the clip
currently playing. For a live conversation use two-way audio below.

The clip is played as it arrives rather than held in memory, so its length is
not limited by the camera's RAM — the upload simply takes about as long as the
audio does, because the camera accepts it no faster than the speaker can play
it. That also means a stalled upload holds the speaker until it finishes or the
camera gives up on it.

Streaming a source that is not a file works the same way, with `-T -`:

```
ffmpeg -i https://example.org/stream.mp3 -f s16le -ac 1 -ar 44100 - | \
  curl -u root:YOUR_PASSWORD -X POST -T - \
       -H 'Content-Type: application/octet-stream;rate=44100' \
       http://192.168.1.10/play_audio
```

### Microphone processing (VQE)

*Ultimate, and only on some SoCs.* HiSilicon and Goke parts carry a voice
quality enhancement block on the audio input channel — noise reduction (ANR),
automatic gain control (AGC) and a high-pass filter. Majestic can switch it on:

```
audio:
  enabled: true
  vqe: true
```

It sits on the **capture** channel, upstream of every encoder, so one setting
reaches RTSP, SIP calls, WebRTC, the `/audio.*` endpoints and MP4 recordings
alike. There is nothing per-protocol to configure and nothing that can
disagree.

Off by default: it changes how every stream from the camera sounds, and an
upgrade should not move that under a camera someone has already tuned by ear.
The shipped values are the ones a vendor firmware uses on this class of SoC, so
turning it on lands somewhere known to work.

Which stages you get depends on `audio.srate`, because the SoC has two engines
and they are not interchangeable:

| `audio.srate` | engine | ANR | AGC | high-pass |
|---|---|:---:|:---:|:---:|
| 8000, 16000 | talk | ✅ | ✅ | 80 / 120 / 150 Hz |
| 48000 | record | — | ✅ | 80 Hz only |
| 32000 | *neither* | — | — | — |

At 32 kHz there is no engine at all; majestic logs that and carries on rather
than pretending. The tuning keys are listed in
[Majestic example config](majestic-config.md).

#### Which cameras actually have it

Two conditions, and both have to hold. The build must be Ultimate, **and** the
SoC must be one of the three generations these SDK calls belong to. Of the
chips Ultimate is published for:

| chip | SoC code | VQE |
|---|---|:---:|
| Hi3516EV200 | 3516E200 | ✅ |
| GK7205V200 | 7205200 | ✅ |
| GK7205V500 | 7205500 | — |
| Hi3516CV200 | 3518E200 | — |
| Hi3516CV300 | 3516C300 | — |

The older parts have a differently shaped SDK call and are not wired up. If
your camera is not on the ✅ list the keys simply will not exist, and
`curl http://localhost/api/v1/config.json` will not list them.

Majestic also builds this for SoC code 3516C500 — the Hi3516CV500 / AV300 /
DV300 family — but no Ultimate image is published for those chips today, so
in practice the two above are the whole list.

#### If the keys are there but nothing changes

The DSP stages are separate shared libraries that the SDK loads at the moment
VQE is switched on, and firmware images built before this feature existed do
not carry them. Then the log says:

```
the SoC would not start the talk VQE engine (0xa0158041) — audio continues
unprocessed. The stages are loaded by dlopen at this point, so the usual cause
is a firmware image built without the VQE engine libraries
```

and the console shows `dlopen ... libhive_HPF.so failed`. Audio keeps flowing
normally; only the processing is missing. The fix is a firmware image that
installs those libraries — update the firmware, don't change majestic.

### Who may call the camera

The SIP client answers calls as well as placing them, which makes the camera
reachable from anywhere that can send it a UDP packet. Since the 2026-09
builds it decides who is allowed to do that.

**A camera that registers needs no configuration for this.** It trusts the
registrar it was pointed at — the PBX in `sip.server` — and refuses everyone
else. That is the setup the [doorbell guide](howto-doorbell-from-camera.md)
describes, and nothing in it changes.

Deployments with no registrar to trust say who may call, in one of two ways:

```
sip:
  # either: name the addresses, and they call without a password
  allowedPeers: "192.168.1.50, 192.168.9.0/24"

  # or: ask everyone for one
  authInbound: true
  inboundPassword: "something-long"     # falls back to sip.password
```

`allowedPeers` takes dotted-quad addresses and CIDR ranges, separated by
commas or spaces. `authInbound` challenges with SIP Digest, which every
softphone and PBX can answer; `inboundUser` and `inboundPassword` fall back to
`sip.username` and `sip.password`, so a doorbell that already has a PBX login
does not need a second one invented for it.

The two combine: an address in `allowedPeers` is never asked for a password,
everybody else is asked if `authInbound` is on and refused with `403` if not.
Liveness probes (`OPTIONS`) are always answered, because a PBX that cannot
qualify the camera marks it unreachable and quietly stops routing calls to it.

`system.unsafe` switches this off along with everything else.

#### If the camera stops answering after an upgrade

One deployment changes behaviour: `doRegister: false` with callers that used
to be accepted because nothing was checking. Those need one of the two keys
above. The camera says so at start-up, and this is the line to grep for:

```
sip uac: nothing may call this camera — it does not register, sip.allowedPeers
is empty and sip.authInbound is off, so every inbound call will be refused. Set
sip.allowedPeers to the caller's address, or sip.authInbound to ask it for a
password
```

Refusals name the caller too, so `sip uac: refused a call from` tells you which
address to add. Both keys are picked up by `killall -HUP majestic`.

To go back to answering anyone — knowing what that means — set
`allowedPeers: "0.0.0.0/0"`.

#### What this does not protect

SIP Digest is MD5 over UDP with no integrity protection, so it stops somebody
who can reach the port, not somebody who can already read your traffic. Its
real job is making an inbound call from an unknown address *possible at all*
without leaving the camera open to everyone.

Two things do not depend on it, and are worth knowing about because they used
to be missing: a `BYE` must carry the dialog's tags before it ends a call, and
a `CANCEL` must name the transaction it cancels. Previously a Call-ID copied
off the wire was enough to do either.

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
[cfa]: https://en.wikipedia.org/wiki/Color_filter_array
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
