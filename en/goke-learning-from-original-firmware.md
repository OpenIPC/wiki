# OpenIPC Wiki
[Table of Content](../index.md)

Goke SoC: Learning from original firmware
-----------------------------------------

### Prepare the enviroment

Over the UART interface, it is possible to temporarily interrupt the normal booting
sequence and drop into a limited Linux shell at early stage of system startup.
```
setenv bootargs ${bootargs} single init=/bin/sh
boot
```
This shell won't load the full working system, so you have to amend it manually.
First, mount `/rom` filesystem:
```
mount -t jffs2 /dev/mtdblock3 /rom
```
Mount the rest of mounting points from `/etc/fstab`:
```
mount -a
```
Also mount the SD card to copy files to and from:
```
mount /dev/mmcblk0p1 on /mnt/s0
```

### Modifying the system

On `/rom` filesystem, you can edit the `/room/etc/passwd` file but once the
device restarts it will be reset to default. This happens because there is a
guide bin file recreating `passwd` file on each start, so we need to modify
that executable.

Copy `system.dat` to an SD card:
```
cp /rom/system.dat /mnt/s0
```
On a linux computer, unpack `system.dat` file using `unsquashfs`:
```
mkdir squashfs-temp
cd squashfs-temp
unsquashfs system.dat
```
Find guide file and edit its content in a hex-editor to modify the name of the
file where password is written on every restart. Search for `/etc/passwd` and
change a letter in its name to something different, like `/etc/passwT`.

Pack the squash file system using `mksquashfs`:
```
mksquashfs ./squashfs-root ./file -comp xz -no-xattrs -noappend -no-exports -all-root -quiet -b 131072
```
and copy it from the SD card back to `/rom` directory on the camera.

Now you can replace the password in `/rom/etc/passwd` with your own password, and when
you restart the device, you will have full working system with your own password.
