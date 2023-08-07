![OpenIPC logo][logo]

## OpenIPC settings

[![Telegram][chat]][telegram_en]

**This page is personal notes by @zigfisher for public reading only and may not be edited by others**

### ssc30kq_imx335_anjoy

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


[logo]: https://openipc.org/assets/openipc-logo-black.svg
[chat]: https://openipc.org/images/telegram_button.svg
[telegram_en]: https://t.me/OpenIPC
