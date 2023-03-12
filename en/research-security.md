
Alternative way to get access to full working system.
---------------------------------------------------

You will not have original root pass but you will be able get into :)

### Limited shell access
TESTED on GOKE SOC. over the UART interface it is possible to get into a limited shell, but this shell does not load full working system.
```
setenv bootargs ${bootargs} single init=/bin/sh
boot

```
Once we are in limited shell it is need to mount ROM filesystem:
```
mount -t jffs2 /dev/mtdblock3 /rom
```

Also will be great to mount sd card to copy some files:
```
mount
mount -a
mount /dev/mmcblk0p1 on /mnt/s0
```

### Modifying the file system
on /rom filesystem you can edit the /room/etc/passwd file but once the device restarts it will be set to default, this happens because there is a guide bin file writing to passwd file on each start, so we need to modify this executable.

copy system.dat to sd card
```
cp /rom/system.dat /mnt/s0
```

on a linux computer it is need to unsquahfs system.dat, do some changes and resquashfs:
```
mkdir squashfs-temp
cd squashfs-temp

unsquashfs system.dat
```

find guide file and hexedit to modify where "/etc/passwd" is written and change one letter, for example "/etc/passwT". This file will be created on start instead of passwd replaced.

re squash the file system:
```
mksquashfs ./squashfs-root ./file -comp xz -no-xattrs -noappend -no-exports -all-root -quiet -b 131072
```

and copy back from sd card to /rom directory on goke soc.

now you can edit /rom/etc/passwd with your own pass, and when you restart the device you will have full working system with your own pass.


