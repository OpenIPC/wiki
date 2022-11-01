# OpenIPC Wiki
[Table of Content](../index.md)

Source code
-----------

**At the moment, we are working on creating a high-quality repository with source code.**

**Please be patient because we want to provide a completely beautiful and ready-made project.**

### Quick build from sources

Install some packages to system and clone OpenIPC repo

```
sudo apt-get update -y
sudo apt-get install -y automake autotools-dev bc build-essential curl fzf git libtool rsync unzip
git clone --depth=1 https://github.com/OpenIPC/firmware.git
cd firmware
```
Run the commands below for your board and your files will end up in the "output/images" directory

```
# Example run it on project root folder
#
PLATFORM=name       make br-linux-{dirclean,rebuild}
PLATFORM=name       make br-rootfs-{squashfs,tar}
#
PLATFORM=name       make br-vtund-openipc-{dirclean,rebuild}
#
```

-----

## Statistical data

Software might do product usage data collection including SoC and sensor model name to gather statistics used in QA process.

We guaranty that the data is fully anonymized, and does not contain anything that can arguably be considered data about an individual, that could be considered end-user data; or that could be sensitive or confidential to users.


