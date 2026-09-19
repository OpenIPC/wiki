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

### If it reboots while people are watching

The log above will not show you this one, and that is the tell. If the camera
survives on its own and only reboots when someone has the live view open — or
reboots a minute or two after every boot because a browser tab reconnects by
itself — the streamer is being killed for running the board out of memory, and
the reboot that follows is the watchdog doing its job. Nothing reaches the log
you are piping over the network, because the reset takes the machine with it.

Two things distinguish it from a crash:

- it follows viewers rather than uptime, so it stops if you close every live
  view and leave the camera alone;
- the camera answers normally for the first seconds after each boot.

On builds from 2026-09-18 onward the camera bounds this itself and refuses
viewers it cannot afford instead of dying. On an older build, keep fewer live
views open, or lower `system.buffer` before you look any further. See
[How many people can watch at once](majestic-streamer.md#how-many-people-can-watch-at-once)
for what a given board can hold and how to read it off `/metrics`.

### The stream is several times the bitrate I set

The Dashboard's **Encoder out** tile reads well above the rate underneath it —
four or five times it, not a few per cent — and lowering `bitrate` does not
help, because the camera was already failing to reach the number it had.

Almost always this is the compression ceiling: `video0.maxQp` is set low enough
that rate control runs out of room to compress and exceeds the bitrate instead
of meeting it. A config written before the default rose in September 2026 still
carries the old value, and updating the firmware does not change a key that has
been set.

On builds from 2026-09-19 onward the camera diagnoses this itself and names the
setting, on the Dashboard and beside the Video settings. On an older build,
check the value by hand:

```
curl -s -u root:PASSWORD 'http://192.168.1.10/api/v1/config.json' | grep -A1 maxQp
```

The same watch covers the opposite symptom — a camera delivering far fewer
frames than its `fps`, which after dark is the sensor slowing down rather than
anything to do with the encoder. See
[When the camera exceeds the bitrate you set](majestic-streamer.md#when-the-camera-exceeds-the-bitrate-you-set)
for both, the measured effect of the ceiling, and the metrics that show it.
