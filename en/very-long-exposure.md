# OpenIPC Wiki
[Table of Content](../README.md)

Very long exposure
------------------

Most of what a camera does is over in a few milliseconds. This page is about
the other end: exposures of a second, five seconds, or longer, for scenes with
almost no light in them — a telescope, an X-ray screen, a fluorescence rig, a
night sky.

**Not every camera can do this.** It is a **HiSilicon and Goke** feature, and
how far it goes depends on the sensor. The numbers on this page were measured
on a **gk7205v300 with an IMX335** at 5 MP; another sensor will reach a
different ceiling by the same method.

### The one idea that explains every setting below

**A frame cannot be exposed for longer than it lasts.** The sensor is reading
out continuously, and the exposure happens inside one frame period. So a
25 fps camera can never expose for more than 40 ms, whatever you ask for.

There is no separate "long exposure mode". There is only a **slow camera**. If
you want a 5 second exposure you need a sensor running at 0.2 frames per
second, and everything below is how to get one.

| sensor running at | longest exposure you can get |
| --- | --- |
| 30 fps | 33 ms |
| 5 fps | 200 ms |
| 1 fps | 1 s |
| 0.5 fps | 2 s |
| 0.2 fps | 5 s |
| 0.13 fps | 7.7 s — the IMX335 5 MP ceiling |

### The mistake that costs everyone an afternoon

The sensor's rate is **not** set by `Isp_FrameRate` in the sensor profile under
`/etc/sensors/`. It is set by your **stream frame rates**, `video0.fps` and
`video1.fps` — and they apply whether or not anything is watching those
streams.

Leave `video1.fps` at its default of 15 and your sensor runs at 15 fps no
matter what the sensor profile says. Exposure then stops at 66 ms, nothing you
change to `isp.exposure` helps, and the camera looks broken.

**Bring both streams down**, not just one, and not just the profile.

### The recipe

```
# 1. slow both streams down. the sensor follows the faster of the two
curl -u root:PASS 'http://CAMERA/api/v1/set?video0.fps=1&video1.fps=1'

# 2. stop auto-exposure deciding for you
curl -u root:PASS 'http://CAMERA/api/v1/set?isp.aeMode=manual'

# 3. pin the gain, or the camera will trade your exposure against it
curl -u root:PASS 'http://CAMERA/api/v1/set?isp.aGain=1&isp.ispGain=1'

# 4. ask for the exposure, in milliseconds. fractions are allowed
curl -u root:PASS 'http://CAMERA/api/v1/set?isp.exposure=1000'
```

Then **check what you actually got**, which is not always what you asked for:

```
curl -u root:PASS http://CAMERA/metrics | grep isp_exptime
```

`isp_exptime` is in microseconds and is what the sensor really did. If it is
lower than you asked for, the frame period is the reason — go back and slow the
streams down further.

Give the camera a few seconds after changing the frame rate or the exposure
before you trust the number or take a picture. The pipeline needs a frame or
two to settle, and at these rates a frame can be seconds long.

### Going below one frame per second

Streams are whole numbers, so `video0.fps` stops at 1 — which gets you a one
second exposure. Past that, the **sensor profile** takes a fraction:

```
# /etc/sensors/5M_imx335.ini
Isp_FrameRate=0.2
```

A value below 1 there is understood as a deliberate request for a long
exposure, and it wins over the stream rates rather than being raised to meet
them. Your streams still run — they simply receive whatever the sensor
produces, which is all they were ever going to get.

This needs a restart of the streamer to take effect, because the sensor is
reprogrammed when the pipeline is built.

### Getting the picture out

For anything measured, take the **raw** frame rather than a JPEG:

```
curl -u root:PASS http://CAMERA/image.dng -o frame.dng
```

That is what the sensor measured, before the camera's own processing has
decided anything about it — no white balance, no noise reduction, no sharpening
and no gamma, all of which destroy photometry. See
[raw sensor data](majestic-streamer.md#raw-sensor-data-as-adobe-dng) for the
endpoint, and the [raw editor](raw-editor.md) for a way to look at one without
leaving the browser.

A 5 MP raw frame is about 7.5 MB and takes a second or two to arrive, even when
the exposure itself is much longer.

### Gain, and which one actually does anything

At these exposures you usually want gain **out** of the picture, not helping.

- `isp.aGain` is the analogue gain, and it is the one that changes what the
  sensor measures. Pin it at 1 for photometry.
- `isp.ispGain` is applied afterwards, in processing. It brightens the picture
  without adding any information.
- `isp.dGain` is a ceiling for automatic mode. In manual it does nothing at
  all, and the camera says so in its log once if you set it.

### What actually stops you: heat, not settings

A sensor accumulates charge whether or not light is arriving. This is **dark
current**, it grows with exposure time, and it roughly doubles for every 6–8 °C
the sensor warms up. Past a certain exposure the frame fills up with it and
your picture is gone regardless of how dark the room is.

On the lab IMX335 at room temperature, the floor of the frame rose at up to
about 41 counts per second, which fills the usable range of a 12-bit frame in
around 94 seconds. That figure is an **upper bound** — those pixels still saw a
little light — so the true limit is longer, but it shows the shape of the
problem: somewhere in the tens of seconds to a few minutes, heat wins.

**Measure your own**, because it depends on your sensor and how warm your
enclosure runs. It takes ten minutes:

1. Cap the lens, or cover the sensor completely. This matters — any light at
   all invalidates it.
2. Take raw frames at 0.25 s, 0.5 s, 1 s, 2 s, with the gain pinned at 1.
3. Look at the average level of each. It should sit near the black level and
   climb with exposure.
4. The slope is your dark current in counts per second. Divide the usable range
   of the frame by it and you have the exposure at which the sensor fills
   itself.

If your exposures are near that limit, **stack short frames instead of taking
one long one**. Ten one-second frames added together collect the same light as
one ten-second frame, but only one second of dark current each — and you can
throw away the one an aeroplane flew through.

### Using it on a telescope

- **Turn auto-exposure off and leave it off.** A star field is mostly black,
  and a metering algorithm reads that as "far too dark" and winds everything to
  maximum. `isp.aeMode: manual` is not optional here.
- **Focus at a short exposure first.** At 25 fps you get feedback as you turn
  the focuser. Set the long exposure afterwards, once focus is fixed, because
  at 0.2 fps you wait five seconds to see the result of every small movement.
- **Pin the gain** so frames taken across a session are comparable. Changing
  gain between frames makes them impossible to stack properly.
- **Take raw, not JPEG.** Sharpening will invent detail that is not in the sky,
  and noise reduction will erase faint stars for looking like noise — which,
  to the camera, they do.
- **Watch the sensor's temperature** rather than the clock. Dark current tracks
  heat, so a camera in a warm enclosure on a summer night reaches its limit far
  sooner than the same camera in December.
- **Track, or keep frames short.** Without a tracking mount, stars trail. The
  rough rule is 500 divided by the focal length in millimetres, in seconds —
  a 500 mm lens gives about one second before trailing shows.

### If it will not go slower than you expect

| what you see | why |
| --- | --- |
| exposure stops at 66 ms | `video1.fps` is still 15 — bring both streams down |
| exposure stops at 33 ms | the sensor is still at 30 fps |
| exposure stops at exactly 1 s | streams are whole numbers; use a fractional `Isp_FrameRate` |
| `isp_exptime` lower than asked | the frame period is shorter than your request |
| the picture is bright grey with no detail | dark current has filled the frame — shorten the exposure |
| changing the gain changes nothing | in manual, `isp.dGain` does nothing; use `isp.aGain` |
