# OpenIPC Wiki
[Table of Content](../README.md)

Moving between lite and ultimate without a UART
-----------------------------------------------

Ultimate is the bigger firmware: Wi-Fi drivers, ZeroTier, MQTT, the CPU person
detector that object detection and PTZ Follow use on chips without an NPU. It
needs a **16 MB NOR flash**. This page moves a camera from lite to ultimate, and
back, over the network, keeping its settings: passwords, SSH keys,
`majestic.yaml` and everything else under `/overlay`.

Nothing here needs a serial console. Everything that can go wrong before the
flash is touched is checked first, and the camera refuses rather than starts.
The one thing nothing can protect against is a **power cut while the flash is
being written** (about a minute). Do this on a camera whose power you trust,
and keep the backup below in any case.

### 1. Find out what you have

On the camera:

```console
root@openipc:~# cat /proc/mtd
dev:    size   erasesize  name
mtd0: 00040000 00010000 "boot"
mtd1: 00010000 00010000 "env"
mtd2: 00200000 00010000 "kernel"
mtd3: 00500000 00010000 "rootfs"
mtd4: 008b0000 00010000 "rootfs_data"
```

Add up the sizes. `0x1000000` is 16 MB, `0x800000` is 8 MB. On 8 MB, ultimate
does not fit: stop here. The second partition may be called something else
(`wtf` on XiongMai boards); that does not matter.

Then look at `rootfs`:

