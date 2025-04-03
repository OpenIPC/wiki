## Подключение камеры к планшету или ПК через LTE (4G) модем

Летать через 4G - крайне интересная тема для самолетов под стабилизацией или автоматическим маршрутом. Разобъем процесс настройки на задачи:

* настроить интернет через модем на камере
* настроить свой сервер zerotier (можно воспользоваться публичным)
* подключить камеру и ПК к одной сети zerotier и настроить стрим

Следуя [этим инструкциям](usb-modeswitch.md), настроим usb_modeswitch и сетевой интерфейс eth1 на камере под прошивкой OpenIPC LTE. Если у вас FPV или LITE прошивка, предварительно нужно ее сменить онлайн:
```
#тут меняем fpv на lte в файле /etc/os-release, можно это сделать вручную
sed -i 's/BUILD_OPTION=fpv/BUILD_OPTION=lte/' /etc/os-release
#а это если у вас lite версия
sed -i 's/BUILD_OPTION=lite/BUILD_OPTION=lte/' /etc/os-release

sysupgrade --force_ver -k -r -n
```
Мы получаем камеру с заводскими настройками и lte прошивкой, в которой в отличие от fpv удален wfb а взамен установлен zerotier-one клиент.
На самом деле, правильным решением будет не использовать usb_modeswitch а настроить вторичную композицию модема сразу на cdc_ethernet. Тогда модем перестанет быть универсальным и сразу будет отображаться как сетевая карта, но зато исчезнет вероятность возникновения ряда проблем.

#### zerotier
Это программное обеспечение для объединения нескольких устройств в одну локальную сеть. Существует публичный сервер для создания своей сети, но лучше поднять свой.
Для этого потребуется vps-сервер под ubuntu.
```
apt-get install -y apt-transport-https gnupg mc iftop          #устанавливаем зависимости
curl -s https://install.zerotier.com | sudo bash               #устанавливаем клиентскую часть

curl -O https://s3-us-west-1.amazonaws.com/key-networks/deb/ztncui/1/x86_64/ztncui_0.7.1_amd64.deb #устанавливаем панель управления
apt-get install ./ztncui_0.7.1_amd64.deb

echo 'HTTPS_PORT=6443' > /opt/key-networks/ztncui/.env         #порт для вебморды управления
echo 'NODE_ENV=production' >> /opt/key-networks/ztncui/.env    #режим работы
echo 'HTTPS_HOST=nn.mm.ff.dd' >> /opt/key-networks/ztncui/.env #внешний ip-адрес нашего сервера

systemctl restart ztncui
```

Входим по ссылке https://ip_addr:6443, логин admin, пароль password.
Далее создаем сеть и настраиваем параметры выдачи адресов, какие вам больше нравятся, остальные настройки по умолчанию.
В режиме private после подключения клиента требуется установить галочку Authorized чтобы разрешить ему подключение.

![ZTNCUI](https://github.com/OpenIPC/sandbox-fpv/raw/master/notes_files/ZTNCUI.png)

Существует альтернатива в виде [публичного сервера](https://my.zerotier.com/), но вопрос надежности и быстродействия остается подвешенным. Программы - клиенты для windows, android скачивать [тут](https://www.zerotier.com/download/).

Подключение к сети производится через указание Network ID, 16-значной символьной строки, которую берем из панели управления. Для камеры ее указываем в /etc/datalink.conf
```
use_zt=true
zt_netid=a8867b0bxxxxxxxxx
```
после чего перезагружаем камеру. При наличии интернет-подключения, хоть LTE хоть ethernet, камера должна подключиться к сети zerotier. Это можно проверить через веб-панель управления и на камере командой ifconfig.
```
ztuplek3wb Link encap:Ethernet  HWaddr 92:31:B1:54:8B
          inet addr:10.7.0.1  Bcast:10.7.0.255  Mask:255.255.255.0
          inet6 addr: fe80::9031:b1ff:fe54/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:2800  Metric:1
          RX packets:93 errors:0 dropped:0 overruns:0 frame:0
          TX packets:1236835 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:5677 (5.5 KiB)  TX bytes:1493618333 (1.3 GiB)
```

 Для ПК или андроид-устройства [устанавливаем](https://www.zerotier.com/download/) программу и аналогично добавляем сеть по ее id, авторизуем устройство в веб-панели. Пробуем перекрестный ping, он должен проходить. Если имеется файервол/брендмауер, как например под windows, нужно добавить в нем разрешающее правило с нашей подсетью.

#### Настройка стрима
Остается в /etc/majestic.yaml указать ip-адрес наземки из сети zerotier и видео можно принимать. Не забудьте согласовать кодеки.
```
outgoing:
- udp://ip_from_zerotier:5600
```

#### Телеметрия
Проверку телеметрии я еще не делал, но работать все должно как то так.
Используется mavlink-routerd с конфигом /etc/mavlink.conf. Нужно указать эндпоинты для локального serial и наземки по ip-адресу zerotier:
```
[General]
TcpServerPort = 0

[UartEndpoint drone]
Device = /dev/ttyAMA0
Baud = 115200

[UdpEndpoint qgroundcontrol]
Mode = Normal
Address = gs_ip_from_zerotier
Port = 14550
```

Так как соединение является двунаправленным, автоматически получаем телеметрию в обе стороны.
