# OpenIPC Wiki
[Table of Content](../README.md)

## Failsafe mode and recovery

An interrupted or corrupt firmware update used to leave a camera bricked
*silently*: it would reboot forever with no picture, no web interface and no
shell, recoverable only by opening the case and soldering a serial header.

Recent firmware for the Goke **gk7205v200** and **gk7205v300** adds a safety net.
A camera that fails to come up cleanly several times in a row no longer loops
forever — the bootloader brings it up in **failsafe mode**: networking and SSH
only, no video and no services. From there you can reach the camera over the
network, look at what went wrong, and put it right without a soldering iron.

This page explains how failsafe mode is entered, how to recognise it, and how to
restore a camera **over the network** or **from an SD card / USB stick**.

> **Availability.** Failsafe is on gk7205v200 and gk7205v300 in OpenIPC images
> from the September 2026 [nightly builds](nightly-builds-and-bisect.md) onward
> (see the [changelog](show-changelog.md)). Because it lives partly in the
> bootloader, and [`sysupgrade`](sysupgrade.md) does **not** replace the
> bootloader, a camera gains it only once a build carrying it has been written
> as a full flash — see [Reach](#a-note-on-reach) at the end. Other SoCs are
> unaffected and boot as before.

### How a camera enters failsafe

The bootloader keeps a small **boot-attempt counter**. It counts up by one on
every boot, and a camera that reaches a *healthy* state — the video stream up and
serving for a sustained window — resets it back to zero. So in normal use the
counter never climbs: each good boot clears it.

If the camera keeps failing before it becomes healthy, the counter is never
cleared and climbs instead. Once it passes the limit (**2**), the bootloader
stops trying to boot normally and enters failsafe.

Two properties matter in practice:

- **A warm reset keeps the count** (so a genuine reboot loop is counted and
  eventually caught), **but pulling the power resets it to zero.** Cutting the
  power therefore grants the camera a fresh set of normal boot attempts — useful
  if the failure was a one-off.
- **Nothing is written to flash on a healthy boot.** The counter lives in RAM,
  not in the bootloader environment, so this feature adds no flash wear and
  cannot corrupt the environment on a power cut.

```
                          ┌──────────────────────────────┐
        power on  ──────▶ │  Bootloader: boot counter +1  │
                          └───────────────┬──────────────┘
                                          │
                              ┌───────────▼───────────┐
                              │   counter > limit?     │   limit = 2
                              └─────┬─────────────┬────┘
                              no    │             │    yes
                       ┌────────────▼───┐    ┌────▼─────────────────────────┐
                       │  normal boot   │    │  FAILSAFE boot               │
                       │  verify + load │    │  network + SSH only          │
                       │  kernel/rootfs │    │  no video / web / services   │
                       └───────┬────────┘    └────┬─────────────────────────┘
                               │                  │  counter is reset here,
                    ┌──────────▼─────────┐        │  so failsafe never loops
                    │  video stream up   │        ▼
                    │  for ~15 seconds?  │   SSH in and recover
                    └────┬──────────┬────┘
                    yes  │          │  no
              ┌──────────▼───┐  ┌───▼───────────────┐
              │ clear counter│  │ leave counter set │──▶ next boot climbs,
              │ (fresh start)│  │                   │    eventually FAILSAFE
              └──────────────┘  └───────────────────┘
```

### Recognising failsafe mode

A camera in failsafe runs **networking and SSH only** — the video stream, the web
interface and every other service are deliberately not started. So you can tell
it apart from a healthy camera by what is *missing* as much as what answers:

- **No video** — RTSP, ONVIF and snapshots do not answer.
- **No web interface** — the WebUI does not load either (it is one of the
  services failsafe skips).
- **SSH works** — if the camera is already [claimed](first-boot.md), your
  existing login still works, because the overlay with your settings stays
  mounted.
- The kernel command line ends with the word `failsafe`. Over SSH:

  ```
  # cat /proc/cmdline
  ... root=/dev/mtdblock3 ... failsafe
  ```

If you have a [serial console](serial_pins_uart.md) attached, you will also have
seen the bootloader report that the boot limit was exceeded and announce that it
is entering failsafe (network + SSH only) as the camera came up.

Once you have fixed the cause, a plain reboot returns the camera to a normal
boot — the failsafe boot resets the counter on the way in, so it does not get
stuck in failsafe.

### The crash report

If the previous boot crashed, the kernel's crash log is preserved across the
reboot for a bug report. Where you read it depends on which state the camera is
in:

- **In failsafe (over SSH)** — the preserved log is kept under `/etc/crash/`
  (a `crash.tar.gz` archive plus a short summary). Copy it off with `scp` (see
  the note about `-O` below).
- **Once the camera is back to a normal boot** — the web interface raises a
  **"this camera recovered from a crash"** notice with a **Download crash log**
  button and a **Dismiss** action. Nothing is ever uploaded anywhere; Dismiss
  clears the notice and the log.

The breadcrumb is stored on the overlay, so the WebUI notice is still waiting for
you after the camera recovers to a normal boot — you do not have to catch it in
failsafe. Attaching that log to a report is what lets the cause be fixed rather
than just worked around.

### Restoring the camera

Pick the first option that applies — most cameras only need the first one.

#### 1 — Over the network, from failsafe (SSH)

If the camera reached failsafe it is on the network and answers SSH. This is the
normal case and needs no serial console.

1. Find the camera's address (from your DHCP server).
2. Log in over SSH with the camera's root password.
3. Optionally grab the crash log first. The camera's BusyBox image has no SFTP
   server, so modern OpenSSH clients need `-O` to fall back to legacy SCP
   (the same caveat as the [upgrade guide](sysupgrade.md)):

   ```
   scp -O root@<camera-ip>:/etc/crash/crash.tar.gz .
   ```
4. Fix the cause. If a bad setting or a failed update caused the loop, correct it
   and reboot.
5. If the installed image itself is broken, flash a known-good one with
   [`sysupgrade`](sysupgrade.md) — that page has the exact command and the
   correct image name for your board and flash size. When it finishes the camera
   reboots into the new image.
6. Reboot. A healthy boot clears the counter and the camera is back to normal.

#### 2 — From the bootloader, when the camera cannot boot at all

Use this when the camera cannot even reach failsafe — for example the kernel or
root filesystem was **erased or corrupted** (a power cut in the middle of a
flash). You need a [serial console](serial_pins_uart.md).

**Automatic recovery (easiest).** When the kernel or rootfs is missing or fails
its integrity check, the bootloader flags the image as bad and tries to recover
on its own — it looks for a recovery image on an **SD card** first, then a **USB
stick**, then over **TFTP** (after a DHCP lease), and reflashes from whichever it
finds. It prints a *"reflashing, do not power off"* banner while it works. So you
can often recover by just preparing one of these and power-cycling:

- **Storage** — format an SD card (or USB stick) as **FAT32** and copy your
  board's two recovery files to it:
  - `uImage.<soc>` — the kernel
  - `rootfs.squashfs.<soc>` — the root filesystem

  (`<soc>` is your board, e.g. `gk7205v200`; download them from the
  [OpenIPC releases](https://github.com/OpenIPC/firmware/releases).) Insert it and
  power-cycle.
- **Network** — serve the same two files from a TFTP server on the same network
  (see [TFTP install](installation-tftpd.md)), then power-cycle the camera on
  that network.

**Manual recovery.** To drive it yourself, attach the serial console, power on,
and press **Ctrl-C** when you see `Press Ctrl-c to stop autoboot` to stop at the
bootloader prompt (`OpenIPC #`). The exact `sf erase` / `sf write` offsets depend
on whether your camera has **8 MB or 16 MB** of flash, so the reliable, size-aware
procedure — flashing a full image over TFTP or from an SD card — is documented in
[U-Boot help](help-uboot.md); set `flashsize` there to `0x800000` for 8 MB or
`0x1000000` for 16 MB.

On a bootloader new enough to carry failsafe, once the two files above are on a
TFTP server or SD card, these one-line shortcuts reflash kernel and rootfs
together — **pick the pair matching your flash size, not your SoC** (a
gk7205v200, for instance, ships with either 8 MB or 16 MB):

```
# over TFTP, 8 MB flash:
run uknor8m && run urnor8m ; reset
# over TFTP, 16 MB flash:
run uknor16m && run urnor16m ; reset
# from an SD card (8 MB layout):
run ukmmc && run urmmc ; reset
# from a USB stick (8 MB layout):
run ukusb && run urusb ; reset
```

Do **not** power off while it is writing.

### Last resort: serial recovery

If none of the above applies — the bootloader itself is damaged, or there is no
console output at all — fall back to the low-level procedures:

- [U-Boot help](help-uboot.md) — bootloader commands, full-image flashing, and
  recovering a locked or damaged bootloader.
- [Serial pins / UART](serial_pins_uart.md) — how to attach a console.
- [Equipment for flashing](equipment-flashing.md) and
  [Flash-chip interfacing](flash-chip-interfacing.md) — reflashing the SPI chip
  directly.

### A note on reach

Failsafe protects **newly-flashed and new-production cameras** first. A
[`sysupgrade`](sysupgrade.md) updates the kernel and root filesystem but **not**
the bootloader, and the boot-attempt counter lives partly in the bootloader — so
the behaviour reaches a camera only after it has received a bootloader carrying
it, which happens on a full flash, not on an over-the-air upgrade. To confirm
whether a given camera has it, check the [changelog](show-changelog.md) for the
build it was flashed from, or watch a [serial console](serial_pins_uart.md) at
boot for the failsafe messages.

### Notes and caveats

- **Never flash an untested image onto a camera you cannot reach with a serial
  recovery cable.** A bad root filesystem is only discovered after it is written.
  Read [Equipment for flashing](equipment-flashing.md) and
  [Serial pins / UART](serial_pins_uart.md) before your first flash.
- **A camera with no root password is [unclaimed](first-boot.md)** and offers no
  shell. If a camera in failsafe was never claimed, use the serial / bootloader
  routes above.
