# OpenIPC Wiki
[Table of Content](../index.md)

A collection of practical networking settings
---------------------------------------------


### ETH0 | DHCP for all platforms

```
auto eth0
iface eth0 inet dhcp
    hwaddress ether $(fw_printenv -n ethaddr || echo 00:24:B8:FF:FF:FF)
    #udhcpc_opts -O search -O ntpsrv -O hostname                                                                                                                                        <= proposition
    #pre-up echo -e "nameserver 77.88.8.8\nnameserver 8.8.4.4\n" >/tmp/resolv.conf                                                                                                      <= dynamic
    #pre-up echo -e "server 0.time.openipc.org iburst\nserver 1.time.openipc.org iburst\nserver 2.time.openipc.org iburst\nserver 3.time.openipc.org iburst" >/tmp/ntp.conf             <= proposition
```


### ETH0 | Static for all platforms

```
auto eth0
iface eth0 inet static
    address 192.168.1.10
    netmask 255.255.255.0
    gateway 192.168.1.1
    hwaddress ether $(fw_printenv -n ethaddr || echo 00:24:B8:FF:FF:FF)
    pre-up echo -e "nameserver 77.88.8.8\nnameserver 8.8.4.4\n" >/tmp/resolv.conf                                                                                                       <= work
    pre-up echo -e "server 0.time.openipc.org iburst\nserver 1.time.openipc.org iburst\nserver 2.time.openipc.org iburst\nserver 3.time.openipc.org iburst" >/tmp/ntp.conf              <= proposition
```


### ETH0:1 | Alias example

```
auto eth0
iface eth0:1 inet static
    address $(fw_printenv -n ipaddr || echo 192.168.1.10)
    netmask 255.255.255.0
```


### ETH2 | Chinese WiFi

```
auto eth2
iface eth2 inet dhcp
    pre-up wifi xm711
    pre-up wpa_passphrase "SSID" "password" >/tmp/wpa_supplicant.conf
    pre-up sed -i '2i \\tscan_ssid=1' /tmp/wpa_supplicant.conf
    pre-up (sleep 3; wpa_supplicant -B -D nl80211 -i eth2 -c/tmp/wpa_supplicant.conf)
    post-down killall -q wpa_supplicant
```


### PPP0 | T31 | CamHi/Xin

```
auto ppp0
iface ppp0 inet ppp
    pre-up echo 61 > /sys/class/gpio/export
    pre-up echo out > /sys/class/gpio/gpio61/direction
    pre-up echo 0 > /sys/class/gpio/gpio61/value
    pre-up sleep 7
    post-down echo 1 > /sys/class/gpio/gpio61/value
    post-down echo 61 > /sys/class/gpio/unexport
```


### USB0 | HI3516EV300/GK7205V300 | CamHi/Xin

```
auto usb0
iface usb0 inet dhcp
    pre-up echo 9 > /sys/class/gpio/export
    pre-up echo out > /sys/class/gpio/gpio9/direction
    pre-up echo 0 > /sys/class/gpio/gpio9/value
    pre-up modprobe usbserial vendor=0x2c7c product=0x6026
    pre-up modprobe rndis_host
    pre-up sleep 10
    post-down echo 1 > /sys/class/gpio/gpio9/value
    post-down echo 9 > /sys/class/gpio/unexport
```


### WG0 | All platforms

```
auto wg0
iface wg0 inet static
    address 192.168.99.1
    netmask 255.255.255.0
    pre-up modprobe wireguard
    pre-up ip link add dev wg0 type wireguard
    pre-up wg setconf wg0 /etc/wireguard.conf
    post-down ip link del dev wg0
```


### WLAN0 | GM8135 | Unknown

```
auto wlan0
iface wlan0 inet dhcp
     pre-up modprobe mac80211
     pre-up modprobe 8188eu
     pre-up wpa_passphrase "SSID" "password" >/tmp/wpa_supplicant.conf
     pre-up sed -i '2i \\tscan_ssid=1' /tmp/wpa_supplicant.conf
     pre-up (sleep 3; wpa_supplicant -B -D wext -i wlan0 -c/tmp/wpa_supplicant.conf)
```


### WLAN0 | HI3516EV200/GK7205V200/GK7205V210 | CamHi/Xin

```
auto wlan0
iface wlan0 inet dhcp
    pre-up echo 9 > /sys/class/gpio/export
    pre-up echo out > /sys/class/gpio/gpio9/direction
    pre-up echo 0 > /sys/class/gpio/gpio9/value
    pre-up modprobe mt7601u
    pre-up wpa_passphrase "SSID" "password" >/tmp/wpa_supplicant.conf
    pre-up sed -i '2i \\tscan_ssid=1' /tmp/wpa_supplicant.conf
    pre-up sleep 3
    pre-up wpa_supplicant -B -D nl80211 -i wlan0 -c/tmp/wpa_supplicant.conf
    post-down killall -q wpa_supplicant
    post-down echo 1 > /sys/class/gpio/gpio9/value
    post-down echo 9 > /sys/class/gpio/unexport
```


