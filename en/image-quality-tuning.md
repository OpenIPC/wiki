# OpenIPC Wiki
[Table of Content](../README.md)

Overview
--------

Each SoC manufacturer has its own software to adjust picture quality:

* HiSilicon - PQTools
* Novatek - isptool
* Fullhan - Coolview

## HiSilicon based boards

### EV300 family

#### Run server module on OpenIPC boards

```console
$ pqtools

.....

dev mounted
libs mounted
pqtools:begin to run
the s32Result is 1
g_bUseSpecAWB is 0
port is : 4321

<HI_PQT_Network_Init>(1486)bind ok!
pqtools:server(port:4321)begin to listen
pqtools:Waiting for connection from client!
```

#### Run server module on XM boards

For sake of simplicity we wse public NFS server:

```console
$ mount -o nolock 95.217.179.189:/srv/ro /utils/
$ cd /utils/ittb_ev300_V1.0.1.2/
$ LD_LIBRARY_PATH=lib ./ittb_control

...
pqtools:Waiting for connection from client!
```

#### Run client software on Windows

Download and install [MATLAB Compiler Runtime][mcr].

Download [PQTools][pqt] and extract a zip archive somewhere on your PC.

Launch `HiPQTools.exe`, select `Hi3516EV200_V1.0.1.2`, type IP address of your
camera and click `OK`.


### Goke boards (gk7205v200, gk7205v210, gk7205v300)

Same shape, different build of both halves. On the camera:

```console
$ pqtools
```

It fetches the board-side server and starts it. On the PC, use the Goke build
of PQTools rather than the EV300 one — they are not interchangeable, and a
profile exported through the wrong one will not load back (see *If the camera
refuses the file* below).

Download [PQTools for Goke][pqt-gk].

Keeping the picture you tuned
-----------------------------

PQTools changes the running camera and nothing else. Close it, or reboot, and
the tuning is gone. To keep it, export it from PQTools as a **`.bin`** profile,
put that file on the camera, and point the camera at it.

### 1. Export from PQTools

Use PQTools' own export. You get a single binary file — on a gk7205v300 it is
100904 bytes; the size differs by SoC, and that exact size matters, so do not
edit or convert the file.

### 2. Put it somewhere that survives a reboot

`/tmp` does not. Anywhere under `/etc` does — the camera keeps a writable
overlay there:

On the camera:

```console
$ mkdir -p /etc/sensors/iq
```

Then from the PC, with the exported file beside you:

```console
> scp tuned.bin root@<camera>:/etc/sensors/iq/tuned.bin
```

Copy it, do not retype or paste it — the exact byte count is part of what makes
the file valid.

### 3. Point the camera at it

```console
$ cli -s .isp.iqProfile /etc/sensors/iq/tuned.bin
```

Or set **Image quality profile** on the camera's settings page. Either way the
camera picks the profile up on its own — no restart, and the video keeps
running.

**The name matters.** A file whose name ends in `.ini` is read as a text
profile; anything else is read as a PQTools binary profile. Call the file
`tuned.bin`, `tuned.pq`, anything — just not `something.ini`.

The camera reports which profile it took and whether it loaded. The picture is
the real test: look at it before and after.

### 4. To bake it into a firmware image

Put the file in the image's overlay, at the same path, and set
`isp.iqProfile` in the `majestic.yaml` the image ships. Every camera flashed
with that image then comes up on your tuning.

### If the camera refuses the file

The camera reports a size mismatch — the profile it was given against the size
a profile for this camera has to be. That means the file came from somewhere
else: a different SoC, a different SDK generation, or a different build of
PQTools.

A binary profile is not portable and cannot be converted. Export it again from
a camera of the same kind, through the PQTools build for that kind.

What a `.ini` profile does, and does not, carry
-----------------------------------------------

Cameras ship text profiles in `/etc/sensors/iq/`, one per sensor. These are the
vendor's tuning files, and they are large — a couple of dozen sections.

> **This changed in September 2026.** The camera used to read two sections of
> such a file and ignore the rest, so editing most of one changed nothing.
> Builds from late September 2026 read most of it. If you tried this before
> and it did nothing, try again on a current build.

On the gen-4 families — hi3516ev200/ev300, hi3516cv500/av300, gk7205v200,
gk7205v300 and gk7205v500 — sharpening, noise reduction, dynamic range, local
contrast, dehaze, defect pixels, the auto-exposure route and the metering
weights are read, along with the ISO-indexed ladders for dynamic range, dehaze
and gamma. gk7205v210 shares the gk7205v200 build, so it behaves the same.

