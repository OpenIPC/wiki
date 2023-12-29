# OpenIPC Wiki
[Table of Content](../README.md)

Auto nightmode on devices without a light sensor
==============================

Not all devices have an onboard light sensor to determine whether night mode should be activated or not. 
For these devices, we can use the image sensor's analog gain value to switch. In low-light conditions, this value will be high, indicating the image sensor is applying gain to boost brightness. In well-lit conditions, this value will be low.

#### Step 1: determine if IR cut filter is set up correctly
This article assumes you have found and entered the correct GPIO pins for your IR cut filter and you are able to toggle the filter using the `IR-cut filter` button in the preview. During daylight conditions, in the preview, the image should not be pink.
If it is pink, most likely your pins are in the wrong order and they need to be swapped in `Majestic > Night Mode`.

#### Step 2: install night mode scripts
We need 2 scripts: the actual night mode script and the startup script that enables the night mode script at boot.

[autonight.sh](https://raw.githubusercontent.com/OpenIPC/device-mjsxj02hl/master/flash/autoconfig/usr/sbin/autonight.sh)

Copy `autonight.sh` to `/usr/sbin`

[S96autonight](https://raw.githubusercontent.com/OpenIPC/device-mjsxj02hl/master/flash/autoconfig/etc/init.d/S96autonight)

Copy `S96autonight` to `/etc/init.d/` and make it executable with `chmod +x /etc/init.d/S96autonight`

#### Step 3: tweak the sensor analog gain value
In `autonight.sh` you will find 3 settings:
```
again_high_target=14000
again_low_target=2000
pollingInterval=5
```

`again_high_target` is the gain value at which night mode will be enabled. Similarly, `again_low_target` is the value at which night mode is turned off. You can change these numbers to optimize for your particular setup.
`pollingInterval` indicates how often the script checks the sensor analog gain value. Lower values will result in quicker response, but may result in more "nervous" switching behavior in response to brief light flashes, etc.

**Note:** to restart the `autonight.sh` script, required e.g. if you have changed a setting, use `/etc/init.d/S96autonight restart`. To stop the script, e.g. if you want to observe the analog gain values without switching the IR filter,
use `/etc/init.d/S96autonight stop`. 
After stopping the script, you can run `/usr/sbin/autonight.sh` manually in a terminal to get log output.

#### Extra: viewing sensor analog gain value and current night mode status
Metrics are displayed at the `/metrics` endpoint in the web interface.

_The current analog gain value is displayed in `isp_again`:_
```
# HELP isp_again Analog Gain
# TYPE isp_again gauge
isp_again 2880
```

_The current night mode setting displayed in `night_enabled`:_
```
# HELP night_enabled Is night mode enabled
# TYPE night_enabled gauge
night_enabled 0
```
