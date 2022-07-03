# OpenIPC Wiki
[Table of Content](../index.md)

Upgrading firmware
------------------

For old firmware `sysupgrade` without parameters is enough.

For newer firmware, use it as `sysupgrade -k -r` to update both kernel and rootfs.

If you got this error:
```
losetup: /tmp/rootfs.squashfs.${soc}: No such file or directory
Rootfs: Unable to get hostname, execution was interrupted...
```
then try to update only kernel first:
`sysupgrade -k`

If it doesn't help, use `--force` option:
`sysupgrade -r --force`

If you caught a glitch, retrieve the most recent version of the utility:
```
curl -k -L -o /usr/sbin/sysupgrade "https://raw.githubusercontent.com/OpenIPC/firmware/master/general/overlay/usr/sbin/sysupgrade"
```
