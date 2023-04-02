# OpenIPC Wiki
[Table of Content](../README.md)

For XM vendor boards with NT98562 and NT98566 SoC ONLY!!!
---------------------------------------------------------

### Initial device firmware update

**This section will be completed at the end of the research**

```
run uk; run ur; reset            # Flash kernel, rootfs and reboot device
```

### Follow-up quick updates

```
run uk; run ur; reset
```

### Notes

After you have finished flashing new firmware, please run `firstboot` command
to format jffs2 partition used to store settings.

### Known issues

Change memory address for some tests.

```
setenv bootcmd 'setenv setargs setenv bootargs ${bootargs};run setargs;sf probe 0;sf read 0x03100000 0x50000 0x200000;nvt_boot'
saveenv
```
