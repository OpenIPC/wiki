# OpenIPC Wiki
[Table of Content](../README.md)

HDR video (HLG) from Majestic
-----------------------------

A camera running Majestic on a supported HiSilicon or Goke chip can stream
**HDR video in HLG** (Hybrid Log-Gamma, ITU-R BT.2100), which TVs and browsers
show as HDR. On an HDR display the bright parts of the scene appear brighter
than ordinary white: a sunlit wall, a lamp, a window. In normal SDR video they
are all compressed into the same top few levels. Shadows and mid-tones stay
where they were.

It is one setting. Where the chip and sensor can do WDR, it is worth having
together with it, because WDR is what captures the extra range in the first
place.

### Turning it on

```yaml
isp:
  hdr: hlg           # off (default) | hlg
  wdrMode: always    # optional, where the chip and sensor support WDR
  antiFlicker: 50    # under mains lighting: 50 or 60 to match your mains
```

Or through the HTTP API:

```
http://<camera>/api/v1/set?isp.hdr=hlg
```

A change rebuilds the video pipeline: the picture stops for a second or two and
RTSP clients reconnect. `isp.hdr: off` returns to the normal SDR picture.

**Where it is offered:** HiSilicon and Goke chips of the Hi3516EV200/EV300,
GK7205V200/V300, GK7205V500 and Hi3516CV500/AV300/DV300 families. A build
that does not offer the key answers 404 to it.

**WDR is not on every one of them.** The GK7205V200 has no WDR mode (see
[FPV](fpv.md)). There `isp.hdr: hlg` still gives an HLG picture, but from
the sensor's ordinary range, so the highlights clip where SDR's would.

### What changes when it is on

- **The picture itself is HDR.** The camera renders it with the HLG transfer
  curve instead of the SDR one:
  - mid-tones sit about where they do in SDR;
  - surface texture (wood grain, flooring, wallpaper) keeps its contrast;
  - the range above reference white is kept for real highlights, such as a
    lamp, a window or a sunlit wall.
- **Every stream is labelled HLG,** so players know what they are getting:
  - RTSP, WebRTC and the web interface's live view
  - HLS: the master playlist says `VIDEO-RANGE=HLG`
  - MP4 recordings and `/video.mp4`
- **Some picture controls stand aside, because each would reshape the picture
  for an SDR screen:** `isp.drc`, `isp.dehaze` and the
  [automatic picture tuning](automatic-image-tuning.md) (`image.tuning`). Settings you made stay saved and come back when HDR is
  switched off.
- **Anti-flicker keeps working,** when it is turned on (`isp.antiFlicker: 50`
  or `60`, matching your mains; it is off by default). Under a lamp that
  flickers with the mains, the shutter stays on a whole number of mains
  half-cycles (10 ms at 50 Hz), as it does in SDR. If that leaves the scene
  brighter than the camera wants, it darkens the mid-tones in the curve
  instead, and the lamp itself still reaches the display's peak.
