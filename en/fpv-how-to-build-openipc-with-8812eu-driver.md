# OpenIPC Wiki
[Table of contents](../README.md)

How to build OpenIPC with RTL8812EU driver
--------------------------------

More details about rtl8812eu can be found here https://github.com/OpenIPC/wiki/blob/master/en/fpv-bl-m8812eu2-wifi-adaptors.md

- Boot into Ubuntu
- Open Terminal

```
sudo apt-get install -y automake autotools-dev bc build-essential curl fzf git libtool rsync unzip
```

```
rm -r -f yourOpenipc #remove any old firmware build directory (optional)
git clone --depth=1 https://github.com/OpenIPC/firmware.git yourOpenipc
cd yourOpenipc
make clean
cd br-ext-chip-sigmastar
cd configs
ls
sudo nano yourSelectconfig
```

```
	Then under Wireless add the line 
BR2_PACKAGE_RTL88X2EU_OPENIPC=y
	Save the file

cd ..
cd ..
make
```

- Select your board and type eg ssc338q fpv and build the firmware
- Navigate to /home/YourUser/yourOpenipc/output/images
- Find your appropriate output .tgz archive ie openipc.ssc338q-nor-fpv.tgz and extract the rootfs and uboot files
- Copy those 2 files to the OpenIPC camera /tmp
    - ssh to the camera
`cd /tmp`

`sysupgrade --kernel=uImage.ssc338q --rootfs=rootfs.squashfs.ssc338q`
or
`sysupgrade --kernel=uImage.ssc30kq --rootfs=rootfs.squashfs.ssc30kq`
