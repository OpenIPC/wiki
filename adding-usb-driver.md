# OpenIPC Wiki
[Table of Content](../README.md)

Adding usb driver to your firmware
---
Since most cameras have very little flash memory, OpenIPC firmware images don't contain many drivers, as they can easily be 1.5MB+ per driver.
This means that in many cases, you will have to add the usb driver to your firmware image.

### Step 1: preparing the build environment
You will need a Linux environment. First download the OpenIPC firmware repository:

```
git clone https://github.com/OpenIPC/firmware.git openipc-firmware
cd openipc-firmware
```

Install packages required for building:

```
sudo make deps
```

### Step 2: determine the driver package
For example, I want to add USB support for sigmastar335 - this is "path to your folder"/openipc-firmware/br-ext-chip-sigmastar/board/infinity6b0/

 

#### open configuration file:
```
infinity6b0-ssc009a.config
```

#### look for the lines:
```
#
# also be needed; see USB_STORAGE Help for more info
#
```

#### add a line
```
CONFIG_USB_STORAGE=m
```

#### look for the lines:
```
#
# SCSI device support
#
CONFIG_SCSI_MOD=y
```

#### add a line 
```
CONFIG_SCSI_MOD=m
CONFIG_CD_MOD=m
```
#### look for the lines:
```
# CONFIG_RAID_ATTRS is not set
CONFIG_SCSI=y
```

#### add a line 
```
CONFIG_SCSI=m
```

#### Build your firmware
Return to the root directory of the openipc firmware directory `openipc-firmware/`.
Run `make` and select the configuration you have edited in the previous step.

Alternatively, you can run `make BOARD=<your_config>`, where `<your_config>` is the name of the config file you have just edited, minus the `_defconfig`

Example: you want to build `lite` for `ssc335`:
```
make BOARD=ssc335_lite
```
When the build is complete, you will find the output in the `output/images/` directory:

```
./rootfs.ssc335_lite.cpio
./openipc.ssc335-nor-lite.tgz
./rootfs.squashfs.ssc335
./rootfs.ssc335.tar
./uImage.ssc335
```

You can now use `rootfs.squashfs.*` and `uImage.*` with [sysupgrade](./sysupgrade.md) or your preferred update mechanism.

After launching, you need to run the commands `modprobe sd_mod` and `modprobe scsi_mod`
 
