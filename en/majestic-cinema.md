# OpenIPC Wiki
[Table of Content](../README.md)

Cinema capture from Majestic
----------------------------

A camera records 8-bit H.264 or H.265, and a film maker grades from RAW. With
`isp.cinema` on, Majestic does the two things only the camera can do for
footage that is meant to be graded rather than watched:

- it makes a picture whose every code value maps back to scene light through
  a **published formula**, the same one for every take;
- it **writes down how each frame was made**: exposure, gains, white balance
  and colour matrix per frame, a sidecar per clip, SMPTE timecode, and RAW
  reference stills.

It is available on Hi3516EV200, Hi3516EV300, Gk7205V200, Gk7205V300 and
Hi3516CV500 cameras. Everything below was measured on a Gk7205V300 and a
Hi3516EV300, both with a Sony IMX335.

### Turning it on

```yaml
isp:
  cinema: log          # off (default) | log
  wdrMode: none        # recommended: the formula is exact without WDR
  awbMode: manual      # hold one white point for the take
  awbGains: "1.5,2.0"  # optional: red and blue against green, 0.25 to 8
records:
  enabled: true
  referenceDng: true          # optional: a RAW still as each clip starts
  referenceDngInterval: 30    # and every 30 s after (0: start only)
```

Or through the HTTP API, for example `http://<camera>/api/v1/set?isp.cinema=log`.
A change rebuilds the video pipeline.

`isp.cinema` overrides `isp.hdr`. They are for different jobs: `isp.hdr: hlg`
is for **watching** (it keeps local contrast and adapts its curve to the
light, which is exactly what makes it impossible to invert), `isp.cinema` is
for **grading**.

### The picture: OpenIPC Log

The camera writes its picture through a fixed log curve, **OpenIPC Log v1**:

```
y = 1 + log2(x) / 13                 for x >= 2^-11
a straight line below that, meeting the log in value and slope
```

`x` is the camera's linear signal (0..1, 1 being the top of its range) and
`y` the code value (0..1; times 255 for 8 bits). The eleven stops from
x = 2^-11 up each get the same share of the 8 bits, 255 / 13 = 19.6 codes.
Below x = 2^-11 the curve is a straight line down to black at y = 0.043
(code 11), so the deepest shadows are linear rather than logarithmic and
nothing is folded. To go back to light:

```
x = 2^((y - 1) * 13)                              for y >= 1 - 11/13
x = 2^-11 - (1 - 11/13 - y) * 13 * ln 2 * 2^-11   below it, and 0 below black
```

What else the mode holds still, because post cannot undo it:

- **The same curve everywhere in the frame:** no local contrast boost, no
  local brightening of shadows or dimming of highlights, no dehaze.
- **Nothing retunes the picture during a take:** the camera stops adjusting
  sharpness, noise reduction and contrast as the light or gain changes.
- **A constant frame rate:** slow shutter is overridden. Auto exposure runs at
  a fixed rate with the exposure capped at one frame period, and a dark scene
  gets gain instead of a longer frame.
- **The sensor runs at the stream's rate.** If the encoder can only take, for
  example, 15 fps at 5 MP while the sensor profile asks for 30, the sensor is
  driven at 15 instead of dropping every other frame. Every recorded frame is
  one the sensor made, and the motion blur matches the frame rate.

**Colour and range.** The stream is labelled BT.709 primaries and matrix. Its
transfer is labelled "unspecified", since there is no standard code for a
camera's own log curve. The samples are **full range**:

- H.265 says so.
- H.264 says *limited* range unless `videoN.fullRange` is on, though the
  samples are full range either way. For H.264 log footage, turn
  `videoN.fullRange` on, or tell the decoder or grading tool the clip is full
  range ("data levels"). Otherwise the shadows are crushed before the curve
  is undone.

### How exact it is

Each frame was decoded through the inverse curve and compared, block by
block, with a RAW frame of the same moment:

| `isp.wdrMode` | slope (1 = ideal) | mean error per stop |
|---|---|---|
| `none` | **0.99** | within ±0.01 stop across the mid-tones, −0.05 at the top |
| `always` (2:1 line WDR) | 0.91 | −0.22 to +0.15 stop, −0.75 at the top |

