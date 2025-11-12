## Notes on using gk7205v300 camera with imx335 sensor

In the main, working with the camera is no different from other gk cameras. Lite or fpv is flashed in the same way, or lite is updated to fpv.
The presence and location of pins for USB and UART should be viewed on the seller's page. For example, the camera purchased at [link](https://aliexpress.ru/item/1005005492432144.html) has USB
on the connector for the FPC cable and are named in the description WIFI_DP and WIFI_DN (USB DP/DN).

The nuances concern the resolution settings. The 1080p mode (setting size: 1920x1080 in majestic.yaml) produces 15 frames / second, which is of course unacceptable. It is necessary in the file `/etc/sensors/imx335_i2c_4M.ini`
comment out (via `;`) the line `clock=27MHz` and set `Isp_FrameRate=30`, then reboot the camera. The corrected files are in the [imx335_gk7205v300](/imx335_gk7205v300) directory.
The `size: 2592x1520` mode also works and produces 20 fps, but the viewing angle of the picture does not change, which suggests interpolation. But it is not known from what resolution - to what. In fact, the delay in 1520p@20 is lower and is about 165 ms, in 1080p@30 - 185 ms.

Also needed is [gkrcparams](gkrcparams.md) for smoother picture.