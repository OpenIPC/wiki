## Несколько камер на одном линке

У камер есть сетевой интерфейс, который в случае двух камер можно использовать даже без свича, просто соединив четыре провода интерфейса друг с другом. Этот интерфейс и будем использовать для связи между камерами.
Если /etc/network/interfaces доработать примерно таким образом:
```
auto eth0
iface eth0 inet dhcp
    hwaddress ether $(fw_printenv -n ethaddr || echo 00:24:B8:FF:FF:FF)

auto eth0:1
iface eth0:1 inet static
    address $(fw_printenv -n ipaddr || echo 192.168.1.9)
    netmask 255.255.255.0
```
то у камер появится саб-интерфейс с адресом, прописанным в переменной env `ipaddr` либо, если она пуста, указанным в address. Нам нужно, чтобы у камер были адреса из одной подсети, например пусть это будут 192.168.1.9 и 192.168.1.10 у "первой" и "второй" камер.
Первая - та, на которой расположен линк wfb и wifi-свисток. От второй нужен только поток на дополнительный порт, пусть 5601 на адрес первой камеры.
В случае, если на второй камере стоит openipc, нужно на ней отключить wfb через `daemon=0` в `datalink.conf` и настроить udp поток в majestic.yaml на 192.168.1.9:5601.
Теперь создадим на первой камере демонстрационный скрипт переключения камер `camswitch.sh`:
```
function wfb_restart {
  kill -9 $(pidof wfb_tx)
  . /etc/wfb.conf
  wfb_tx -p ${stream} -u ${udp_port} -K /etc/drone.key -B ${bandwidth} -M ${mcs_index} -S ${stbc} -L ${ldpc} -G ${guard_interval} -k ${fec_k} -n ${fec_n} -T ${fec_timeout} -i ${link_id} ${wlan} &
}

function cam_1 {
  # this is main cam, with wfb_tx
  sed -i 's/udp_port=5601/udp_port=5600/' /etc/wfb.conf
  wfb_restart
}

function cam_2 {
  # set '- udp: cam1ip:5601' in /etc/majestic.yaml on cam2
  sed -i 's/udp_port=5600/udp_port=5601/' /etc/wfb.conf
  wfb_restart
}

cam_$1
```
Дадим ему права на выполнение через `chmod +x camswitch.sh` и теперь мы можем переключаться между камерами, вызывая `camswitch.sh 1` или `camswitch.sh 2`.
Скрипт останавливает wfb_tx, заменяет в его конфиге udp_port (основная камера шлет на 5600 а вторая на 5601) и запускает заново, таким образом переключаясь между потоками.
Можно подключить вызов скрипта например к [channels.sh](notes_cam_control.md) и управлять переключением с какого то канала RC.
