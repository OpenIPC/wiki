# OpenIPC Wiki
[Table of Content](../README.md)

Dahua DH-IPC-HFW2449SP-S-IL
---

4 MP bullet dual-illuminator camera based on Novatek NT98566 (NA51089) with SPI NAND flash.

### Hardware

| Component | Details |
|---|---|
| SoC | Novatek NT98566 (NA51089), ARM Cortex-A9 |
| RAM | 128 MB DDR3 |
| Flash | 128 MiB SPI NAND, Fudan Micro `FM25S01A` (`0xA1 0xE4`, 1-bit on-die ECC) |
| Sensor | SmartSens `SC430AI` (4 MP, 2688x1520, MIPI 2-lane) |
| Ethernet | Internal 100 Mbps PHY (PoE supported) |
| Audio | Built-in microphone (Novatek EAC, 48 kHz AAC) |
| Storage | microSD card slot (SDIO1) |
| Illumination | Dual LED (IR + warm white) + motorized IR-Cut filter |

### Files

Download from GitHub releases:
- [u-boot-nt98566-nand.bin](https://github.com/OpenIPC/firmware/releases/download/latest/u-boot-nt98566-nand.bin)
- [openipc.nt98566-nand-ultimate.tgz](https://github.com/OpenIPC/firmware/releases/download/latest/openipc.nt98566-nand-ultimate.tgz)

Place `u-boot-nt98566-nand.bin` and `rootfs.ubifs.nt98566` (unpacked from the `.tgz`) into your TFTP server directory.

### UART and Bootloader

- UART0: 3.3V, 115200 8N1 (`TX`, `RX`, `GND` header on the mainboard).
- Factory OTP secure boot is **disabled** (all 16 eFuse fields are `0`).
- Stock Dahua U-Boot (`U-Boot 2019.04`, stop key `*`) restricts `setenv`/`tftp` and does not boot third-party firmware images.

### Flashing

1. **Back up the entire 128 MiB stock SPI NAND flash first** using the NAND routes in [Backing up stock firmware](backup-stock-firmware.md) (programmer or bad-block-aware NAND dump) and keep the copy off the camera.
2. Flash `u-boot-nt98566-nand.bin` to offset `0x0` (via an external flash programmer, or from a RAM-booted OpenIPC U-Boot with `run ub` - see [Novatek unbrick](novatek-unbrick.md) for Ethernet RAM boot with `defib`, noting that `defib` on `nt98566` has not been confirmed on hardware yet), then reboot and stop at the `OpenIPC #` prompt.
3. Configure networking, MAC address, memory split, erase the `ubi` partition once, and flash `rootfs.ubifs.nt98566` (it already includes `/boot/uImage`):

```
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.254
setenv ethaddr 00:11:22:33:44:55
setenv osmem 48M
saveenv
nand erase.part ubi
run ur && reset
```

See [Installation on Novatek (SPI NAND)](install-novatek.md#spi-nand-boards-nt98566) for general SPI NAND notes and follow-up `sysupgrade --rootfs=` updates.

### First Boot and Sensor

Log in as `root` (over UART, SSH, or web UI) and set a root password. If `SC430AI` is not auto-detected on first boot, set it once and reboot:

```sh
fw_setenv sensor sc430ai
reboot
```

### GPIO

| Function | GPIO | Notes |
|---|---|---|
| IR-Cut pin 1 | `GPIO 234` (`DSI_GPIO10`) | H-bridge leg 1 |
| IR-Cut pin 2 | `GPIO 133` (`D_GPIO5`) | H-bridge leg 2 |
| Illuminator enable | `GPIO 226` (`DSI_GPIO2`) | Master LED driver power (`1` = on, `0` = off) |
| Illuminator mode | `GPIO 227` (`DSI_GPIO3`) | Mode selector (`1` = IR LED, `0` = warm white LED; `whiteLightInvert: true`) |

Notes:
- `GPIO 133` (`D_GPIO5`) is shared with Ethernet PHY LED2 in the generic NA51089 EVB device tree and is switched to GPIO mode automatically when requested by `gpio-nvt-na51089`.
- The dual illuminator uses a **shared power enable + mode selector** circuit, not two independent LED channels. IR and warm white LEDs are mutually exclusive and cannot be turned on at the same time.
- `nightMode.whiteLightShared: true` (majestic builds that have it show **Shared lamp driver** in the WebUI's night mode settings) tells majestic this: `backlightPin` (`GPIO 226`) powers the driver and `whiteLightPin` (`GPIO 227`, with `whiteLightInvert: true`) picks the bank. Either lamp then lights on its own, also the warm white one with the IR lamp off or by day. When both are wanted the warm white one wins, and IR comes back without a dark gap when it goes out. `whiteLight: auto` with `colorNight: true` lights the warm bank for a colour night ([OpenIPC/majestic#396](https://github.com/OpenIPC/majestic/issues/396)).
- On an older majestic, without that key, warm white light needs both the camera light (`backlightPin`) and `whiteLight` on, and `whiteLight: auto` does not work on this board.

### Majestic configuration

Apply the camera-specific settings via the Majestic API and reboot:

```sh
curl http://localhost/api/v1/config --data-binary @- <<'EOF'
{
  "isp": {
    "sensorConfig": "/etc/sensors/sc430ai.yaml"
  },
  "video0": {
    "size": "2688x1520"
  },
  "audio": {
    "enabled": true,
    "codec": "aac",
    "srate": "48000"
  },
  "nightMode": {
    "irCutPin1": 234,
    "irCutPin2": 133,
    "backlightPin": 226,
    "whiteLightPin": 227,
    "whiteLightInvert": true,
    "whiteLightShared": true,
    "whiteLight": "manual"
  }
}
EOF
reboot
```
