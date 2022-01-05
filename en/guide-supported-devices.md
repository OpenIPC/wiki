![OpenIPC logo](https://cdn.themactep.com/images/logo_openipc.png "OpenIPC logo")

## Supported devices

Unfortunately, we cannot provide you a long list of devices that are undoubtedly
compatible with our firmware. Camera manufacturers tend to change hardware
design and swap components even within the same model line, without any notice.

Below, we listed some of the cameras we had in our possession, but again, there
is no guarantee that if you buy one of those cameras today you won't end up with
unsupported hardware on your hands.

Somewhat working method to determine if your camera is supported by the recent
version of our firmware is to open[^1] the camera case and take a look at the
chip markings. Then look up your chip in the [list of supported hardware][1]
and check its development status.

If you still have your doubts, take as hi-res pictures of the hardware close-ups
and ask for help in one of our Telegram groups.

[^1]: Attention! Doing so, you are taking full responsibility for your actions.
Most likely, opening the case will void the warranty of the device. We cannot
be held liable for any damage to the camera, yourself, your house, your pets,
or anything else. If you don't feel comfortable around hardware, this project
may not be right for you.

_If you have another supported device to add, please do it [here][2]._

| Brand    | Model              | Processor   | Sensor | Flash Memory | LAN | WLAN      | USB  | Card |
|----------|--------------------|-------------|--------|--------------|-----|-----------|------|------|
|          |                    |             |        |              |     |           |      |      |
| Anjoy    | MS-J10             | SSC335      | IMX307 |              | Yes | No        | Yes  | No   |
| Anjoy    | YM-J10D            | SSC337      | IMX307 |              | Yes | No        | Yes  | No   |
|          |                    |             |        |              |     |           |      |      |
| LTV      | CNE-724 48         | HI3516EV200 |        |              | Yes | No        | No   | Yes  |
|          |                    |             |        |              |     |           |      |      |
| Rotek    | Switcam HS303 (v1) | HI3518EV200 |        |              | No  | RTL8188FU | WiFi | Yes  |
| Rotek    | Switcam HS303 (v2) | HI3518EV200 | OV9732 | GD25Q128CSIG | No  | RTL8188EU | WiFi | Yes  |
| Rotek    | Switcam HS303 (v3) | HI3518EV200 |        |              | No  | RTL8188EU | WiFi | Yes  |
|          |                    |             |        |              |     |           |      |      |
| Xiaomi   | MJSXJ02HL          | HI3518EV300 |        |              | No  |           |      | Yes  |
|          |                    |             |        |              |     |           |      |      |
| Zenotech | HI3516D_MB_V13_RA  | HI3516DV100 | OV9689 | GD25Q128CSIG | Yes | No        |      | No   |

[1]: https://github.com/OpenIPC/firmware#current-development-status-
[2]: https://github.com/OpenIPC/wiki/blob/master/en/guide-supported-devices.md
