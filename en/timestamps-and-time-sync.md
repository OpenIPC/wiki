# OpenIPC Wiki
[Table of Content](../README.md)

Frame Timestamps & Time Synchronization
=======================================

### Preamble

This page is for engineers evaluating OpenIPC cameras for applications
where it matters **when** each frame was captured, not just **what** it
contains: multi-camera fusion, robotics, photogrammetry, latency
measurement, evidence chains, scientific instrumentation.

Short version: OpenIPC HiSilicon cameras on the SoCs listed below give
you **per-frame wall-clock timestamps anchored to the sensor's
frame-start IRQ, with ±3–5 ms accuracy when `ntpd` is well disciplined**.
Multiple cameras on the same NTP server are mutually comparable to that
precision without any additional cabling or sync hardware.

Supported SoCs (kernel hook is wired and hardware-validated):

- `hi3516ev200`, `hi3516ev300`, `gk7205v200` (V4 family)
- `hi3516av300`, `hi3516cv500`

Below is what this means in practice, what it *doesn't* give you, and
how to decide whether it's good enough for your use case.

### What "sensor frame-start timestamp" means

Every encoded frame leaving the camera over RTSP carries a wall-clock
timestamp that reflects the moment the sensor started capturing that
frame — sampled inside the kernel's MIPI RX interrupt handler the
instant the sensor begins streaming row 0.

The kernel exposes per-frame events via `/dev/openipc-frame-ts`, and
majestic uses them to anchor the NTP / RTP-timestamp pair in every
RTCP Sender Report it emits. Receivers that honour RTCP SR — most
ROS 2 `image_transport` plugins, GStreamer's `rtspsrc`, FFmpeg's RTSP
demuxer, libav-based pipelines — get a frame timestamp that reflects
when the frame was *captured*, not when the packet arrived over the
network.

The accuracy budget breaks down roughly as:

- **NTP discipline**: typically ±2–5 ms on a healthy LAN with a local
  NTP server; ±10–30 ms over public internet
- **IRQ latency between sensor vsync and `ktime_get_real_ns()`**: a
  few microseconds on these single-core 32-bit ARM SoCs; not a
  meaningful contributor
- **Sensor readout duration** (rolling shutter): not in the timestamp;
  see *Limitations* below

So the dominant error term is *your network's NTP quality*. With a
chrony-disciplined LAN reference, ±3–5 ms is a routine result across a
4–8 camera deployment.

#### Can it be tighter than NTP? (PTP discussion)

NTP's accuracy floor on these cameras is around the millisecond, set
mostly by the protocol's coarse polling and software path through the
network stack. PTP (IEEE 1588) is the next step up — when supported
properly it gives sub-microsecond multi-device sync over LAN.

**No HiSilicon SoC supported by OpenIPC has hardware-assisted PTP
timestamping.** The MAC PHYs on these chips don't expose the per-packet
hardware timestamping registers that PTP needs to bypass software
jitter. So full-precision PTP isn't reachable on this hardware.

There is a middle path: `linuxptp`'s `ptp4l` can run in *software
timestamping* mode, which gets the timestamps from the kernel network
stack rather than the PHY. On a quiet LAN with a single switch, this
typically tightens multi-device sync from NTP's millisecond ballpark
to roughly ±100 µs – 1 ms. Significant for some workloads, marginal
for others; nobody has empirically validated this on V4/cv500 hardware
yet, so treat it as exploratory.

If you genuinely need sub-microsecond sync (industrial inspection,
high-speed motion capture), look at cameras with PTP-capable PHYs;
that's not these.

### Compared to Basler / FLIR / industrial machine vision

When industrial robotics talks about "synchronised cameras" they
usually mean PTP — hardware time sync over a PHY-aware Ethernet path.
That's appropriate for high-speed manufacturing inspection,
microsecond-level event correlation, or genuinely fast-moving subjects
(rotating turbine blades, projectile tracking).

For a lot of robotics deployments, you don't need that:

|                                     | OpenIPC (supported HiSi SoCs)   | Basler ace / FLIR Blackfly     |
|-------------------------------------|---------------------------------|--------------------------------|
| Time sync mechanism                 | NTP (software);                 | PTP (hardware-timestamped)     |
|                                     | software PTP plausible          |                                |
| Multi-camera sync precision         | ±3–5 ms (LAN, disciplined NTP)  | sub-µs                         |
| Shutter                             | Rolling (most sensors)          | Global available               |
| Per-unit cost                       | $15–40                          | $400–2 000+                    |
| Direct ROS support                  | Via standard RTSP plugins       | Via vendor SDK + ROS wrappers  |
| Hardware trigger IN (capture on pulse) | No (sensor `XVS_IN` not broken out on commodity boards; per-sensor slave-mode driver work not done) | Yes |
| Strobe OUT (drive external LED)     | **Yes** — `/sys/class/misc/openipc-frame-ts/strobe_*`, requires a SoC GPIO reachable on the board | Yes |
| External-event timestamping (correlate GPIO pulse with nearest frame) | **Yes** — `samples/openipc_event_trigger/`, userspace, ms-class accuracy | Yes |

