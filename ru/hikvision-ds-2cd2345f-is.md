# OpenIPC Wiki
[Оглавление](../index.md)

Hikvision DS-2CD2345F-IS
--------------

Среди камер продаваемых Ростелекомом существует модель Hikvision DS-2CD2345F-IS. От большинства прочих отличается тем, что оригинальной прошивки для неё, судя по всему, нет. Но железо поддерживается OpenIPC и значит не всё потеряно.

## Текущая ситуация
- В настоящее время удалось запустить сборку для процессора hi3516av100, т.к. только в ней есть поддержка памяти NAND, а всё остальное идентично сборке для hi3516av100.
- Последняя протестированная работающая сборка - от 27.05.22 Сборка от 6.10.22 запускается, но в ней отсутствует eth0. Причина выясняется.
- В протестированной сборке отсутствует поддержка UBIFS, поэтому периодически настройки каеры слетают к дефолтным значениям.
- Переключение день/ночь реализовано дополнительным скриптом. Есть определённые проблемы на границах тёмного и светлого времени суток - в сумерках многократно переключается то в один то в другой режим. 
- Микрофон не работает.
- Запись на карпту памяти не тестировал. 

## Платформа
- процессор hi3516dv100
- сенсор ov4689
- объём ОЗУ 128Мб
- объём ПЗУ 128Мб
- тип ПЗУ NAND

## Прошивка
### Переменные окружения
```
setenv soc hi3516av100
setenv sensor ov4689
setenv totalmem 128M

setenv osmem 32M

setenv bootargs 'mem=32M console=ttyAMA0,115200 panic=20 root=/dev/mtdblock3 rootfstype=squashfs init=/init mtdparts=hinand:1024k(boot),1024k(env),2048k(kernel),5120k(rootfs),-(rootfs_data)'

setenv bootcmd 'setenv setargs setenv bootargs ${bootargs}; run setargs; nand read 0x82000000 0x200000 0x200000; bootm 0x82000000'

setenv ethaddr 00:12:34:56:78:90    //задать MAC-адрес камеры, если не задан
setenv ipaddr 192.168.1.10          //задать IP-адрес камеры, если не задан
setenv serverip 192.168.1.2         //задать адрес компа с TFTP-сервером
```
### Образы ядра и файловой системы 
```
mw.b 0x82000000 0xff 0x1000000
tftp 0x82000000 uImage.${soc}
nand erase 0x200000 0x200000
nand write.i 0x82000000 0x200000 0x200000

mw.b 0x82000000 0xff 0x1000000
tftp 0x82000000 rootfs.squashfs.${soc}
nand erase 0x400000 0x500000
nand write 0x82000000 0x400000 0x500000

reset
```
Можно вводить команды одной строкой через **;**, но лучше построчно, чтобы контролировать выполнение.  
### Первый запуск
После загрузки системы нужно войти под пользователем root без пароля и выполнить команду **firstboot**. Система выполнит необходимые операции и перезапустится. Если не перезапустилась, то сделать это командой **reboot**. 
Затем снова войти в бут и почистить память:
```
nand erase 0x900000 0x7700000
reset
```
Эту же операцию нужно выполнить, если происходят сбои по вине неподходящей файловой системы. Но то же самое можно сделать и через веб-интерфейс.
### Веб-интерфейс
Веб-интерфейс по умолчанию доступен по порту **85**. Логин: **admin**, пароль: **12345**. При первом входе будет предложено задать новый сложный пароль. Сам использую англоязычный интерфейс, поэтому и все пункты меню буду приводить тоже на английском. Основная часть системы — стример **Majestic**. Он выполняет функции захвата и трансляции изображения и делает всё остальное, что с этим связано. Надо настроить.
#### Majestic->Majestic settings
##### ISP
- В поле **Path to sensor configuration file** выбрать **/etc/sensors/ov4689_i2c_1080p.ini**
##### VIDEO0
- Включить **Enable Video0**
- Выбрать **Video0 codec: h265**
- Задать **Video resolution: 1920×1080**
- Задать **Video frame rate: 25**
- Задать **Video bitrate: 2048**
- Задать **Send I-frame each 1 second: 1**
##### VIDEO1
- Включить **Enable Video1**
- Выбрать **Video0 codec: h265**
- Задать **Video resolution: 704×576**
- Задать **Video frame rate: 25**
- Задать **Video bitrate: 512**
- Задать **Send I-frame each 1 second: 1**

После проведения указанных манипуляций сохранить изменения — видео настроено. В разделе **Preview** картинку можно увидеть только для JPEG и MJPEG. Просмотр видео работает не всегда — баг это или фича, разбираемся.
Увидеть картинку можно через VLC, выбрав в меню пункт Открыть URL и введя одну из строк:
- rtsp://admin:password@ip-address:554/stream=0 — первый поток
- rtsp://admin:password@ip-address:554/stream=1 — второй поток
 
где: password — ваш пароль, ip-address — адрес камеры.