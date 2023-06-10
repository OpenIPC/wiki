Attention News
=====================

This is where the hot news will be posted that you should pay attention to, it's not a changelog

Automatic translation: [English](https://github.com/OpenIPC/wiki/blob/master/en/attention-news.md) | [Russian](https://github-com.translate.goog/OpenIPC/wiki/blob/master/en/attention-news.md?_x_tr_sl=en&_x_tr_tl=ru&_x_tr_hl=en&_x_tr_pto=wapp) | [Chinese](https://github-com.translate.goog/OpenIPC/wiki/blob/master/en/attention-news.md?_x_tr_sl=en&_x_tr_tl=zh-CN&_x_tr_hl=en&_x_tr_pto=wapp)


## 01.06.2023

We updated the Buildroot version, changed the toolchain build system, moved and streamlined configuration files to configure network devices - a lot of changes.

The global changes in the structure of the project caused some devices that use external WiFi modules to stop or stop working after the update.

We kindly ask you to be understanding and until documentation and releases are corrected, please do NOT update at least these types of devices, and maybe others with WiFi:

* Smartwares CIP-37210
* Switcam HS303 v1
* Switcam HS303 v2
* Switcam HS303 v3
* Ezviz (any)
* Xiaomi (any)

If you broke your device, please rollback your firmware to May 1, 2023 or return to the firmware of the [sub-project](https://github.com/topics/device-openipc).

You can get official OpenIPC firmware for the last half year on our [Telegram channel](https://t.me/openipc_dev), they are published automatically.