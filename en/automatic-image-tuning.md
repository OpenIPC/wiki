# OpenIPC Wiki
[Table of Content](../README.md)

Automatic image tuning
----------------------

A camera pointed at a real scene does not get one correct set of picture
settings. Fog flattens everything into a narrow band of grey; low sun puts
deep shade and bright sky in the same frame; an overcast afternoon needs
nothing done to it at all. Settings chosen on the day of installation are
chosen for the weather that day.

**Automatic image tuning** watches the picture the camera is actually sending
and adjusts up to four settings to follow it. It is **on by default** from the
September 2026 builds.

It is deliberately undramatic. On a picture that already uses its range it
does nothing, and on most cameras most of the time that is what it does.

### Which cameras have it

It needs picture statistics the camera measures for itself, which not every
part provides:

| | |
| --- | --- |
| **Tunes all four settings** | hi3516ev200, hi3516ev300, gk7205v200, gk7205v300, gk7205v500 |
| **Tunes three** — contrast, brightness and saturation; these parts have no `isp.dehaze` | hi3516cv500, hi3516av300, hi3516dv300 |
| **Stays inert** | everything older, and hi3516cv6xx. The setting may be present, but nothing measures, so nothing is driven. |

On a camera in the last row the panel says so rather than pretending — see
[When it will not run](#when-it-will-not-run).

### What it changes, and what it will not touch

| Setting | Driven |
| --- | --- |
| `image.contrast` | yes |
| `image.luminance` (Brightness) | yes |
| `image.saturation` | yes |
| `isp.dehaze` | yes |
| `image.hue` | **never** |
| `isp.drc` | **never** |
| Exposure, gain, white balance, the IR-cut filter | **never** |

Your saved values are the **starting point** it works from and the value it
returns to. It is not trying to replace them: a camera whose settings suit its
scene will be left on them, and one that has drifted into fog will be brought
back afterwards. Nothing it does is written to the configuration — the file on
the camera keeps saying what you set.

### Reading what it is doing

On **Camera → Settings → Live**, the Scene row is one set of modes:

> **Automatic** │ Indoor · Outdoor · Low light

The lit chip is the mode in force. Choosing **Automatic** hands the picture to
the camera; choosing any of the other three takes it back and applies that
look. While Automatic is in force the three sliders it drives stop being
controls and show the value the camera is running instead — Hue stays yours in
every mode, because nothing touches it.

Under the row is a sentence saying what the camera is doing right now:

| What it says | What it means |
| --- | --- |
| *Nothing to do — the picture already spans N of 255* | The picture is using its range. This is the common case and the correct one. |
| *Lifting the picture — …* | It is working, and the knobs it names are where it has them. |
| *Holding back — stretching further would clip* | Stretching more would crush shadows or blow highlights, so it has stopped. The percentages say which end. |
| *Too dark to help — …* | The light has gone and the sensor gain is high. Stretching a noisy picture only amplifies the noise, so it has given the picture back. Normal after dark. |
| *Paused — standing aside while you adjust the picture* | You have moved something. It stops for a minute rather than fight you, and **measures nothing while paused** — so the figures beside it are from before you started. |
| *No reading — nothing measurable from the picture yet* | It is on and cannot measure. See [When it will not run](#when-it-will-not-run). |
| *Off — the camera is not tuning itself* | Switched off. |

There is also a bracket along the bottom of the **Luma** histogram showing the
range the camera measured, next to the histogram your browser computed from
the same picture. They should agree.

### Reading it from outside the browser

Everything the panel shows comes from `/metrics`, so a camera nobody has a
browser pointed at can be watched while it is running — with one gap, noted
below, about telling the reasons for silence apart:

| Metric | Meaning |
| --- | --- |
| `image_tune_state` | which of the situations in the table above the camera is in. The values and what each one means are printed by the camera itself, on the `# HELP` line above the metric — read them from the camera you are scraping rather than from here, so a build that grows a state does not leave this page wrong |
| `image_tune_span` | the range the picture occupies, p95 − p5 of 0–255 — the thing it is trying to increase |
| `image_tune_clip_lo_ppm` | share of the picture crushed to black, parts per million |
| `image_tune_clip_hi_ppm` | share blown to white, parts per million |
| `image_tune_headroom` | how much of its range the sensor gain leaves it, percent — 100 in good light, 0 when it has given up for the night |
| `image_tune_scene_dist` | how far the picture has drifted since its last decision, tenths of a percent |
| `image_tune_dehaze`, `image_tune_contrast`, `image_tune_luminance`, `image_tune_saturation` | where it is holding each setting, which is **not** what the settings page shows |

Two things about these worth knowing before you graph them:

- They are **absent, not zero**, whenever there is nothing to report. A gauge
  that disappears makes a scraper draw a gap; one reading 0 makes it draw a
  decision that was never taken.
- **Absence on its own does not say why**, and this is the one place where the
  metrics tell you less than the page does. Switched off, unsupported
  hardware, and a camera that has given up because it cannot measure all look
  identical from `/metrics` — the whole set is simply missing. To tell them
  apart, read `image.tuning` from
  [`/api/v1/config.json`](majestic-streamer.md): set to `false` and the
  operator switched it off; set to `true` with no metrics and the camera
  cannot run it, for one of the reasons below.
- While the camera is **paused**, nothing is being measured, so `span` and the
  clipping figures are the last reading from before the pause. They can be
  minutes old.

### How often it looks

Every couple of seconds it takes a cheap reading that tells it whether the
picture has changed at all, and only pays for a real measurement when it has,
when it is mid-correction, or every two minutes regardless. A camera watching
a still scene therefore costs almost nothing to leave switched on.

A measurement is one frame of the main stream, sampled on a lattice rather
than pixel by pixel, so its cost does not grow with sensor resolution.

### When it will not run

Two cases, and they look different on the page.

**The camera's own picture statistics are not available**, which is the case on
older HiSilicon parts. It gives up immediately and the panel reads *No answer —
the camera is not reporting what it is doing*. Nothing is lost: the feature
simply stays inert on hardware that cannot drive it.

**The main stream is compressed.** Measuring needs real pixels and a compressed
frame cannot supply them, so each attempt fails: the panel reads *No reading*
for a while, and once it has given up, *No answer*. Your saved picture settings
are put back when it stops. Set

```yaml
isp:
  yuvCompression: none          # none | seg | auto
```

if you want tuning on that camera. `off` is not one of the values and is
refused with HTTP 400.

### Switching it off

Either pick one of the other Scene modes on the Live page, or:

```yaml
image:
  tuning: false
```

Changing it restarts the video. Your saved picture settings are applied on the
way back up, so the picture returns to exactly what the configuration says.

### Things that will surprise you

**The sliders read differently from the file.** With Automatic in force, the
Live page shows where the camera is holding each setting, while
`majestic.yaml` and `/api/v1/config.json` still hold your values. Both are
telling the truth about different things.

**Switching mode takes effect on Save.** The chips change what the page shows
straight away — the lit mode, the locked sliders — but handing the picture over
or taking it back restarts the video, so it happens when you save. Until then
the sentence reads *Paused*, which is true: your unsaved edits have asked the
camera to stand aside.

**Saving a slider re-bases it.** It takes the new value as its starting point
and works from there, rather than treating your edit as something to undo.

**It goes quiet after dark.** High sensor gain means a noisy picture, and
stretching a noisy picture amplifies the noise along with the detail — so it
stands down as the light goes and hands the picture back. On an outdoor camera
that is most of the night, every night.

**It can reduce contrast, not only raise it.** When both ends of the picture
are clipping, pulling contrast in is the only thing that rescues both at once,
so the value it holds can sit below the one you saved.

**`isp.dehaze` applies without restarting the video**, so it is worth trying at
several values by hand if you want to see what the camera is working with.

### Related pages

- [Majestic example config](majestic-config.md) — the keys above, with ranges
  and which platforms have them
- [Automatic night mode without light sensor](auto-night-mode-without-light-sensor.md)
  — the other thing that changes the picture on its own
- [Image quality tuning](image-quality-tuning.md) — the vendor tools for
  offline sensor tuning, which is a different job entirely
