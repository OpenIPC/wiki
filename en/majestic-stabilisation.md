# OpenIPC Wiki
[Table of Content](../README.md)

Image stabilisation in Majestic
-------------------------------

A camera on a mast, a pole or a vehicle sways, and the picture sways with it.
Majestic's image stabilisation, `isp.dis`, holds the picture steadier while
the camera moves.

| Chip | Supported |
|---|---|
| HiSilicon / Goke | yes, using the chip's own stabiliser |
| Ingenic T31 and later | yes, using the chip's own stabiliser |
| SigmaStar SSC338Q, SSC30KQ, SSC377 | yes, in software; the rest of this page is about these |

The other SigmaStar chips do not offer it.

### Turning it on

In `/etc/majestic.yaml`:

```yaml
isp:
  dis: true
```

Then restart Majestic (`killall -1 majestic`, or reboot). It is off by default.

On SigmaStar this needs a Majestic build newer than 27 October 2026. On an
older build the setting does nothing.

### What changes in the picture

- **Shake is held back and pans still come through.** A slow, deliberate
  pan is followed, and the picture settles back afterwards.
- **The view is a little narrower.** The picture keeps the middle 80% of each
  side (64% of the area), scaled back up to the resolution you configured, so
  a stream at the sensor's full resolution is slightly softer.
- **Every stream gets the same steadied picture:** the main stream, the sub
  stream, JPEG snapshots and motion detection.

### What to expect

Measured on an SSC377 with an imx335 sensor running at 24 frames a second. A
known shake was applied at several speeds, and the motion left over was
compared with stabilisation off and on. 1.00 means no change; lower is
better:

| Shake frequency | 0.5 Hz | 1 Hz | 2 Hz | 3 Hz | 5 Hz | 8 Hz |
|---|---|---|---|---|---|---|
| motion left over | 0.71 | 0.33 | 0.42 | 0.77 | **1.43** | **1.79** |

**It steadies slow sway and makes fast vibration worse.** The correction
always trails the motion slightly (under a tenth of a second). Against slow
movement that hardly matters. Against shake faster than about 3 times a
second, the correction arrives too late and adds to the motion instead of
cancelling it.

On a vehicle:

| Motion | Typical speed | Measured effect |
|---|---|---|
| Body sway, pitching, rocking on a mast | 0.5–2 Hz | 30–70% of the motion remains; best near 1 Hz |
| Engine, road, fan vibration | above 3 Hz | Made worse |

Fast vibration also blurs and wobbles each frame, and no stabiliser that
crops the picture can undo that. Mount the camera rigidly, or on rubber
dampers, for vibration. Turn on stabilisation for sway.

A higher frame rate should shorten the lag and so widen the range it helps
with. That has not been measured: the figures above are for 24 frames a
second only.

### What it costs

- **CPU:** about 3% of one core on the single-core SSC377.
- **A still camera stays still.** On a fixed mount, stabilisation adds no
  visible movement of its own (0.03 pixels measured, against 0.07 with it
  off).

### When it does not start

If stabilisation cannot start, Majestic logs the reason and keeps streaming
without it. On the SSC377:

- **Too many outputs at once.** With the main stream, sub stream, JPEG
  snapshots and motion detection all enabled, it cannot start. Turn off any
  one of them.
- **A crop is set.** It does not start while `video0.crop` or `video1.crop` is
  set. A crop changed while stabilisation runs takes effect once `isp.dis` is
  off again and Majestic restarted.

### Checking that it runs

- **Metrics.** `/metrics` shows the `dis_*` lines below only while
  stabilisation is running. `dis_frames` counting up means it is working.
- **Log.** If the metrics are missing, read Majestic's startup messages with
  `logread`. Around the start of the video pipeline, Majestic says whether
  stabilisation started, and if not, why.

| Metric | Meaning |
|---|---|
| `dis_frames` | frames processed so far |
| `dis_detect_us` | time the last frame took to process, in microseconds |
| `dis_offset_x`, `dis_offset_y` | how far the picture is currently shifted from the centre, in pixels |
| `dis_refused` | frames whose motion was too large to be shake, and was ignored |
| `dis_crop_errors` | corrections the chip refused; should stay 0 |
| `dis_put_errors` | internal buffer errors; should stay 0 |

### Status on the SSC338Q and SSC30KQ

The figures above were measured on an SSC377. Stabilisation on the SSC338Q
and SSC30KQ works the same way but has not yet been run on one of those
cameras. If it fails there, Majestic logs why and keeps streaming without
it. Reports from SSC338Q and SSC30KQ owners are very welcome, ideally from
a moving vehicle. Please include the startup log and the `dis_*` metrics.

### See also

- [Majestic example config](majestic-config.md): the `isp` section.
- [Majestic streamer](majestic-streamer.md).
