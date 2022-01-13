## For XM vendor boards ONLY with SoC NT98562 and NT98566 !!!

### Initial device firmware update

**This section will be completed at the end of the research**

```
run uk; run ur; reset            <= Flash kernel, rootfs and reboot device
```

### Follow-up quick updates

```
run uk; run ur; reset
```

### Notes

After the first flash firmware of the device, please run the **firstboot** command to format the jffs2 partition of the settings.

-----

### Known issues

Change memory address for some tests

```
setenv bootcmd 'setenv setargs setenv bootargs ${bootargs}; run setargs; sf probe 0; sf read 0x03100000 0x50000 0x200000; nvt_boot'; saveenv
```