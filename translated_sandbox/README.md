# sandbox-fpv
Sandbox for FPV experiments. Telegram-group: `https://t.me/+BMyMoolVOpkzNWUy` | [link](https://t.me/+BMyMoolVOpkzNWUy)

## News
* `26.07.2023` - FPV link setup via 4G modem .

* `01.07.2023` - A short note about the imx335 gk7205v300 camera . About baud for telemetry .

* `22.06.2023` - Finally, the problem with the picture being jerky at 30fps was resolved .

* `06.04.2023` - Added coupler firmware for ivg-g2s with u-boot on board.

* `05.04.2023` - Added functionality to rcjoystick for displaying packet losses (link quality) in rssi.

* `04.04.2023` - OpenIPC has added the majestic streamer, now the ivg-g2s camera runs h265 cbr (constant bitrate). This gave a cleaner picture and a significant reduction in noise. At the same time, changes were made to the link launch process. The main service is now S98datalinkwith the config /etc/datalink.conf, and wfb is now launched via /usr/bin/wifibroadcast. The articles have been corrected to accommodate this innovation.

* `01.04.2023` - Due to certain circumstances, wfb-ng was replaced in my camera and recorder with an alternative from OpenHD . Here is the package for assembly in buildroot OpenIPC. The shell wrappers take into account both options, due to the presence of a parameter link_idthat is not required in the OpenHD implementation. Archive with binaries of both options.

## Notes

* [Notes on setting up the link on the gk7205v200 camera and hi3536ev100 (dv100) recorder](notes_link_gk7205v200_hi3536ev100.md)
* [Notes on camera firmware gk7205v200 on OpenIPC](notes_start_ivg-g2s.md)
* [Notes on firmware for hi3536ev100 recorder on OpenIPC](notes_start_hi3536ev100.md)
* [A note about the imx335 gk7205v300 camera](notes_imx335_gk7205v300.md)
* [Adding smoothness to video on goke/hisilicon cameras](gkrcparams.md)
* [A note about controlling the camera via RC channels from the ground](notes_cam_control.md)
* [Switch between two cameras in the air](note-two-cameras-switched.md)
* [Loader for telemetry for gk7502v200, which does not hang the camera upon reboot](gk7205v200_u-boot-7502v200-for-telemetry.md)
* [Controlling buttons from the front panel on the recorder](nvr_gpio.md)
* [Connecting and setting up a tablet or smartphone for video and OSD via USB](usb-tethering.md)
* [Connecting the tablet to the recorder via wifi via the tablet's AP](note-nvr-tab-ap.md)
* [Connecting the tablet to the recorder via ethernet-usb-device](usb-eth-modem.md)
* [Using the hardware as a joystick to transmit RC channels via mavlink](rcjoystick.md)
* [About the analogue of RSSI](rcjoystick.md#rssi)
* [SBUS-to-USB joystick for using any equipment with an sbus receiver](sbus-to-usb-joystick)
* [FPV link setup via 4G modem](lte-fpv.md)
* [Installing usb_modeswitch on a camera with fpv, lite firmware](usb-modeswitch.md)

#### Miscellaneous
* [mavfwd for inav (one way msp) for camera](user_TipoMan/mavfwd_mavlink2.tar?raw=true)
* [Displaying video on windows and MP](gstlaunch_on_windows.md)
* [Disabling watchdog on the hi3536dv100 recorder](note_nvr_wdt.md)
* [Different from 115200 baud on camera uart for telemetry](note_telemetry_baud.md)

## Road map
* ~~Starting video with transfer from the recorder to the PC.~~
* ~~Launch one- and two-way telemetry.~~
* ~~Starting video transfer via usb tethering to an Android tablet.~~
* ~~Building and testing LTE firmware on e3372h + zerotier~~
* ~~Starting telemetry routing via mavlink-router.~~
* ~~Finding ways to control the camera through mavlink.~~.
* Finding ways to output video and osd via hdmi.
* ~~~Switching between several cameras, where one is the master with wfb-ng, and the rest are slaves.~~~
* Development of expansion board for camera: bec 5v/3.3v; usb hub, uart, wifi/modem power transistor, microSD.
* Development of a zoom lens control board and a method for controlling commercially available boards.
* Development of a stabilizing gimbal controlled from the ground via wfb-ng.



## Russians:

## Новое
* `26.07.2023` - Настройка FPV-линка [через 4G модем](lte-fpv.md).

* `01.07.2023` - Короткая заметка о камере [imx335 gk7205v300](notes_imx335_gk7205v300.md). О [baud для телеметрии](note_telemetry_baud.md).

* `22.06.2023` - Наконец [решилась](gkrcparams.md) проблема с дерганностью картинки на 30fps.

* `06.04.2023` - Добавлена [прошивка coupler](notes_start_ivg-g2s.md#L33) для ivg-g2s с u-boot на борту.

* `05.04.2023` - В rcjoystick [добавлен](rcjoystick.md#rssi) функционал для целей отображения потерь пакетов (качества линка) в rssi.

* `04.04.2023` - В OpenIPC "допилили" стример majestic, теперь на камере ivg-g2s работает h265 cbr (постоянный битрейт). Это дало более чистую картинку и значительное уменьшение шума. Вместе с этим были внесены изменения в процесс запуска линка. Основным сервисом теперь является `S98datalink` с конфигом `/etc/datalink.conf`, а запуск wfb теперь производится через `/usr/bin/wifibroadcast`. Статьи были исправлены под это нововведение.

* `01.04.2023` - В связи с некоторыми обстоятельствами, wfb-ng был заменен в моих камере и регистраторе на альтернативу от [OpenHD](https://github.com/OpenHD/wifibroadcast/). [Тут](wfbopenhd.zip) пакет для сборки в buildroot OpenIPC. В шелл-обертках учтены оба варианта, по наличию параметра `link_id` который не требуется в реализации от OpenHD. [Архив](https://github.com/OpenIPC/sandbox-fpv/blob/master/wfb.zip) с бинарниками обоих вариантов.

## Заметки

* [Заметки о настройке линка на камере gk7205v200 и регистраторе hi3536ev100 (dv100)](notes_link_gk7205v200_hi3536ev100.md)
* [Заметки о прошивке камеры gk7205v200 на OpenIPC](notes_start_ivg-g2s.md)
* [Заметки о прошивке регистратора hi3536ev100 на OpenIPC](notes_start_hi3536ev100.md)
* [Заметка о камере imx335 gk7205v300](notes_imx335_gk7205v300.md)
* [Добавляем плавности видео на goke/hisilicon камерах](gkrcparams.md)
* [Заметка о управлении камерой через RC каналы с наземки](notes_cam_control.md)
* [Переключение между двумя камерами в воздухе](note-two-cameras-switched.md)
* [Загрузчик под телеметрию для gk7502v200, который не вешает камеру при ребуте](gk7205v200_u-boot-7502v200-for-telemetry.md)
* [Управление кнопками с front panel на регистраторе](nvr_gpio.md)
* [Подключение и настройка планшета или смартфона для видео и OSD по USB](usb-tethering.md)
* [Подключение планшета к регистратору по wifi через AP планшета](note-nvr-tab-ap.md)
* [Подключение планшета к регистратору через ethernet-usb-device](usb-eth-modem.md)
* [Использование аппаратуры как джойстика для передачи каналов RC через mavlink](rcjoystick.md)
* [Про аналог RSSI](rcjoystick.md#rssi)
* [SBUS-to-USB joystick для использования любой аппаратуры с sbus приемником](sbus-to-usb-joystick)
* [Настройка FPV-линка через 4G модем](lte-fpv.md)
* [Установка usb_modeswitch на камеру с прошивкой fpv, lite](usb-modeswitch.md)

#### Разное
* [mavfwd для inav (односторонний msp) для камеры](user_TipoMan/mavfwd_mavlink2.tar?raw=true)
* [Отображение видео на windows и в MP](gstlaunch_on_windows.md)
* [Отключение watchdog на регистраторе hi3536dv100](note_nvr_wdt.md)
* [Отличный от 115200 baud на uartе камеры для телеметрии](note_telemetry_baud.md)

## Дорожная карта
* ~~Запуск видео с передачей с регистратора на пк.~~
* ~~Запуск одно-и двусторонней телеметрии.~~
* ~~Запуск передачи видео через usb tethering на android-планшет.~~
* ~~Сборка и тестирование прошивки LTE на e3372h + zerotier~~
* ~~Запуск маршрутизации телеметрии через mavlink-router.~~
* ~~Поиск путей управления камерой сквозь mavlink~~.
* Поиск способов вывода видео и osd через hdmi.
* ~~~Переключение между несколькими камерами, где одна ведущая с wfb-ng, а остальные ведомые.~~~
* Разработка платы расширения для камеры: bec 5v/3.3v; usb hub, uart, транзистор питания wifi/modem, microSD.
* Разработка платы управления зум-объективом и способа управления имеющимися в продаже платами.
* Разработка стабилизирующего подвеса, управляемого с земли сквозь wfb-ng.
