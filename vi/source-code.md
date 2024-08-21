# OpenIPC Firmware Development Guide

## Table of Contents
- Introduction
- Building from Sources
- Installing the Firmware
- Anatomy of the Project
- Modifying and Adding Packages
- Building a Custom Version of the Firmware
- Statistical Data

## Introduction

This document serves as a comprehensive guide for developers looking to contribute to the OpenIPC firmware, including how to build from sources, understand the project's structure, modify, and add new packages, as well as instructions for installing the firmware on devices.

We are currently developing a high-quality source code repository. Your patience is appreciated as we strive to deliver a fully polished and ready-to-use project.

## Building from Sources

Before you start building your own firmware, it's essential to make a few changes to your system and understand the general process.

### Clone OpenIPC Firmware Git Repository

```cd
mkdir -p local/src
cd local/src
git clone https://github.com/OpenIPC/firmware.git openipc-firmware
cd openipc-firmware
```

### Install Required Packages

```bash
sudo make deps
```

For Debian/Ubuntu, an example of installing the necessary packages and downloading our repository:

```sudo apt-get update -y
sudo apt-get install -y automake autotools-dev bc build-essential curl fzf git libtool rsync unzip
git clone --depth=1 https://github.com/OpenIPC/firmware.git
cd firmware
```

Alternatively, you can use the following command in the root of your OpenIPC firmware directory to install dependencies:

```bash
sudo make deps
```

### Quick Build from Sources

To build the desired version of the firmware for your processor, run the following command in the root of the project. The files will be available in the directory "output/images".

```bash
./building.sh hi3518ev300_ultimate
```

Examples of rebuilding the Linux kernel, root filesystems, and individual packages in our project:

```BOARD=hi3518ev300_ultimate  make br-linux-{dirclean,rebuild}
BOARD=hi3518ev300_ultimate  make br-rootfs-{squashfs,tar}
BOARD=hi3518ev300_ultimate  make br-vtund-openipc-{dirclean,rebuild}
```

### Create a Permanent Storage for Downloaded Bundles

By default, Buildroot stores all downloaded files in `dl/` directory inside
buildroot file tree.

OpenIPC building script creates a fresh buildroot file tree before every
compilation, meaning either deletes all downloaded packages or copies them back
and forth prior and after creating a fresh setup.

You can set your own storage directory outside of the buildroot tree. Add the
following piece of code to `.profile` file in your home directory:

```bash
BR2_DL_DIR="${HOME}/buildroot_dl"
[ ! -d "$BR2_DL_DIR" ] && mkdir -p $BR2_DL_DIR
export BR2_DL_DIR
```

Then, source the changes.

```bash
source ~/.profile
```

### Build the firmware.

Building of a binary firmware for your IP camera is fairly easy. Just clone
source code from the repository and run:

```bash
make
```

You will be greeted with a list of available targets.

![](../images/firmware-building-whiptail.webp)

Each target's name consists of a name of vendor, SoC model (System-on-Chip,
the heart of an IP camera, central processor with extra features) and flavor
denoting releases for different purposes - **Lite**, a compact release for
cameras with only 8MB of ROM; **Ultimate**, an extended release for cameras
with 16MB+ ROM, **FPV**, a release crafted specifically for use in drones,
or **Mini**, a fully liberated version of the firmware with an alternative
open-source streamer.

Select desired target and hit enter. Building ensues.

Process of building firmware binary takes from 15-20 minutes to several hours
depending on your computer performance and selected target. If you want to
speed up the process, make sure you use a computer with SSD rather than HDD as
the process of compiling involves a lot of reading and writing. Faster CPU is
also beneficial, and one cannot have too much RAM, either. You could even rent
an online virtual server for a handful of cents to compile your firmware with
the power of cloud computing.

The very first run is the longest as the script will download every source
bundle required for successful compilation. Consequent runs will take a little
less time.

After the compilation is done, you'll find the final binary kernel and `rootfs`
image in `output/images/` directory.

```
paul@r610:~/src/openipc-firmware$ ls -l output/images/
total 35628
-rw-r--r-- 1 paul paul  4816896 Nov 22 06:06 rootfs.squashfs.t10
-rw-r--r-- 1 paul paul 14520320 Nov 22 06:06 rootfs.t10.cpio
-rw-r--r-- 1 paul paul 15544320 Nov 22 06:06 rootfs.t10.tar
-rw-r--r-- 1 paul paul  1597586 Nov 22 06:02 uImage.t10
```

## Installing the Firmware

After you build your custom firmware, you need to install it on the camera.
You can do it in two ways:
1. Use Advanced Install instructions as you did first time you flashed the camera: copy the build files to your TFTP server and then do the flashing procedure as explained in specific Advanced Instructions for your camera;
2. Manual install: boot up your camera, connect it to your local network and then using scp copy the two files (rootfs and uImage) to your camera /tmp folder (/tmp folder is a temporary storage, as big as your camera free RAM).
Then, run this commands:

```
sysupgrade --kernel=/tmp/uImage.... --rootfs=/tmp/rootfs.... -z
```
Replace uImage... and rootfs... with your actual filenames resulted from the build process.
You can add -n key if you need to clean overlay after update (reset all settings to default).
After the instalation is complete, the camera will reboot automatically.
Connect again to the camera and run this command (same as -n in the previous command):

