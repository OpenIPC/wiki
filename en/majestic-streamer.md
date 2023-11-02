# OpenIPC Wiki
[Table of Content](../README.md)

Majestic Streamer
-----------------

### Preamble

Majestic is a video streaming application, the heart of our firmware (in
relation to camera/video surveillance functionality). Majestic is configurable
via /etc/majestic.yaml file, and has many features/services enabled by default.
Unneeded options can be switched off for better security and performance. See /etc/majestic.full for configuration options.

### Camera related URLs in firmware

Majestic supports multiple audio, video and still image formats, and more.
You can find the full list of available endpoints on [this page](https://openipc.org/majestic-endpoints).

The long JPEG control parameter did not fit into the example on the site and we publish it here:

`/image.jpg?width=640&height=360&qfactor=73&color2gray=1`

### Changing parameters via cli

At the moment it is possible to change parameters in the configuration file via the CLI utility.

This allows parameters to be changed with a single line in pseudo-dynamic mode on some platforms 
simply by forcing a re-read of the configuration file.
```
cli -s .video0.codec h264 ; cli -s .video0.fps 10 ; killall -1 majestic 
```

### Auto day/night detection

The experiments continue...

### Motion detection

Motion detect is supported for Hisilion/Goke, Ingenic and Sigmastar, the script file needs to be located at:
`/etc/motion_detect.sh`

The following will be executed on a motion event:
```
/etc/motion_detect.sh [object count] [x coordinate] [y coordinate] [region width] [region height]
```

Example script:
```
#!/bin/sh
echo [$0] [$1] [$2] [$3] [$4] [$5]
```

Final result:
```
20:37:02  <SED_IVE_DETCTOR> [  motion] motion_update@155             Motion detected: [1163x0] -> [690x475]
20:37:02  <SED_IVE_DETCTOR> [   tools] motion_event@615              Execute motion script: /etc/motion_detect.sh
[/etc/motion_detect.sh] [1] [1163] [0] [690] [475]
```

More info:
- https://github.com/OpenIPC/majestic/issues/28
- https://github.com/OpenIPC/majestic/issues/117

The experiments continue...

### Broadcasts using RTMP

To instantly launch a YouTube broadcast, run these commands in the console:
```
cli -s .video0.codec h264
cli -s .audio.enabled true
cli -s .outgoing.enabled true
cli -s .outgoing.server rtmp://upload.rutube.ru/live_push/you-key-here
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

We ask that you add information about other popular services here, thank you.

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
cat test.pcm | curl -v -u user:password -H "Content-Type: application/json" -X POST --data-binary @- http://192.168.1.10/play_audio
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
