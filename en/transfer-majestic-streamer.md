## Preamble

Majestic is a video streaming application, the heart of our firmware (in relation to camera/video surveillance functionality). It's configurable via file /etc/majestic.yaml and by default has many features/services enabled. Unneeded options can be turned off for better security and performance.

## Camera related URLs in firmware

With firmware running, you can access the camera using URLs below (192.168.1.10 is an example of camera IP address):

### Live video

* http://192.168.1.10/ - [HLS](https://en.wikipedia.org/wiki/HTTP_Live_Streaming) live streaming is web browser
* http://192.168.1.10/mjpeg.html - [MJPEG](https://en.wikipedia.org/wiki/Motion_JPEG) & [MP3](https://en.wikipedia.org/wiki/MP3) streaming in web browser
* http://192.168.1.10/video.mp4 - [MP4](https://en.wikipedia.org/wiki/MPEG-4_Part_14) video (Fragmented MP4) 
* rtsp://192.168.1.10 - Main channel of [RTSP](https://en.wikipedia.org/wiki/RTSP) stream (section "video0:" in config )
* rtsp://192.168.1.10/stream=1 - Second channel RTSP streamer (section "video1:" in config )

### Still image

* http://192.168.1.10/image.jpg - image snapshot in [JPEG](https://en.wikipedia.org/wiki/JPEG) format

Supports specific image parameters in URL like `/image.jpg?width=640&height=360&qfactor=73&color2gray=1`:
1) `width` and `height` - size of picture to scale original image
2) `qfactor` - JPEG quality factor between 1 and 99
3) `color2gray` - force to grayscale convertion
4) `crop` - crop image in format `16x16x320x320`, where first numbers are left and top image coordinates and others are image width and height

* http://192.168.1.10/image.heif - image snapshot in [HEIF](https://en.wikipedia.org/wiki/High_Efficiency_Image_File_Format) format, use `stream` parameter to specify channel (the same approach as for RTSP channels)
* http://192.168.1.10/image.yuv - image snapshot in [YUV420](https://en.wikipedia.org/wiki/YUV) format

Use `convert -verbose -sampling-factor 4:2:0 -size 1920x1080 -depth 8 image.yuv image.png` to convert to usable format, where `1920x1080` is picture resolution from video0 and `.png` is a target format.

* http://192.168.1.10/image.dng - [raw image](https://en.wikipedia.org/wiki/Raw_image_format) snapshot from sensor in [Adobe DNG](https://en.wikipedia.org/wiki/Digital_Negative) format (only for v>=2 HiSilicon processors)

### Audio input

* http://192.168.1.10/audio.opus - [Opus](https://en.wikipedia.org/wiki/Opus_(audio_format)) audio stream
* http://192.168.1.10/audio.m4a - [AAC](https://en.wikipedia.org/wiki/Advanced_Audio_Coding) audio stream
* http://192.168.1.10/audio.mp3 - [MP3](https://en.wikipedia.org/wiki/MP3) audio stream
* http://192.168.1.10/audio.pcm - Raw [PCM](https://en.wikipedia.org/wiki/Pulse-code_modulation) audio stream

Use `ffplay -f s16le -ac 1 -ar 48k http://192.168.1.10/audio.pcm`, where `48k` is sample rate

* http://192.168.1.10/audio.alaw - [A-law](https://en.wikipedia.org/wiki/A-law_algorithm) compressed audio stream

Use `ffplay -ar 48000 -ac 1 -f alaw http://192.168.1.10/audio.alaw`, where `48000` is sample rate

* http://192.168.1.10/audio.ulaw - [μ-law](https://en.wikipedia.org/wiki/%CE%9C-law_algorithm) compressed audio stream

Use `ffplay -ar 48000 -ac 1 -f mulaw http://192.168.1.10/audio.ulaw`, where `48000` is sample rate

* http://192.168.1.10/audio.g711a - [G.711](https://en.wikipedia.org/wiki/G.711) A-law audio stream

Use `ffplay -ar 8000 -ac 1 -f alaw http://192.168.1.10/audio.g711a`

### Playing audio on camera via network (Hisilicon/Goke only)

`curl -T test.pcm http://10.216.128.66:8888/play_audio`

[pcm](https://en.wikipedia.org/wiki/Pulse-code_modulation) file format can be prepared using [sox] program(https://en.wikipedia.org/wiki/SoX):

`sox speech.mp3 -t raw -r 8000 -e signed -b 16 -c 1 test.pcm`

### API

Night API endpoint (make sure `nightAPI` in `nightMode` is enabled or use it from a camera without restrictions):

* http://192.168.1.10/night/on - Turn on night mode
* http://192.168.1.10/night/off - Turn off night mode (set to day)
* http://192.168.1.10/night/toggle - Toggle current mode

### Monitoring

* http://192.168.1.10/metrics - Standard Node exporter compatible and application-specific metrics for [Prometheus](https://prometheus.io/)