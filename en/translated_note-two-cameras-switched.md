## Several cameras on one link

The cameras have a network interface, which in the case of two cameras can be used even without a switch, simply by connecting the four interface wires to each other. This interface will be used for communication between the cameras.
If /etc/network/interfaces is modified in approximately the following way:
```
auto eth0
iface eth0 inet dhcp
    hwaddress ether $(fw_printenv -n ethaddr || echo 00:24:B8:FF:FF:FF)

auto eth0:1
iface eth0:1 inet static
    address $(fw_printenv -n ipaddr || echo 192.168.1.9)
    netmask 255.255.255.0
```
then the cameras will have a sub-interface with the address specified in the env variable `ipaddr` or, if it is empty, specified in address. We need the cameras to have addresses from the same subnet, for example, let it be 192.168.1.9 and 192.168.1.10 for the "first" and "second" cameras.
The first one is the one with the wfb link and wifi-whistle. From the second one we only need a stream to an additional port, let's say 5601 to the address of the first camera.
If the second camera has openipc, you need to disable wfb on it via `daemon=0` in `datalink.conf` and configure the udp stream in majestic.yaml to 192.168.1.9:5601.
Now let's create a demo camera switching script `camswitch.sh` on the first camera:
```
function wfb_restart {
  kill -9 $(pidof wfb_tx)
  . /etc/wfb.conf
  wfb_tx -p ${stream} -u ${udp_port} -K /etc/drone.key -B ${bandwidth} -M ${mcs_index} -S ${stbc} -L ${ldpc} -G ${guard_interval } -k ${fec_k} -n ${fec_n} -T ${fec_timeout} -i ${link_id} ${wlan} &
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
Let's give it execution rights via `chmod +x camswitch.sh` and now we can switch between cameras by calling `camswitch.sh 1` or `camswitch.sh 2`.
The script stops wfb_tx, replaces udp_port in its config (the main camera sends to 5600 and the second to 5601) and starts it again, thus switching between streams.
You can connect a script call, for example, to [channels.sh](notes_cam_control.md) and control switching from some RC channel.