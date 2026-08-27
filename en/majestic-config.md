# OpenIPC Wiki
[Table of Content](../README.md)

Majestic example config
-----------------------
```
system:
  webPort: 80
  httpsPort: 443
  #httpsCertificate: /etc/ssl/certs/www.example.com.crt
  #httpsCertificateKey: /etc/ssl/private/www.example.com.key
  logLevel: debug
  buffer: 1024
  plugins: false

isp:
  #sensorConfig: /etc/sensors/imx222_1080p_line.ini
  antiFlicker: disabled
  #blkCnt: 4
  #drc: 300
  #rawMode: slow
  #iqProfile: <path/to/file>
  #lowDelay: false
  #awbMode: auto
  #memMode: reduction
  #slowShutter: disabled
  #dis: false

image:
  mirror: false
  flip: false
  rotate: 0
  contrast: 50
  hue: 50
  saturation: 50
  luminance: 50

video0:
  enabled: true
  codec: h264
  #size: 1920x1080
  fps: 20
  bitrate: 4096
  rcMode: vbr
  gopSize: 1.0
  #gopMode: normal
  #svct: off
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
  #sliceUnits: 4
  #minQp: 12
  #maxQp: 42

video1:
  enabled: false
  codec: h264
  size: 704x576
  fps: 15

jpeg:
  enabled: true
  qfactor: 50
  fps: 5
  #size: 160x120
  rtsp: false

osd:
  enabled: false
  font: /usr/share/fonts/truetype/UbuntuMono-Regular.ttf
  template: "%d.%m.%Y %H:%M:%S"
  posX: 16
  posY: 16
  #privacyMasks: 0x0x234x640,2124x0x468x1300

audio:
  enabled: false
  volume: 30                                              # 0 mutes the input
  srate: 8000
  codec: opus
  outputEnabled: false
  outputVolume: 30
  #speakerPin: 32
  #speakerPinInvert: false

rtsp:
  enabled: true
  port: 554

nightMode:
  lightMonitor: true
  #irCutPin1: 1
  #irCutPin2: 2
  irCutSingleInvert: false
  #backlightPin: 65
  colorToGray: true
  #overrideDrc: 300
  #minThreshold: 2000
  #maxThreshold: 5000
  #lightSensorPin: 62
  lightSensorInvert: false
  #dncDelay: 30

motionDetect:
  enabled: false
  visualize: false
  debug: false
  #roi: 1854x1304x216x606,1586x1540x482x622
  #skipIn: 960x540x1920x1080
  #sensitivity: 3

records:
  enabled: false
  path: /mnt/mmcblk0p1/%F/%H.mp4
  maxUsage: 95
  #splitRecord: 10

outgoing:
  enabled: false
  #server: udp://192.168.1.10:5600
  #naluSize: 1200
  #audioCodec: ""                                         # RTMP audio codec (aac|alaw|ulaw|pcm); empty follows audio.codec
  #audioSource: auto                                      # auto|mic|silence|file|none; silence/file feed a track when there is no microphone
  #audioFile: ""                                          # ADTS .aac looped when audioSource is file
  # Several destinations (majestic.yaml only, not available in the WebUI). Each
  # entry is its own connection: udp/unix as RTP, rtmp/rtmps as RTMP.
  #servers:
  #  - udp://IP:port
  #  - unix:/tmp/rtpstream.sock
  #  - rtmps://dc4-1.rtmp.t.me/s/mykey

watchdog:
  enabled: true
  timeout: 300

hls:
  enabled: false

onvif:
  enabled: false

ipeye:
  enabled: false

netip:
  enabled: false
  #user: admin
  #password: 6V0Y4HLF
  #port: 34567
  #snapshots: true
  #ignoreSetTime: false

cloud:
  enabled: false

#webrtc:
  # https://www.w3.org/TR/webrtc/#rtciceserver-dictionary with optional
  # '?transport=udp' or '?transport=tcp'. Comma-separated; turn: entries need
  # turnUsername and turnCredential beside them. Unset means
  # stun:stun.cloudflare.com:3478, which was measured to answer from networks
  # where the older Google and AWS defaults stayed silent.
  #iceServers: stun:stun.cloudflare.com:3478
  #turnUsername:
  #turnCredential:

# fpv.enabled switches the SigmaStar FPV path on, and also disables
# userspace 3A. The encoder knobs it used to gate now live per channel,
# under video0/video1 with the rest of them.
#fpv:
  #enabled: false

```