### WLAN0 | HI3516EV300/GK7205V300 | CamHi/Xin

```
auto wlan0
iface wlan0 inet dhcp
    pre-up devmem 0x100C0080 32 0x530
    pre-up echo 7 > /sys/class/gpio/export
    pre-up echo out > /sys/class/gpio/gpio7/direction
    pre-up echo 0 > /sys/class/gpio/gpio7/value
    pre-up modprobe mt7601u
    pre-up wpa_passphrase "SSID" "password" >/tmp/wpa_supplicant.conf
    pre-up sed -i '2i \\tscan_ssid=1' /tmp/wpa_supplicant.conf
    pre-up sleep 3
    pre-up wpa_supplicant -B -D nl80211 -i wlan0 -c/tmp/wpa_supplicant.conf
    post-down killall -q wpa_supplicant
    post-down echo 1 > /sys/class/gpio/gpio7/value
    post-down echo 7 > /sys/class/gpio/unexport
```


### WLAN0 | HI3518EV300 | Unknown

```
auto wlan0
iface wlan0 inet dhcp
    pre-up modprobe rtl8188fu
    pre-up wpa_passphrase "SSID" "password" >/tmp/wpa_supplicant.conf
    pre-up sed -i '2i \\tscan_ssid=1' /tmp/wpa_supplicant.conf
    pre-up sleep 3
    pre-up wpa_supplicant -B -D nl80211 -i wlan0 -c/tmp/wpa_supplicant.conf
    post-down killall -q wpa_supplicant
```


### WLAN0 | SSC335 | Apical

```
auto wlan0
iface wlan0 inet dhcp
    pre-up echo 14 > /sys/class/gpio/export
    pre-up echo out > /sys/class/gpio/gpio14/direction
    pre-up echo 1 > /sys/class/gpio/gpio14/value
    pre-up echo '00:24:B8:FF:FF:FF' >/tmp/.mac.info
    pre-up modprobe mac80211
    pre-up insmod /lib/modules/4.9.84/sigmastar/ssw101b_wifi_usb.ko
    pre-up wpa_passphrase "SSID" "password" >/tmp/wpa_supplicant.conf
    pre-up sed -i '2i \\tscan_ssid=1' /tmp/wpa_supplicant.conf
    pre-up sleep 3
    pre-up wpa_supplicant -B -D wext -i wlan0 -c/tmp/wpa_supplicant.conf
    post-down killall -q wpa_supplicant
    post-down echo 0 > /sys/class/gpio/gpio14/value
    post-down echo 14 > /sys/class/gpio/unexport
```


### WLAN0 | SSC337DE | Tiandy

```
auto wlan0
iface wlan0 inet dhcp
    pre-up echo 14 > /sys/class/gpio/export
    pre-up echo out > /sys/class/gpio/gpio14/direction
    pre-up echo 1 > /sys/class/gpio/gpio14/value
    pre-up modprobe cfg80211
    pre-up insmod /lib/modules/4.9.84/sigmastar/rtl8192eu.ko
    pre-up wpa_passphrase "SSID" "password" >/tmp/wpa_supplicant.conf
    pre-up sed -i '2i \\tscan_ssid=1' /tmp/wpa_supplicant.conf
    pre-up sleep 3
    pre-up wpa_supplicant -B -D nl80211 -i wlan0 -c/tmp/wpa_supplicant.conf
    post-down killall -q wpa_supplicant
    post-down echo 1 > /sys/class/gpio/gpio14/value
    post-down echo 14 > /sys/class/gpio/unexport
```


### WLAN0 | T10 | Netcam

```
auto wlan0
iface wlan0 inet dhcp
    pre-up modprobe mac80211
    pre-up modprobe mt7601sta
    pre-up wpa_passphrase "SSID" "password" >/tmp/wpa_supplicant.conf
    pre-up sed -i '2i \\tscan_ssid=1' /tmp/wpa_supplicant.conf
    pre-up sleep 3
    pre-up wpa_supplicant -B -D nl80211 -i wlan0 -c/tmp/wpa_supplicant.conf
    post-down killall -q wpa_supplicant
```


### WLAN0 | T31 | CamHi/Xin

```
auto wlan0
iface wlan0 inet dhcp
    pre-up echo 61 > /sys/class/gpio/export
    pre-up echo out > /sys/class/gpio/gpio61/direction
    pre-up echo 0 > /sys/class/gpio/gpio61/value
    pre-up wpa_passphrase "xxxxxx" "xxxxxx" >/tmp/wpa_supplicant.conf
    pre-up sed -i '2i \\tscan_ssid=1' /tmp/wpa_supplicant.conf
    pre-up sleep 3
    pre-up wpa_supplicant -B -D wext -i wlan0 -c/tmp/wpa_supplicant.conf
    post-down killall -q wpa_supplicant
    post-down echo 1 > /sys/class/gpio/gpio61/value
    post-down echo 61 > /sys/class/gpio/unexport
```