- **A 2592×1944 stream becomes 2592×1920,** cropped evenly top and bottom; see
  [Chrome on a Mac](#chrome-on-a-mac-and-the-25921944-frame) below.

### Where you will see it as HDR

You need an HDR-capable display with HDR switched on. On a Mac that's System
Settings → Displays → High Dynamic Range for an external monitor; the built-in
display of recent MacBooks only has HDR headroom below full brightness. You
also need a player that honours the HLG label:

| | File / recording | HLS | Web interface (MSE) | WebRTC |
|---|---|---|---|---|
| Chrome (macOS) | yes | yes | yes | yes |
| Safari (macOS) | yes | yes | yes | **no** |

- **WebRTC needs a browser that decodes the stream's codec.** H.265 over
  WebRTC depends on the machine's hardware decoder, and Chrome may connect
  and show nothing at all (see
  [self-hosted cloud camera](howto-self-hosted-cloud-camera.md#things-that-will-surprise-you)).
  That is a codec problem, not an HDR one: "yes" above means a picture that
  plays is shown as HDR.
- **Safari over WebRTC** discards the colour labelling of every stream it
  receives, HDR or not, and shows the picture as SDR. In Safari, use the
  web interface's MSE transport or HLS.
- **On an SDR screen** an HLG picture is converted for display and looks
  slightly flatter than the camera's normal SDR picture. If nobody watching has
  an HDR screen, leave `isp.hdr` off.
- **Other players** (VLC, smart TVs playing a recording from USB) were not
  tested. Many TVs expect 10-bit HDR, and this is 8-bit (see Limits).

### Chrome on a Mac, and the 2592×1944 frame

Chrome 145 and later on macOS show HDR video as HDR only at frame sizes that
survive a floating-point rounding step exactly. At other sizes the same video
plays flat. Affected heights include 1936, 1944 and 1952 lines, so the
5-megapixel 2592×1944 frame of sensors such as the Sony IMX335 is one of
them, while 2592×1920 is not.

- **Reported:** to Chromium as
  [crbug.com/572225701](https://issues.chromium.org/issues/572225701).
- **Safari:** not affected.
- **What Majestic does about it:** until a fixed Chrome is common, with HDR on
  it keeps every stream to a size Chrome handles. A full-sensor 2592×1944
  stream is cropped to 2592×1920 (12 lines from the top and 12 from the
  bottom). A crop or a scaled size you set yourself is reduced
  slightly, to the nearest size that works.

To check which way Chrome is showing a video, start it with
`--show-mac-overlay-borders` (on a Mac: quit Chrome, then
`open -a "Google Chrome" --args --show-mac-overlay-borders`):
- **Yellow** border: the video is shown as HDR.
- **Green** border: it is flattened.

### What it looks like, measured

**Setup.** A Goke GK7205V300 camera with a Sony IMX335 sensor, 2:1 line WDR,
`isp.antiFlicker: 50`, indoors. Each run alternates HLG and SDR on the same
camera in random order, with two full-resolution frames for each, several
rounds per run; the tables give the averages.

**What is measured.** Every number is light on the screen:
- SDR is shown with its white at 203 cd/m², where HDR puts SDR white;
- HLG is shown on the 1000 cd/m² reference display.

**Texture** is the fine contrast inside a surface, in stops. Higher means more
visible grain.
- Each surface is one hand-picked rectangle of 250–560 pixels a side, the same
  in every frame.
- Each frame's brightness is converted to light on screen and to log2, and a
  Gaussian blur (sigma 4 pixels) is subtracted, which leaves the fine detail.
- The RMS of that detail over the two frames' average is the measured
  contrast.
- The camera's noise is the part that differs between the two frames. It is
  subtracted in quadrature, so what remains is detail present in both.

**Above reference white** is the share of the frame brighter than 203 cd/m².
SDR cannot go above its own white, so its column is empty; its pixels at white
are counted under *clipped*.

**Daylight:**

| | floor | wooden door | patterned glass | wallpaper | median | above reference white | brightest 0.1% | clipped |
|---|---|---|---|---|---|---|---|---|
| SDR | 0.25 | 0.58 | 2.75 | 0.48 | 26 cd/m² | — | 203 cd/m² | 0.49% |
| HLG | 0.34 | 0.54 | 3.04 | 0.66 | 48 cd/m² | 5.3% | 969 cd/m² | 0.10% |

**A 200 W LED floodlight on, its light flickering at twice the mains
frequency:**

| | floor | wooden door | patterned glass | wallpaper | median | above reference white | brightest 0.1% | clipped |
|---|---|---|---|---|---|---|---|---|
| SDR | 0.38 | 0.25 | 2.78 | 0.74 | 32 cd/m² | — | 203 cd/m² | 5.8% |
| HLG | 0.54 | 0.46 | 3.17 | 0.79 | 44 cd/m² | 14.5% | 1000 cd/m² | 0.21% |

In the HLG picture:
- surfaces carry at least as much texture as in SDR, except the dark wooden
  door in daylight, at 93% of SDR's;
- the brightest highlights reach the display's maximum;
- it clips far less than SDR does, and a lamp in frame stays brighter than the
  glow around it;
- under the flickering lamp, with `isp.antiFlicker: 50`, the picture is as
  steady as SDR's.

### Why there is no Dolby Vision

iPhones record HLG as Dolby Vision profile 8.4: an HLG picture plus a layer
of per-frame metadata that Dolby-capable players use to fit the picture to
their screen. Majestic does not, for these reasons:
- **Profile 8.4 needs 10-bit video.** These chips encode 8-bit only, so a
  conforming stream cannot be made. The 8-bit Dolby Vision profile (9) is
  H.264 on an SDR picture, not HLG.
- **Chrome does not play Dolby Vision** that is not encrypted, so the web
  interface's live view would ignore the layer anyway. Other players were not
  tested.
- **It is a licensed format.** Producing it requires a licence from Dolby.
- **HLG is designed to work without metadata.** The display adapts it to its
  own peak brightness. HDR10+, the open format with dynamic metadata, needs
  PQ and 10-bit video, so it is out of reach for the same reason.

### Limits

- **8-bit only.** These chips encode 8-bit H.265, so there is no Main10. Chrome
  and Safari show 8-bit HLG as HDR, but smooth gradients such as a sky or a
  plain wall band sooner than they would in 10-bit.
- **Snapshots** (`/image.jpg` and the other stills) come from the same HLG
  picture and look flat on an ordinary screen.
- **Reported resolution.** The HLS playlist's `RESOLUTION` and ONVIF report the
  configured size, not the HDR crop.
- **Tested hardware.** Only GK7205V300 + IMX335 was measured. The other chip
  families above have the same image pipeline, but their pictures were not.
- **Availability.** Requires the 2026-10-11 nightly or a later build;
  `majestic -v` prints the build date. Earlier builds do not have
  `isp.hdr`.
