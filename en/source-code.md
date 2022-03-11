# OpenIPC Wiki
[Table of Content](index.md)

Source code
-----------

**At the moment, we are working on creating a high-quality repository with source code.**

**Please be patient because we want to provide a completely beautiful and ready-made project.**

### Quick build from sources

Install some packages to system and clone OpenIPC repo

```
sudo apt-get update -y
sudo apt-get install -y bc build-essential git tcl unzip
git clone --depth=1 https://github.com/OpenIPC/firmware.git
cd firmware
```
Run the commands below for your board and your files will end up in the "output/images" directory

#### Hi3516Ev300

```
export PLATFORM=hisilicon
make prepare
make BOARD=unknown_unknown_hi3516ev300_openipc all
```

#### SSC335

```
export PLATFORM=sigmastar
make prepare
make BOARD=unknown_unknown_ssc335_openipc all
```

#### XM530

```
export PLATFORM=xiongmai
make prepare
make BOARD=unknown_unknown_xm530_openipc all
```

-----

## Statistical data

Software might do product usage data collection including SoC and sensor model name to gather statistics used in QA process..

We guaranty that the data is fully anonymized, and does not contain anything that can arguably be considered data about an individual, that could be considered end-user data; or that could be sensitive or confidential to users.

-----

## Other notes

```
make help
make install-deps
make prepare
make list-configs
cd output ; make sdk
```

```
# Example run it on project root folder
#
PLATFORM=name       make br-linux-{dirclean,rebuild}
PLATFORM=name       make br-rootfs-{squashfs,tar}
#
PLATFORM=name       make br-busybox-{dirclean,rebuild}
PLATFORM=name       make br-bwm-ng-{dirclean,rebuild}
PLATFORM=name       make br-fwprintenv-openipc-{dirclean,rebuild}
PLATFORM=name       make br-gdbserver-lite-{dirclean,rebuild}
PLATFORM=name       make br-gesftpserver-{dirclean,rebuild}
PLATFORM=name       make br-ipctool-{dirclean,rebuild}
PLATFORM=name       make br-libyaml-{dirclean,rebuild}
PLATFORM=name       make br-motors-{dirclean,rebuild}
PLATFORM=name       make br-node-exporter-{dirclean,rebuild}
PLATFORM=name       make br-vtund-openipc-{dirclean,rebuild}
#
PLATFORM=hisilicon  make br-fdk-aac-openipc-{dirclean,rebuild}
PLATFORM=hisilicon  make br-hisi_gpio_scanner-{dirclean,rebuild}
PLATFORM=hisilicon  make br-hisilicon-osdrv-hi3516cv500-{dirclean,rebuild}
PLATFORM=hisilicon  make br-hisilicon-osdrv-hi3516ev300-{dirclean,rebuild}
PLATFORM=hisilicon  make br-lame-openipc-{dirclean,rebuild}
PLATFORM=hisilicon  make br-libcurl-openipc-{dirclean,rebuild}
PLATFORM=hisilicon  make br-libevent-openipc-{dirclean,rebuild}
PLATFORM=hisilicon  make br-libogg-openipc-{dirclean,rebuild}
PLATFORM=hisilicon  make br-majestic-hi3516cv500-{dirclean,rebuild}
PLATFORM=hisilicon  make br-majestic-hi3516ev300-{dirclean,rebuild}
PLATFORM=hisilicon  make br-mbedtls-openipc-{dirclean,rebuild}
PLATFORM=hisilicon  make br-opus-openipc-{dirclean,rebuild}
PLATFORM=hisilicon  make br-uacme-openipc-{dirclean,rebuild}
#
PLATFORM=novatek    make br-novatek-osdrv-nt9856x-{dirclean,rebuild}
#
PLATFORM=sigmastar  make br-libhv-openipc-{dirclean,rebuild}
PLATFORM=sigmastar  make br-libsrt-openipc-{dirclean,rebuild}
PLATFORM=sigmastar  make br-majestic-ssc335-{dirclean,rebuild}
PLATFORM=sigmastar  make br-sigmastar-osdrv-ssc335-{dirclean,rebuild}
#
PLATFORM=xiongmai   make br-xiongmai-osdrv-xm530-{dirclean,rebuild}
```
