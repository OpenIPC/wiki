# OpenIPC Wiki
[Table of Content](../README.md)

## Boot device with NFS

Booting a camera with its root filesystem on an NFS share lets you develop and
debug **without reflashing**. Edit files on your workstation, reboot the camera,
and the change is live. It also scales to a fleet: many cameras can boot from one
server, each optionally served a different kernel/rootfs.

There are two ways to do this:

1. **[Manual method](#manual-method)** — point u-boot at an NFS share by hand,
   using any existing firmware. Quick, no rebuild.
2. **[The `openipc-nfs-root` package](#the-openipc-nfs-root-package)** — build a
   purpose-made NFS-root image with stable MAC handling, a writable overlay, and
   automatic boot-time setup (password, DNS/NTP, hostname, SSH key).

---

## Manual method

This walkthrough boots a camera over NFS/TFTP using any existing firmware, by
typing commands at the u-boot prompt over a UART console. Nothing in flash is
modified unless you explicitly `saveenv`, so it is non-destructive and easy to
revert. The worked example uses a XiongMai XM530 camera; only the SoC-specific
values (`mem=`, load address, `mtdparts`, console name) differ between boards.

You will need two services reachable from the camera — a **TFTP server** for the
kernel and an **NFS server** for the rootfs. They can be the same machine.

### 1. Connect a UART console

Wire a 3.3 V USB-UART adapter to the camera's GND / RX / TX pads and open a serial
console at 115200 baud:

```sh
picocom -b 115200 /dev/ttyUSB0
```

> **Warning:** never connect the UART adapter to a pad carrying 12 V — it will
> destroy the adapter. Confirm pad voltages with a multimeter first (RX/TX idle at
> ~3.3 V).

Power the camera and press `Ctrl+C` repeatedly to interrupt autoboot and drop to
the u-boot prompt.

### 2. Save the current u-boot environment

Before changing anything, print and copy the existing variables so you can restore
them later:

```
printenv
```

Note especially `bootcmd`, `bootargs`, `ipaddr`, `serverip`, `ethaddr`, and the
`mtdparts` string. A typical XM530 stock environment looks like:

```
bootargs=mem=35M console=ttyAMA0,115200 root=/dev/mtdblock2 rootfstype=cramfs mtdparts=xm_sfc:256K(boot),1536K(kernel),1280K(romfs),4544K(user),256K(custom),320K(mtd)
bootcmd=sf probe 0;sf read 80007fc0 40000 180000;bootm 80007fc0
ipaddr=192.168.1.10
serverip=192.168.1.107
ethaddr=00:12:41:00:00:01
```

Check the network works from u-boot:

```
ping 192.168.1.1
```

### 3. Set up the TFTP server (kernel)

Install a TFTP daemon and point it at a root directory, e.g. `/mnt/tftproot`. With
`atftp` on the server (`/etc/conf.d/atftp` or your distro's equivalent):

```
TFTPD_ROOT="/mnt/tftproot"
TFTPD_OPTS="--daemon --user nobody --group nobody"
```

Obtain a kernel image. Either download the prebuilt OpenIPC release archive for
your SoC and extract the `uImage`, or build it from source. Place it in the TFTP
root under a recognisable name, e.g. `/mnt/tftproot/uImage.xm530`.

Verify the server serves it:

```sh
atftp --get -r uImage.xm530 -l /tmp/uImage.xm530 192.168.1.1
```

### 4. Set up the NFS server (rootfs)

Export a directory that will hold the unpacked rootfs (`/etc/exports`):

```
/mnt/nfsroot 192.168.0.0/16(async,rw,no_subtree_check,no_root_squash)
```
```sh
sudo exportfs -ra
```

Populate it with an OpenIPC rootfs. From a release archive, unpack the SquashFS
image with `unsquashfs` into `/mnt/nfsroot/`; from a local build, untar
`rootfs.tar` there (preserving permissions). Confirm it is writable:

```sh
sudo mount -o nolock,rw 192.168.1.3:/mnt/nfsroot /mnt/test
sudo touch /mnt/test/writetest && sudo rm /mnt/test/writetest
```

> If you get read-only errors, a parent directory is likely exported read-only —
> the camera will still boot but cannot write. Fix the export for a usable system.

### 5. Boot over NFS from u-boot

Set the server/client addresses, build the NFS bootargs, and boot. Note u-boot
`setenv` uses a space (no `=`) after the variable name:

```
setenv serverip 192.168.1.1
setenv ipaddr 192.168.1.10

setenv bootargsnfs 'mem=35M console=ttyAMA0,115200 panic=20 root=/dev/nfs rootfstype=nfs nfsroot=192.168.1.3:/mnt/nfsroot,v4,nolock,tcp rw ip=192.168.1.10:192.168.1.3:192.168.1.1:255.255.255.0::eth0'

setenv nfsboot 'tftp 0x81000000 uImage.xm530;setenv setargs setenv bootargs ${bootargsnfs};run setargs;bootm 0x81000000'

run nfsboot
```

The kernel `ip=` argument is positional:

```
ip=<client-ip>:<server-ip>:<gateway>:<netmask>:<hostname>:<device>:<autoconf>
```

A successful boot prints something like:

```
IP-Config: Complete:
 device=eth0, hwaddr=00:12:41:09:9c:1b, ipaddr=192.168.1.10, mask=255.255.255.0, gw=192.168.1.1
 bootserver=192.168.1.3, rootserver=192.168.1.3, rootpath=
```

> **Always use `tcp` in the `nfsroot=` options.** NFS over UDP can fail silently on
> some setups. `panic=20` reboots the board 20 s after a kernel panic, which is
> handy while iterating.

### 6. First login

Log in over the console or SSH with the OpenIPC defaults:

```
user: root
pass: 12345
```

On XiongMai boards, stop the watchdog immediately so it doesn't reboot the camera
mid-setup:

```sh
rmmod xm_wdt
```

If sensor auto-detection didn't run (common on a read-only rootfs), create the
sensor symlink by hand and start the streamer — for example:

```sh
ln -s /usr/lib/sensors/libsns_X50_XM530.so /usr/lib/libsns.so
majestic
```

### 7. Make it permanent, or revert

To boot from NFS automatically on every power-on, set `bootcmd` and persist it —
only after you've confirmed the manual boot works:

```
setenv bootcmd 'tftp 0x81000000 uImage.xm530;setenv setargs setenv bootargs ${bootargsnfs};run setargs;bootm 0x81000000'
saveenv
```

To return to the firmware in flash, restore the `bootcmd`/`bootargs` you saved in
step 2 and `saveenv` again. Because the NFS setup lives only in u-boot variables
(unless you flashed anything), reverting is just restoring those variables.

The bootargs above differ per SoC. For example, a HI3516EV200 board uses an
`ttyAMA0` console and its own memory size:

```
setenv bootargsnfs 'mem=${osmem:-32M} console=ttyAMA0,115200 panic=20 root=/dev/nfs rootfstype=nfs nfsroot=192.168.1.254:/media/nfs/hi3516ev200,v3,nolock,tcp rw ip=192.168.1.55:192.168.1.254:192.168.1.254:255.255.255.0::eth0'
```

---

## The `openipc-nfs-root` package

The `openipc-nfs-root` Buildroot package builds a kernel + rootfs tarball pair
tailored for NFS boot, instead of a flashable firmware image. It is opt-in and
disabled by default — boards that don't enable it get the normal flashable
firmware and no kernel changes.

### Why use it

- **No flash wear, no reflash cycle** — iterate on `/etc`, init scripts, or
  binaries directly on the server.
- **Bigger rootfs** — NFS root is not bound by the 8/16 MB flash limits, so you
  can include debug tooling (`gdb`, `strace`, test harnesses) that never fits in a
  normal build.
- **Stable per-device MAC** — a single kernel patch makes the early-boot network
  take its MAC from the device tree, then from an `ethaddr=` boot argument, before
  falling back to a random MAC. Stable MACs make DHCP reservations and per-device
  NFS exports reliable.
- **Fleet provisioning** — boot many cameras from one server; key each device on
  its MAC or on DHCP option 60 (settable in the u-boot env as `bootp_vci`) to
  decide which kernel/rootfs to serve.

### Build it

The helper script builds without permanently editing any defconfig — it
temporarily appends the package settings to `general/openipc.fragment`, builds,
and restores the fragment afterwards:

```sh
./contrib/make_nfsroot <defconfig> [options]
```

| Flag         | Meaning                                                         |
|--------------|----------------------------------------------------------------|
| `--passwd`   | Root password — plaintext, or a `$1$…`/`$5$…`/`$6$…` hash       |
| `--tz`       | IANA timezone, e.g. `Europe/Berlin` (POSIX TZ derived at build) |
| `--ntp`      | Static NTP server (else learned from DHCP)                      |
| `--dns`      | Static DNS server (else learned from DHCP / u-boot)            |
| `--hostname` | Fallback hostname if none supplied by DHCP / u-boot env         |
| `--pkgs`     | File listing extra `BR2_PACKAGE_*=y` lines to fold in           |

Example:

```sh
./contrib/make_nfsroot gk7205v300_lite_defconfig \
    --passwd 'hunter2' --tz Europe/Berlin --hostname cam-lab-01
```

On success it prints the output paths:

```
NFS-root build complete
-----------------------
kernel: [1.8M]   output/images/uImage.gk7205v300
rootfs: [15M]    output/images/rootfs.gk7205v300.tar
```

Alternatively, enable it directly and build as usual — the two paths are
equivalent:

```sh
echo 'BR2_PACKAGE_OPENIPC_NFS_ROOT=y' >> general/openipc.fragment
make BOARD=gk7205v300_lite
```

### Configuration options

| Symbol                          | Default | Notes |
|---------------------------------|---------|-------|
| `BR2_PACKAGE_OPENIPC_NFS_ROOT`  | n       | Master switch |
| `…_TMPFS_SIZE`                  | `16M`   | Writable overlay size in read-only mode |
| `…_PASSWD`                      | `12345` | Root password (plaintext or hash) — **change it for anything but a lab** |
| `…_TIMEZONE`                    | (host)  | IANA zone; empty → detect from build host |
| `…_NTP_SERVER`                  | (DHCP)  | Static NTP server; empty → DHCP / default route |
| `…_DNS_SERVER`                  | (DHCP)  | Static DNS server; empty → DHCP / u-boot |
| `…_HOSTNAME`                    | (DHCP)  | Fallback hostname |

### Server setup

Unpack the rootfs onto your NFS export, preserving permissions:

```sh
sudo mkdir -p /srv/nfs/cam-gk7205v300
sudo tar -xpf output/images/rootfs.gk7205v300.tar -C /srv/nfs/cam-gk7205v300
```

Export it (`/etc/exports`):

```
/srv/nfs/cam-gk7205v300  192.168.1.0/24(rw,no_root_squash,no_subtree_check)
```
```sh
sudo exportfs -ra
```

Serve the kernel (`output/images/uImage.<soc>`) over TFTP, or flash only the
kernel partition while leaving the rootfs on NFS.

### Pointing u-boot at it

```
setenv bootargs console=ttyS0,115200 \
    ip=dhcp \
    root=/dev/nfs \
    nfsroot=192.168.1.10:/srv/nfs/cam-gk7205v300,vers=3,tcp \
    ro \
    ethaddr=00:11:22:33:44:55 \
    hostname=cam-lab-01
```

Tokens the OpenIPC init keys on:

- **`root=/dev/nfs`** — selects the NFS-root path in `/init`.
- **`ro` / `rw`** — read-only (tmpfs overlay) vs read-write (direct). See below.
- **`ethaddr=`** — stable MAC. Omit it to let a device-tree MAC win; omit both for
  a random MAC. The u-boot default `00:00:23:34:45:66` is deliberately ignored so
  it never overrides a real address.
- **`hostname=`** — optional; otherwise a DHCP- or build-supplied hostname is used.

Static IP instead of DHCP:

```
ip=192.168.1.50:192.168.1.10:192.168.1.1:255.255.255.0:cam-lab-01:eth0:off
```

### Read-only vs read-write

**Read-only (`ro`) — recommended for fleets.** The export is mounted read-only and
a tmpfs overlay (`…_TMPFS_SIZE`, default 16 MB) provides the writable layer. Many
cameras can share one export safely, each with its own private, volatile overlay.
Runtime changes are lost on reboot. The root password is reapplied every boot, and
a persistent SSH host key is generated once and stored in the u-boot environment,
then restored each boot — so the key is stable even though the rootfs isn't.

**Read-write (`rw`) — single device per export.** The camera writes directly to
the share and changes persist, but **only one device may use a given export** —
concurrent writers will corrupt it. First-boot setup runs once, guarded by
`/etc/firstboot`.

### Networking note

On an NFS root, `eth0` and `lo` are brought up by the kernel's early network
config before userspace starts. To stop any service from reconfiguring or downing
`eth0` — which would instantly kill the rootfs — the package installs no-op
`ifup`/`ifdown` profiles. Userspace still sees the interfaces as up and may
"toggle" them, but the operations do nothing; the link stays as the kernel left
it. This is intentional and specific to NFS-root builds.

### Troubleshooting

| Symptom | Likely cause / fix |
|---------|--------------------|
| Build fails: `requires Linux >= 4.5` | The board's kernel predates `eth_platform_get_mac_address()`; that board can't use the package. |
| Random/wrong MAC each boot | No `ethaddr=` and no device-tree MAC. Add `ethaddr=` to bootargs or provide it via the device tree. |
| Changes vanish after reboot | You are in `ro` mode — expected (tmpfs overlay). Use `rw` for persistence, single device only. |
| Corrupted rootfs with several cameras | Multiple devices on one `rw` export. Switch them to `ro` (shared) or give each its own `rw` export. |
| SSH host-key changes each boot | `fw_setenv` is not writable on your board, so the key can't be persisted. Check u-boot env access. |

### See also

- Buildroot manual: [Linux kernel specific infrastructure](https://buildroot.org/downloads/manual/adding-packages-linux-kernel-spec-infra.txt)
