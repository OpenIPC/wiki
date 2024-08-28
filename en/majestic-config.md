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
  volume: 30
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
  lightSensorPinInvert: false
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
  #- udp://IP:port                                        # Multiple data sending is configured only in the /etc/majestic.yaml file and is not available for control from the WebUI
  #- unix:/tmp/rtpstream.sock
  #- rtmps://dc4-1.rtmp.t.me/s/mykey

watchdog:
  enabled: true
  timeout: 300

hls:
  enabled: false

onvif:
  enabled: false

ipeye:
  enabled: false

youtube:                                                  # This function only works with the external daemon plugin for Majestic
  enabled: false
  #key: xxxx-xxxx-xxxx-xxxx-xxxx

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
  # '?transport=udp' or '?transport=tcp'
  #iceServers: stun:stun.kinesisvideo.eu-north-1.amazonaws.com:443

```
