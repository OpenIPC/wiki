# OpenIPC Wiki
[Table of Content](../README.md)

For XM vendor boards with NT98562 and NT98566 SoC ONLY!!!
---------------------------------------------------------

### What is supported

- XM vendor boards whose U-Boot prompt is `nvt@na51089:`. The vendor U-Boot
  stays on flash; only the kernel and the root filesystem are replaced.
- NOR flash of 8 MB or more. Anything past 8 MB goes to the settings partition.
- Sensors with video: SC401AI, SC500AI and SC501AI. With any other sensor the
  camera boots and is reachable on the network, but has no video.
- Images: `openipc.nt98562-nor-lite.tgz` and `openipc.nt98566-nor-lite.tgz`.
  The NT98566 image has been checked on hardware; the NT98562 one is built from
  the same tree but has not been tested on a camera yet. Reports are welcome.

### Initial device firmware update

You need a UART console and a TFTP server on the camera's network.

1. Back up the whole flash first and keep the copy off the camera, as described
   in [Backing up stock firmware](backup-stock-firmware.md). U-Boot on these
   boards cannot send a backup over the network, so use a programmer or the
   stock firmware's shell.
2. Download the archive for your SoC, for example
   https://github.com/OpenIPC/firmware/releases/download/latest/openipc.nt98562-nor-lite.tgz,
   and put the `uImage.<soc>` and `rootfs.squashfs.<soc>` files from it in the
   TFTP root.
3. Power the camera on while pressing Ctrl-C on the console until the
   `nvt@na51089:` prompt appears; the boot delay is zero, so a single key press
   is usually too late. Then enter, with your own addresses and SoC:

```
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.254
setenv soc nt98562
setenv osmem 32M
setenv bootargs 'earlyprintk console=ttyS0,115200 mem=${osmem} panic=20 nprofile_irq_duration=on root=/dev/mtdblock3 rootfstype=squashfs init=/init mtdparts=spi_nor.0:64k(loader),256k(boot),2048k(kernel),5120k(rootfs),-(rootfs_data)'
setenv bootcmd 'setenv setargs setenv bootargs ${bootargs};run setargs;sf probe 0;sf read 0x03100000 0x50000 0x200000;nvt_boot'
setenv uk 'mw.b 0x01000000 ff 1000000;tftp 0x01000000 uImage.${soc} && sf probe 0 && sf erase 0x50000 0x200000 && sf write 0x01000000 0x50000 ${filesize}'
setenv ur 'mw.b 0x01000000 ff 1000000;tftp 0x01000000 rootfs.squashfs.${soc} && sf probe 0 && sf erase 0x250000 0x500000 && sf write 0x01000000 0x250000 ${filesize}'
saveenv
run uk && run ur && reset
```

   Each `run` must end with `Written: OK`. If a download or a write fails, the
   line stops there: nothing more is erased and the camera does not reset. Fix
   the TFTP side and run the line again.
4. The settings partition still holds what the stock firmware left there and
   has to be formatted once. A freshly flashed camera is unclaimed and has no
   shell, so log in as `root` on the console or over SSH with no password,
   answer the one-time setup prompt, and run `firstboot`. It formats the
   partition and reboots.
5. `firstboot` also erases the password you just set, so the camera comes back
   unclaimed. Claim it for good: open its web page to set the root password and
   accept the licence, or log in over SSH or the console again. See
   [Factory reset and the unclaimed camera](first-boot.md).

### Follow-up quick updates

From the U-Boot prompt, with the new files in the TFTP root:

```
run uk && run ur && reset
```

Or run `sysupgrade` on a running camera.

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
