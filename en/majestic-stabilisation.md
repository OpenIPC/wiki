# OpenIPC Wiki
[Table of Content](../README.md)

Image stabilisation in Majestic
-------------------------------

A camera on a mast, a pole or a vehicle sways, and the picture sways with it.
Majestic's image stabilisation, `isp.dis`, holds the picture still while the
camera moves, by showing a slightly smaller window of the frame and moving
that window against the motion.

The same setting means different things on different chips:

| Chip | How it stabilises |
|---|---|
| HiSilicon / Goke | The ISP's own stabiliser (DIS) |
| Ingenic T31 and later | The ISP's "move state" mode |
| SigmaStar SSC338Q, SSC30KQ (infinity6e) and SSC377 (infinity6c) | Measured from the picture by Majestic itself; the rest of this page |

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

### What it does on SigmaStar

These chips have no stabiliser that works without a gyro, so Majestic measures
the motion from the picture:

- It looks at a small patch in the middle of each frame and finds how far it
  moved since the previous frame.
- From those steps it works out which part of the motion is shake and which
  part is a deliberate pan.
- It moves the visible window against the shake. A slow pan still comes
  through, and the window drifts back to the centre afterwards.

Every stream shows the same steadied picture: the main stream, the sub
stream, JPEG snapshots and motion detection.

**The picture keeps the middle 80% of each side** (64% of the area), which is
what leaves room for the window to move. The window is scaled back up to the
size you configured, so a stream at the sensor's full resolution loses a
little sharpness. Every crop-based stabiliser costs the same.

### What to expect

The stabiliser was measured on an SSC377 with an imx335 at 2560×1920. A known
shake was applied to the picture at several speeds, and the motion left over
was compared with the stabiliser off and on. 1.00 means no change; lower is
better:

| Shake frequency | 0.5 Hz | 1 Hz | 2 Hz | 3 Hz | 5 Hz | 8 Hz |
|---|---|---|---|---|---|---|
| motion left over | 0.71 | 0.33 | 0.42 | 0.77 | **1.43** | **1.79** |

**It steadies slow sway and makes fast vibration worse.** The motion is
measured on frames that have already gone to the encoder, so the correction
arrives about two frames late. Against slow movement that does not matter.
Against shake faster than about 3 times a second, the late correction adds to
the motion instead of cancelling it.

On a vehicle:

| Motion | Typical speed | What the stabiliser does |
|---|---|---|
| Body sway, pitching, rocking on a mast | 0.5–2 Hz | Cuts it to about a third |
| Engine, road, fan vibration | above 3 Hz | Makes it worse |

Fast vibration also smears and wobbles each frame (motion blur and rolling
shutter), and no window can undo that. Mount the camera rigidly, or on rubber
dampers, for vibration. Turn on the stabiliser for sway.

A higher frame rate shortens the delay: at 60 fps the limit moves up to about
6 Hz.

### What it costs

- **CPU:** about 3% of one core on the single-core SSC377.
- **A still camera stays still.** On a fixed mount the stabiliser adds no
  visible movement of its own: it measured 0.03 pixels against 0.07 with it
  off.
- **A spare scaler port.** The SSC377 and its relatives have four, and
  Majestic uses one each for the main stream, the snapshot, the sub stream
  and motion detection. With all four in use the stabiliser has no port
  left, so it does not start; the log says so and the video runs
  unstabilised. Turning off any one of those four makes room.

### Things that do not combine

- **`video0.crop` / `video1.crop` on the SSC377 (infinity6c).** On this chip
  your crop and the stabiliser's window are the same setting, so with a crop
  set the stabiliser does not start. On the SSC338Q and SSC30KQ the two are
  meant to work together, with your crop applied inside the steadied picture
  (see the status note below).
- **A crop changed while the stabiliser runs** on the SSC377 waits for
  `isp.dis` to be turned off and Majestic restarted.

### Checking that it runs

The log says so at startup:

```
logread | grep -i stabilis
```

A line such as `Stabilising a 2048x1536 window of the 2560x1920 frame on 2
port(s)` means it is running. If it did not start, the same search shows
why (`Running without stabilisation`, with the reason logged just before it).
Majestic keeps streaming either way.

While it runs, `/metrics` has:

| Metric | Meaning |
|---|---|
| `dis_frames` | frames measured so far |
| `dis_detect_us` | how long the last measurement took, in microseconds |
| `dis_offset_x`, `dis_offset_y` | how far the window is from the centre, in pixels |
| `dis_refused` | measurements thrown away as implausible: a jump too large to be shake |
| `dis_crop_errors` | window moves the hardware refused; should stay 0 |
| `dis_put_errors` | frame buffers the hardware would not take back; should stay 0 |

### Status on the SSC338Q and SSC30KQ

The measurements above are from the SSC377. The SSC338Q and SSC30KQ use the
same measurement and the same correction. Only the last step, moving the
window, goes through a different part of the chip, and that step has not yet
been run on one of these cameras. If it fails, Majestic logs why and keeps
streaming without stabilisation. Reports from SSC338Q/SSC30KQ owners are very
welcome, with the startup log line and the `dis_*` metrics, ideally from a
moving vehicle.

### See also

- [Majestic example config](majestic-config.md): the `isp` section.
- [Majestic streamer](majestic-streamer.md).
