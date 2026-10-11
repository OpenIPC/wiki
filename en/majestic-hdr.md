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

It is one setting, and it is worth having together with WDR, which is what
captures the extra range in the first place.

### Turning it on

```yaml
isp:
  wdrMode: always    # recommended: WDR captures the range HDR then shows
  hdr: hlg           # off (default) | hlg
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

### What changes when it is on

- **The picture itself is HDR.** The camera renders it with the HLG transfer
  curve instead of the SDR one. Brightness is aimed so that diffuse white
  (paper, a white wall) sits at HLG's reference white, and the range above it
  is kept for highlights.
- **Every stream is labelled HLG,** so players know what they are getting:
  - RTSP, WebRTC and the web interface's live view
  - HLS: the master playlist says `VIDEO-RANGE=HLG`
  - MP4 recordings and `/video.mp4`
- **Some picture controls stand aside, because each would reshape the picture
  for an SDR screen:** `isp.drc`, `isp.dehaze` and the automatic picture tuning
  (`image.tuning`). Settings you made stay saved and come back when HDR is
  switched off.
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

Measured on a Goke GK7205V300 camera with a Sony IMX335 sensor at 2592×1944, in
2:1 line WDR, indoors under flicker-free LED bulbs. Values are the code level of
the H.265 stream (0–1). The light levels in brackets assume the 1000 cd/m² HLG
reference display; an HDR screen scales the whole range to its own peak.

| | SDR (`isp.hdr: off`) | HLG (`isp.hdr: hlg`) |
|---|---|---|
| White bed sheet (diffuse white) | 0.62 | 0.77 (≈230 cd/m², HLG reference white is 0.75) |
| Darkest 10% of the frame | 0.32 | 0.34 (≈20 cd/m²) |
| Brightest 1% | 0.90 | 0.91 (≈540 cd/m²) |
| Brightest 0.1% | 0.99 | 0.98 (≈900 cd/m², the display's peak) |
| Clipped pixels | 0.45% | 0.19% |

In the HLG picture:
- the brightest 1% of the scene is 26 times brighter than the darkest 10%;
- it clips less than the SDR picture does;
- the brightest highlights reach the display's maximum.

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
- **Availability.** Requires a Majestic build from mid-October 2026 or later.
