# OpenIPC Wiki
[Table of Content](../README.md)

A collection of practical networking settings
---------------------------------------------

> Attention! If something does not work, run `ifdown -v <iface>; ifup -v <iface>` and check the output!

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
    up /usr/sbin/ntpd -N -q
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

### WLAN0 | Update SSID & PWD from SD card

```
auto wlan0
iface wlan0 inet dhcp
    sleep 2
    pre-up wlanssid=$(cat /mnt/mmcblk0p1/wlanssid); if [ $wlanssid ]; then fw_setenv wlanssid $wlanssid; fi
    pre-up wlanpass=$(cat /mnt/mmcblk0p1/wlanpass); if [ $wlanpass ]; then fw_setenv wlanpass $wlanpass; fi
    post-up wpa_passphrase "$(fw_printenv -n wlanssid || echo OpenIPC)" "$(fw_printenv -n wlanpass || echo OpenIPC12345)" > /tmp/wpa_supplicant.conf
    post-up sed -i '2i \\tscan_ssid=1' /tmp/wpa_supplicant.conf
    post-up wpa_supplicant -B -i wlan0 -D nl80211,wext -c /tmp/wpa_supplicant.conf
    post-down killall -q wpa_supplicant
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

### WLAN0 | GK7205V200 | RTL8188

```
auto wlan0
iface wlan0 inet dhcp
    pre-up echo 57 > /sys/class/gpio/export
    pre-up echo out > /sys/class/gpio/gpio57/direction
    pre-up echo 0 > /sys/class/gpio/gpio57/value
    pre-up modprobe mac80211
    pre-up sleep 1
    pre-up insmod /lib/modules/4.9.37/extra/rtl8188fu.ko
    pre-up sleep 1
    pre-up wpa_passphrase "OpenIPC_NFS" "project2021" >/tmp/wpa_supplicant.conf
    pre-up sed -i '2i \\tscan_ssid=1' /tmp/wpa_supplicant.conf
    pre-up sleep 3
    pre-up wpa_supplicant -B -Dnl80211 -i wlan0 -c/tmp/wpa_supplicant.conf
    post-down killall -q wpa_supplicant
    post-down echo 1 > /sys/class/gpio/gpio57/value
    post-down echo 57 > /sys/class/gpio/unexport

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

### WLAN0 | GK7205V300 + ATBM603X | Unknown

```
auto wlan0
iface wlan0 inet dhcp
    pre-up devmem 0x100C0080 32 0x530
    pre-up echo 7 > /sys/class/gpio/export
    pre-up echo out > /sys/class/gpio/gpio7/direction
    pre-up echo 0 > /sys/class/gpio/gpio7/value
    pre-up modprobe mt7601u
    pre-up modprobe atbm603x_wifi_usb
    pre-up wpa_passphrase "SSID" "password" >/tmp/wpa_supplicant.conf
    pre-up sed -i '2i \\tscan_ssid=1' /tmp/wpa_supplicant.conf
    pre-up sleep 3
    pre-up wpa_supplicant -B -D nl80211 -i wlan0 -c/tmp/wpa_supplicant.conf
    post-down killall -q wpa_supplicant
    post-down echo 1 > /sys/class/gpio/gpio7/value
    post-down echo 7 > /sys/class/gpio/unexport
```

Note: Enter commands in U-Boot console to enable the wifi device

```
fw_setenv wlandev atbm603x-generic-usb
saveenv
```

### WLAN0 | HI3518EV200 | CamHi/Xin

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


### WLAN0 | HI3518EV200 | CIP37210 and HS303v1

```
auto wlan0
iface wlan0 inet dhcp
    pre-up echo 3 > /sys/class/gpio/export
    pre-up echo out > /sys/class/gpio/gpio3/direction
    pre-up echo 1 > /sys/class/gpio/gpio3/value
    pre-up modprobe mac80211
    pre-up sleep 1
    pre-up insmod /lib/modules/4.9.37/extra/rtl8188fu.ko
    pre-up sleep 1
    pre-up wpa_passphrase "SSID" "password" >/tmp/wpa_supplicant.conf
    pre-up sed -i '2i \\tscan_ssid=1' /tmp/wpa_supplicant.conf
    pre-up ifconfig wlan0 up
    pre-up wpa_supplicant -B -Dnl80211 -iwlan0 -c/tmp/wpa_supplicant.conf
    pre-up sleep 3
    #pre-up echo -e "nameserver 77.88.8.8\nnameserver 8.8.4.4\n" >/tmp/resolv.conf
    post-down killall -q wpa_supplicant
    post-down echo 0 > /sys/class/gpio/gpio3/value
    post-down echo 3 > /sys/class/gpio/unexport
```


### WLAN0 | HI3518EV200 | HS303v2

