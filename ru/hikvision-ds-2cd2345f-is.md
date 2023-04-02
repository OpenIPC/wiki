# OpenIPC Wiki
[Оглавление](../README.md)

Hikvision DS-2CD2345F-IS
--------------

**Внимание, на данный момент это просто рабочие заметки, а НЕ полная инструкция к действию !**

Среди камер продаваемых Ростелекомом существует модель Hikvision DS-2CD2345F-IS. От большинства прочих отличается тем, что оригинальной прошивки для неё, судя по всему, нет. Но железо поддерживается OpenIPC и значит не всё потеряно.

## Текущая ситуация
- Нужно использовать сборку для процессора hi3516av100, т.к. только в ней есть поддержка памяти NAND, а всё остальное идентично сборке для hi3516dv100.
- Переключение день/ночь реализовано дополнительным скриптом. Есть определённые проблемы на границах тёмного и светлого времени суток - в сумерках многократно переключается то в один то в другой режим. 
- Микрофон не работает.
- Запись на карту памяти не работает. 
- Вход и выход не работают.

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
setenv osmem 48M
setenv baseaddr 0x82000000

setenv bootargs 'mem=48M console=ttyAMA0,115200 panic=20 init=/init root=ubi0:rootfs rootfstype=ubifs ubi.mtd=3,2048 mtdparts=hinand:256k(boot),768k(wtf),3072k(kernel),-(ubi) of_mdio.higmacphy=0'
setenv bootcmd 'nand read ${baseaddr} 0x100000 0x300000; bootm ${baseaddr}'

setenv ethaddr 00:12:34:56:78:90    //задать MAC-адрес камеры, если не задан
setenv ipaddr 192.168.1.10          //задать IP-адрес камеры, если не задан
setenv serverip 192.168.1.2         //задать адрес компа с TFTP-сервером

saveenv
```
### Образы ядра и файловой системы 
```
mw.b ${baseaddr} ff 0x1000000
tftp ${baseaddr} uImage.${soc}
nand erase 0x100000 0x300000
nand write.i ${baseaddr} 0x100000 0x300000

mw.b ${baseaddr} ff 0x1000000
tftp ${baseaddr} rootfs.ubi.${soc}
nand erase 0x400000 0x7c00000
nand write.i ${baseaddr} 0x400000 ${filesize}

reset
```
Можно вводить команды одной строкой через **;**:
```
mw.b ${baseaddr} ff 0x1000000; tftp ${baseaddr} uImage.${soc}; nand erase 0x100000 0x300000; nand write ${baseaddr} 0x100000 0x300000

mw.b ${baseaddr} ff 0x1000000; tftp ${baseaddr} rootfs.ubi.${soc}; nand erase 0x400000 0x7c00000; nand write ${baseaddr} 0x400000 ${filesize}

