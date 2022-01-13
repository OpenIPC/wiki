## Upgrade firmware

`sysupgrade`  for old firmware

`sysupgrade -k -r`  for new firmware

If you got this error:
```
losetup: /tmp/rootfs.squashfs.${soc}: No such file or directory
Rootfs: Unable to get hostname, execution was interrupted...
```
Try first update kernel:
`sysupgrade -k`

If it doesn't help use option --force:
`sysupgrade -r --force`


If you caught a glitch:
```
curl -k -L -o /usr/sbin/sysupgrade "https://raw.githubusercontent.com/OpenIPC/firmware/master/general/overlay/usr/sbin/sysupgrade"
```