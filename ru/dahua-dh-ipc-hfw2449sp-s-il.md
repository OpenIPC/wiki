# OpenIPC Wiki
[Оглавление](../README.md)

Dahua DH-IPC-HFW2449SP-S-IL
---

Уличная 4 МП камера с двойной подсветкой (ИК + тёплый белый свет) на базе Novatek NT98566 (NA51089) и SPI NAND.

### Платформа

| Компонент | Характеристики |
|---|---|
| Процессор | Novatek NT98566 (NA51089), ARM Cortex-A9 |
| Память ОЗУ | 128 МБ DDR3 |
| Флеш-память | 128 МиБ SPI NAND, Fudan Micro `FM25S01A` (`0xA1 0xE4`, 1-bit on-die ECC) |
| Сенсор | SmartSens `SC430AI` (4 МП, 2688x1520, MIPI 2-lane) |
| Сеть | Встроенный 100 Мбит PHY (PoE) |
| Звук | Встроенный микрофон (Novatek EAC, 48 кГц AAC) |
| Карта памяти | Слот microSD (SDIO1) |
| Подсветка | Двойная (ИК + тёплый белый LED) + моторизованный ИК-фильтр |

### Файлы прошивки

Скачиваем с GitHub загрузчик и архив прошивки:
- [u-boot-nt98566-nand.bin](https://github.com/OpenIPC/firmware/releases/download/latest/u-boot-nt98566-nand.bin)
- [openipc.nt98566-nand-ultimate.tgz](https://github.com/OpenIPC/firmware/releases/download/latest/openipc.nt98566-nand-ultimate.tgz)

Загрузчик `u-boot-nt98566-nand.bin` кладём в папку TFTP-сервера как есть, а из архива `.tgz` распаковываем туда же `rootfs.ubifs.nt98566`.

### UART и загрузчик

- UART0: 3.3V, 115200 8N1 (`TX`, `RX`, `GND` на плате).
- Аппаратный Secure Boot (OTP/eFuse) **отключён** (все 16 полей равны `0`).
- Стоковый загрузчик Dahua (`U-Boot 2019.04`, остановка клавишей `*`) ограничивает `setenv`/`tftp` и не запускает сторонние прошивки.

### Прошивка

1. **Обязательно снимите полный дамп 128 МиБ стоковой SPI NAND** по NAND-инструкции из [Backing up stock firmware](../en/backup-stock-firmware.md) (программатором либо с учётом бэд-блоков) и сохраните его отдельно.
2. Прошейте `u-boot-nt98566-nand.bin` по смещению `0x0` (программатором либо из запущенного в RAM загрузчика OpenIPC командой `run ub` - см. [Novatek unbrick](../en/novatek-unbrick.md) для загрузки в RAM через `defib`, но работа `defib` на `nt98566` на железе пока не подтверждена), затем перезагрузите камеру и остановите загрузку в консоли `OpenIPC #`.
3. Настройте сеть, MAC-адрес камеры, `osmem`, один раз очистите раздел `ubi` и прошейте `rootfs.ubifs.nt98566` (ядро `/boot/uImage` уже находится внутри):

```
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.254
setenv ethaddr 00:11:22:33:44:55
setenv osmem 48M
saveenv
nand erase.part ubi
run ur && reset
```

Дальнейшие обновления из Linux выполняются командой `sysupgrade` (или `sysupgrade --rootfs=/tmp/rootfs.ubifs.nt98566`), из U-Boot - командой `run ur && reset`.

### Первый запуск, сенсор и microSD

Войдите под `root` (через UART, SSH или веб-интерфейс) и задайте пароль. Если `SC430AI` не определился автоматически, пропишите его один раз. Для работы слота microSD (на этой плате нет пина детекта карты, а питание слота включается по `GPIO 9`, активный `0`, см. [SD card GPIO overrides](../en/install-novatek.md#sd-card-sdio1-gpio-overrides)) задайте `sd_cd_gpio` и `sd_power_gpio`, затем перезагрузите камеру:

```sh
fw_setenv sensor sc430ai
fw_setenv sd_cd_gpio 0
fw_setenv sd_power_gpio 9
reboot
```

### GPIO

| Назначение | GPIO | Примечание |
|---|---|---|
| Питание microSD | `GPIO 9` (`C_GPIO9`) | Включение питания карты (`0` = вкл, `1` = выкл); пина CD нет (`sd_cd_gpio=0`, `sd_power_gpio=9`) |
| ИК-фильтр, пин 1 | `GPIO 234` (`DSI_GPIO10`) | H-мост, плечо 1 |
| ИК-фильтр, пин 2 | `GPIO 133` (`D_GPIO5`) | H-мост, плечо 2 |
| Питание подсветки | `GPIO 226` (`DSI_GPIO2`) | Общее включение драйвера LED (`1` = вкл, `0` = выкл) |
| Режим подсветки | `GPIO 227` (`DSI_GPIO3`) | Переключатель режима (`1` = ИК, `0` = белый свет; `whiteLightInvert: true`) |

Особенности:
- `GPIO 133` (`D_GPIO5`) в общем EVB DTB для NA51089 совмещён с `ETH_LED2` и автоматически переводится в режим GPIO драйвером `gpio-nvt-na51089` при запросе пина.
- Двойная подсветка построена по схеме **общее питание + переключатель режима**, а не как два независимых канала. Одновременно включить ИК и белый свет нельзя.
- Параметр `nightMode.whiteLightShared: true` (сборки majestic, где он есть, показывают **Shared lamp driver** в настройках ночного режима WebUI) сообщает majestic именно это: `backlightPin` (`GPIO 226`) включает питание драйвера, а `whiteLightPin` (`GPIO 227`, с `whiteLightInvert: true`) выбирает группу светодиодов. Тогда каждая лампа включается сама по себе, в том числе белый свет при выключенной ИК-подсветке или днём. Если нужны обе, побеждает белый свет, а когда он гаснет, ИК включается снова без тёмного промежутка. `whiteLight: auto` вместе с `colorNight: true` подсвечивает цветную ночь белым светом ([OpenIPC/majestic#396](https://github.com/OpenIPC/majestic/issues/396)).
- В более старом majestic, без этого параметра, для белого света нужно включить и подсветку камеры (`backlightPin`), и `whiteLight`, а `whiteLight: auto` на этой плате не работает.

### Настройка Majestic

Применяем настройки камеры одной командой через API Majestic и перезагружаем:

```sh
curl http://localhost/api/v1/config --data-binary @- <<'EOF'
{
  "isp": {
    "sensorConfig": "/etc/sensors/sc430ai.yaml"
  },
  "video0": {
    "size": "2688x1520"
  },
  "audio": {
    "enabled": true,
    "codec": "aac",
    "srate": "48000"
  },
  "nightMode": {
    "irCutPin1": 234,
    "irCutPin2": 133,
    "backlightPin": 226,
    "whiteLightPin": 227,
    "whiteLightInvert": true,
    "whiteLightShared": true,
    "whiteLight": "manual"
  }
}
EOF
reboot
```
