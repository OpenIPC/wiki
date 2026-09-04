# OpenIPC Wiki
[Table of Content](../README.md)

Majestic example config
-----------------------

Majestic reads `/etc/majestic.yaml`. A camera only needs the keys it wants to
change from the defaults, so a working file is usually much shorter than what
follows — this page is a reference of what exists, not a file to paste whole.
`/etc/majestic.full` on the camera is a shorter sample of the same thing.

Two ways to check a key against the build you are actually running, which beats
trusting any wiki page:

```
curl http://localhost/api/v1/config.json     # every key this binary has, with defaults and ranges
curl 'http://localhost/api/v1/set?video0.fps=10'   # applies live and saves; 404 if the key is unknown
```

Sections marked *(build-dependent)* only exist in some builds — see
[Lite, Ultimate and FPV](majestic-streamer.md#lite-ultimate-and-fpv). Sections
marked *(platform-dependent)* only exist on the SoCs that can act on them.

```
system:
  webPort: 80
  httpsPort: 443
  #httpsCertificate: /etc/ssl/certs/www.example.com.crt
  #httpsCertificateKey: /etc/ssl/private/www.example.com.key
  logLevel: debug
  buffer: 1024
  plugins: false                # load /usr/lib/<vendor>.so, see "Majestic plugins"
  #telemetry: true              # anonymous install counter (MAC, uptime, chip,
                                # sensor, flash/SD size) sent as a DNS query
  #unsafe: false                # true disables ALL authentication
  #staticDir: /var/www          # where the web interface is served from

# (platform-dependent) Most of this section is per-vendor; the platforms that
# read each key are noted. A key your build does not have answers 404.
isp:
  #sensorConfig: /etc/sensors/imx222_1080p_line.ini   # path, or just the sensor name
  antiFlicker: disabled         # disabled | 50 | 60
  #blkCnt: 4
  #drc: 300
  #rawMode: slow                # none | slow | fast
  #iqProfile: <path/to/file>
  #lowDelay: false
  #awbMode: auto                # auto|manual|day|cloudy|incandescent|
                                # flourescent|twilight|shade|warm|custom
  #memMode: reduction           # normal | reduction        (HiSilicon/Goke)
  #slowShutter: disabled        # disabled|low|medium|high  (HiSilicon/Goke)
  #dis: false                   # digital stabilisation     (HiSilicon/Goke, Ingenic)
  #wdr: 0                       #                           (SigmaStar)
  #edgeGain: false              #                           (SigmaStar)
  #iqServer: false              #                           (SigmaStar)
  #pad: 0                       #                           (SigmaStar)
  #yuvCompression: auto         # HiSilicon gen 3/4 only; saves ~1/3 of the main
                                # frame buffer, ignored with rotate/mirror/masks
  # Manual exposure and gain. Each is skipped when absent, so leaving it out
  # keeps the automatic behaviour.
  #exposure: 0                  #                (HiSilicon/Goke, SigmaStar, Ingenic)
  #aGain: 0                     #                (HiSilicon/Goke, SigmaStar)
  #dGain: 0                     #                (HiSilicon/Goke)
  #ispGain: 0                   #                (HiSilicon/Goke)

image:
  mirror: false
  flip: false
  rotate: 0                     # 0 | 90 | 270
  contrast: 50
  hue: 50
  saturation: 50
  luminance: 50
  #tuning: false                # automatic image tuning

video0:
  enabled: true
  codec: h264                   # h264 | h265
  #size: 1920x1080
  fps: 20
  bitrate: 4096
  rcMode: vbr                   # cbr | vbr | avbr
  #profile: main                # base | main | high
  gopSize: 1.0
  #gopMode: normal              # normal | dual | smart
  #adjustBitrate: true          # may a WebRTC viewer on a thin link lower this
                                # channel's rate; turn off for a channel feeding
                                # an NVR, a recorder or an outgoing publisher
  #osd: true                    # draw the overlay on THIS stream. The overlay is
                                # rendered per stream and sized for this stream's
                                # own frame, so turning it off here leaves the
                                # other streams stamped. Privacy masks are not
                                # affected — see "On-screen display and privacy
                                # masks"
  #svct: off                    # off | 2x | 4x — see "Majestic encoder tuning"
  # Encoder reference structure. Every P frame references the keyframe, so
  # one lost frame costs one frame. Wants a SHORT gopSize (~1.0). See
  # "Majestic encoder tuning". Each key here is skipped when absent, so
  # leaving it out changes nothing.
  #refEnhance: 0
  #refPred: false
  # SigmaStar, video0 only: cyclic intra refresh, 3DNR, ROI and ISP bypass
  #intraLine: 8
  #intraQp: false
  #noiseLevel: 2
  #roiRect:
  #  - 0x0x640x360
  #roiQp: "-5"
  #bypass: 0
  #crop: 0x0x960x540
  # Split a picture into several NAL slices, so one lost packet costs part of a
  # frame instead of all of it.
  #sliceUnits: 4                # macroblock rows per slice (HiSilicon/Goke, SigmaStar)
  #sliceBytes: 0                # target bytes per slice; wins over sliceUnits
                                # when both are set          (HiSilicon/Goke)
  # Quantiser bounds. The defaults are per-vendor — read them back from
  # /api/v1/config.json rather than assuming the numbers here.
  #minQp: 28
  #maxQp: 42

video1:
  enabled: false
  codec: h264
  size: 704x576
  fps: 15
  #osd: true                    # as video0.osd, and on by default here too: a
                                # sub stream carries the overlay unless this is
                                # turned off
  # video1 takes the same keys as video0

jpeg:
  enabled: true                 # JPEG as a whole. false frees the snapshot
                                # channel's frame, but /image.jpg then answers
                                # 503 and /mjpeg is unavailable -- ONVIF
                                # snapshots and the WebUI preview with them
  qfactor: 50
  fps: 5                        # MJPEG stream only
  #size: 160x120                # applies to /mjpeg AND /image.jpg
  #osd: true                    # burn the OSD into JPEG output, sized for the
                                # snapshot's own frame rather than the main
                                # stream's
  rtsp: false                   # also publish MJPEG over RTSP (max 2040 px/axis)
  #tuned: off                   # HiSilicon/Goke only: largest /image.jpg?width=...
                                # to serve, e.g. 1920x1080. Needs a restart.
  #toProgressive: false         # Ultimate only: send /image.jpg progressively,
                                # so a slow link paints a whole coarse picture
                                # first instead of a sharp band at a time. Same
                                # image, ~5% smaller, and costs CPU per snapshot

osd:
  enabled: false                # the TEXT overlay. Privacy masks below are not
                                # part of it and do not need it. Which streams
                                # get the text is then video0.osd / video1.osd /
                                # jpeg.osd, each on by default
  font: /usr/share/fonts/truetype/UbuntuMono-Regular.ttf
  template: "%d.%m.%Y %H:%M:%S"
  #size: "1.0"                  # font scale factor
  #weight: normal               # normal | thin
  #outline: true
  #bgAlpha: 25                  # plate opacity, 0-100
  # Placement. anchor: proportional (the default) uses posX/posY on their
  # -16..16 scale; any other anchor uses offsetX/offsetY, measured inward from
  # that corner or edge. An axis the anchor centres ignores its offset.
  #anchor: proportional         # proportional | top-left | top | top-right |
                                # left | center | right | bottom-left | bottom |
                                # bottom-right
  #offsetX: "0"
  #offsetY: "0"
  posX: 16
  posY: 16
  # Rectangles of the picture to black out, written against the MAIN stream's
  # frame and scaled into each of the others. They cover every stream that is
  # running -- both video channels and the snapshot -- and a rectangle covering
  # nothing is ignored. See "On-screen display and privacy masks" for what each
  # SoC family can and cannot do.
  #privacyMasks: 0x0x234x640,2124x0x468x1300

# (build-dependent: absent from FPV builds)
audio:
  enabled: false
  volume: 30                                              # 0 mutes the input
  #gain: 0                                                # 0-31, analogue gain
  srate: 8000                                             # 8000|16000|32000|48000
  codec: opus                   # opus | aac | pcm | alaw | ulaw (| mp3, Ultimate)
  outputEnabled: false
  outputVolume: 30
  #outputGain: 0
  #speakerPin: 32
  #speakerPinInvert: false
  #inputChannel: 0
  #jitterBufferMs: 80           # RTSP back-channel: 0 = passthrough (LAN),
                                # 80 helps over Wi-Fi/WAN

# (build-dependent: Ultimate, and only on some SoCs — see "Microphone
# processing (VQE)" in Majestic streamer). Runs on the capture channel, so one
# setting reaches RTSP, SIP, WebRTC, the /audio.* endpoints and recordings
# alike. All of it is inside the audio: section above.
  #vqe: false                   # master switch for the three stages below
  #anr: true                    # noise reduction (8/16 kHz only)
  #anrIntensity: 25             # 0-25
  #anrNoiseThreshold: 41        # 30-60 dB
  #agc: true                    # automatic gain control
  #agcTargetLevel: -1           # -40..-1 dBFS
  #agcNoiseFloor: -42           # dBFS; -65..-20 at 8/16 kHz, -50..-20 at 48 kHz
  #agcMaxGain: 20               # 0-30 dB
  #hpf: true                    # high-pass filter
  #hpfFreq: 80                  # 80 | 120 | 150 Hz; 48 kHz has 80 only

rtsp:
  enabled: true
  port: 554
  #alias1: cam/realmonitor      # extra URL path that selects stream 1
  #alias2: cam/substream        # extra URL path that selects stream 2
  #backchannel: false           # ONVIF Profile T talkback (needs audio output)
  #audioCodec: ""               # override audio.codec for RTSP only

nightMode:                      # see en/ircut-filter.md for how the filter is
                                # actually driven, and what the metrics mean
  lightMonitor: false           # on alone = automatic exposure-based day/night
                                # (sensor pin wins if set; both thresholds win
                                # over automatic)
  #irCutEnabled: true           # false parks the filter: pins kept, not driven
  #irCutPin1: 1                 # the two coils of one H-bridge, not two
  #irCutPin2: 2                 # switches — order decides which way it moves
  irCutSingleInvert: false      # for a board with a single coil pad
  #backlightEnabled: true       # false parks the lamp: wiring kept, stays dark
  #backlightPin: 65
  colorToGray: true
  #overrideDrc: 300
  #minThreshold: 2000           # compared against isp_again, whose units are
  #maxThreshold: 5000           # per-SoC: read your own before choosing
  #lightSensorPin: 62
  lightSensorInvert: false
  #monitorDelay: 30             # seconds, 0-60
  #autoNightGain: 16            # automatic mode: night at this gain multiple;
                                # unset = night when the exposure runs out
  #autoDayGain: 2               # automatic mode: day at or below this multiple
  #autoNightDelay: 15           # seconds of darkness before night, 5-600
  #autoDayDelay: 60             # seconds of brightness before day, 5-600
  #backlightPwmChannel: none    # none | pwm1 | pwm3 — a dimmable lamp on a PWM
                                # pad; EV200/EV300 and GK7205V200/V500 only,
                                # backlightPin is then ignored
  #backlightPwmFreq: 400        # Hz, 50-20000
  #backlightPwmMin: 10          # duty floor, % — LEDs have an ignition threshold
  #backlightPwmMax: 100         # duty ceiling, %

# Motion runs /usr/sbin/motion.sh, and — with records.mode below — can record a
# clip per event. There is no "exclude" key: roi says where motion counts, and
# nothing says where it does not.
motionDetect:
  enabled: false
  visualize: false              # draw a box around what moved. On SigmaStar this
                                # and osd.privacyMasks cannot both be drawn; if
                                # masks are set the masks are kept and the boxes
                                # are not drawn
  debug: false                  # a log line per detection — several a second
  #roi: 1854x1304x216x606,1586x1540x482x622
  #sensitivity: 3               # 0-8

# path is a DIRECTORY and filename is the base name; the extension is added by
# Majestic. Both are strftime patterns, expanded when a file is opened. Older
# configs that put the whole filename in `path` produce a directory of that
# name — split them.
records:
  enabled: false
  path: /mnt/mmcblk0p1/%F       # -> /mnt/mmcblk0p1/2026-08-27/
  filename: "%H-%M"             # -> 14-30.mp4. Add %S for second precision
  maxUsage: 95                  # delete the oldest clips above this, %
  #split: 20                    # minutes per file, 1-100. A clip is cut at the
                                # next keyframe after the split falls due, so it
                                # can run up to one gopSize long
  #substream: false             # record video1 instead of video0
  #notime: false                # ignore filename, number files 00000.mp4 upward
  #audioCodec: ""               # mp3 | aac | opus; empty follows audio.codec
  #key: ""                      # XOR-obfuscate the payload; names files .enc

  # When to record. "continuous" is the default and records without stopping;
  # "motion" writes one clip per detection and nothing in between, and needs
  # motionDetect.enabled. See "Recording on motion" in majestic-streamer.md —
  # in particular, set video0.gopSize at or below preRollSec or the run-up is
  # mostly discarded.
  #mode: continuous             # continuous | motion
  #preRollSec: 5                # seconds kept from BEFORE the trigger, in RAM
  #postRollSec: 10              # seconds kept after movement stops
  #minClipSec: 3                # shortest a motion clip may be

  # Housekeeping and durability. The defaults suit an SD card; there is rarely
  # a reason to change them.
  #purgeSeconds: 60             # how often free space is checked and the oldest
                                # clips deleted. Used to follow `split`, so a
                                # camera writing 20-minute files looked three
                                # times an hour
  #syncSeconds: 30              # how often the open clip is committed to the
                                # card, which bounds what a power cut costs.
                                # 0 disables it; a clip is still committed when
                                # it is closed
  #fragmentMs: 1000             # how much video one MP4 fragment holds. Also
                                # the unit the recorder buffers and drops
  #fragmentBytes: 0             # hard size limit for one fragment; 0 derives it
                                # from the bitrate

outgoing:
  enabled: false
  #server: udp://192.168.1.10:5600
  #naluSize: 1200
  #substream: false                                       # publish video1
  #thinEnhance: false                                     # send the SVC-T base layer only
  #audioCodec: ""                                         # RTMP audio codec (aac|alaw|ulaw|pcm); empty follows audio.codec
  #audioSource: auto                                      # auto|mic|silence|file|none; silence/file feed a track when there is no microphone
  #audioFile: ""                                          # ADTS .aac looped when audioSource is file
  # Several destinations (majestic.yaml only, not available in the WebUI). Each
  # entry is its own connection: udp/unix as RTP, rtmp/rtmps as RTMP.
  # rtmp/rtmps needs a Lite or Ultimate build; udp/unix work everywhere.
  #servers:
  #  - udp://IP:port
  #  - unix:/tmp/rtpstream.sock
  #  - rtmps://dc4-1.rtmp.t.me/s/mykey

watchdog:
  enabled: true
  timeout: 300

# HLS and records are mutually exclusive — turning records on turns this off.
hls:
  enabled: false
  #segments: 4                  # finished segments held for clients, 2-8. Each
                                # is a copy of that much video in RAM, so this
                                # is memory; nothing is allocated while HLS is off

mdns:
  enabled: true                 # answers for openipc.local and <hostname>.local

onvif:
  enabled: true
  #username: root
  #password: ""                 # opt-in CLEARTEXT pair, only for clients that
                                # need WSSE PasswordDigest or HTTP Digest

ipeye:
  enabled: false
  #model: ""

netip:
  enabled: false
  #user: admin
  #password: 6V0Y4HLF
  #port: 34567
  #snapshots: true
  #ignoreSetTime: false

# (build-dependent: Lite and Ultimate)
cloud:
  enabled: false
  #host: ""                     # empty keeps the built-in default
  #port: 0

# (build-dependent: Lite and Ultimate)
#sip:
  #enabled: false
  #server: pbx.example.com
  #port: 5060
  #username: doorbell
  #password: secret
  #localUri: ""
  #callTarget: sip:100@pbx.example.com   # several, comma-separated, are allowed
  #localIp: ""                 # goes into Via/Contact; must be routable back
  #localPort: 5060
  #doRegister: true
  #registerExpires: 3600        # seconds, 60-86400; refreshed at expires-60
  #buttonPin: 0                 # GPIO wired to the doorbell button
  #buttonActiveLow: true
  #rtpPortHint: 5004            # start of the local RTP port scan
  #ringMode: sequential         # several targets: sequential | parallel
  #ringSeconds: 10              # 1-300
  #ringCycles: 3                # 0-100 passes over the target list; 0 = forever

  # Who may call this camera. A camera that registers already trusts its
  # registrar and refuses everyone else, so these are for deployments with no
  # registrar to trust. See "Who may call the camera" in Majestic streamer.
  #allowedPeers: ""             # addresses allowed to call in, e.g.
                                # "192.168.1.50, 192.168.9.0/24"
  #authInbound: false           # ask everyone else for a password instead
  #inboundUser: ""              # falls back to sip.username
  #inboundPassword: ""          # falls back to sip.password

# (build-dependent: Lite and Ultimate)
#webrtc:
  # https://www.w3.org/TR/webrtc/#rtciceserver-dictionary with optional
  # '?transport=udp' or '?transport=tcp'. A list, separated by commas or
  # spaces. Unset means stun:stun.cloudflare.com:3478, which was measured to
  # answer from networks where the older Google and AWS defaults stayed silent.
  # Set it to 'none' to stop the camera contacting anyone.
  #iceServers: stun:stun.cloudflare.com:3478, turn:relay.example:3478
  # Required alongside any turn:/turns: entry. Without both, a browser refuses
  # to build the connection at all, so an unauthenticated relay is dropped from
  # the list rather than handed over.
  #turnUsername:
  #turnCredential:

# fpv.enabled switches the SigmaStar FPV path on, and also disables
# userspace 3A. The encoder knobs it used to gate now live per channel,
# under video0/video1 with the rest of them.
#fpv:
  #enabled: false
```

### See also

- [Majestic streamer](majestic-streamer.md) — endpoints, HTTP API, build flavours
- [On-screen display and privacy masks](majestic-streamer.md#on-screen-display-and-privacy-masks)
  — which streams get the overlay, and what masks do on each SoC family
- [Majestic encoder tuning](majestic-encoder-tuning.md) — `refEnhance`, `refPred`, `svct`, ROI
- [Majestic plugins](majestic-plugins.md) — what `system.plugins` turns on
