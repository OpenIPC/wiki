# OpenIPC Wiki
[Table of Content](../index.md)

Source code
-----------

**At the moment, we are working on creating a high-quality repository with source code.**

**Please be patient because we want to provide a completely beautiful and ready-made project.**

### Quick build from sources

An example of installing the necessary packages for Debian/Ubuntu and downloading our repository

```
sudo apt-get update -y
sudo apt-get install -y automake autotools-dev bc build-essential curl fzf git libtool rsync unzip
git clone --depth=1 https://github.com/OpenIPC/firmware.git
cd firmware
```

Example of running the command in the root of the project to build the desired version of the firmware for your processor

The files will be available in the directory "output/images".

```
./building.sh hi3518ev300_ultimate
```

Examples of rebuilding the Linux kernel, root filesystems and individual packages in our project

```
BOARD=hi3518ev300_ultimate  make br-linux-{dirclean,rebuild}
#
BOARD=hi3518ev300_ultimate  make br-rootfs-{squashfs,tar}
#
BOARD=hi3518ev300_ultimate  make br-vtund-openipc-{dirclean,rebuild}
```

-----

## Statistical data

Software might do product usage data collection including SoC and sensor model name to gather statistics used in QA process.

We guaranty that the data is fully anonymized, and does not contain anything that can arguably be considered data about an individual, that could be considered end-user data; or that could be sensitive or confidential to users.


