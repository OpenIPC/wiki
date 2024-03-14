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

Welcome to the OpenIPC Wiki. This document serves as a comprehensive guide for developers looking to contribute to the OpenIPC firmware, including how to build from sources, understand the project's structure, modify, and add new packages, as well as instructions for installing the firmware on devices.

We are currently working on creating a high-quality repository with source code. Please be patient, as we aim to provide a completely beautiful and ready-made project.

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

For Debian/Ubuntu, an example of installing the necessary packages and downloading our repository:

```sudo apt-get update -y
sudo apt-get install -y automake autotools-dev bc build-essential curl fzf git libtool rsync unzip
git clone --depth=1 https://github.com/OpenIPC/firmware.git
cd firmware
```

Alternatively, you can use the following command in the root of your OpenIPC firmware directory to install dependencies:

```sudo make deps
```

### Quick Build from Sources

To build the desired version of the firmware for your processor, run the following command in the root of the project. The files will be available in the directory "output/images".

```./building.sh hi3518ev300_ultimate
```

Examples of rebuilding the Linux kernel, root filesystems, and individual packages in our project:

```BOARD=hi3518ev300_ultimate  make br-linux-{dirclean,rebuild}
BOARD=hi3518ev300_ultimate  make br-rootfs-{squashfs,tar}
BOARD=hi3518ev300_ultimate  make br-vtund-openipc-{dirclean,rebuild}
```

### Create a Permanent Storage for Downloaded Bundles

By default, Buildroot stores all downloaded files in the dl/ directory inside the buildroot file tree. To avoid redownloading or copying files back and forth, set your own storage directory outside of the buildroot tree by adding the following to your .profile:

```BR2_DL_DIR="${HOME}/buildroot_dl"
[ ! -d "$BR2_DL_DIR" ] && mkdir -p $BR2_DL_DIR
export BR2_DL_DIR
```

Source the changes with:

```source ~/.profile
```

## Installing the Firmware

After building your custom firmware, this section guides you through the two main methods of installing it on a camera: using Advanced Install instructions or manual installation through scp.

## Anatomy of the Project

OpenIPC firmware utilizes [Buildroot][1] to build its firmware binaries. It's advised to familiarize yourself with the [Buildroot documentation][2] to not only compile the provided source code but also to make your own modifications to the firmware. OpenIPC organizes its firmware sources in directories by IP camera SoC vendors as Buildroot external trees.

### Making Changes and Adding Packages

You can modify existing packages or add new ones to meet your project's needs. This section provides guidelines on how to make these changes effectively.

### Building a Custom Version of the Firmware

This section covers the steps for adding drivers or packages to the firmware and compiling binary files for specific hardware. It emphasizes the importance of computer performance in the compilation process and provides tips for customizing the firmware.

## Statistical Data

Software might collect product usage data, including SoC and sensor model names, to gather statistics used in the QA process. We guarantee that the data is fully anonymized and does not contain any individual, sensitive, or confidential user data.

[1]: https://buildroot.org/
[2]: https://buildroot.org/docs.html
[3]: https://github.com/OpenIPC/firmware/blob/96b2a0ed2f5457fda5b903ab67146f30b5062147/Makefile#L25
[4]: https://github.com/OpenIPC/firmware/releases/tag/latest
[5]: https://buildroot.org/downloads/manual/manual.html
