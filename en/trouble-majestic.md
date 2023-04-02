# OpenIPC Wiki
[Table of Content](../README.md)

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
