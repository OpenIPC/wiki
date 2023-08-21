![OpenIPC logo][logo]

## OpenIPC settings

[![OpenIPC][site]][site_basic]  [![Telegram][chat]][telegram_en]

**This page is personal notes by @zigfisher for public reading only and may not be edited by others**

### Device table for customization


* [ssc30kq-imx335-anjoy](#ssc335-imx307-anjoy)
* [ssc335-imx307-anjoy](#ssc335-imx307-anjoy)
* [ssc335de-imx335-anjoy](#ssc335de-imx335-anjoy)
* [t31l-sc2335-camhi](#t31l-sc2335-camhi)


-------


### gk7205v200-?-xiongmai

Board names: G3-0625

```
cli -s .system.staticDir /var/www/majestic
cli -s .nightMode.enabled true
cli -s .nightMode.irCutPin1 9
cli -s .nightMode.irCutPin2 8
cli -s .video0.codec h264
cli -s .hls.enabled false
```


### ssc30kq-imx335-anjoy

Board names: MC-L12, MC-L12B

```
cli -s .system.staticDir /var/www/majestic
cli -s .nightMode.enabled true
cli -s .nightMode.irCutPin1 23
cli -s .nightMode.irCutPin2 24
cli -s .video0.codec h264
cli -s .video0.size 1280x720
cli -s .video0.fps 60
cli -s .hls.enabled false
```


### ssc335-imx307-anjoy

Board names: MS-J10

```
cli -s .system.staticDir /var/www/majestic
cli -s .nightMode.enabled true
cli -s .nightMode.irSensorPin 61
cli -s .nightMode.irSensorPinInvert false
cli -s .nightMode.irCutPin1 78
cli -s .nightMode.irCutPin2 79
cli -s .video0.codec h264
cli -s .video0.size 1920x1080
cli -s .video0.fps 30
cli -s .hls.enabled false
```


### ssc335de-imx335-anjoy

Board names: MC500L8

```
cli -s .system.staticDir /var/www/majestic
cli -s .nightMode.enabled true
cli -s .nightMode.irSensorPin 61
cli -s .nightMode.irSensorPinInvert false
cli -s .nightMode.irCutPin1 78
cli -s .nightMode.irCutPin2 79
cli -s .video0.codec h264
cli -s .video0.size 1920x1080
cli -s .video0.fps 30
cli -s .hls.enabled false
```


### t31l-sc2335-camhi

Board names: 2G-M2122

```
cli -s .system.staticDir /var/www/majestic
cli -s .nightMode.enabled true
cli -s .nightMode.irCutPin1 58
cli -s .nightMode.irCutPin2 57
cli -s .video0.codec h264
cli -s .hls.enabled false
cli -s .isp.blkCnt 1
```



[logo]: https://openipc.org/assets/openipc-logo-black.svg
[chat]: https://openipc.org/images/telegram_button.svg
[site]: https://openipc.org/images/openipc_button.svg
[site_basic]: https://openipc.org
[telegram_en]: https://t.me/OpenIPC
