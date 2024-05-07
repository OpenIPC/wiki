# OpenIPC Wiki
[Table of Content](../README.md)

Wyze integration
----------------
This is where we'll be writing down our guide to flashing new devices and reports on our experiments.  The tables below also include some "clones" manufactured by Hualai, the ODM vendor for Wyze for reference.

### Known camera revisions:

| MODEL     | IC 25466- | FCC ID         | PCB VER                           | SoC      | WIFI                  | MAC PREFIX | SUPPORTED | NOTES                                                     |
|-----------|-----------|----------------|-----------------------------------|----------|-----------------------|------------|-----------|-----------------------------------------------------------|
| WYZEC2    |           | 2ANJHWYZEC2    | 2019-06-38                        | T20X BGA | SDIO: Realtek 8189FTV | 2C:AA:8E   | YES       | https://gist.github.com/csev1755/e60abe15d8708e0d2b0a592e808b2022  |
| WYZECP1   |           | 2ANJHHWYZECP1  | DF3-IFPM01 V1.4                   | T20X BGA | SDIO: Realtek 8189ES  | 2C:AA:8E   | YES       |                                                           |
| WYZEC3    | WYZEC3    | 2AUIUWYZEC3    | WYZEV3_T31GC2053 V1.4_20201010    | T31ZX    | SDIO: Realtek 8189FTV | 7C:78:B2   | YES       | https://t.me/openipc/49957 https://youtu.be/t7Nzo-KXTH0   | 
| WYZEC3    | WYZEC3A   | 2AUIUWYZEC3A   | WYZEV3_T31GC2053 V1.2_20200715    | T31X     | SDIO: Realtek 8189FTV | 7C:78:B2   | YES       | https://youtu.be/jm4wze_HY78                              |
| WYZEC3    | WYZEC3A   | 2AUIUWYZEC3A   | WYZEV3_T31GC2053 V2.02_20210523   | T31ZX    | SDIO: AltoBeam 6031   | D0:3F:27   | YES       | https://t.me/openipc/49049 https://t.me/openipc/49050     |
| WYZEC3    | WYZEC3A   | 2AUIUWYZEC3A   | WYZEV3_T31GC2053 V2.03_20211206   | T31X     | SDIO: AltoBeam 6031   | D0:3F:27   | YES       | https://t.me/openipc/45444 https://t.me/openipc/48942     |
| WYZEC3    | WYZEC3B   | 2AUIUWYZEC3B   | WYZEV3_T31GC2053 V2.02_20210523   | T31ZX    | SDIO: Realtek 8189FTV | D0:3F:27   | YES       | https://t.me/openipc/38728 https://t.me/openipc/38753     |
| WYZEC3    | WYZEC3B   | 2AUIUWYZEC3B   | WYZEV3_T31GC2053 V2.03_20211206   | T31X     | SDIO: Realtek 8189FTV | D0:3F:27   | YES       | https://t.me/openipc/76036                                |
| WYZEC3    | WYZEC3F   | 2AUIUWYZEC3F   | WYZEV3_T31AGC2053 V3.2_20210714   | T31A BGA | SDIO: AltoBeam 6031   | D0:3F:27   | YES       | https://t.me/openipc/43299 https://t.me/openipc/38755 https://t.me/openipc/38757     |
| WYZEC3    | WYZEC3F   | 2AUIUWYZEC3F   | WYZEV3_T31AGC2053 V3.2_20210714   | T31A BGA | SDIO: AltoBeam 6031   | D0:3F:27   | YES       | https://youtu.be/VkqX9yg0odU                              |
| WVDBV1    | WVDB1A    | 2AUIUWVDB1A    | WYZEDB3_MB_T31_2.2                | T31X     | SDIO: Realtek 8189FTV | 7C:78:B2   | YES       |                                                           |
| WYZECP2   | WYZECP2A  | 2AUIUWYZECP2   | DF3-MCU-S01-V2.2                  | T31X     | SDIO: AltoBeam 6031   | 7C:78:B2   | YES       |                                                           |
| WYZECPAN3 | WYZECPAN3 | 2AUIUWYZECPAN3 | WYZE PAN V3 MB V 1.3              | T31X     | SDIO: AltoBeam 6031   | D0:3F:27   | NO        | NOT SUPPORTED - Secure Boot ENABLED                       |
| WYZEC3P   | WYZEC3P   | 2AUIUWYZEC3P   | WYZEV3PRO_T40GC4653_v2.2_20220228 | T40XP    | SDIO: Realtek 8192FS  | D0:3F:27   | UNTESTED  | UNTESTED                                                  |
| WVOD2     | WVOD2     | 2AUIUWVOD2     | HL_WCO2 MAIN01 V1.0               | T31ZX    | SDIO: BCM43438        | D0:3F:27   | UNTESTED  | UNTESTED - Ingenic Zeratul Battery Platform               |
| ATOMCAM2  |           |                | V3C_T31GC2063 V1.1_202001110      | T31ZX    | SDIO: AltoBeam 6031   | 7C:DD:E9   | YES       | AtomCam 2 Japan http://www.atomtech.co.jp                 |
| PERSONALCAM  |           |                |                                | T31??    | SDIO: AltoBeam 6031   | ??:??:??   | YES       | Camera Personal Wifi https://tienda.personal.com.ar       |


