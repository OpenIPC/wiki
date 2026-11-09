# OpenIPC Wiki
[Table of Content](../README.md)

AI noise reduction in Majestic
------------------------------

In low light a camera turns up its gain, and the picture fills with grain.
Grain is expensive: the encoder spends bitrate trying to keep it, and what
is left looks blotchy. Majestic's AI noise reduction, `isp.aibnr`, runs a
denoising neural network on the camera's NPU before the picture is
processed into colour. It works on the raw sensor data, where noise is
easiest to tell apart from detail.

It is available on one chip family only:

| Chip | Supported |
|---|---|
| Hi3516CV610 variants with the NPU (see below) | yes |
| Hi3516CV608, Hi3516CV610-10B | no, the chip has no AI noise reduction |
| everything else | no |

### What you need

This needs Majestic and OpenIPC firmware builds newer than 9 November 2026.

1. **A Hi3516CV610 variant with the NPU.** OpenIPC records the variant in
   the bootloader environment as `socmodel`:

   ```sh
   fw_printenv socmodel
   ```

   `20s`, `20g`, `00s` and `00g` have the NPU. `10b` does not, and neither
   does the Hi3516CV608.

2. **Ultimate firmware.** Only the ultimate image carries the feature and
   the model files it needs. Lite firmware does not have it.

3. **A model for your sensor's resolution.** The network is built for one
   exact frame size, and the firmware ships models for two of them:

   | Resolution | Sensors |
   |---|---|
   | 1920×1080 | CV2003, IMX662, SP2308 |
   | 2560×1440 | GC4653, SC4336P, VS4388 |

   Check what your camera has:

   ```sh
   ls /usr/share/aiisp
   ```

   Each resolution has two files, `aibnr_model_<width>x<height>.bin` and
   `aibnr_model_<width>x<height>_high_iso.bin`. The camera switches to the
   second one when the gain is high. IMX335 cameras (2592×1944) have no
   model. At five megapixels the NPU would manage only about 10 frames a
   second.

4. **A normal (linear) sensor mode.** It does not work together with WDR.

### Turning it on

In `/etc/majestic.yaml`:

```yaml
isp:
  aibnr: true
```

Or from the shell, where `cli` saves the setting and tells Majestic to reload
it:

```sh
cli -s .isp.aibnr true
```

It is also in the web interface's settings, as *AI noise reduction*. It is
off by default.

Changing it rebuilds the video pipeline, so streams drop for a moment and
RTSP clients reconnect.

### The frame rate

The NPU denoises one frame at a time. At 1920×1080 that takes about 33 ms,
which is almost exactly the time between frames at 30 frames a second. Two
settings follow from that:

| `isp.aibnrFps` | What you get at 1080p |
|---|---|
| `0` (default) | the sensor keeps its own rate; at 30 fps about 28 frames a second come through, slightly unevenly |
| `25` | the sensor runs at 25 and every frame comes through, evenly |

```yaml
isp:
  aibnr: true
  aibnrFps: 25
```

If a stream is configured faster than `aibnrFps` (for example
`video0.fps: 30` with `aibnrFps: 25`), it runs at `aibnrFps` and the log says
so.

At 2560×1440 each frame takes longer. The chip's vendor quotes 12 frames a
second at 2688×1520. That has not been measured on OpenIPC yet, so start
low and raise `aibnrFps` while the stream stays smooth.

### What it costs

Measured on a Hi3516CV610-family camera with an IMX662 at 1920×1080:

| | Off | On, sensor at 30 fps | On, `aibnrFps: 25` |
|---|---|---|---|
| frames per second delivered | 30 | 28 | 25 |
| NPU busy | 0% | 94% | 82% |
| free memory | 76 MB | 44 MB | 44 MB |

- **Memory:** about 30 MB more at 1080p, all of it given back when the
  setting is turned off.
- **NPU:** busy for almost the whole frame time, so nothing else can use it
  while noise reduction runs.
- **Picture edges:** the outermost 8 pixels on each side are cropped,
  because the denoiser leaves a faint pattern there. The stream keeps its
  configured resolution.
- **CPU:** load barely changes.

### When it cannot run

If noise reduction cannot start, the camera streams exactly as it does with
the setting off, and Majestic's log says why.

**The sensor is in a WDR mode.** Noise reduction waits while WDR is on. Put
the sensor back in its normal (linear) mode, and noise reduction comes back
on by itself with that change. There is nothing to toggle.

**Anything else.** That covers:

- no model for the sensor's resolution,
- a chip without AI noise reduction,
- a damaged model file,
- not enough memory.

In these cases the setting stays inactive until it is turned off and on
again, or Majestic restarts. That way a broken model cannot leave the camera
rebuilding its pipeline over and over. Fix the cause first: add or replace
the model file, or free memory by lowering the stream sizes. Then turn the
setting off and on.

### Checking that it is working

From outside the camera:

- **Frame rate:** with the sensor at 30 fps and `aibnrFps` at `0`, the
  stream's frame rate drops to about 28 while it runs. With `aibnrFps: 25`
  it runs at 25. At 30 exactly, noise reduction is not running.
- **Memory:** `free` on the camera shows about 30 MB less at 1080p than
  with the setting off.

The chip's own driver also reports how busy the NPU is. On HiSilicon it does
this in the same status files the [encoder tuning](majestic-encoder-tuning.md)
page reads:

```sh
cat /proc/umap/svp_npu
```

At 1080p and 30 fps, `hw_utilization` sits in the low 90s. With the setting
off, or after a failure, it is 0.

### How much it helps

How much it helps depends on the scene and the light. The difference is
small in daylight, where there is little noise to remove, and largest at
night, at high gain. On a plain flat surface at high gain, fine-grained
noise in the brightness fell by about a third. A comparison on a detailed
scene in low light, against the camera's ordinary noise reduction, has not
been made yet. The quickest way to judge is your own camera: take a snapshot
at night with the setting off, then on, and compare.
