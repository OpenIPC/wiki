# OpenIPC Wiki
[Table of Content](../README.md)

Telling a camera about its own hardware
=======================================

A mainline OpenIPC image is built for an SoC family, not for a camera. It has to boot on
any board with that chip, so it ships no knowledge of where *your* camera's IR-cut filter
is wired, which pad powers its SD card, or where it should fetch its next firmware from.

There are **two ways** to tell it, and which one you want depends on whether you are
setting up a camera or supporting a model.

| | [Through the camera's own settings](#through-the-cameras-own-settings) | [Through a device profile](#through-a-device-profile) |
| --- | --- | --- |
| **Who does it** | whoever has the camera | whoever maintains support for that model |
| **How** | the web interface, or `cli` over SSH | three files in [OpenIPC/builder](https://github.com/OpenIPC/builder) |
| **Applies to** | that one camera | every unit of that model, on first boot |
| **Takes effect** | immediately | before the streamer ever starts |
| **Survives a reboot** | yes | yes |
| **Survives a factory reset** | **no** — settings go with the overlay | **yes** — the profile re-applies them |
| **Needs a rebuild** | no | yes, the image is rebuilt for that device |

They are not alternatives so much as the same settings arriving by different routes: a
device profile mostly consists of the very writes the web interface would have made, made
for you before you ever open it. Read the first section if you have a camera in front of
you; read the second if you want the next hundred units of that model to come up right
with nobody touching them.

---

Through the camera's own settings
---------------------------------

Most of what a camera needs to know about its own hardware is an ordinary setting, and
the web interface is where you set it. Nothing here involves files, a rebuild, or a
shell.

**Settings → Pins** draws the chip and lets you say what is soldered to each pad — a
lamp, a button, a sensor bus. You can **Try it** first, and **Keep** it once you are
happy; a kept choice is saved on the camera rather than needing a boot script to
re-apply it, which is the part a hand-written `devmem` line never managed.

**Settings → Day / Night** is where the IR-cut filter's two coil pins, the infrared
lamp and a light sensor go, and it can test the filter and tell you if the coils are
wired backwards.

If you do not yet know which pad is which, the camera will find out for you — see
[Finding out what a pin is wired to](finding-a-gpio.md), which covers both hunts, what
the camera refuses to drive and why, and what to do when it comes up empty.

The same settings are reachable over SSH with `cli`, which is useful for scripting and
is exactly what a device profile uses:

```sh
cli -s .nightMode.irCutPin1 63
cli -s .nightMode.irCutPin2 67
cli -s .nightMode.backlightPin 72
cli -g .nightMode.irCutPin1          # read one back
```

> `cli -s` cannot fail. It stores whatever key path you hand it and exits 0, and a key
> the streamer does not recognise is simply ignored — for the life of the device. A typo
> such as a trailing colon costs you the setting silently, so check the spelling of every
> path you add. [Majestic example config](majestic-config.md) lists the real ones. The
> web interface does not have this problem: it only offers paths that exist.

**Where these settings live, and what erases them.** They are written into the streamer's
configuration file, which sits in the writable overlay on top of the read-only root
filesystem. A reboot keeps them. A **factory reset** clears that overlay, and your
settings go with it — the camera comes back with whatever its image shipped. That is the
single biggest practical difference between the two routes, and the reason a model with
real support behind it uses the second one.

---

Through a device profile
------------------------

A device profile is how a camera model comes up already knowing its own hardware, with
nobody opening the web interface at all. It is three files:

| File | Runs | Use it for |
| --- | --- | --- |
| `/usr/share/openipc/customizer.sh` | once, on first boot | settings that should persist: bootloader environment, streamer configuration, extra accounts |
| `/usr/share/openipc/muxes.sh` | every boot | pad multiplexing and GPIO states that do not survive a power cycle |
| `/usr/share/openipc/gpio.conf` | never — it is sourced | naming the pins, so scripts refer to `$ircut1` rather than `67` |

All three are optional. An image without them boots perfectly well; it simply knows
nothing about the board it is on, and everything above has to be done by hand.

> **These files belong in [OpenIPC/builder](https://github.com/OpenIPC/builder), not in
> OpenIPC/firmware.** `general/overlay/` in the firmware tree is copied verbatim into
> *every* image the tree builds, so a `customizer.sh` placed there sets your camera's
> sensor, upgrade URL and pin numbers on every camera of every vendor. In builder each
> file sits under `devices/<board>/general/overlay/usr/share/openipc/` and reaches only
> that board. See [Where they live](#where-they-live) below.

### When each one runs

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

### `customizer.sh` — the one-time setup

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

These are the same writes described under
[Through the camera's own settings](#through-the-cameras-own-settings), and they carry
the same caution: a mistyped path is stored and ignored rather than rejected, so it costs
you the setting silently. Presetting from a profile makes that worse, not better — there
is no one at the web interface to notice the switch did nothing.

**Anything else a first boot should do** — creating a limited viewer account, for
instance. It is a shell script.

#### Running it again

`/etc/custom.ok` is the marker that stops it re-running. It lives in the writable overlay
mounted over the root filesystem, so:

- to re-run the script on the next boot by hand: `rm /etc/custom.ok && reboot`
- a **factory reset** clears the whole overlay, and `/etc/custom.ok` with it, so the
  script runs again on the boot after — see
  [Factory reset and the unclaimed camera](first-boot.md)

That second point is the one that surprises people: a factory reset does not just forget
your settings, it re-applies the device's defaults from scratch.

### `muxes.sh` — the every-boot part

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

### `gpio.conf` — naming the pins

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

# SD card power rail — this board enables it by driving the pad low
gpio clear $mmc_pwr
```

> **Polarity is board-specific, and the name does not tell you which way round it is.**
> `mmc_pwr` is enabled by `gpio clear` on the board above and by `gpio set` on the one in
> [the worked example](#a-minimal-worked-example) below; both are real devices. `gpio.conf`
> records *which pad*, never *which level* — so check your board rather than copying a
> line, and say in a comment which way yours goes.

Consumers guard the include, because the file is optional:

```sh
if [ -e /usr/share/openipc/gpio.conf ]; then
        . /usr/share/openipc/gpio.conf
fi
```

Both `muxes.sh` and per-device helper scripts such as a reset-button daemon use it, and
so does the QR-code Wi-Fi provisioning script in the firmware tree, which blinks `$led1`
while it scans.

### Where they live

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

# SD card power rail — this board enables it high, and it resets on every
# power cycle, so it has to be re-applied rather than set once
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

For a single camera you would reach the same end state without any of these files: set
the three pins on **Settings → Day / Night**, the sensor and upgrade URL are already
right for the image you flashed, and the SD-card rail is one line in a startup script or
a pad you declare on **Settings → Pins**. The profile's value is not that it can do
something the interface cannot — it is that the hundredth unit of this model does it
without anyone being there, and does it again after a factory reset.

## Troubleshooting

**A setting I made in the web interface is gone.** A factory reset clears the overlay,
and the streamer's configuration lives there. Settings made on the camera do not come
back; settings carried by a device profile do, because `customizer.sh` runs again on the
next boot. If you want a setting to survive resets, it has to be in the profile.

**Nothing happened on first boot.** The scripts are only run if they exist at those exact
paths. Check them on the camera with `ls -l /usr/share/openipc/`, and look for the
`Run customizer script...` and `Run custom muxes & gpios preset script...` lines in the
boot log.

**It ran once and now it will not.** That is `/etc/custom.ok` doing its job. Remove it and
reboot.

**A `cli -s` setting did not take.** Re-read the key path character by character. The
write succeeds whatever you type, so a wrong path is silent. Setting the same thing once
through the web interface is the quickest way to find out what the path should be.

**A GPIO does not do what you expect.** Confirm the number first with
[Finding out what a pin is wired to](finding-a-gpio.md) — a pad that is multiplexed to
something other than GPIO will accept `gpio set` and change nothing visible.
