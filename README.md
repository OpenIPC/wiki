OpenIPC Wiki
============

> "Improving the world, one patch at a time."

## Table of Content

### Introduction

- [About the project](en/menu-index.md)
- [Supported devices](en/guide-supported-devices.md)
- [Supported sensors per SoC](en/guide-supported-sensors.md)
- [Changelog](en/show-changelog.md)

### Installation

- [Detailed installation guide](en/installation.md)
- [Installation on Goke](https://openipc.org/cameras/vendors/goke)
- [Installation on HiSilicon](https://openipc.org/cameras/vendors/hisilicon)
- [Installation on Ingenic](https://openipc.org/cameras/vendors/ingenic)
- [Installation on Novatek](https://openipc.org/cameras/vendors/novatek)
- [Installation on SigmaStar](https://openipc.org/cameras/vendors/sigmastar)
- [Installation on XM510/XM530](https://openipc.org/cameras/vendors/xiongmai)
- [Old installation guides](en/old-installation.md)
- [Very old full manual](en/old-manual.md)

### Usage

- [Network settings](en/network-settings.md)
- [Adding a wifi driver to your firmware](en/adding-wifi-driver.md)
- [Wireless settings](en/wireless-settings.md)
- [System features](en/system-features.md)
- [Majestic streamer](en/majestic-streamer.md)
- [Majestic example config](en/majestic-config.md)
- [Majestic usage research](en/majestic-research.md)
- [Web interface](en/web-interface.md)
- [Upgrade firmware](en/sysupgrade.md)
- [Image quality tuning](en/image-quality-tuning.md)
- [Memory tuning](en/memory-tuning.md)
- [Using ipctool](en/example-ipctool.md)
- [Board specific GPIO settings list](en/gpio-settings.md)
- [ACMEv2](en/acme-v2.md)
- [YouTube streaming](en/youtube-streaming.md)
- [WiFi XM530](en/wifi-xm530.md)
- [HomeKit integration](en/homekit-integration.md)
- [Automatic night mode without light sensor](en/auto-night-mode-without-light-sensor.md)
- [ZeroTier setup](en/zerotier.md)

### FPV

- [Frequently Asked Question (FAQ) for FPV](en/fpv-faq.md)
- [General Info](en/fpv-general.md)
- [OpenIPC AIO "Mario"](en/fpv-openipc-aio-mario.md)
- [OpenIPC AIO "UltraSight"](en/fpv-openipc-aio-ultrasight.md)
- [OpenIPC AIO "Thinker"](en/fpv-openipc-aio-thinker.md)
- [Guide to configure an FPV camera and groundstation](en/fpv-step-by-step-guide.md)
- [Steps from buy to fly](en/fpv-from-buy-to-fly.md)
- [OpenIPC as FPV system](en/fpv.md)
- [Sigmastar FPV devices](en/fpv-sigmastar.md)
- [OpenIPC Alliance for FPV](en/fpv-openipc-alliance.md)
- [Ubuntu based groundstation](en/fpv-gs-ubuntu.md)
- [OrangePI 5 Ubuntu based groundstation](en/fpv-ground-orange_pi5.md)
- [An Orange Pi 5 minimal VRX for Goggles](en/fpv-orange-pi-5-groundstation.md)
- [A selection of OpenIPC videos on YouTube](en/fpv-youtube.md)
- [RunCam WiFiLink based on OpenIPC](en/fpv-runcam-wifilink-openipc.md)
- [Radxa based groundstation](en/fpv-radxa.md)
- [The mavfwd tool](en/fpv-mavfwd.md)

### Troubleshooting

- [Network does not work on hi35xx](en/trouble-network-hi35xx.md)
- [Majestic does not work, camera reboots](en/trouble-majestic.md)
- [Sigmastar unbrick instructions](en/sigmastar-unbrick.md)
- [Ingenic T31 unbrick with SD card](en/ingenic-t31-unbrick-with-sd-card.md)

### Equipment

- [Equipment for flashing](en/equipment-flashing.md)
- [CH341A programmer voltage fix](en/hardware-programmer-ch341a-voltage-fix.md)
- [Flash Chip Interfacing](en/flash-chip-interfacing.md)

### Development

- [Boot device with NFS](en/dev-nfs-boot.md)
- [FFMPEG usage](en/dev-ffmpeg-usage.md)
- [Kernel configuration for adding new platforms](en/integration-kernel.md)
- [List of supported sensors](en/firmware-sensors.md)
- [Visual sensor identification](en/visual_sensor_identification.md)
- [List of OpenIPC Buildroot packages](en/dev-buildroot-packages.md)
- [Firmware development guide](en/source-code.md)
- [Bug reports](https://github.com/OpenIPC/firmware/issues)
- [Buildroot User Manual](https://buildroot.org/docs.html)
- [U-Boot Documentation](https://u-boot.readthedocs.io/)

### Help, Tips, and Tricks

- [Frequently Asked Question (FAQ)](en/faq.md)
- [U-Boot Tips](en/help-uboot.md)
- [Web UI Help](en/help-webui.md)
- [Live streaming to Telegram](en/howto-streaming-telegram.md)
- [Interesting tricks](en/dev-tricks.md)
- [Glossary](en/glossary.md)

### Hardware

- [SoC manufacturers](en/hardware-soc-manufacturers.md)
- [Image sensors manufacturers](en/hardware-sensor-manufacturers.md)
- [IPC boards manufacturers](en/hardware-board-manufacturers.md)

### Cameras

- [AHD2NET converter](en/device-ahd2net-converter.md)
- [Chacon IPCAM-RI01](en/device-chacon-ipcam-ri01.md)
- [Smartwares CIP-37210](en/device-smartwares-cip-37210.md)
- [Foscam X5](en/device-foscam-x5.md)
- [TP-Link Tapo C110](en/device-tapo-c110.md)
- [Xiaomi Mi Camera 2K (MJSXJ03HL)](https://github.com/OpenIPC/device-mjsxj03hl/)
- [ATOM Cam / Hualai / Wyze](en/device-wyze-integration.md)
- [Digitus DN-16048 Optizoom](en/device-digitus-dn16048.md)
- [XiongMai IPG-53H20AF](en/device-ipg-53h20af.md)
- [LSC Smart Connect Video Doorbell (2021)](en/device-lsc-smart-connect-video-doorbell-2021.md)

### Software

- [List of Software for Recording Video](en/software-video-recording.md)

### Packages

- [Vtun](en/package-vtun.md)
- [WireGuard](en/package-wireguard.md)

### Subprojects

- [coupler](https://openipc.org/coupler)
- [firmware](https://openipc.org/firmware)
- [ipctool](https://openipc.org/ipctool)
- [telemetry](https://openipc.org/telemetry)
- [Firmware Partitions Calculation](https://themactep.com/tools/firmware-partitions-calculation)

### Our resources

- [OpenIPC](https://openipc.org/)
- [Releases in GitHub](https://github.com/OpenIPC/firmware/releases/tag/latest)
- [Releases in Telegram](https://t.me/s/openipc_dev)
- [OpenCollective](https://opencollective.com/openipc)
- [Twitter](https://twitter.com/OpenIPC)
- [Telegram](https://t.me/openipc)

### Roadmap

- [ToDo](en/todo-all.md)
- [Developers](en/contribute.md)
- [Notes from old sources](en/notes-for-resorting.md)

### Reference Book

- [Company names](en/company-names.md)
- [Dahua Naming Rule](https://dahuawiki.com/Name_Rule)
- [Hikvision IP Camera Model Naming Convention](https://www.vueville.com/home-security/cctv/ip-cameras/hikvision-network-camera-guide/#model-naming-convention)

### Resources for recycling and integration

- [https://github.com/OpenIPC/camerasrnd](https://github.com/OpenIPC/camerasrnd)
- [https://openwrt.org/docs/techref/hardware/soc/soc.hisilicon.hi35xx](https://openwrt.org/docs/techref/hardware/soc/soc.hisilicon.hi35xx)

In Russian
----------

- [О проекте](ru/about.md)
- [Установка. Шаг за шагом.](ru/installation.md)
- [Настройка.](ru/configuration.md)
- [Модернизация адаптера USB2TT_004 для управления питанием.](ru/usb2ttl.md)
- [Программный переход с openipc-1.0 (OpenWrt) на openipc-2.x (Buildroot)](ru/upgrade-from-1.md)
- [Вопросы и ответы](ru/faq.md)
- [Хочу помочь!](ru/contribute.md)

### Варианты использования

- [Для FPV](ru/fpv.md)
- [Экшн-камера](ru/action-camera.md)
- Астрокамера
- Видеорегистратор

### Помощь

- [Веб-интерфейс](ru/help-webui.md)
- [Настройка отправки в Telegram](/ru/telegram_help_ru.md)

### Камеры

- [Switcam HS-303](ru/hardware-hs303.md)
- [Ростелекомовская камера с NAND](ru/hardware-rtk-nand.md)
- [Полезные ссылки](ru/resources.md)
- [Обзоры камер разных производителей](ru/reviews.md)
- [Hikvision DS-2CD2345F-IS](ru/hikvision-ds-2cd2345f-is.md)
- [Ростелеком IPC-HFW1230SP/IPC-HDW1230SP](ru/rostelecom-ipc-hfw1230sp.md)
- [HiWatch DS-I122](ru/hiwatch-ds-i122.md)

## Что можно прочитать про прошивку OpenIPC?

- [Часто задаваемые вопросы и ответы на них][faq1]
- [Заметки от Олега Левшина][faq3]

## Дискуссии

- [Дискуссия по дорожной карте проекта](ru/discussion-roadmap.md)
- [Дискуссия по watchdog и rtc](ru/discussion-watchdog.md)
- [Дискуссия по версиям Buildroot](ru/discussion-buildroot.md)
- [Дискуссия по проблемам и поддержке SPI FLASH](ru/discussion-flash.md)
- [Темы для дискуссий разработчиков](ru/discussion.md)

#### This is an open project, so you can help, too.

We try to collect, organize and share as much information regarding different
aspects of the project as we can. But sometimes we overlook things that seem
obvious to us, developers, but are not so obvious to end-users, people who are
less familiar with nuts and bolts behind the scene. That is why we set up this
wiki and let anyone having a GitHub account to make additions and improvements
to the knowledgebase. Read [How to contribute.](en/contribute.md)

[faq1]: https://github.com/OpenIPC/camerasrnd/blob/master/doc/XM-FAQ-ru.md
[faq3]: https://alarmsystem-cctv.ru/openipc-%D0%BE%D1%82%D0%BA%D1%80%D1%8B%D1%82%D1%8B%D0%B9-%D0%BA%D0%BE%D0%BB%D0%BB%D0%B5%D0%BA%D1%82%D0%B8%D0%B2/
[logo]: images/logo_openipc.png
