# OpenIPC Wiki
[Table of Content](../README.md)

For XM vendor boards with NT98562 and NT98566 SoC ONLY!!!
---------------------------------------------------------

### Initial device firmware update

> **This section will be completed at the end of the research**

```
run uk; run ur; reset            # Flash kernel, rootfs and reboot device
```

### Follow-up quick updates

```
run uk; run ur; reset
```

### Notes

After you have finished flashing new firmware, please run `firstboot` command
to format `jffs2` partition used to store settings.

### Memory split: `osmem` and `mem=`

On these boards U-Boot divides the RAM using the `osmem` variable: Linux gets
the first `osmem`, and the video pipeline gets the rest. The kernel, however,
takes its own size from the `mem=` argument in `bootargs`. The two must always
be equal:

- `osmem` larger than `mem=` — the camera stops right after the kernel is
  decompressed and prints nothing more.
- `mem=` larger than `osmem` — Linux and the video pipeline end up using the
  same memory; the camera crashes and reboots as soon as the video drivers
  load, on every boot.

Keep a literal `${osmem}` in `bootargs` instead of a number. The `bootcmd`
these boards use (`setenv setargs setenv bootargs ${bootargs};run setargs;...`)
expands it at every boot, so `osmem` becomes the only value you change. From
Linux, replace just the `mem=` value and leave the rest of your `bootargs`,
partition layout included, exactly as it is:

```
fw_printenv -n bootargs > /root/bootargs.orig
fw_setenv bootargs "$(fw_printenv -n bootargs | sed 's/mem=[0-9]*M/mem=${osmem}/')"
fw_printenv bootargs
```

The last command must now show `mem=${osmem}`. Copy `/root/bootargs.orig` off
the camera as well: `firstboot` wipes `/root`, while the U-Boot environment
survives. To undo: `fw_setenv bootargs "$(cat /root/bootargs.orig)"`.

If `fw_printenv bootcmd` does not start with
`setenv setargs setenv bootargs ${bootargs};run setargs`, set it from the
U-Boot console:

```
setenv bootcmd 'setenv setargs setenv bootargs ${bootargs};run setargs;sf probe 0;sf read 0x03100000 0x50000 0x200000;nvt_boot'
saveenv
```

Then change the split with `fw_setenv osmem <size>` and reboot. Choose the size
for your board: everything `osmem` gives to Linux is taken from video memory, so
a board with less RAM, or a heavier stream, needs a smaller value. As an
example, a 128 MB NT98566 with a 5 MP sensor boots and streams at both the
default 32M and at 54M.
