# OpenIPC Wiki
[Оглавление](index.md)

Switcam HS-303
--------------

Публичные заметки по прошивке устройств Switcam HS303 (всех версий) в
[OpenIPC](https://openipc.org) v1.0 (на базе OpenWrt).

Обсуждение проекта и возможностей прошивок (на русском языке) в группе
[Telegram](https://t.me/openipc_modding).

### Наиболее актуальные вопросы и ответы

#### Какие типы устройств поддерживаются в проекте OpenIPC v1.0?

На данный момент полноценно поддерживается Switcam HS-303 (v1).
В будущем планируется поддержка устройств v2 и v3.

#### Где можно взять прошивку для устройства Ростелеком Switcam HS303 (v1)?

Обсуждение работы этих камер доступно по специальной подписке на
[OpenIPC paywall](https://paywall.pw/openipc).

#### Какой путь до SD карты необходимо указывать в `majestic.yaml` для прошивки
openipc-1.0?

`/mnt/mmc/%Y/%m/%d/%H.mp4`

### Специализированные настройки для Switcam HS303(v2)

Обсуждение работы этих камер доступно по специальной подписке на
[OpenIPC paywall](https://paywall.pw/openipc).

#### Модифицированный блок из файла /etc/network/interface

```
auto wlan0
iface wlan0 inet dhcp
    pre-up echo 54 > /sys/class/gpio/export
    pre-up echo out > /sys/class/gpio/gpio54/direction
    pre-up echo 1 > /sys/class/gpio/gpio54/value
    pre-up modprobe r8188eu
    pre-up wpa_passphrase "OpenIPC" "openipc2021" >/tmp/wpa_supplicant.conf
    pre-up sed -i '2i \\tscan_ssid=1' /tmp/wpa_supplicant.conf
    pre-up ifconfig wlan0 up
    pre-up wpa_supplicant -B -Dwext -iwlan0 -c/tmp/wpa_supplicant.conf
    post-down killall -q wpa_supplicant
```

#### Модифицированный блок из файла /etc/majestic.yaml

```
nightMode:
  enabled: true
  irSensorPin: 62
  irSensorPinInvert: true
  irCutPin1: 2
  pinSwitchDelayUs: 150
  backlightPin: 56
  nightAPI: true
```