Without WDR the published inverse matches the RAW to within a few hundredths
of a stop in the mid-tones and 0.05 stop in the top stop, which is as close as
this measurement resolves. With WDR it does not: the chip fuses the two
exposures and compresses them before the curve, and how far off the result is
depends on the exposure ratio the camera picks from the light. Under a mains-
flickering lamp it got worse, not better, and no single inverse covered every
case. **For footage that must be graded accurately, use `isp.wdrMode: none`.**

### White balance you can hold

A grade matched across shots needs one white point per take:

- `isp.awbMode: manual` with `isp.awbGains: "R,B"` sets the red and blue
  multipliers against green, each 0.25 to 8;
- `manual` without gains holds whatever automatic white balance had reached,
  and the camera logs it as an `isp.awbGains` value to copy;
- `auto` gives control back.

### The clip sidecar

Every recording made with `isp.cinema` on gets `<clip>.json` beside it,
written when the clip opens, so it survives a clip that never closes. It is
not written beside encrypted recordings. Schema `openipc-cinema/1`:

| field | meaning |
|---|---|
| `written` | UTC time the clip opened |
| `camera` | platform, sensor, firmware build |
| `transfer` | `openipc-log` with its parameters and formula |
| `signal` | 8-bit, `bt709`, the transfer code in the stream, and `range` as the stream signals it |
| `tone` | which picture adjustments are off: local contrast, local tone, dehaze, automatic retuning |
| `exposure_at_start` | WDR on or off, long and short exposure (µs), analog, digital and ISP gain, ISO |
| `white_balance` | mode, red and blue gains against green, colour temperature, the 3×3 colour matrix in force |
| `black_level_12bit` | per Bayer channel |
| `ae_target` | the exposure compensation in force |

### Per-frame metadata: SMPTE RDD 18 in every frame

Every H.264 and H.265 frame carries one SEI `user_data_unregistered` message
ahead of its slices, identified by the UUID
`e34aecd7-6228-407a-b5d2-4a22eb6906ac`. Its payload is **SMPTE RDD 18
acquisition metadata**, KLV coded per SMPTE ST 336: the same sets, keys and
local tags a camera writes into SDI ancillary data or MXF. It travels with the
video everywhere: RTSP, MP4 recordings, HLS and WebRTC.

**Camera Unit Metadata Set** (standard items):

| tag | item | value |
|---|---|---|
| 81.06 | Capture Frame Rate | sensor rate, rational fps |
| 81.09 | Shutter Speed (Time) | the long exposure, rational seconds |
| 81.0A | Camera Master Gain Adjustment | analog × digital × ISP gain, 0.01 dB |
| 81.0B / 81.1E | ISO Sensitivity | the ISP's ISO |
| 81.18 | Color Matrix | the 3×3 matrix in force, R to R first |
| 81.0D | Auto White Balance Mode | 0 preset (`isp.awbGains`), 1 automatic, 2 hold |
| 81.0E | White Balance | colour temperature the ISP estimates, K |

**User Defined Acquisition Metadata Set** (identified by the same UUID, as an
AUID with its halves swapped; version 1.0):

| tag | item | value |
|---|---|---|
| E1.00 | frame counter | UInt32, per stream |
| E1.01 | PTS | UInt64 µs, the clock the MP4 timestamps use |
| E1.02 | capture time | UInt64 µs since the epoch, from the sensor's frame-start interrupt where the kernel provides it |
| E1.03 | short exposure | rational seconds; equal to 81.09 without WDR |
| E1.04 / E1.05 / E1.06 | analog / digital / ISP gain | rational × |
| E1.07 / E1.08 | red / blue white-balance gain | rational, against green |
| E1.09 | transfer curve | 1 = OpenIPC Log v1 |

It costs about 300 bytes a frame, under 60 kbit/s at 25 fps. Grading tools
read RDD 18 from MXF rather than from an MP4's SEI, so for now the records are
for scripts: ffmpeg exposes the SEI, and any KLV parser decodes the payload.

### Timecode

Footage carries **SMPTE 12M time-of-day timecode** at the sensor's frame rate,
counted without dropping, on the camera's local time. Cameras agree on the
timecode when they agree on the clock (NTP) **and** are set to the same time
zone.

- **Recordings (H.264 and H.265):** a QuickTime timecode track that the video
  track references. Its one sample is the clip's start, from the capture time
  of the clip's first frame. ffmpeg, QuickTime and NLEs read it as the clip's
  start timecode.
