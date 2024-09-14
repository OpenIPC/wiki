# OpenIPC Wiki
[Table of Content](../README.md

Majestic Usage Research
-----------------------

### RTMP services

- [go2rtc](https://github.com/AlexxIT/go2rtc)
- [libnginx-mod-rtmp](https://github.com/arut/nginx-rtmp-module)
- [MediaMTX](https://github.com/bluenviron/mediamtx)
- [OvenMediaEngine](https://github.com/AirenSoft/OvenMediaEngine)
- [HappyTime Media Server](https://www.happytimesoft.com/products/media-server/index.html)
- [OSS SRS](https://ossrs.io/)
- [Wowza](https://www.wowza.com/)

### Testing

```
SRS:
docker run --rm -it -p 1935:1935 -p 1985:1985 -p 8080:8080 ossrs/srs:6 objs/srs -c conf/docker.conf

Outgoing (with H265 codec):
rtmp://192.168.1.85/openipc/live

FFMpeg:
ffplay rtmp://192.168.1.85/openipc/live
```
