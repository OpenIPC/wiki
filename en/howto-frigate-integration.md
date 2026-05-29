# OpenIPC Wiki
[Table of Content](../README.md)

Integrate Frigate NVR with OpenIPC
==================================

[Frigate](https://frigate.video/) is an open-source NVR with real-time
object detection. It ingests RTSP, so any OpenIPC camera streaming with
Majestic can be added as a Frigate camera without extra software on the
camera side.

This guide covers two levels of integration:

- **Level 1 — Passive recording.** Frigate connects to the camera's RTSP
  stream and runs its own motion + object detection. The camera does no
  extra work.
- **Level 2 — Camera-side motion as external trigger.** Majestic's built-in
  motion detector publishes events over MQTT, and Frigate uses those events
  to gate its own detection windows. Useful when the Frigate host is
  CPU-bound and the camera's on-chip detector is "good enough" to gate the
  object detector.

> Frigate's `onvif:` config block wires up PTZ autotracking only; as of
> 0.17 it does not subscribe to ONVIF motion events. Camera-side motion
> still has to reach Frigate through MQTT (Step 3).

## What you'll need

- An OpenIPC camera reachable on the LAN, streaming via RTSP.
- A Frigate install (0.14 or newer recommended) — Docker, Home Assistant
  add-on, or bare-metal.
- (Level 2 only) An MQTT broker (e.g. Mosquitto) reachable from both the
  Frigate host and the camera, and an Ultimate firmware build on the camera
  so `mosquitto_pub` is available — see the
  [FAQ](faq.md) for the difference between Lite and Ultimate builds.

## Step 1 — Confirm the camera's RTSP stream

Majestic exposes two streams by default:

```
rtsp://<user>:<pass>@<camera-ip>:554/stream=0    # main, full resolution
rtsp://<user>:<pass>@<camera-ip>:554/stream=1    # sub, lower resolution
```

Default credentials on a fresh image are `root` / `12345`. Verify the
stream works before touching Frigate:

```sh
ffprobe -v error -rtsp_transport tcp -i \
  "rtsp://root:12345@192.168.1.10:554/stream=0"
```

You should see the codec (`hevc` or `h264`), resolution, and frame rate
reported.

If the sub-stream is black or missing, enable it in `/etc/majestic.yaml`:

```yaml
video1:
  enabled: true
  size: 640x360
  codec: h264
  fps: 15
```

`stream=1` is well worth enabling — Frigate uses it for the motion +
detect stage, which is by far the most CPU-hungry part of the pipeline.

## Step 2 — Minimal Frigate config (Level 1)

Add the camera to Frigate's `config.yml`. Two-input setup: low-res
sub-stream for detection, full-res main stream for recording and
snapshots.

```yaml
mqtt:
  enabled: false  # Level 1 doesn't need MQTT

cameras:
  openipc_front:
    ffmpeg:
      inputs:
        - path: rtsp://root:12345@192.168.1.10:554/stream=1
          input_args: preset-rtsp-restream
          roles:
            - detect
        - path: rtsp://root:12345@192.168.1.10:554/stream=0
          input_args: preset-rtsp-restream
          roles:
            - record
    detect:
      width: 640
      height: 360
      fps: 5
    record:
      enabled: true
      retain:
        days: 7
        mode: motion
    snapshots:
      enabled: true
    motion:
      threshold: 20      # OpenIPC sub-stream is small; default 30 misses events
      contour_area: 15
    objects:
      track:
        - person
        - car
```

Restart Frigate. The camera should appear in the web UI within a few
seconds. Walk past it and confirm events are recorded.

### Hardware acceleration

H.265 on the main stream is heavy to decode in software. Add an
`hwaccel_args` preset matching your Frigate host so ffmpeg uses the GPU:

```yaml
ffmpeg:
  hwaccel_args: preset-vaapi   # or preset-nvidia, preset-rpi-64-h264, etc.
```

See [Frigate's hwaccel docs](https://docs.frigate.video/configuration/hardware_acceleration/)
for the right preset.

## Step 3 — Camera-side motion as external trigger (Level 2, optional)

This step replaces Frigate's pixel-diff motion stage with Majestic's
on-chip motion detector. The camera fires an MQTT message, Frigate
treats it as a motion event, and the object detector runs only during
those windows. Best suited to busy scenes where Frigate's motion stage
otherwise eats CPU.

> Motion detection in Majestic is currently supported on Hisilicon/Goke,
> Ingenic and Sigmastar SoCs. See
> [Majestic streamer — Motion detection](majestic-streamer.md) for the
> source of truth on this list.

### 3a. Enable motion detection in Majestic

```sh
cli -s .motionDetect.enabled true
cli -s .motionDetect.debug true
killall majestic; sleep 3; majestic &
```

You should see lines like the following in Majestic's log when something
moves in front of the camera:

```
<hi_motionDetect> [mdetect] motion_detect_thread@820  Motion detected in 23 regions, 0x0 -> [1672x2150]
```

### 3b. Publish motion events over MQTT from the camera

Majestic invokes `/usr/sbin/motion.sh` only on the **rising edge** of a
motion event (the moment motion starts, not on every frame while motion
continues). Replace the default script with one that publishes to your
broker. Adjust the broker host, credentials and topic to match your
setup:

```sh
#!/bin/sh
# /usr/sbin/motion.sh
# Called with four positional args: x y w h (bounding box of detected
# motion in vendor coordinates). Most integrations ignore them.
BROKER="192.168.1.20"
CAMERA="openipc_front"

mosquitto_pub -h "$BROKER" \
  -t "openipc/$CAMERA/motion" \
  -m "{\"x\":$1,\"y\":$2,\"w\":$3,\"h\":$4,\"ts\":$(date +%s)}"
```

Make it executable and verify by hand:

```sh
chmod +x /usr/sbin/motion.sh
/usr/sbin/motion.sh 100 200 300 400
mosquitto_sub -h 192.168.1.20 -t 'openipc/#' -v   # from another host
```

### 3c. Have Frigate honour the external signal

There is no first-class "use external motion" toggle in Frigate, so the
practical pattern is to make Frigate's motion stage very cheap (so it
never gates events) and use the MQTT API to flip detection on/off per
camera based on the camera's signal. Wire this up through your home
automation broker (Home Assistant automation, Node-RED flow, or a small
script) by:

1. Subscribing to `openipc/<camera>/motion`.
2. Publishing `ON` to `frigate/<camera>/detect/set` when an event arrives.
3. Publishing `OFF` after a debounce timeout (e.g. 15 seconds).

The Frigate MQTT topics for runtime control are documented in
[Frigate's MQTT reference](https://docs.frigate.video/integrations/mqtt/).

This is more brittle than Level 1 — only adopt it if profiling shows
Frigate's motion stage is genuinely the bottleneck on your host.

## Troubleshooting

- **"Connection refused" / repeated reconnects in Frigate.** Confirm the
  camera's RTSP URL works from the Frigate host:
  `ffplay -rtsp_transport tcp <url>`. RTSP-over-UDP is unreliable across
  most home networks — keep `preset-rtsp-restream` (which forces TCP).
- **Stream connects but stutters or shows tearing.** Software decoding
  H.265 is the usual culprit. Add `hwaccel_args` (see Step 2) or fall
  back to H.264 in `/etc/majestic.yaml` via `video0.codec: h264`.
- **No events triggered, even when waving at the camera.** Frigate's
  default `motion.threshold` (30) is tuned for higher-resolution streams.
  Drop it to 18–22 for OpenIPC's 640×360 sub-stream.
- **Sub-stream is black or garbled.** Confirm `video1.enabled: true` in
  `/etc/majestic.yaml`, and that `video1.size` is below the main stream.
- **Level 2: `motion.sh` runs once per motion burst, not per frame.**
  This is intentional — the script fires on the rising edge of motion
  detection, gated to at most once every 5 seconds. If you need the
  falling edge (motion ended) to trigger something, use Frigate's
  `detect/set OFF` debounce instead of expecting the camera to fire.
- **Level 2: `motion.sh` runs but Frigate doesn't react.** Frigate does
  not subscribe to arbitrary topics. Either publish directly to
  `frigate/<camera>/detect/set` from the camera, or bridge via your home
  automation broker as described in Step 3c.

## See also

- [List of Software for Recording Video](software-video-recording.md)
- [Majestic streamer](majestic-streamer.md) — full reference for the
  motion detector, RTSP and ONVIF endpoints
- [HomeKit integration](homekit-integration.md) — alternative path via
  go2rtc, useful if you also want Apple Home
- [Home Assistant generic camera](home-assitantant-view.md)
- [Frigate documentation](https://docs.frigate.video/)
