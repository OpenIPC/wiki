![OpenIPC logo][logo]

## OpenIPC settings

[![OpenIPC][site]][site_basic]  [![Telegram][chat]][telegram_en]

**This page is personal notes by @zigfisher for public reading only and may not be edited by others**

### Device table for customization

* Anjoy
    * [ssc30kq-imx335-anjoy](#ssc335-imx307-anjoy)
    * [ssc335-imx307-anjoy](#ssc335-imx307-anjoy)
    * [ssc335de-imx335-anjoy](#ssc335de-imx335-anjoy)


-------


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
cli -s .watchdog.enabled false
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
cli -s .watchdog.enabled false
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
cli -s .watchdog.enabled false
```


[logo]: https://openipc.org/assets/openipc-logo-black.svg
[chat]: https://openipc.org/images/telegram_button.svg
[site]: https://openipc.org/assets/openipc_button.svg
[site_basic]: https://openipc.org
[telegram_en]: https://t.me/OpenIPC