| `rootfs` size | Layout | Go to |
|---|---|---|
| `00a00000` (10 MB) | 16 MB layout, room for ultimate already | [2A](#2a-the-16-mb-layout-sysupgrade) |
| `00500000` (5 MB) on a 16 MB chip | 8 MB layout, from an 8 MB profile or a vendor install | [2B](#2b-the-8-mb-layout-ipctool) |

`grep BUILD /etc/os-release` tells you which firmware runs now. `BUILD_OPTION`
is `lite` or `ultimate`. A `BUILD_PLATFORM` with two underscores
(`hi3516ev300_lite_xm-85h50ai`) is a **device profile** from
[OpenIPC/builder](https://github.com/OpenIPC/builder). Move it to the same
device's other profile from the builder releases, not to the generic firmware:
the profile carries the board's drivers and settings.

### 2A. The 16 MB layout: sysupgrade

No repartition is needed; flash the other variant over this one:

```console
root@openipc:~# sysupgrade --force_ver \
    --url=https://github.com/OpenIPC/firmware/releases/download/latest/openipc.hi3516ev300-nor-ultimate.tgz
```

Use your SoC in the file name, and `-nor-lite.tgz` to go back.

- `--force_ver` is needed because lite and ultimate from the same night carry
  the same version. Without it, sysupgrade prints `Same version, nothing to
  update` and reboots having written nothing.
- A device profile also needs `--force_soc`, and its own image:
  `https://github.com/OpenIPC/builder/releases/download/latest/<soc>_ultimate_<device>-nor.tgz`.

Settings are kept, as with any sysupgrade. After the reboot, check
`grep BUILD_OPTION /etc/os-release`.

### 2B. The 8 MB layout: ipctool

The kernel grows from 2 to 3 MB and the rootfs from 5 to 10 MB, starting at a
new place. `sysupgrade` cannot do that. `ipctool upgrade` can, while the camera
runs:

- it keeps the bootloader and everything else in front of the kernel exactly as
  it is;
- it edits only what has to change in the bootloader's environment: the
  partition list and how much kernel to read;
- it copies your settings into the new settings partition.

#### Back up the whole flash first

On your computer, with the camera's address and password:

```console
$ ssh root@192.0.2.10 "cat /dev/mtd0 /dev/mtd1 /dev/mtd2 /dev/mtd3 /dev/mtd4" > camera-backup.bin
$ ls -l camera-backup.bin
-rw-r--r-- 1 user user 16777216 ... camera-backup.bin
```

It must be exactly 16777216 bytes. Keep it. It is the whole camera: with it,
anything can be put back, and with it we can reproduce a problem exactly
(see [Something went wrong](#something-went-wrong)).

It also holds your password hash, Wi-Fi keys and SSH keys, so do not post it
publicly.

#### Rehearse it on your computer (recommended)

[qemu-hisilicon](https://github.com/OpenIPC/qemu-hisilicon) runs your
backup as a virtual camera, its own bootloader included. You can do the whole
migration there first and see the result before your real camera is touched.

This recipe is tested on `hi3516ev300`. The project's README lists the SoCs
whose Linux boots. On a Linux computer:

```console
$ git clone https://github.com/OpenIPC/qemu-hisilicon && cd qemu-hisilicon
$ bash qemu/setup.sh            # builds QEMU, once
$ cp ../camera-backup.bin rehearsal.bin
$ ./qemu-src/build/qemu-system-arm -M hi3516ev300,sensor=none,flash-file=rehearsal.bin \
    -m 128M -nographic -serial file:console.txt -monitor none \
    -nic user,hostfwd=tcp::2222-:22
```

Use your SoC for the machine name. Work on a **copy**: everything the virtual
camera writes goes into that file.

- After a minute it answers on `ssh -p 2222 root@127.0.0.1` with your camera's
  password.
- Run the steps below against it, with `-P 2222` for scp. `console.txt` shows
  the boot and the flashing.
- The picture stays black: there is no sensor in the virtual camera, and the
  streamer may not start. What the rehearsal proves is the layout, the boot
  and the settings.

#### Make the upgrade bundle

On your computer, with Python 3:

```console
$ curl -LO https://raw.githubusercontent.com/OpenIPC/ipctool/master/tools/upgrade_bundle.py
$ curl -LO https://github.com/OpenIPC/firmware/releases/download/latest/openipc.hi3516ev300-nor-ultimate.tgz
$ python3 upgrade_bundle.py --layout nor16m -f openipc.hi3516ev300-nor-ultimate.tgz -o ultimate.bundle
```

For a device profile, take its image from the builder releases instead, and
tell the camera where its future upgrades come from:

```console
$ python3 upgrade_bundle.py --layout nor16m -f hi3516ev300_ultimate_xm-85h50ai-nor.tgz \
    -e upgrade=https://github.com/OpenIPC/builder/releases/download/latest/hi3516ev300_ultimate_xm-85h50ai-nor.tgz \
    -o ultimate.bundle
```

The script refuses an image that does not fit its partition.

#### Copy it and run it

The bundle is about 10 MB, and the camera writes from it, so it needs that much
room in `/tmp` (`df -h /tmp`). If there is not enough, put it on an SD card
(`/mnt/mmcblk0p1/`).

```console
$ scp -O ultimate.bundle root@192.0.2.10:/tmp/
$ ssh root@192.0.2.10
root@openipc:~# rm -f /tmp/ipctool      # so the next line fetches the current release
root@openipc:~# ipctool upgrade /tmp/ultimate.bundle
```

`ipctool` is downloaded from GitHub the first time it runs. A camera without
internet access can take it from the
[release page](https://github.com/OpenIPC/ipctool/releases/tag/latest)
(`ipctool` for ARM, `ipctool-mips32`, `ipctool-arm64`), copied to `/tmp` and
made executable.

Before stopping anything it prints what it will do:

```
Keeping boot (256 KB)
Keeping env (64 KB)
Settings: 56 entries in 576 of 2752 KB
bootargs will be: ... mtdparts=hi_sfc:256k(boot),64k(env),3072k(kernel),10240k(rootfs),-(rootfs_data) ...
bootcmd will be: ... sf read ... 0x50000 0x300000 ...
```

Then your SSH session drops: every other process is stopped while the flash is
written. The camera reboots by itself, and answers again on its old address with
its old password after about a minute and a half.

It refuses, with **nothing written** and the camera still running, when:

| Message | Meaning |
|---|---|
| `image ... doesn't fit to ... partition` | wrong bundle for this layout |
| `the settings need more than ... KB there is room for` | the settings partition is smaller under ultimate (2.7 MB, 8.7 MB under lite). Clean up `/overlay` (old backups, logs), or use `--wipe-settings` |
| `rootfs_data ... is not mounted as jffs2` | the settings cannot be read. `--wipe-settings` goes ahead without them |
| `... has extended attributes, which cannot be carried` | a file in `/overlay` carries one; copying it without would bring back files you deleted |
| `The bootloader's environment names no partitions` / `Cannot find root= and mtdparts= ...` | a bootloader this does not know how to edit. Please send us the backup |

`--wipe-settings` starts the new firmware from defaults. The camera then comes
up **unclaimed**, with no password. Set one in the web interface (see
[Factory reset and the unclaimed camera](first-boot.md)).

#### Check

```console
root@openipc:~# cat /proc/mtd
mtd2: 00300000 00010000 "kernel"
mtd3: 00a00000 00010000 "rootfs"
mtd4: 002b0000 00010000 "rootfs_data"
root@openipc:~# grep BUILD_OPTION /etc/os-release
BUILD_OPTION=ultimate
```

From now on the camera upgrades like any other 16 MB-layout camera:
`sysupgrade -k -r`, or the web interface.

### Back to lite

**On the 16 MB layout** (where 2B left you): use 2A with the lite image. Lite
runs fine in the bigger partitions.

**To return to the 8 MB layout exactly**, for instance a device profile that
only exists in lite, use 2B with `--layout nor8m` and the lite image:

```console
$ python3 upgrade_bundle.py --layout nor8m -f openipc.hi3516ev300-nor-lite.tgz -o lite.bundle
```

The settings partition grows back to 8.7 MB, so the settings always fit.

### Something went wrong

- **The camera did not come back.** If it rebooted into a broken state, it
  needs a UART (or a programmer) and your backup.
- **Before writing to us**, run the same bundle against your backup in QEMU
  (see the rehearsal above). If it fails there too, the problem is reproducible,
  and we can fix it from the backup alone.
- Open an issue at [OpenIPC/ipctool](https://github.com/OpenIPC/ipctool/issues)
  with:
  - what `ipctool upgrade` printed;
  - `cat /proc/mtd` and `fw_printenv` from before;
  - the bundle's file name.

  Send the backup itself **privately**, not attached to the issue: it contains
  your passwords and keys.

### Tested

- **8 MB layout, vendor bootloader:** a XiongMai 85H50AI (hi3516ev300, 16 MB
  NOR, XiongMai bootloader). Rehearsed in QEMU on its own flash dump, then on
  the camera itself. Settings carried: every file under `/overlay` was
  byte-identical afterwards, except the clock and random-seed files the
  firmware rewrites on every boot.
- **8 MB layout, OpenIPC bootloader:** in QEMU, a hi3516ev300 on OpenIPC's own
  bootloader, from the 16 MB layout to the 8 MB one (lite) and back (ultimate).
- **16 MB layout:** in QEMU, a hi3516ev300 on the generic firmware, sysupgraded
  to lite and back to ultimate.
