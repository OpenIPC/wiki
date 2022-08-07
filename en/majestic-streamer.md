# OpenIPC Wiki
[Table of Content](../index.md)

Majestic Streamer
-----------------

### Preamble

Majestic is a video streaming application, the heart of our firmware (in
relation to camera/video surveillance functionality). Majestic is configurable
via /etc/majestic.yaml file, and has many features/services enabled by default.
Unneeded options can be switched off for better security and performance.

### Camera related URLs in firmware

With firmware running, you can access the camera using URLs below
(192.168.1.10 is an example of camera IP address):

#### Live video

* http://192.168.1.10/hls - [HLS][hls] live streaming is web browser.
* http://192.168.1.10/mjpeg.html - [MJPEG][mjpeg] & [MP3][mp3] streaming in web browser.
* http://192.168.1.10/video.mp4 - [MP4][mp4] video (Fragmented MP4).
* rtsp://192.168.1.10 - Main channel of [RTSP][rtsp] streamer (video0 in config).
* rtsp://192.168.1.10/stream=1 - Second channel of RTSP streamer (video1 in config)

#### Still image

* http://192.168.1.10/image.jpg - image snapshot in [JPEG][jpeg] format.
  Supports specific image parameters in URL, e.g. `/image.jpg?width=640&height=360&qfactor=73&color2gray=1`:
  -`width` and `height` - size of picture to scale original image.
  - `qfactor` - JPEG quality factor between 1 and 99.
  - `color2gray` - force to grayscale conversion.
  - `crop` - crop image in format `16x16x320x320`,
     where first numbers are left and top image coordinates
     and others are image width and height.
* http://192.168.1.10/image.heif - image snapshot in [HEIF][heif] format,
  use `stream` parameter to specify channel (the same approach as for RTSP channels)
* http://192.168.1.10/image.yuv420 - image snapshot in [YUV420][yuv] format.
* http://192.168.1.10/image.dng - [raw image][raw] snapshot from the sensor in
  [Adobe DNG][dng] format (only for v>=2 HiSilicon processors).

##### Tips:

To convert YUV image to a more common image format, use `convert` command from
ImageMagick software. Run it like this:
```
convert -verbose -sampling-factor 4:2:0 -size 1920x1080 -depth 8 image.yuv image.png
```
where `1920x1080` is the picture resolution of video0, and `.png` is the target
image format.

### Audio

* http://192.168.1.10/audio.opus - [Opus][opus] audio stream.
* http://192.168.1.10/audio.m4a - [AAC][aac] audio stream.
* http://192.168.1.10/audio.mp3 - [MP3][mp3] audio stream.
* http://192.168.1.10/audio.pcm - Raw [PCM][pcm] audio stream.
* http://192.168.1.10/audio.alaw - [A-law][alaw] compressed audio stream.
* http://192.168.1.10/audio.ulaw - [μ-law][ulaw] compressed audio stream.
* http://192.168.1.10/audio.g711a - [G.711][g711] A-law audio stream.

##### Tips:

To play audio stream use [ffplay][ffplay] utility from [ffmpeg][ffmpeg] package.

```
ffplay -ar 48000 -ac 1 -f s16le http://192.168.1.10/audio.pcm
ffplay -ar 48000 -ac 1 -f alaw http://192.168.1.10/audio.alaw
ffplay -ar 48000 -ac 1 -f mulaw http://192.168.1.10/audio.ulaw
ffplay -ar 8000 -ac 1 -f alaw http://192.168.1.10/audio.g711a
```

To play audio on camera speaker over network (Hisilicon/Goke only):

```
curl -T test.pcm http://10.216.128.66:8888/play_audio
```

[PCM][pcm] file can be prepared using [sox][sox] program:

```
sox speech.mp3 -t raw -r 8000 -e signed -b 16 -c 1 test.pcm
```

### API

Night API endpoint (make sure `nightMode` is enabled in Majestic config,
or use it from the camera without restrictions):

* http://192.168.1.10/night/on - Turn on night mode.
* http://192.168.1.10/night/off - Turn off night mode (set to day).
* http://192.168.1.10/night/toggle - Toggle current mode.

### Monitoring

* http://192.168.1.10/metrics - Standard Node exporter compatible
  and application-specific metrics for [Prometheus](https://prometheus.io/).


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