If your application can tolerate **±5 ms multi-camera sync and rolling
shutter**, OpenIPC is 10–50× cheaper per camera and the time-stamping
plumbing now exists end-to-end. Cases where this is the right trade:

- **Multi-camera surround on indoor mobile robots / AGVs** — motion
  speeds of 0.5–2 m/s; 5 ms of sync error corresponds to ~5 mm of
  apparent displacement, well below most SLAM front-ends'
  feature-matching tolerance.
- **Agricultural drones with 4–8 cameras for orthomosaics or NDVI** —
  GPS-correlation precision is the bottleneck, not inter-camera sync.
- **Educational / academic robotics labs** — students need cameras
  with believable timestamps for ROS 2 bags; Basler-class hardware
  isn't in the lab budget.
- **Wildlife camera traps with event correlation** — cameras spread
  across an area, all NTP-disciplined off a single hub.
- **Fixed-site monitoring with motion-event correlation across
  cameras** — construction sites, retail, smart farming.
- **Camera–IMU temporal calibration research** — `kalibr` works with
  millisecond-precision timestamps and *estimates* the residual
  per-camera offset; PTP isn't required.

Cases where you should still reach for Basler / FLIR:

- Anything involving fast rotating machinery, projectile tracking,
  motion-capture-class accuracy
- High-speed industrial inspection where rolling-shutter skew matters
- **True hardware trigger IN** — capture exactly one frame on a PLC
  pulse. OpenIPC can correlate a trigger with the nearest free-running
  frame (see "External-event timestamping" above), which is enough for
  most event-marking workloads, but it cannot gate the sensor itself.
- Direct GigE Vision integration with existing factory tooling

### Limitations to be honest about

1. **Rolling shutter on most supported sensors.** IMX335, IMX415,
   IMX307, the GC-series, the SC-series — these are all rolling
   shutter. Fast camera or subject motion produces the usual skew
   artefacts. The frame-start timestamp refers to row 0's exposure;
   row N starts roughly `N × readout_per_row` later. The chrdev also
   exposes an `ISP_FEND` event giving you the per-mode readout
   duration so you can compute exposure midpoint when needed (typical
   values: ~10 ms at 1080p, ~26 ms at 5MP).
2. **No hardware PTP.** See the discussion above; software PTP via
   `linuxptp` may help, but full sub-µs sync is not reachable on this
   SoC class.
3. **SoC coverage**: only the SoCs listed at the top of this page.
   Older HiSilicon generations are not supported by this feature.
4. **Single sensor channel per camera.** Multi-sensor designs (two
   sensors on one camera SoC) aren't widely tested with this path.
5. **NTP discipline is your responsibility.** Out of the box,
   `busybox ntpd` against a public pool gives roughly ±10–30 ms.
   For tight deployments, run a local `chrony` server and discipline
   the cameras off it; ±3–5 ms is routinely achievable that way but
   not automatic.

### How to verify it's working on your camera

```sh
# On the camera:
ls -l /dev/openipc-frame-ts          # should exist
cat /sys/class/misc/openipc-frame-ts/uevent  # confirms the chrdev

# Stream from a client, check the RTCP Sender Report's NTP field
# matches camera-side wall clock to within NTP precision.
# (GStreamer rtspsrc with debug level 5 dumps SR contents.)
```

A working setup, on a 30 fps sensor with `ntpd` disciplined against a
local server, shows RTCP SR NTP timestamps within ±3–5 ms of the host
client's wall clock at the time of frame capture (not packet arrival).

### Available userspace tools

Two reference samples live alongside the kernel module — copy them as
templates when wiring your own consumer:

- **`samples/openipc_frame_ts/openipc_frame_ts_test.c`** — drain
  events from the chrdev, print per-frame jitter / drop stats.
  Useful for verifying the kernel side is working and for measuring
  end-to-end NTP timestamp precision.
- **`samples/openipc_event_trigger/openipc_event_trigger.c`** —
  correlate an external GPIO pulse with the nearest sensor
  frame-start. PLC / photoeye / strobe event marking. See its
  [README](https://github.com/OpenIPC/openhisilicon/blob/main/samples/openipc_event_trigger/README.md)
  for what it does and doesn't do (it's correlation, not gating).

The kernel-side **strobe-out** feature has no sample because it's
purely sysfs — see the
[chrdev README](https://github.com/OpenIPC/openhisilicon/tree/main/kernel/openipc_frame_ts#strobe-out-gpio-driven-by-frame-events)
for the four sysfs knobs and the two modes (`pulse` for fixed-width
flash pulses, `hold` for ring lights gated to the sensor readout
window).

### Going deeper

- Source of the kernel-side implementation and chrdev ABI reference:
  [OpenIPC/openhisilicon/kernel/openipc_frame_ts](https://github.com/OpenIPC/openhisilicon/tree/main/kernel/openipc_frame_ts)