reset
```
##№ Первый запуск
Не прерываем загрузку бута и наблюдаем лог запуска системы. Если всё прошло штатно и в использованной сборке ничего не отломано, то через несколько секунд увидим приглашение входа. Логинимся под пользователем root без пароля и вводим команду ifconfig eth0, чтобы увидеть полученный IP-адрес.
## Веб-интерфейс
Веб-интерфейс по умолчанию доступен по порту 85. Логин: admin, пароль: 12345. При первом входе будет предложено задать новый сложный пароль, который станет также и паролем root при входе в консоль через UART или SSH.
Основная часть системы — стример Majestic. Он выполняет функции захвата и трансляции изображения и делает всё остальное, что с этим связано. Надо настроить.
### Majestic -> Image Signal Processor (ISP)
- В поле Path to sensor configuration file выбрать /etc/sensors/ov4689_i2c_1080p.ini для разрешения 2МП либо /etc/sensors/ov4689_i2c_4M.ini для разрешения 4МП.
### Majestic -> Mainstream Video (Video0)
- Убедиться, что включен переключатель Enable Video0
- В поле Video0 codec выбрать вариант h265
### Majestic -> Substream Video (Video1)
- Включить переключатель Enable Video1
- В поле Video1 codec выбрать вариант h265
### Settings -> Reset…
- Нажать Reboot Camera для перезапуска.

В Preview только слайд-шоу, а если хочется видеопотока, то проще всего увидеть его в VLC, выбрав в меню пункт Открыть URL и введя одну из строк:

- rtsp://admin:password@ip-address:554/stream=0 — первый поток
- rtsp://admin:password@ip-address:554/stream=1 — второй поток
 
где: password — ваш пароль, ip-address — адрес камеры.

Если дефолтные значения параметров не устраивают и кажется, что картинка может быть лучше, можно поиграть с настройками сенсора и видеопотоков, но есть шанс сломать Majestic. Для восстановления работоспособности в меню Settings -> Reset… есть пункт Reset Majestic Settings. После его использования надо сделать ещё и Reboot Camera.
## Переключение день/ночь
При наступлении тёмного времени суток или выключении источников света, как правило, видеокамеры переходят в ночной режим. Происходит перевод изображения в чёрно-белый режим, отключается ИК-фильтр и включается ИК-подсветка. В обратной ситуации производятся обратные действия.

Система может определять отсутствие света либо по датчику, либо по изображению. Пока Majestic умеет работать только с датчиком. В этой модели камеры его нет. Значит надо задать параметры управляющих выходов, а управлять ими придётся с помощью скрипта.
### Пункт меню Majestic -> Night Mode:
 Настройка GPIO
- Включить Enable night mode
- Задать GPIO pin1 of signal for IRcut filter: 105
- Задать GPIO pin2 of signal for IRcut filter: 104
- Задать GPIO pin to turn on night mode illumination: 114

Теперь **Majestic** знает про **GPIO** и можно попробовать поуправлять переключением вручную из командной строки через **API**. Нужно войти в систему под пользователем **root** без пароля. Команды следующие:
```
curl http://ip-address/night/on         //включить ночной режим.
curl http://ip-address/night/off        //выключить ночной режим.
curl http://ip-address/night/toggle     //переключить режим.
```
Если всё работает, движемся дальше — автоматизируем процесс управления переключением режима на основе изменения времени экспозиции.

### Скрипт управления переключением режима
Создаём файл файл скрипта:
```
cat > /usr/sbin/checkexp.sh
```
… и вставляем содержимое через буфер обмена:
```
#!/bin/sh
sleep 10
login=$(cat /etc/httpd.conf | grep cgi-bin | cut -d':' -f2)
pass=$(cat /etc/httpd.conf | grep cgi-bin | cut -d':' -f3)
chtime=300 #change time to check isp_again, default 300 sec
chexp=15 #change isp_again threshold (15-30)
day=1

while true; do

exp=$(curl -s http://localhost/metrics | grep ^isp_again | cut -d' ' -f2)
bri=`expr $exp / 1000`
logger "Analog gain $bri"

    if [ $bri -gt $chexp -a $day -eq 1 ] ;then
	day=0
	curl -u $login:$pass http://localhost/night/on
	logger "Night mode ON"
    fi
	
	if [ $bri -le $chexp -a $day -eq 0 ] ;then
	day=1
	curl -u $login:$pass http://localhost/night/off
	logger "Night mode OFF"
    fi

sleep $chtime
done
```
Сохраняем файл нажав комбинацию **Ctrl+D** и даём разрешение на выполнение:
```
chmod +x /usr/sbin/checkexp.sh
```
Если теперь запустить скрипт, то он начнёт анализировать экспозицию и управлять ночным режимом. По умолчанию интервал проверки задан длительностью 300 секунд, то бишь 5 минут.

Для того, чтобы скрипт запускался автоматически при старте системы, создаём файл запуска:
```
cat > /etc/init.d/S99rc.local
```
… и вставляем содержимое:
```
./usr/sbin/checkexp.sh > /dev/null 2>&1 &
exit 0
```
Сохраняем файл нажав комбинацию *Ctrl+D* и даём разрешение на выполнение:
```
chmod +x /etc/init.d/S99rc.local
```
Теперь можно перезапускать камеру и радоваться что переключение режима, хоть и не идеально, но работает.