GPIO:

| MODEL     | IRCUT1 | IRCUT2 | IR LED1 | IR LED2 | WIFI   | LED1   | LED2   | SPEAKER | TF_EN  | TF_CD  | SD_ABLE | SD_PWR |BUTTON1 | BUTTON2 | SUB1G  | USB    |
|-----------|--------|--------|---------|---------|--------|--------|--------|---------|--------|--------|---------|--------|--------|---------|--------|--------|
| WYZEC2    | GPIO25 | GPIO26 | GPIO49  |         | GPIO62 | GPIO38 | GPIO39 | GPIO63  | GPIO43 | GPIOXX | GPIO48  |        | GPIO46 |         |        | GPIO47 |
| WYZECP1   | GPIO26 | GPIO25 | GPIO49  |         | GPIO62 | GPIO38 | GPIO39 | GPIO63  | GPIO43 | GPIOXX | GPIO48  |        | GPIO46 |         |        | GPIO47 |
| WYZEC3    | GPIO53 | GPIO52 | GPIO47  | GPIO49  | GPIO57 | GPIO38 | GPIO39 | GPIO63  | GPIO50 | GPIO62 | GPIO48  |        | GPIO51 |         |        |        |
| WYZEDBV1  | GPIO53 | GPIO52 | PWM2    |         | GPIO57 | GPIO38 | GPIO39 | GPIO58  |        |        | GPIO62  |        | GPIO06 | GPIO07  | GPIO61 |        |
| WYZECP2   | GPIO49 | GPIO50 | GPIO60  |         | GPIO58 | GPIO38 | GPIO39 | GPIO07  | GPIO47 | GPIO48 | GPIO54  |        | GPIO06 |         |        |        |
| WYZECPAN3 |        |        |         |         |        |        |        |         |        |        |         |        |        |         |        |        |
| WYZEC3PRO | GPIO118| GPIO119| GPIO66  | GPIO67  | GPIO57 | GPIO105| GPIO106| GPIO63  | GPIO58 | GPIO70 | GPIO71  | GPIO121| GPIO107|         |        |        |
| WVOD2     |        |        |         |         |        |        |        |         |        |        |         |        |        |         |        |        |
| ATOMCAM2  | GPIO53 | GPIO52 | GPIO26  |         | GPIO57 | GPIO38 | GPIO39 | GPIO63  | GPIO50 | GPIO59 | GPIO48  |        | GPIO51 |         |        | GPIO47 |
| PERSONALCAM  |        |        | GPIO14  |         | GPIO57 | GPIO47 | GPIO48 | GPIO63  | GPIO50 | GPIO59 | GPIO39  |        |        |         |        |        |


MOTORS: 
| MODEL     | HST1   | HST2   | HST3   | HST4   | VST1   | VST2   | VST3   | VST4   | HMAX | VMAX  | MAX SPEED |
|-----------|--------|--------|--------|--------|--------|--------|--------|--------|------|-------|-----------|
| WYZECP1   | GPIO54 | GPIO53 | GPIO52 | GPIO51 | GPIO75 | GPIO76 | GPIO79 | GPIO80 | 2590 | 720   | 900       |
| WYZECP2   | GPIO52 | GPIO53 | GPIO57 | GPIO51 | GPIO59 | GPIO61 | GPIO62 | GPIO63 | 2540 | 720   | 900       |
| WYZECPAN3 |        |        |        |        |        |        |        |        |      |       |           |
| PERSONALCAM | GPIO49 | GPIO57 | GPIO54 | GPIO51 | GPIO60 | GPIO61 | GPIO62 | GPIO63 | 2130 | 1600  | 900       |

---

## Wyze Cam Pan v3 cameras have hardware lock in secureboot and cannot be upgraded to OpenIPC!

---

### OpenIPC installation

> [!CAUTION]
> The link below no longer works, Please replace the link with one that works or is updated.

[Use these scripts](https://github.com/themactep/device-wyze-v3/blob/master/installation.md) to convert your Wyze Cam V3 to OpenIPC.

### Current issues

* ~~Exposure does not work well https://github.com/OpenIPC/majestic/issues/102~~
* ~~SD card does not work in the U-Boot (power is available)~~ fixed
* ~~Problem with loading u-boot from an microSD card. It doesn't reach the promt. Not only on wyze v3 (https://t.me/openipc_modding/179369), but also on another board T31L (https://t.me/openipc/47739). Most likely it will be IMPOSSIBLE, because in the camera there is a microSD power management MOSFET, which must be turned on BEFORE booting from the card (the experiment with not fully loaded u-boot was possible due to direct power supply to the microSD card, bypassing the transistor). Please confirm my version if it is not possible otherwise.~~ impossible without modification (direct 3.3V power supply to the microSD card reader)
