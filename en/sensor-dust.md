# OpenIPC Wiki
[Table of Content](../README.md)

Dust on the sensor glass: finding it, and proving a clean took it away
----------------------------------------------------------------------

A speck of dust on the glass in front of the sensor never shows as a speck. It
sits a fraction of a millimetre in front of the focal plane, so the lens draws
it as a soft blot the shape of its aperture, a few dozen pixels across, that
takes a fixed share of the light away and never moves with the scene. Most
people never notice one. It shows the day something stretches the picture: a
strong dehaze, a contrast boost, a grey sky, footage graded afterwards. A
camera can carry several for years.

The camera can find them itself, from the live scene, with nobody standing in
front of it and no test chart. It can also answer the question that matters
after a clean: is the dirt actually gone, or did you just move it around?

### What you need

- **Firmware from `nightly-20261021` or later** (see
  [Nightly builds](nightly-builds-and-bisect.md) for how builds are named and
  how to check yours).
- **A web interface from 2026-10-21 or later** for the **Dust** tab with
  everything on this page. The tab first appeared earlier that day; a web
  interface from between the two lacks the motion figure and warnings
  described below.
- **A route to the internet the first time you open the raw page.** The Dust
  tab is part of the [raw editor](raw-editor.md), which the web interface
  fetches on first use and the browser then caches. Without it the raw page
  offers the frame as a download instead, and there is no Dust tab; the
  [endpoint](#from-a-shell) works regardless.
- **Raw capture switched on**, ideally. The camera measures on the raw frame
  where it can, and falls back to the processed picture where it cannot (see
  [Raw first](#raw-first-the-processed-picture-is-not-a-measurement) for why
  that matters). Which cameras serve raw, and how to switch it on, is in
  [Raw editor](raw-editor.md).
- **An IR-cut filter on two GPIO pads**, only for **Which glass?**: both
  `nightMode.irCutPin1` and `nightMode.irCutPin2` set, and the filter not
  switched off. Without them the button is simply not offered.

### Checking a camera

Open **Camera → Raw** in the web interface and choose the **Dust** tab.

1. **Point the camera at something still and plain**, in daylight. A painted
   wall a few metres away is ideal; a clear sky is good. See
   [Choosing what to point it at](#choosing-what-to-point-it-at) — it decides
   whether the answer means anything.
2. **Measure.** The camera takes a few frames, which takes about eight seconds
   on a 5 MP camera, and the tab draws a ring at each spot it found over the
   frame on screen. Below the picture it lists them with how much light each
   one takes.
3. **Save as before** if you are going to clean. The measurement is stored on
   the camera and survives a reboot, so the clean can be days later.
4. Clean the glass.
5. **Compare.** Each spot from the "before" comes back **cleared**, **still
   there** or **not judged**, and anything that was not there before is listed
   as **new**.
6. **Forget** removes the saved "before" when you are done.

**Which glass?** moves the IR-cut filter out and back to tell a speck on the
filter from one on the sensor's own cover glass. See
[Which glass](#which-glass-the-ir-cut-filter).

### Choosing what to point it at

Whatever else a speck looks like, it is soft, round and fixed. Anything in the
picture that is also soft and round can be taken for one, and a picture that
changes between the frames the camera takes can fake one.

| pointed at | what you get |
|---|---|
| a plain wall, in daylight | the best answer: every speck, and very little else |
| a clear sky | as good, as long as it is clear |
| a street, trees, a busy room | big specks are found; faint ones hide in the texture, and a comparison says **not judged** there rather than guessing |
| a cloudy sky, traffic, leaves in wind | the picture moves between frames, and a moving picture is the one thing that can fake a speck. The camera says how much moved and warns (below) |
| darkness | noise. Measure in daylight |

On a hi3516ev300 with an IMX335 carrying eleven specks, measured thirteen
times over a morning against a wall seen through a window, every speck was
found in every run; the faintest took about 4% of the light. The one cut in
half by the edge of the frame was found every time but reported as less
certain in all but one.

### Reading the answer

**Light taken** is the depth of the speck: 20% means the darkest part of its
pattern lets through 80% of the light it should. The eleven specks on the
camera above took between 4% and 27%. Below about 1.2% nothing is reported;
the tab shows that limit as *smallest it can see*.

A spot drawn **dashed**, marked *less certain*, is reported and compared like
the rest but never called new dirt. A spot is less certain when it:

- is cut by the edge of the frame;
- is brighter than it is dark — a lamp, a reflection; dust takes light away;
- is round, but only just;
- lies where the picture moved between the frames.

The tab also says **how much of the picture moved between frames**. On a still
scene it reads 0%, and that figure is what makes a clean result worth
believing. Traffic crossing part of a street view reads around 1%; a cloudy sky
reads 100%. Spots where the picture moved are less certain and are not judged,
and when more than a fifth of it moved the camera adds a warning, shown in an
amber box: measure again with the camera on something still.

#### After a clean

| verdict | means |
|---|---|
| **cleared** | nothing even a third as deep is left where the speck was, round or not |
| **still there** | a round, dark pattern at least a third as deep is still at its place |
| **not judged** | the place could hide one: the picture is busy there, something bright or not round lies across it, or the scene moved there. Point the camera at something plainer and compare again |
| **new** | a certain spot that the "before" did not have |

A spot that stays after a clean is either dirt the clean did not reach, or a
mark in the scene itself. The camera cannot tell which and says so; you are
the one who knows whether you reached it. Cleaning *is* the experiment that
settles it.

The comparison also refuses to judge when the light is too different from the
"before" on the processed picture (more than a factor of two in gain or
brightness): the tone curve moves how dark a speck reads, so the verdicts would
be the tone curve's. On raw it always compares.

### What a speck looks like

Most specks draw a **dark disc**, often slightly triangular or hexagonal: the
lens's aperture blades are in the shape. A small speck very close to the sensor
draws **rings** instead — a dark core, a bright ring, a dark outer ring — the
way light diffracts round a small obstacle. A ring-shaped speck can be as
noticeable as a disc and yet barely darker than its surroundings on average.
The camera reports both kinds.

On the camera above, one such speck took ±4–5% of the light at its strongest,
survived a thorough clean, and was reported as certain in four runs out of
four on a white wall afterwards.

### Which glass: the IR-cut filter

Dust can sit on the sensor's cover glass, or on the IR-cut filter in front of
it, and they are cleaned differently. **Which glass?** tells them apart by
measuring with the filter where it is, moving it, measuring again, and putting
it back. A speck on the filter moves with it; one on the cover glass does not.

| result | seen | where it is |
|---|---|---|
| **cover glass** | in both positions | the sensor's cover glass, or anything else that does not move |
| **IR-cut filter** | only with the filter in | on the filter |
| **the glass that replaces it at night** | only with the filter out | on whatever swings in to take the filter's place |

A spot is put on the filter only when it is seen to go when the filter moves. A
spot the other position could not judge counts as not having moved, so on a
busy scene "cover glass" means "not seen to move" rather than "seen to stay".

It takes about fifteen seconds. During that time:

- raw snapshots are refused;
- the live picture shows the scene through the other filter position. In
  daylight with the filter out, that is the infrared-tinted colour of a camera
  with no filter, for those seconds.

Where the filter is put back depends on
[who moves it](majestic-streamer.md#who-moves-the-filter-and-the-lamp). With
`nightMode.irCut: auto` it goes where day and night want it at that moment, so
a switch to night that came due meanwhile is honoured. With `manual` it goes
back where it was before the measurement. A filter that does not take the drive is tried again. If
something else moved the filter during the measurement — a day/night switch,
an operator — it is left where they put it, and the answer is refused rather
than labelled with the wrong position.

On the camera above, all eleven specks came back on the cover glass, in four
runs out of four.

### Raw first: the processed picture is not a measurement

The camera measures the green channel of the raw frame wherever it can, before
any of its own processing. Only where there is no raw does it use the
processed picture, and the answer says which (*measured on the raw frame*).

The reason is measured. The processed picture passes through a tone curve and
local contrast controls — dehaze, dynamic range compression, the automatic
image tuning — and they decide how dark a speck looks:

| the same three specks, on the camera above | | | |
|---|---|---|---|
| processed picture, night, gain 32× | 18–23% | 11–14% | 7–8% |
| processed picture, dawn, gain 1.4× | 44% | 32% | 16% |
| processed picture, one morning, automatic tuning moving | 34–91% | 24–90% | 11–37% |
| **raw**, the same morning, eleven captures | **14.7–16.5%** | **12.7–13.3%** | **7.2–7.5%** |
| **raw** at gain 13.8× | **15.4%** | **13.5%** | **7.4%** |

(Measured with an earlier build; what the table shows — how far processing
moves a speck's depth — does not depend on the build.) On raw the depth is the light the speck takes, whatever the gain and whatever the
tone curve does. On the processed picture it is whatever the tone curve
made of it, which is also why a "before" taken on one cannot be compared with
a measurement on the other.

### From a shell

Everything the tab does is one HTTP call. From the camera itself
(`127.0.0.1`) no password is needed, which makes it usable from scripts; from
elsewhere, log in as for any other endpoint.

| request | what it does |
|---|---|
| `GET /api/v1/optics/dust` | measure now |
| `POST /api/v1/optics/dust` | measure now and save it as the "before" |
| `GET /api/v1/optics/dust?compare=1` | measure now and judge each spot of the "before" |
| `POST /api/v1/optics/dust/sites` | which glass: measure with the filter in and out |
| `DELETE /api/v1/optics/dust` | forget the "before" (204) |

```sh
curl -s http://127.0.0.1/api/v1/optics/dust
```

```json
{ "width": 2592, "height": 1944, "frames": 3, "source": "raw", "luma": 61.0,
  "thresholdPct": 1.2, "movingPct": 0.0, "gain": 1.0,
  "spots": [ { "x": 1200, "y": 800, "radius": 30, "attenuationPct": 12.5 },
             { "x": 40, "y": 1500, "radius": 24, "attenuationPct": 3.1, "marginal": true } ] }
```

- `x`, `y`, `radius` are in the pixels of the frame measured.
- `attenuationPct` is the light taken; `marginal` marks a less certain spot.
- `source` is `raw` or `luma` (the processed picture).
- `movingPct` is how much of the picture moved between the frames.
- `warnings`, present only when there is something to say, is a list of
  sentences for a person.

A comparison adds a `baseline` object: `taken`, `comparable`, the counts
`cleared`, `remaining` and `unjudged`, `spots` (each with `state` —
`cleared`, `remains` or `unjudged` — and `nowPct`, what is left there now),
`new`, and its own `warnings`. **Which glass?** gives each spot a `site`
(`glass`, `filter` or `window`) with `inPct` and `outPct`, and under `ircut`
each position's `frames`, `luma` and `movingPct`.

| status | why |
|---|---|
| 401 | the camera has not been claimed yet ([Factory reset and the unclaimed camera](first-boot.md)) |
| 403 | a `POST` or `DELETE` sent from a page on another site |
| 404 | `?compare=1` with no "before" saved |
| 409 | the "before" was measured on the other source (raw or processed) or at another frame size; save a new one |
| 501 | this camera can give neither a raw nor a processed frame for it, or (for **Which glass?**) has no filter it can move |
| 503 | busy: another measurement, a raw snapshot or a firmware upgrade is running. Ask again in a moment |

### What it costs

Measured on the camera above (a 5 MP sensor, one Cortex-A7 core):

- **About 8 s** per measurement, about 6 s of it the analysis. It runs beside
  the video, not instead of it: an RTSP client's longest gap between frames was
  0.20 s during a measurement against 0.13 s idle.
- **About 17 MB** of memory while it runs, all of it given back afterwards.
- **An occasional lost video frame**, on this camera. Taking a raw frame now
  and then cost the video one frame at capture: 1 raw snapshot in 15 did. A
  measurement takes three, so roughly one measurement in five dropped a single
  frame. That is the raw capture's cost, the same as for any raw snapshot, and
  it is not the same on every chip: on some SigmaStar and Ingenic cameras a raw
  capture stalls the video for much longer. See
  [On SigmaStar](majestic-streamer.md#on-sigmastar) and
  [On Ingenic T31 and T23](majestic-streamer.md#on-ingenic-t31-and-t23)
  before measuring on one of those.
- **Which glass?** takes about 15 s and about 27 MB.

### What it cannot do

- **Tell a speck from a soft, round, dark mark that is really in the scene.**
  Nothing in a still picture can. A clean settles it.
- **See a faint speck through a busy or moving picture.** It says **not
  judged** there instead of **cleared**, and warns when the picture moved.
- **Be certain at the edge of the frame.** A speck the edge cuts is usually
  reported as less certain.
- **Tell the cover glass from anything else that does not move with the
  filter.** "Cover glass" means "not on the filter". In practice dust on the
  back of the lens is too far from the sensor to show at all, but the
  measurement itself cannot say so.
- **Measure reliably without raw.** See the table above: on the processed
  picture the percentages follow the tone curve, and only the refusal to
  compare across very different light keeps the verdicts honest.