White balance is not read, and neither is anything on the older families,
whose profiles are written in a different vocabulary.

Each of those sections appears twice in a vendor profile: once for daylight,
and once with an `ir_` prefix for when the IR-cut filter is out of the light
path. The camera switches between the two halves as it moves between its day
and night settings.

The camera prints a summary at startup naming the profile it read, which half
of it, and anything in the file it could not use or does not read. If an edit
appears to change nothing, that summary is the first thing to check.

Two traps worth knowing before editing a ladder:

- **`[dynamic_dehaze]` does nothing until `isp.dehaze` is `-1`** — on the
  families that have that key, which is hi3516ev200/ev300 and
  gk7205v200/v300/v500. Any other value puts the dehaze block in manual mode,
  where the automatic strength the ladder writes is ignored. `-1` hands the
  block to the profile, and automatic image tuning then leaves that one knob
  alone and goes on tuning the rest — it takes effect live, without a
  restart. The default is unchanged, so no camera moves without being told
  to. Elsewhere the key does not exist and the ladder simply runs.
- **The ISO counts written in a shipped profile are not always the array
  lengths.** Some files declare one count and list one more value than that.
  The camera reads the arrays for what they hold and requires them to agree
  with each other, rather than trusting the count.

A section whose values do not parse — a row shorter than the chip's table, a
value out of range — is refused whole rather than applied in part.

`isp.*` settings in `/etc/majestic.yaml` are applied on top of the profile, so
where both have an opinion the setting wins. See
[Majestic configuration](majestic-config.md).

### Getting your tuning back out as text

There is no converter from a `.bin` to a `.ini`, and there cannot be one: a
binary profile carries no record of which named setting any part of it came
from, so there is nothing for a converter to read.

What works is the other direction — asking the camera what it is currently
running. From the late-September 2026 nightly builds:

```console
> curl -u root:PASSWORD -o profile-day.ini \
      http://<camera>/api/v1/isp/profile.ini
```

That writes the camera's live image settings out as an `.ini` in the same
vocabulary the shipped profiles use, and it loads straight back in through
`isp.iqProfile`. So a PQTools session, or a `.bin` imported once, can be turned
into text you can read, edit, diff, send to somebody else or bake into an
image.

Three things are deliberately not in that file, each said in its own comments
where you would otherwise go looking:

- **The day/night half the camera was not in.** It holds one set of settings,
  not two, so a camera in its night settings writes out `ir_` sections. To
  capture both, download once in daylight and once at night — under **two
  different names**, as above, or the second overwrites the first.
- **The ISO-indexed ladders**, including the 3D noise reduction table. The
  camera holds the rung it is running at, not the ladder that produced it, and
  writing that rung out as a curve would claim one light level's tuning for
  every light level. Copy those sections across from the profile you started
  from.
- **One dynamic-range setting**, for the same reason in a smaller way. Where a
  ladder is driving it the file says so in place of the number; with no ladder
  loaded it is ordinary tuning and is written out normally.

One more caveat: the auto-exposure section is what the camera is *running*,
which is not the profile's values if you have set `isp.aeSpeed`,
`isp.aeTolerance`, `isp.aeBlackDelay` or `isp.aeWhiteDelay` — those are applied
on top. The file carries a comment saying so.

Verified on a gk7205v300 with an IMX335 sensor, running the IMX335 profile the
images ship: nine sections download, load back section for section, and the
next download is identical.

### Which profile a camera picks on its own

With `isp.iqProfile` unset the camera looks for
`/etc/sensors/iq/<sensor>.ini` matching the sensor it detected, and falls back
to `/etc/sensors/iq/default.ini`. An explicit setting always wins.

> **This changed in September 2026 too.** The camera used to go straight to
> `default.ini`, which is a fixed link to one sensor's profile per SoC family
> — so an IMX335 camera could be running the IMX307 tuning with `imx335.ini`
> installed beside it. On an older build, point `isp.iqProfile` at the file
> named after your own sensor.

[mcr]: https://ssd.mathworks.com/supportfiles/MCR_Runtime/R2012a/MCR_R2012a_win32_installer.exe
[pqt]: https://openipc.org/utilities
[pqt-gk]: https://github.com/openipc/pqtools/raw/master/gk7205v200/PQTools.tgz