- **Every H.265 frame:** an SEI `time_code` message (H.265 D.2.27) with that
  frame's own timecode. ffmpeg reports it as `SMPTE 12-1 timecode` side data.
  H.264 frames do not carry it; their recordings still have the track.
- **Where the time comes from:** the sensor's frame-start interrupt, paired
  with the system clock, where the kernel provides it; otherwise the frame's
  own timestamp mapped through the video clock. Never the time the frame
  happens to be written.
- **Only streams at the sensor's rate carry it.** A sub stream that drops
  frames to a lower rate gets no timecode, since its frames are not the ones a
  count at the sensor's rate would name.

Measured with two IMX335 cameras recording at once, one at 20 fps and one at
15 fps, while a lamp was switched on and off twice: the four switches landed
on the same timecode in both clips to +33, 0, +17 and −17 ms, inside one frame
period of either camera.

Non-broadcast rates (20 fps, 15 fps) are counted as they are. An NLE expecting
24, 25 or 30 may show such a clip at a mismatched project rate.

### RAW reference stills

`records.referenceDng: true` saves a DNG, the sensor's own RAW frame, beside
each clip as it starts: `<clip>.ref0000.dng`. `records.referenceDngInterval`
adds one every N seconds after (`.ref0030.dng` at 30 s; at least 5).

Each still carries:

- the capture time to the millisecond, in local time with its UTC offset;
- in its XMP, the same instant, the clock that placed it and, with
  `isp.cinema` on, the SMPTE timecode of that frame. A still therefore lines
  up with the video by its own metadata;
- Make, Model (the sensor) and Software;
- for the IMX335, a measured **NoiseProfile**: variance = S·x + O with
  S = 1.13e-4 × gain and O = 4.5e-8 × gain² + 6.9e-8.

A still costs the video nothing. Measured at 25 fps with a still every 10 s,
the clip had every frame, 40 ms apart, through four stills. They are about
7.5 MB each at 5 MP, 2.6 MB at 1080p. They are deleted with their clip when
the card fills, and are not written beside encrypted recordings.

`/image.dng` gives the same file on demand.

### Into ACES

The footage goes to ACES2065-1 by the inverse of the curve above followed by
the standard BT.709 → AP0 matrix (Bradford, D65 to the ACES white):

```
| 0.4397010  0.3829780  0.1773350 |
| 0.0897923  0.8134230  0.0967616 |
| 0.0175440  0.1115440  0.8707040 |
```

Nothing in it is fitted to a camera, so it holds for every sensor in log mode.
x = 1, the top of the ISP's range, lands at ACES 1.0. Where a scene's grey
falls depends on exposure, as with any log camera.

As an **OCIO v2** colour space, to paste into an ACES studio config:

```yaml
  - !<ColorSpace>
    name: OpenIPC Log - BT.709
    family: Input/OpenIPC
    encoding: log
    to_scene_reference: !<GroupTransform>
      children:
        - !<LogCameraTransform> {base: 2, log_side_slope: 0.0769230769230769, log_side_offset: 1, lin_side_break: 0.00048828125, direction: inverse}
        - !<MatrixTransform> {matrix: [0.4397010, 0.3829780, 0.1773350, 0, 0.0897923, 0.8134230, 0.0967616, 0, 0.0175440, 0.1115440, 0.8707040, 0, 0, 0, 0, 1]}
```

OCIO's `LogCameraTransform` builds exactly this curve's linear toe from
`lin_side_break`. Checked against the formula, it agrees to within 3e-6 above
the curve's black. Below black (code 0.043, which the camera never writes) it
carries the toe's line into small negatives, as ACES transforms usually do. A
3D LUT to ACEScct for tools that take neither can be baked from this colour
space with OCIO's `ociobakelut`.

The input to all of this is **full-range** R'G'B'. See *Colour and range*
above for H.264.

**Colour accuracy per sensor** is not characterised yet. A correction on top
of this transform needs a reference chart whose values are known: a genuine
Calibrite (X-Rite) ColorChecker Classic, or a chart read with a
spectrophotometer. Clone charts sold as "24 colour checker" do not match their
own printed values closely enough to fit one.

### Limits

- **8 bits.** These chips encode neither 10-bit video nor RAW video.
- **Clipped stays clipped.** The metadata says where the clip point was; it
  cannot bring detail back.
- **Manual exposure needs `isp.wdrMode: none`.** The manual exposure keys are
  refused in WDR mode.
- **WDR footage is approximate.** For an exact inverse, shoot without WDR.