```
auto wlan0
iface wlan0 inet dhcp
    pre-up echo 54 > /sys/class/gpio/export
    pre-up echo out > /sys/class/gpio/gpio54/direction
    pre-up echo 1 > /sys/class/gpio/gpio54/value
    pre-up modprobe r8188eu
    pre-up sleep 1
    pre-up wpa_passphrase "SSID" "password" >/tmp/wpa_supplicant.conf
    pre-up sed -i '2i \\tscan_ssid=1' /tmp/wpa_supplicant.conf
    pre-up ifconfig wlan0 up
    pre-up wpa_supplicant -B -Dwext -iwlan0 -c/tmp/wpa_supplicant.conf
    pre-up sleep 3
    post-down killall -q wpa_supplicant
    post-down echo 0 > /sys/class/gpio/gpio54/value
    post-down echo 54 > /sys/class/gpio/unexport
```


### WLAN0 | HI3518EV200 | HS303v3 and IPC-136W

```
auto wlan0
iface wlan0 inet dhcp
    pre-up devmem 0x200f000c 32 0x0
    pre-up echo 7 > /sys/class/gpio/export
    pre-up echo out > /sys/class/gpio/gpio7/direction
    pre-up echo 1 > /sys/class/gpio/gpio7/value
    pre-up modprobe r8188eu
    pre-up sleep 1
    pre-up wpa_passphrase "SSID" "password" >/tmp/wpa_supplicant.conf
    pre-up sed -i '2i \\tscan_ssid=1' /tmp/wpa_supplicant.conf
    pre-up ifconfig wlan0 up
    pre-up wpa_supplicant -B -Dwext -iwlan0 -c/tmp/wpa_supplicant.conf
    pre-up sleep 3
    post-down killall -q wpa_supplicant
    post-down echo 0 > /sys/class/gpio/gpio7/value
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


### WLAN0 | HI3518EV300 | MJSXJ02HL

```
auto wlan0
iface wlan0 inet dhcp
    pre-up devmem 0x112C0048 32 0x1D54
    pre-up devmem 0x112C004C 32 0x1174
    pre-up devmem 0x112C0064 32 0x1174
    pre-up devmem 0x112C0060 32 0x1174
    pre-up devmem 0x112C005C 32 0x1174
    pre-up devmem 0x112C0058 32 0x1174
    pre-up devmem 0x10020028 32 0x28000000
    pre-up devmem 0x10020028 32 0x20000000
    pre-up modprobe cfg80211
    pre-up insmod /lib/modules/4.9.37/external/8189fs_kasito.ko
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


### WLAN0 | MT7601U | T31 | CamHi/Xin

```
fw_setenv wlandevice mt7601u-t31-camhi
fw_setenv wlanssid MySSID
fw_setenv wlanpass MyPassword
```


### WLAN0 | T31 | Xiaomi MJSXJ03HL 2K

```
auto wlan0
iface wlan0 inet dhcp
    pre-up modprobe mac80211
    pre-up insmod /lib/modules/rtl8189ftv.ko
    pre-up wpa_passphrase "SSID" "password" >/tmp/wpa_supplicant.conf
    pre-up sed -i '2i \\tscan_ssid=1' /tmp/wpa_supplicant.conf
    pre-up sleep 1
    pre-up wpa_supplicant -B -D nl80211 -i wlan0 -c/tmp/wpa_supplicant.conf
    post-down killall -q wpa_supplicant
```

### WLAN0 | T31 + ATBM6031 SDIO | Wyze V3, HL-CAM04

```
auto wlan0
iface wlan0 inet dhcp
    pre-up modprobe mac80211
    pre-up modprobe atbm603x_wifi_sdio
    pre-up wpa_passphrase "SSID" "password" >/tmp/wpa_supplicant.conf
    pre-up sed -i '2i \\tscan_ssid=1' /tmp/wpa_supplicant.conf
    pre-up sleep 1
    pre-up wpa_supplicant -B -D nl80211 -i wlan0 -c/tmp/wpa_supplicant.conf
    post-down killall -q wpa_supplicant
```

### WLAN0 | T31 | RTL8188FU | iFlytek

```
auto wlan0
iface wlan0 inet dhcp
    pre-up echo 10 > /sys/class/gpio/export
    pre-up echo out > /sys/class/gpio/gpio10/direction
    pre-up echo 1 > /sys/class/gpio/gpio10/value
    pre-up modprobe mac80211
    pre-up sleep 1
    pre-up insmod /lib/modules/8188fu.ko
    pre-up sleep 1
    pre-up wlan_addr=$(fw_printenv -n wlanaddr); if [ -n "$wlan_addr" ]; then ip link set dev wlan0 address $wlan_addr; fi
    post-up wpa_passphrase "$(fw_printenv -n wlanssid || echo OpenIPC)" "$(fw_printenv -n wlanpass || echo OpenIPC12345)" > /tmp/wpa_supplicant.conf
    post-up sed -i '2i \\tscan_ssid=1' /tmp/wpa_supplicant.conf
    post-up wpa_supplicant -B -i wlan0 -D nl80211,wext -c /tmp/wpa_supplicant.conf
    post-down killall -q wpa_supplicant
```
