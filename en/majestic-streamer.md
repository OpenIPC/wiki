# OpenIPC Wiki
[Table of Content](../README.md)

Majestic Streamer
-----------------

### Preamble

Majestic is a video streaming application, the heart of our firmware (in
relation to camera/video surveillance functionality). Majestic is configurable
via /etc/majestic.yaml file, and has many features/services enabled by default.
Unneeded options can be switched off for better security and performance. See /etc/majestic.full for configuration options.

### User levels in the system

At the moment, the access has two level in system:

**root** - the main system user, whose name and password are identical when logging into the system via SSH and WEB, there are no restrictions.

**viewer** - a user with limited rights who is denied access via SSH and WEB. The user can only receive RTSP requiring authorization. 
Update by 2024.11.08 - in the near future we will also give him the ability to watch all media resources available on the WEB port, and also 
control the /night/toggle switch, but the login to the interface itself will still be prohibited. 
We might also add a specific path to the directory of scripts that it will be allowed to execute
```
adduser viewer -s /bin/false -D -H ; echo viewer:123456 | chpasswd
```

### Control signals

```
-HUP restart Majestic (Except Ingenic T21).
-SIGUSR2 SDK Shutdown (For all platforms).
```

### Camera related URLs in firmware

Majestic supports multiple audio, video and still image formats, and more.
You can find the full list of available endpoints on [this page](https://openipc.org/majestic-endpoints).

The long JPEG control parameter did not fit into the example on the site and we publish it here:

`/image.jpg?width=640&height=360&qfactor=73&color2gray=1`

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

```
/metrics/isp
/metrics/venc
/metrics/motion
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
Works only for simple day/night schemes with minimal configuration and in the absence of mentions of irSensorPin in the majestic.yaml configuration file.
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

### Motion detection

Motion detect is supported for Hisilion/Goke, Ingenic and Sigmastar.
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

Reboot the camera and restart `majestic` in the foreground:

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
reboot
```

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

For basic ONVIF to work correctly, you need to enable it and add a user to the system as shown in the example:

```
curl 'http://localhost/api/v1/set?onvif.enabled=true'
adduser viewer -s /bin/false -D -H
echo viewer:123456 | chpasswd
```

### JPEG and MJPEG

For the purpose of unification and standardization for all platforms, as well as to increase the stability of the streamer, the image size will always be equal to the size on the Video0 channel and a separate setting is not provided.

###  ROI

Detection zones of two types:

`motionDetect.roi: 1854x1304x216x606,1586x1540x482x622`

`motionDetect.skipIn: 960x540x1920x1080`

**roi** - region of interest, when we specify one or more regions whose movements we are interested in.

**skipIn** - on the contrary, if we are interested in movements on the whole screen, except for some areas (for example, there is a tree in the frame, which is swaying in the wind).

Coordinate format is the same as in osd.privacyMasks: x,y of the top left point, length and width in pixels.

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

### How to create an audio file to play on camera's speaker over network

Using [sox][sox] program convert any source audio file to [PCM][pcm] 8kbps audio:
```
sox speech.mp3 -t raw -r 8000 -e signed -b 16 -c 1 test.pcm
```

### How to play audio file on camera's speaker over network

```
curl -u root:12345 --data-binary @test.pcm http://192.168.1.10/play_audio
```

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
[raw]: https://en.wikipedia.org/wiki/Raw_image_format
[rtsp]: https://en.wikipedia.org/wiki/RTSP
[ulaw]: https://en.wikipedia.org/wiki/%CE%9C-law_algorithm
[yuv]: https://en.wikipedia.org/wiki/YUV
[ffplay]: https://ffmpeg.org/ffplay.html
[ffmpeg]: https://ffmpeg.org/
[sox]: https://en.wikipedia.org/wiki/SoX
