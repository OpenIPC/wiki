[Table of Content](../README.md)

Integrate OpenIPC into HomeKit
---

Currently OpenIPC doesn't have native HomeKit support yet, integration is made by 3rd party package [go2rtc](https://github.com/AlexxIT/go2rtc "go2rtc"), thanks [@gtxaspec](https://github.com/gtxaspec "@gtxaspec") for adding this package into OpenIPC

### Hardware requirement

Since the compiled binary file will 3.3MB in size, flash chip size should be 16MB  at least, DDR size should be 128MB at least

### Compile go2rtc package

Install go and upx first
```
apt update
apt install golang upx
```
- ####  Method 1: Compile the whole firmware
Edit board config file in `firmware/br-ext-chip-xxxx/configs` directory, add the following line to enable the go2rtc package
```
BR2_PACKAGE_GO2RTC=y
```
then run
```
make distclean
make all BOARD=board_config_name
```
- #### Method2: Compile the package only
```
make distclean
make br-go2rtc-rebuild BOARD=board_config_name
```
The compiled go2rtc binary file will located at `firmware/output/per-package/go2rtc/target/usr/bin`, default config file at `firmware/output/per-package/go2rtc/target/etc`

### Edit config file

Put config file `go2rtc.yaml` into `/etc/` directory, example config:

```
log:
  level: info  # default level
  api: trace
  exec: debug
  ngrok: info
  rtsp: warn
  streams: error
  webrtc: fatal

rtsp:
  listen: ":8553"

webrtc:
  candidates:
    - stun:8555

streams:
  openipc: rtsp://admin:12345@127.0.0.1/stream=0

homekit:
  openipc:                   # same stream ID from streams list
    pin: 19550224           # custom PIN, default: 19550224
    name: openipc-ssc30kq      # custom camera name, default: generated from stream ID
    device_id: openipc       # custom ID, default: generated from stream ID
```

### Run go2rtc

```
/usr/bin/go2rtc -config /etc/go2rtc.yaml &
```

Open the Home app on your Apple device, click the `+` button on the top-right corner, the OpenIPC camera should appear there automatically, enter the pin numbers in the config file to pair with it.

### Autorun on startup

Add the following lines into /etc/rc.local

```
/usr/bin/go2rtc -config /etc/go2rtc.yaml &
```

### Limitations

- No HomeKit Secure Video support yet
- No motion sensor support yet
- No two-way audio support yet

