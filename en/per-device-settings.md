# OpenIPC Wiki
[Table of Content](../README.md)

Per-device settings: `customizer.sh`, `muxes.sh` and `gpio.conf`
================================================================

A mainline OpenIPC image is built for an SoC family, not for a camera. It has to boot on
any board with that chip, so it ships no knowledge of where *your* camera's IR-cut filter
is wired, which pad powers its SD card, or where it should fetch its next firmware from.

Three files supply exactly that, and they are the reason a supported retail camera comes
up already knowing its own hardware:

| File | Runs | Use it for |
| --- | --- | --- |
| `/usr/share/openipc/customizer.sh` | once, on first boot | settings that should persist: bootloader environment, streamer configuration, extra accounts |
| `/usr/share/openipc/muxes.sh` | every boot | pad multiplexing and GPIO states that do not survive a power cycle |
| `/usr/share/openipc/gpio.conf` | never — it is sourced | naming the pins, so scripts refer to `$ircut1` rather than `67` |

All three are optional. An image without them boots perfectly well; it simply knows
nothing about the board it is on.

> **These files belong in [OpenIPC/builder](https://github.com/OpenIPC/builder), not in
> OpenIPC/firmware.** `general/overlay/` in the firmware tree is copied verbatim into
> *every* image the tree builds, so a `customizer.sh` placed there sets your camera's
> sensor, upgrade URL and pin numbers on every camera of every vendor. In builder each
> file sits under `devices/<board>/general/overlay/usr/share/openipc/` and reaches only
> that board. See [Where they live](#where-they-live) below.

## When each one runs

`/etc/init.d/S30customizer` is what calls them. `rcS` runs the `S??*` scripts in sorted
order, so S30 lands after logging and the clock are up and before the hostname, kernel
modules, networking and the streamer:

```
S01syslogd → S02fakehwclock → S29debugfs → S29pstore → S30customizer →
S31hostname → S35modules → S38mdev → S40network → … → S95majestic → S99rc.local
```

That position is deliberate. Settings written by `customizer.sh` are in place before
anything reads them: `S40network` picks up the wireless credentials, and the streamer
starts long afterwards with whatever configuration was written.

`S30customizer` does four things in order:

1. If `/etc/custom.ok` does **not** exist and `customizer.sh` does, run it, then create
   `/etc/custom.ok`.
2. If `/etc/network.ok` does **not** exist and `wireless.sh` does, run it, then create
   `/etc/network.ok`. (This hook is supported but no device currently ships one.)
3. If `muxes.sh` exists, run it — **every boot**, with no marker file.
4. Repair the camera's MAC address if it needs one.

## `customizer.sh` — the one-time setup

This is a plain shell script run once, in full, as root. There is no schema and no
special vocabulary: whatever you would type at a shell, you can put here.

Three kinds of thing are worth putting in it.

**Bootloader environment**, via `fw_setenv`. These survive reflashing the rootfs, which
is why they are the right home for a board's identity. Across the 96 devices in builder
that ship a `customizer.sh`, the common ones are:

| Variable | Set by | What it does |
| --- | --- | --- |
| `upgrade` | 95 devices | the URL `sysupgrade` fetches this board's firmware from |
| `wlandev` | 77 | which wireless profile `/etc/wireless/usb` should use |
| `wlanssid`, `wlanpass` | 68 | network credentials, if the device ships with any |
| `osmem`, `rmem`, `totalmem` | 33 / 25 / 3 | the memory split — see [Memory tuning](memory-tuning.md) |
| `sensor` | 10 | the image sensor, when autodetection cannot find it |

`rcS` reads `sensor` and `upgrade` into the environment at every boot, so a value set
here is visible to everything that starts afterwards. Note that the reset button is
*not* one of these: it is named in `gpio.conf` as `button`, and read from there by the
device's own reset daemon.

**Streamer configuration**, via `cli -s`. Anything you would otherwise set through the
web interface can be preset:

```sh
cli -s .image.mirror true
cli -s .image.flip true
cli -s .nightMode.irCutPin1 52
cli -s .nightMode.irCutPin2 53
cli -s .nightMode.backlightPin 4
cli -s .audio.enabled true
```

> `cli -s` cannot fail. It stores whatever key path you hand it and exits 0, and a key
> the streamer does not recognise is simply ignored — for the life of the device. A typo
> such as a trailing colon costs you the setting silently, so check the spelling of every
> path you add. [Majestic example config](majestic-config.md) lists the real ones.

**Anything else a first boot should do** — creating a limited viewer account, for
instance. It is a shell script.

### Running it again

`/etc/custom.ok` is the marker that stops it re-running. It lives in the writable overlay
mounted over the root filesystem, so:

- to re-run the script on the next boot by hand: `rm /etc/custom.ok && reboot`
- a **factory reset** clears the whole overlay, and `/etc/custom.ok` with it, so the
  script runs again on the boot after — see
  [Factory reset and the unclaimed camera](first-boot.md)

That second point is the one that surprises people: a factory reset does not just forget
your settings, it re-applies the device's defaults from scratch.

## `muxes.sh` — the every-boot part

Pad multiplexing and GPIO output states are hardware registers. They reset when the
camera loses power, so unlike the bootloader environment they cannot be set once — which
is why this script has no marker file and runs on every boot.

Keep it to what genuinely must be re-applied: putting a pad into the right function,
powering a peripheral on, setting an LED's initial state.

```sh
#!/bin/sh

### set leds power off ###
gpio set 10
gpio set 25

### sd card power en ###
devmem 0x100c0058 32 0
gpio set 38
```

The `gpio` helper takes `set` (drive high), `clear` (drive low), `toggle`, `read` and
`unexport`, and exports the pin and sets its direction for you on first use. See
[Finding out what a pin is wired to](finding-a-gpio.md) if you do not yet know your
board's numbers, and [Board specific GPIO settings list](gpio-settings.md) for boards
somebody has already mapped.

## `gpio.conf` — naming the pins

A bare `gpio set 38` in three different scripts is three chances to get it wrong, and
nothing to grep for when the board revision moves a pad. `gpio.conf` gives the pins
names. It is not executed — it is *sourced*, so it is a list of shell variables:

```sh
alarm_in=-1
alarm_out=-1
button=64
ircut1=63
ircut2=67
led1=10
led2=25
light_ir=72
light_wl=-1
light_sensor=-1
mmc_pwr=38
speaker=28
usb=7
```

Seven names appear on every one of the 18 devices that ship a `gpio.conf` — `button`,
`ircut1`, `ircut2`, `led1`, `led2`, `light_ir` and `mmc_pwr`. Six more are almost as
common: `alarm_in`, `alarm_out`, `light_wl`, `speaker` and `usb` on 17, and
`light_sensor` on 16. Individual boards add their own (`led3`, `relay`, `motors`,
`pir_sensor`) — nothing validates the list, so a name only matters to the scripts that
read it.

**`-1` means the board does not have that pin.** Keep the line rather than deleting it:
it records that somebody looked and the answer was "absent", which is information the
next person needs.

To use it, source it and then refer to the names:

```sh
#!/bin/sh
. /usr/share/openipc/gpio.conf

# sd card power enable
gpio clear $mmc_pwr
```

Consumers guard the include, because the file is optional:

```sh
if [ -e /usr/share/openipc/gpio.conf ]; then
        . /usr/share/openipc/gpio.conf
fi
```

Both `muxes.sh` and per-device helper scripts such as a reset-button daemon use it, and
so does the QR-code Wi-Fi provisioning script in the firmware tree, which blinks `$led1`
while it scans.

## Where they live

In [OpenIPC/builder](https://github.com/OpenIPC/builder), under the device's own
directory, at the same paths they will occupy on the camera:

```
devices/<soc>_<variant>_<vendor>-<model>/
└── general/
    ├── overlay/
    │   └── usr/share/openipc/
    │       ├── customizer.sh
    │       ├── muxes.sh
    │       └── gpio.conf
    └── scripts/
        └── excludes/<soc>_<variant>.list
```

When builder builds that device it copies the contents of `devices/<board>/` over a fresh
checkout of the firmware tree, so `devices/<board>/general/overlay/...` becomes
`general/overlay/...` and is picked up as part of the rootfs overlay like anything else.
That is why the paths match: the device directory is a patch over the firmware tree,
applied for one board only.

The same directory is where a per-device *exclusion list* goes — the list of files to
strip from that board's rootfs to fit its flash. Note that the list is keyed by
`<soc>_<variant>` and not by device, so it must live in the device directory to be
per-board; the same file placed in the firmware tree would prune the generic image for
that SoC too.

## A minimal worked example

For a camera whose IR-cut filter is on pins 63 and 67, whose status LED is pin 10, and
whose SD-card power needs enabling at every boot:

`gpio.conf`

```sh
button=64
ircut1=63
ircut2=67
led1=10
led2=-1
light_ir=72
light_wl=-1
light_sensor=-1
mmc_pwr=38
speaker=-1
usb=-1
alarm_in=-1
alarm_out=-1
```

`muxes.sh`

```sh
#!/bin/sh
. /usr/share/openipc/gpio.conf

# SD card power rail — resets on every power cycle
gpio set $mmc_pwr
```

`customizer.sh`

```sh
#!/bin/sh
#
# Perform basic settings on a known IP camera
#
fw_setenv sensor sc2335
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/<board>-nor.tgz'
#
# Tell the streamer where the IR-cut actuator is
#
cli -s .nightMode.irCutPin1 63
cli -s .nightMode.irCutPin2 67
cli -s .nightMode.backlightPin 72

exit 0
```

## Troubleshooting

**Nothing happened on first boot.** The scripts are only run if they exist at those exact
paths. Check them on the camera with `ls -l /usr/share/openipc/`, and look for the
`Run customizer script...` and `Run custom muxes & gpios preset script...` lines in the
boot log.

**It ran once and now it will not.** That is `/etc/custom.ok` doing its job. Remove it and
reboot.

**A `cli -s` setting did not take.** Re-read the key path character by character. The
write succeeds whatever you type, so a wrong path is silent.

**A GPIO does not do what you expect.** Confirm the number first with
[Finding out what a pin is wired to](finding-a-gpio.md) — a pad that is multiplexed to
something other than GPIO will accept `gpio set` and change nothing visible.
