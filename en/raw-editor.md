# OpenIPC Wiki
[Table of Content](../README.md)

Raw editor
----------

The camera can hand over what the sensor measured, before any of its own
processing — see [raw sensor data, as Adobe DNG](majestic-streamer.md#raw-sensor-data-as-adobe-dng)
for the endpoint itself. The raw editor is what opens one without leaving the
browser: it develops the frame on your machine, measures the sensor, and can
calibrate the camera's colour from a chart.

It is **not part of the firmware**. The web interface fetches it the first time
you open it, so the camera needs a route to the internet for that one request;
after that the browser caches it. A camera with no route out shows the raw page
with a download button and an explanation instead, which is the page working as
intended rather than a failure.

**Not every camera can do this.** Raw is a **HiSilicon and Goke** feature;
other SoC families do not serve it, and neither do the oldest HiSilicon parts.
The menu entry is there on every camera regardless, so the page itself is where
you find out:

- *This firmware does not serve raw frames* — the hardware cannot, and nothing
  will change that.
- *Raw capture is switched off for this camera* — it can, but `isp.rawMode` is
  `none`. Turn it on in **Settings**, under **Live**, where the image settings
  are drawn.

The [endpoint's own section](majestic-streamer.md#raw-sensor-data-as-adobe-dng)
has a one-line check that answers the same question from a shell.

Where it is available, **Camera → Raw** in the web interface opens it. It takes
a frame straight away, which is several megabytes off the camera and takes a
few seconds — there is nothing to press first.

![The Develop screen](../images/raw-editor/develop.webp)

### Develop

The picture. On current firmware the frame arrives with the camera's own white
balance recorded in it, so the first render is what the camera thought the
scene looked like rather than a neutral one. Older builds write a placeholder
balance of 1:1:1 and a black level of zero instead — the panel shows what your
file actually carries, and
[how good the colour is depends on your firmware](majestic-streamer.md#how-good-the-colour-is-depends-on-your-firmware)
says how to tell which you have.

| | |
|---|---|
| **Raw** | Which corner of the sensor's grid is red. It comes from the file; the Bayer probe at the foot of the panel narrows it to two candidates and cannot settle between them, so if the colours look swapped, try the other. |
| **Black** / **White** | Where the sensor's floor and ceiling sit, taken from the file. Moving White brightens the picture — a rendering choice, not a measurement. |
| **Demosaic** | How the missing two-thirds of each pixel are reconstructed. **RCD** is the default and the closest. **None** shows the mosaic itself, which is what you want when the question is about the sensor rather than the picture. |
| **Pick a neutral** | Click anything in the frame that ought to be grey. This is the fix for a colour cast, and it reads the mosaic rather than the picture on screen, so it measures the scene rather than the balance already applied. |

If the first render has a cast, there are two quite different reasons and the
White balance panel tells them apart. Where it shows a real measured balance,
the cast is the camera's own automatic white balance being wrong, faithfully
recorded — a raw frame carries the balance the camera chose, mistakes included.
Where it shows 1:1:1, the file simply has no balance in it and the cast is the
sensor's raw response, with milky blacks to match because the black level is
zero as well.

Picking a neutral fixes both, and is the quicker route either way.

### Diagnose

![The Diagnose panel, on a flat frame with scattered defects](../images/raw-editor/diagnose.webp)

Measures the sensor rather than the picture: how many pixels disagree with
their neighbours by more than the noise explains, the black level the frame
implies against the one the file claims, what has already clipped, and how
noisy the rest is.

**Read the number with the two things beside it, not on its own.** Pointed at
an ordinary furnished room the scan will report hundreds of pixels, and almost
all of them are detail in the scene rather than faults in the sensor. Two
things in the panel say which you are looking at:

- **Spread.** Real sensor defects are scattered at random across the frame.
  Detail in a picture is not — it sits wherever the picture had detail. A
  figure near 1 is scattered, as the screenshot above shows; well below 1 means
  the scan is describing the room, and the panel says so in as many words.
- **The histogram.** Every pixel by how far it sits from its neighbours, on a
  logarithmic scale, against the curve noise alone would produce. Where the
  bars follow the curve there is nothing there; the tails are what is left.

**On a 12-bit camera, check your firmware date first.** Builds before
2026-09-17 wrote every second pixel of a raw frame four bits short, which is
precisely the kind of neighbour-to-neighbour disagreement this panel counts —
enough to report a healthy sensor as a defective one. See [12-bit
sensors](majestic-streamer.md#12-bit-sensors-check-your-build-date-before-you-trust-the-numbers)
for how to tell whether it applies to your camera. 10-bit sensors were never
affected.

To get an answer you can act on:

1. **Point it at something plain** — a blank wall, or the lens cap. The flatter
   and darker the frame, the less there is to mistake for a defect.
2. Use **Where to look → Darkest** so the scan only believes the dim parts of
   the frame, where a defect stands out and detail does not.
3. Take **about five captures**, keeping each one, moving the camera between
   them. A faulty pixel appears in all of them wherever the camera points;
   noise appears once and never again; detail moves with the view. The panel
   tallies them and says which it is looking at.

One capture is never enough, and five of the same unchanged view is not either.

### Calibrate

![The Calibrate screen, with the chart found](../images/raw-editor/calibrate.webp)

Measures the camera's colour against a 24-patch chart and can write the result
back, so the camera's own picture — not just the raw frame — comes out closer.

Put a chart in front of the camera, reasonably flat on and evenly lit, and open
Calibrate. It looks for the chart by itself and puts four corners on it; drag
any that sit off, and the dots show where each patch will be read from. Then
**Measure the chart**.

The result reports a mean and worst ΔE — how far each patch landed from where
it should be. Under 3 is a good fit. A spiky light source, which most LED
lighting is, will not do better whatever the chart, so measure under something
continuous if the number matters.

Writing it to the camera is deliberately hard to regret: the new colour is
applied live and **put back by itself after thirty seconds** unless you confirm
you can still see a sane picture. That is the bargain a display resolution
change makes, for the same reason — a bad colour matrix survives a reboot.

### When it will not open

The editor is fetched from the internet on first use. If it does not arrive the
raw page says so and still offers the frame as a download, which any desktop
raw converter will open. Nothing else in the web interface depends on it.

Raw capture is also demanding on small cameras — a frame is several megabytes
and the camera needs that much memory while it serves the request. The
[memory notes](majestic-streamer.md#on-a-board-with-little-ram-read-this-before-you-ask-for-one)
beside the endpoint are worth reading before using this on a board with little
RAM.

### Where it comes from

[OpenIPC/raw-editor](https://github.com/OpenIPC/raw-editor). The reasoning
behind the choices here — why RCD is the default demosaic and what the others
cost, why the Bayer probe stops at two candidates, why the neutral picker reads
the mosaic — is in that repository's README, along with what it takes to send a
patch.
