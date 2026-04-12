# OpenIPC Wiki
[Table of Content](../README.md)

Reading SPI flash unique ID from userspace
------------------------------------------

### What is a flash unique ID?

Every SPI NOR flash chip (Winbond W25Q, GigaDevice GD25Q, Macronix MX25L, etc.)
has a factory-programmed **8-byte unique identifier** burned in at the
factory. No two chips share the same ID. This is useful for:

- **Device identification** -- generate a stable device serial number
  without needing a separate EEPROM or MAC address chip.
- **License binding** -- tie a software license or configuration to a
  specific hardware unit.
- **Fleet management** -- uniquely identify cameras in large deployments.

The ID is read-only and survives full flash erases.

### How it works on OpenIPC (7.0 kernel)

Starting with the OpenIPC 7.0-rc6 "neo" kernel, the mainline Linux SPI NOR
driver reads the flash unique ID at boot using the JEDEC **Read Unique ID**
command (`0x4B`) and exposes it through the standard
[NVMEM](https://www.kernel.org/doc/html/latest/driver-api/nvmem.html)
framework as a `factory-otp` device.

The data flow looks like this:

```
SPI flash chip (W25Q128)
  |
  |  RDUID command (0x4B)
  v
spi-nor driver (drivers/mtd/spi-nor/)
  |
  |  factory OTP callbacks
  v
MTD core (drivers/mtd/mtdcore.c)
  |
  |  registers NVMEM device + seeds entropy pool
  v
/sys/bus/nvmem/devices/factory-otp0/nvmem    <-- userspace reads this
```

No extra kernel modules, no vendor-specific hacks -- it is part of the
standard Linux MTD/NVMEM stack.

### Reading the unique ID

SSH into your camera and read the NVMEM file:

```console
root@openipc-hi3516ev300:~# xxd /sys/bus/nvmem/devices/factory-otp0/nvmem
00000000: e460 4020 1f2c 572b                      .`@ .,W+
```

That is the 8-byte unique ID: `E4604020 1F2C572B`.

To get it as a plain hex string (useful in scripts):

```console
root@openipc-hi3516ev300:~# od -An -tx1 /sys/bus/nvmem/devices/factory-otp0/nvmem | tr -d ' \n'
e46040201f2c572b
```

You can use it to derive a stable hostname, serial number, or device
identifier:

```bash
#!/bin/sh
# Generate a short device ID from the flash unique ID
UID=$(od -An -tx1 /sys/bus/nvmem/devices/factory-otp0/nvmem | tr -d ' \n')
echo "device-${UID}"
# Output: device-e46040201f2c572b
```

### Checking that your system supports it

1. **Verify the NVMEM device exists:**

```console
root@openipc-hi3516ev300:~# ls /sys/bus/nvmem/devices/factory-otp0/
nvmem  ...
```

If `factory-otp0` is missing, see the troubleshooting section below.

2. **Check dmesg for OTP registration** (optional):

```console
root@openipc-hi3516ev300:~# dmesg | grep -i factory
```

On a working system there will be no errors. The kernel silently
registers the NVMEM device and seeds the entropy pool.

### Which cameras and flash chips are supported?

The unique ID feature requires:

| Requirement | Details |
|-------------|---------|
| **Kernel** | OpenIPC 7.0-rc6 "neo" or later |
| **Flash chip** | Winbond W25Q series (W25Q32, W25Q64, W25Q128, W25Q256, etc.) |
| **SoC** | Any SoC using the mainline `spi-nor` driver (HiSilicon hi3516ev200/300, etc.) |

The JEDEC Read Unique ID command (`0x4B`) is also supported by GigaDevice
and Macronix chips. Patches for those manufacturers can be added following
the same pattern.

### Real-world example: hi3516ev300 with W25Q128

This is the output from a HiSilicon hi3516ev300 camera board with a
Winbond W25Q128 (16 MB) flash chip, running the OpenIPC neo firmware:

```console
root@openipc-hi3516ev300:~# uname -r
7.0.0-rc6

root@openipc-hi3516ev300:~# cat /proc/mtd
dev:    size   erasesize  name
mtd0: 00040000 00010000 "boot"
mtd1: 00010000 00010000 "env"
mtd2: 00300000 00010000 "kernel"
mtd3: 00a00000 00010000 "rootfs"
mtd4: 002b0000 00010000 "rootfs_data"

root@openipc-hi3516ev300:~# ls /sys/bus/nvmem/devices/
factory-otp0  mtd0  mtd1  mtd2  mtd3  mtd4

root@openipc-hi3516ev300:~# xxd /sys/bus/nvmem/devices/factory-otp0/nvmem
00000000: e460 4020 1f2c 572b                      .`@ .,W+
```

### Troubleshooting

**`factory-otp0` does not appear:**

- Make sure you are running the OpenIPC "neo" variant (kernel 7.0+). The
  older 4.9/5.10 vendor kernels do not have this feature.
- Check that your flash chip is a Winbond W25Q part. You can verify the
  JEDEC ID from U-Boot:
  ```
  hisilicon # sf probe
  hifmc_spi_nor_probe(1827): SPI Nor(cs 0) ID: 0xef 0x40 0x18
  ```
  `0xef` = Winbond, `0x40 0x18` = W25Q128.

**Reading returns all zeros or all `0xFF`:**

- The flash chip may not support the RDUID command. Older or non-JEDEC
  compliant chips may not have a unique ID programmed.

### How it differs from the vendor approach

The original SigmaStar/HiSilicon vendor kernels (4.9 era) exposed the flash
serial number via a custom sysfs attribute on the vendor flash driver:

```
cat /sys/devices/soc0/soc/soc:flashisp/serial
```

The OpenIPC 7.0 approach uses the standard Linux NVMEM framework instead.
This is the same interface used by other OTP storage across the kernel (MAC
addresses in EEPROM, factory calibration data, etc.), making it portable
across SoC platforms.

| | Vendor kernel (4.9) | OpenIPC neo (7.0) |
|---|---|---|
| Interface | Custom sysfs attribute | Standard NVMEM framework |
| Path | `/sys/.../flashisp/serial` | `/sys/bus/nvmem/devices/factory-otp0/nvmem` |
| Format | 16-char hex string | Raw 8 bytes (use `xxd` or `od`) |
| Portability | SigmaStar only | Any SoC with mainline spi-nor |

### For developers: how it is implemented

The implementation lives in three places in the kernel source:

1. **`drivers/mtd/spi-nor/otp.c`** -- `spi_nor_otp_read_uid()` sends the
   RDUID command and provides the MTD factory OTP callbacks.

2. **`drivers/mtd/spi-nor/winbond.c`** -- `winbond_nor_late_init()` wires
   up the factory OTP for parts that have the `WINBOND_NOR_F_HAS_UID` flag.

3. **`drivers/mtd/mtdcore.c`** -- the existing MTD core registers any flash
   with factory OTP callbacks as a `factory-otp` NVMEM device automatically.

To add support for another manufacturer (e.g. GigaDevice), you only need to:
- Add a manufacturer flag (e.g. `GD_F_HAS_UID`)
- Wire up `params->fact_otp.read = spi_nor_otp_read_uid` in the
  manufacturer's `late_init` hook
- Tag the supported part entries with the flag

The RDUID command (`0x4B`) uses the same protocol across Winbond, GigaDevice,
and Macronix, so `spi_nor_otp_read_uid()` can be reused as-is.
