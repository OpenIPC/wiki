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
vendor's tuning files, and they are large — a couple of dozen sections. **The
camera reads two of them:** the auto-exposure section and the 3D noise
reduction section. The rest is carried for PQTools' benefit and has no effect
on the picture.

So editing a section of one of these files usually changes nothing, and that is
expected rather than a fault.

If you want the whole of a tune — sharpening, dynamic range, white balance,
gamma — that is what the binary profile above is for.

### Which profile a camera picks on its own

With `isp.iqProfile` unset the camera falls back to
`/etc/sensors/iq/default.ini`, which is a fixed link to one sensor's profile
per SoC family — so an IMX335 camera may be running the IMX307 tuning even
though `imx335.ini` is installed beside it. If that is your camera, point
`isp.iqProfile` at the file named after your own sensor. An explicit setting
always wins.

[mcr]: https://ssd.mathworks.com/supportfiles/MCR_Runtime/R2012a/MCR_R2012a_win32_installer.exe
[pqt]: https://openipc.org/utilities
[pqt-gk]: https://github.com/openipc/pqtools/raw/master/gk7205v200/PQTools.tgz

