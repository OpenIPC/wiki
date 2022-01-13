## Specialized device settings for Switcam HS303(v2)

A discussion of the operation of these cameras is available by a specialized subscription to [OpenIPC paywall](https://paywall.pw/openipc)

### Modified part from the /etc/network/interface file

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

### Modified part from the /etc/majestic.yaml file

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