```
firstboot
```

Remember! The user and password will be reset to default in most cases (the default is usually root/12345)

## Anatomy of the Project

OpenIPC firmware v2 utilizes [Buildroot][1] to build its firmware binaries. So
you should make yourself familiar with the [Buildroot documentation][2] if you
want not only to compile provided source code but make your own modifications
to the firmware.

You can add drivers or software not included in the our official releases, you
can remove unneeded drivers or software that you're not going to use, to free
up some space in the firmware. You can change default settings to better suit
your needs. The beauty of open source is that anyone can improve it, anytime.
Just don't forget to contribute your changes back to the upstream repo so that
everyone can benefit from it.

Please note that OpenIPC uses a slightly outdated version of Buildroot. As of
today, it is Buildroot [2021.02.12][3], so you might need to check out the
documentation for that particular version, as later versions may have
incompatible changes.

OpenIPC firmware sources are organized in directories by IP camera SoC vendors
as Buildroot external trees, namely `br-ext-chip-<vendor name>`. Each of such
directories has a number of subdirectories: `board/`, `configs/`, `linux/` and
`packages/`, and a few config files, all related to different boards bearing
chips from that particular vendor.

`board/` directory includes subdirectories named by groups of processors called
families. Inside each of such a family directory reside kernel configuration
files for individual processors in that family, common patches and other
family-specific files.

`configs/` directory includes default configuration files (defconfig) for
various boards with processors from the given vendor. These config files also
can differ by hardware settings, set of included packages, different default
settings, branding, and so on. Each of these defconfig files is a separate
package resulting in a separate firmware binary.

`linux/` directory includes configuration files for patching kernel to make it
work with vendor-provided binary blobs, if any.

`package/` directory has symlinks to packages used for building the resulting
firmware.

`Config.in` is a configuration file consolidating configuration files from all
provided packages.

`external.mk` is a makefile referring to makefiles from all provided packages.

`external.desc` is a file with the description of the external tree.


### Making Changes and Adding Packages

You can modify existing packages or add new ones to meet your project's needs. This section provides guidelines on how to make these changes effectively.

Once you start tinkering with the packages you'll realize you need a way to
rebuild only one particular package, without rebuilding the whole project.
Is it even possible? Fortunately, yes. All you have to do after making changes
to the package configs is to run a couple of commands:
```
make br-<package>-dirclean
make br-<package>-rebuild
```
where _\<package>_ is the name of the package you want to recompile. Although,
as Buildroot manual states,

> While `br-<package>-rebuild` implies `br-<package>-reinstall` and `br-<package>-reconfigure`
implies `br-<package>-rebuild`, these targets as well as `<package>` only act on
the said package, and do not trigger re-creating the root filesystem image.
If re-creating the root filesystem in necessary, one should in addition run
`make br-all`.

Run `make br-linux-rebuild br-all` to rebuild Linux kernel image,
`make br-busybox-rebuild br-all` to rebuild busybox and pack it into a rootfs image.

Remember! the name of the package in the two commands above is the folder name of your package, not the package name you set in Config.in file

f you want to add new packages to a particular project, these are the changes you need to do (let's take for example goke board, fpv type firmware; the steps can be applied to any project or all projects):
  * Add your new package in [root]/general/package/ folder (where [root] is your local folder where you cloned the firmware repo);
  * Add your new package Config.in file to the list of sources packages in this file: [root]/general/package/Config.in
  * Modifiy your target project configuration (i.e. goke board, fpv firmware) to include and build your new package, add your package to this file: [root]/br-ext-chip-qoke/configs/gk7205v200_fpv_def_config
  * Build the firmware.

After the build completes, your package (if it did installed any files) should be part of the generated images and file systems.


### Building a Custom Version of the Firmware

Sometimes your need to add a driver or a package to the firmware. How can you
do that using provided OpenIPC Firmware sources? It is really easy. Clone the
firmware repository locally and compile binary files for your particular
hardware.

Compilation process heavily depends on your computer performance. The more CPU
threads and memory you get, the faster the process. Anyway, you can expect the
initial compilation to last about half an hour, give or take. The resulting
binary files will reside in `output/images` directory. If you did not make any
changes to the sources then these files should be identical to those
[available from GitHub][4].

Compilation process has also built a toolchain suitable for compiling packages
for your version of firmware. The toolchain is located in `output/host`
directory.

To customize your firmware, add or remove a package run `make br-menuconfig`.
That will load buildroot configuration menu where you can make changes following
[The Buildroot user manual][5]. Make your changes and save amended config on exit.
Then run `make clean all`.

__Be aware that building firmware directly with buildroot will not rename the
resulting image files adding a soc suffix to them. You either can to it
yourself or adjust your firmware updating the commands accordingly.__


[1]: https://buildroot.org/
[2]: https://buildroot.org/docs.html
[3]: https://github.com/OpenIPC/firmware/blob/96b2a0ed2f5457fda5b903ab67146f30b5062147/Makefile#L25
[4]: https://github.com/OpenIPC/firmware/releases/tag/latest
[5]: https://buildroot.org/downloads/manual/manual.html
