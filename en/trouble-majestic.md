# OpenIPC Wiki
[Table of Content](../README.md)

## Troubleshooting: Majestic does not show any images, no reboot

Let's say that `top` shows that majestic is running, but no image is displayed.
The preview tab shows only a test pattern and there is an error similar to the
one below in dmesg.

```
...
sc2336 chip found @ 0x30 (i2c0)
sensor driver version H20210805a
sc2336 stream on
error: one buffer schedule only support nrvbs = 1, chan index:0, num_buffers:2
...
```

The `nrvbs = 1` may be the problem. Set the `isp.blkCnt` majestic property
to 1 with the Block Count control on the ISP tab of Majestic settings, then
restart majestic.
This issue has only been documented on T31L and T31N SOCs with SC2336 and
JXF37 sensors; let us know if you see this on a different platform an if this
setting change works for you.

## Troubleshooting: Majestic does not work, camera reboots

To troubleshoot majestic you first need to get access to its logs, right to the moment as it crashes, 
that leads to watchdog rebooting the system and deleting the logs from the camera. So you need to copy 
log to a safe place as it populates. And you can achieve that using ssh access to the camera and piping
output to a file on your desktop.

Run this command on your Linux desktop (do not forget to replace _192.168.1.10_ with camera's actual IP address)
and wait for the camera to reboot once again. The resulting log file will be in the same directory named and 
dated similar to _majestic-2022-12-14.log_
```
ssh root@192.168.1.10 "killall majestic; sleep 2; majestic" > majestic-$(date +"%F").log
```
