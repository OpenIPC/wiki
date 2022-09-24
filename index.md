OpenIPC Wiki
============

> "Improving the world, one patch at a time."

## Table of Content

### Introduction
- [About the project](en/menu-index.md)
- [Supported devices](en/guide-supported-devices.md)
- [Changelog](en/show-changelog.md)

### Subprojects
- [coupler](https://openipc.org/coupler)
- [firmware](https://openipc.org/firmware)
- [ipctool](https://openipc.org/ipctool)
- [telemetry](https://openipc.org/telemetry)
- [Firmware Partitions Calculation](https://themactep.com/tools/firmware-partitions-calculation)

### Installation
- [Installation, step by step, and overall options](en/installation.md)
- [Installation on Goke based boards](en/install-goke.md), but you'd better use <https://openipc.org/cameras/vendors/goke>
- [Installation on HiSilicon based boards](en/install-hisi.md), but you'd better use <https://openipc.org/cameras/vendors/hisilicon>
- [Installation on Novatek based boards](en/install-novatek.md), but you'd better use <https://openipc.org/cameras/vendors/novatek>
- [Installation on SigmaStar based boards](en/install-ssc335.md), but you'd better use <https://openipc.org/cameras/vendors/sigmastar>
- [Installation on XM510 based boards](en/install-xm510.md), but you'd better use <https://openipc.org/cameras/vendors/xiongmai>
- [Installation on XM530 based boards](en/install-xm530.md), but you'd better use <https://openipc.org/cameras/vendors/xiongmai>
- [Very old full manual](en/old-manual.md)

### Usage
- [Network settings](en/network-settings.md)
- [System features](en/system-features.md)
- [Majestic streamer](en/majestic-streamer.md)
- [Microbe web interface](en/microbe-web.md)
- [Upgrade firmware](en/sysupgrade.md)
- [Image quality tuning](en/image-quality-tuning.md)
- [Memory tuning](en/memory-tuning.md)
- [Using ipctool](en/example-ipctool.md)
- [Board specific GPIO settings list](en/gpio-settings.md)
- [ACMEv2](en/acme-v2.md)
- [YouTube streaming](en/youtube-streaming.md)
- [WiFi XM530](en/wifi-xm530.md)

### Firmware
- [Releases in GitHub](https://github.com/OpenIPC/firmware/releases/tag/latest)
- [Releases in Telegram](https://t.me/s/openipc_dev)
- [Source code](en/source-code.md)

### Development
- [Boot device with NFS](en/dev-nfs-boot.md)
- [FFMPEG usage](en/dev-ffmpeg-usage.md)
- [Kernel configuration for adding new platforms](en/integration-kernel.md)

### Help, Tips, and Tricks
- [U-Boot Tips](en/help-uboot.md)
- [Web UI Help](en/help-webui.md)
- [Interesting tricks](en/dev-tricks.md)
- [Questions and answers](en/faq.md)

### Reference Book
- [Company names](en/company-names.md)
- [Hikvision IP Camera Model naming convention](https://www.vueville.com/home-security/cctv/ip-cameras/hikvision-network-camera-guide/#model-naming-convention)

### Developer manuals
- [Buildroot User Manual](https://buildroot.org/docs.html)
- [U-Boot Documentation](https://u-boot.readthedocs.io/)

### Contacts
- [Bug reports](https://github.com/OpenIPC/firmware/issues)

### Our resources
- [OpenIPC](https://openipc.org/)
- [OpenCollective](https://opencollective.com/openipc)
- [Twitter](https://twitter.com/OpenIPC)
- [Telegram](https://t.me/openipc)

### Roadmap
- [ToDo](en/todo-all.md)
- [Developers](en/developers.md)
- [Notes from old sources](en/notes-for-resorting.md)

### Hardware
- [SoC manufacturers](en/hardware-soc-manufacturers.md)
- [Image sensors manufacturers](en/hardware-sensor-manufacturers.md)
- [IPC boards manufacturers](en/hardware-board-manufacturers.md)

### Resources for recycling and integration
- <https://github.com/OpenIPC/camerasrnd>
- <https://openwrt.org/docs/techref/hardware/soc/soc.hisilicon.hi35xx>


In Russian
----------
- [О проекте](ru/about.md)
- [Установка. Шаг за шагом.](ru/installation.md)
- [Настройка.](ru/configuration.md)
- [Программный переход с openipc-1.0 (OpenWrt) на openipc-2.x (Buildroot)](ru/upgrade-from-1.md)
- [Вопросы и ответы](ru/faq.md)
- [Использование для FPV](ru/fpv.md)
- [Разработка платы расширения 38x38 для FPV систем](ru/fpv-extension.md)
- [Хочу помочь!](ru/contribute.md)

### Помощь
- [Веб-интерфейс](ru/help-webui.md)

### Камеры
- [Switcam HS-303](ru/hardware-hs303.md)
- [Ростелекомовская камера с NAND](ru/hardware-rtk-nand.md)
- [Полезные ссылки](ru/resources.md)
- [Обзоры камер разных производителей](ru/reviews.md)

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

[faq1]: https://github.com/OpenIPC/camerasrnd/blob/master/docs/XM-FAQ-ru.md
[faq3]: https://alarmsystem-cctv.ru/openipc-%D0%BE%D1%82%D0%BA%D1%80%D1%8B%D1%82%D1%8B%D0%B9-%D0%BA%D0%BE%D0%BB%D0%BB%D0%B5%D0%BA%D1%82%D0%B8%D0%B2/
[logo]: images/logo_openipc.png
