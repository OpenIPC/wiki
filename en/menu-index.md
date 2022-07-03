# OpenIPC Wiki
[Table of Content](../index.md)

## Basic information

The OpenIPC is an alternative [firmware](https://github.com/OpenIPC) for
IP cameras and a kind of umbrella for other projects that are components of
our system.

The OpenIPC is a Linux operating system based on Buildroot/OpenWrt projects and
targeting IP cameras with chipsets from different vendors, starting
with Goke GK72xx, HiSilicon Hi35xx, SigmaStar SSC33x, and XiongmaiTech XM5xx.

Everyone is welcome to use/contribute to the project in any way they find useful!

We would be grateful for any feedback and suggestions.


## Official links

* [OpenIPC on Wiki](https://openipc.github.io/wiki) - Collection of various documentation and instructions.
* [OpenIPC on GitHub](https://github.com/OpenIPC/) - GitHub organization, most projects are hosted here.
* [OpenIPC on OpenCollective](https://opencollective.com/openipc) - OpenCollective community.
* [OpenIPC on Twitter](https://twitter.com/openipc) - Our main news.
* [OpenIPC on YouTube](https://www.youtube.com/channel/UCaXlbR2uGTRFh8jQ2lCFd2g) - Our instructions and streams (in the plans).


## Telegram chat groups

* [OpenIPC](https://t.me/openipc) (EN) - International channel to discuss the development of our project, [*](https://combot.org/c/1166652144)
* [OpenIPC modding](https://t.me/openipc_modding) (RU) - general issues on modifying IPCam device firmware, [*](https://combot.org/c/-1001247643198)
* [OpenIPC development](https://t.me/openipc_software) (RU) - HiSilicon, XM porting in OpenWrt and programmer issues, [*](https://combot.org/c/-1001196905312)
* [OpenIPC advice](https://t.me/openipc_advice) (RU) - problems, finding solutions, long conversations, [*](https://combot.org/c/1385065634)
* [OpenIPC majestic](https://t.me/joinchat/YgHc5Bg4NOoxOTdi) (RU) - for Majestic streamer testers, [*](#)
* [OpenIPC Iranian](https://t.me/joinchat/T_GwQUBTJdfXJrFb) (IR) - special group for Iranian users / تیم OpenIPC برای کاربران ایرانی, [*](https://combot.org/c/-1001341239361)
* [OpenIPC demo](https://t.me/openipc_demo)  (EN/RU) - test bot with buttons, after connecting, give the "/menu", [*](https://combot.org/c/1414887196)
* [OpenIPC ExIPCam](https://t.me/ExIPCam) (RU) - ExIPCam program and hardware/software repairing devices, [*](https://combot.org/c/1213889378)
* [OpenIPC updates](https://t.me/s/openipc_updates) (RU) - Firmware & Software updates information channel
* [OpenIPC dev](https://t.me/s/openipc_dev) - Firmware & Software development channel


## Team developments

### Firmware

* [openipc-2.x](https://openipc.github.io/firmware) - Firmware development and creation system based on Buildroot.
* [openipc-1.0][chaos_calmer] - Firmware development and creation system based on OpenWrt 15.05.
* [coupler][coupler] - Seamless transition between video cameras firmware.

### Streamers

* [majestic](https://github.com/OpenIPC/firmware/wiki/majestic_streamer) - Universal IPCam streamer.
* [mini][mini] - OpenSource Mini IP camera streamer.

### Tools

* [ipctool](https://openipc.github.io/ipctool) - Tool (and library) for checking IP camera hardware.
* [yaml-cli][yaml-cli] - Tool for change setting in CLI.
* [glutinium](https://github.com/ZigFisher/Glutinium) - Additional OpenWRT packages.

### Windows software

* [exipcam](http://team.openipc.org/exipcam) - Cool utility for repairing IPCam (For Windows, works in Linux via Wine).
* [ipcam_dms](http://team.openipc.org/ipcam_dms) - IPCam Device Management System (For Windows, works in Linux via Wine).


## Developers

| Name                                                             | Role                                                   | Participation                                                            |
|------------------------------------------------------------------|--------------------------------------------------------|--------------------------------------------------------------------------|
| [Dmitry Ilyin](https://web.telegram.org/#/im?p=@widgetii)        | co-founder and main participant of the OpenIPC project | [ipctool][ipctool], [majestic][majestic], [mini][mini], [motors][motors] |
| [Dmitry Ermakov](https://web.telegram.org/#/im?p=@dimerrr)       | main participant                                       | [coupler][coupler], [firmware][firmware], [ipctool][ipctool]             |
| [Igor Zalatov](https://web.telegram.org/#/im?p=@FlyRouter)       | **project founder and development coordinator**        | [chaos_calmer][chaos_calmer], [firmware][firmware], [wiki][wiki]         |
| [Ivan Pozdeev](https://web.telegram.org/#/im?p=@John)            | developer                                              | [microbe-web][webui], [yaml-cli][yaml-cli]                               |
| [Konstantin](#)                                                  | developer                                              | [hisi-trace][hisi-trace], [yaml-cli][yaml-cli]                           |
| [Maksim Patrushev](https://web.telegram.org/#/im?p=@maxi380)     | developer                                              | [motors][motors]                                                         |
| [Maxim Chertov](https://web.telegram.org/#/im?p=@mAX3773)        | co-founder of the OpenIPC project                      | [chaos_calmer][chaos_calmer], [ipctool][ipctool], [mini][mini]           |
| [Paul Philippov](https://web.telegram.org/#/im?p=@themactep)     | main participant                                       | [microbe-web][webui]                                                     |
| [Sergey Sharshunov](https://web.telegram.org/#/im?p=@USSSSSH)    | co-founder of the OpenIPC project                      | [chaos_calmer][chaos_calmer], [burn][burn]                               |
| [Temirkhan Myrzamadi](https://web.telegram.org/#/im?p=@hirrolot) | main participant                                       | [smolrtsp][smolrtsp]                                                     |
| [Vasiliy Yakovlev](https://web.telegram.org/#/im?p=@#)           | general facilitator                                    |                                                                          |


### Support

OpenIPC offers two levels of support.

- Free support through the community (via [chat](https://openipc.org/#telegram-chat-groups) and [mailing lists](https://github.com/OpenIPC/firmware/discussions)).
- Paid commercial support (from the team of developers).

Please consider subscribing for paid commercial support if you intend to use our product for business.
As a paid customer, you will get technical support and maintenance services directly from our skilled team.
Your bug reports and feature requests will get prioritized attention and expedited solutions. It's a win-win
strategy for both parties, that would contribute to the stability your business, and help core developers
to work on the project full-time.

If you have any specific questions concerning our project, feel free to [contact us](mailto:flyrouter@gmail.com).

### Participating and Contribution

If you like what we do, and willing to intensify the development, please consider participating.

You can improve existing code and send us patches. You can add new features missing from our code.

You can help us to write a better documentation, proofread and correct our websites.

You can just donate some money to cover the cost of development and long-term maintaining of what we believe
is going to be the most stable, flexible, and open IP Network Camera Framework for users like yourself.

You can make a financial contribution to the project at [Open Collective](https://opencollective.com/openipc/contribute/backer-14335/checkout).

Thank you.

<p style="text-align:center">
<a href="https://opencollective.com/openipc/contribute/backer-14335/checkout" target="_blank"><img src="https://opencollective.com/webpack/donate/button@2x.png?color=blue" width="375" alt="Open Collective donate button"></a>
</p>


[burn]: https://github.com/OpenIPC/burn
[chaos_calmer]: https://github.com/OpenIPC/chaos_calmer
[coupler]: https://github.com/OpenIPC/coupler
[firmware]: https://github.com/OpenIPC/firmware
[hisi-trace]: https://github.com/OpenIPC/hisi-trace
[ipctool]: https://github.com/OpenIPC/ipctool
[majestic]: https://github.com/OpenIPC/majestic
[mini]: https://github.com/OpenIPC/mini
[motors]: https://github.com/OpenIPC/motors
[smolrtsp]: https://github.com/OpenIPC/smolrtsp
[webui]: https://github.com/OpenIPC/microbe-web
[wiki]: https://github.com/wiki
[yaml-cli]: https://github.com/OpenIPC/yaml-cli
