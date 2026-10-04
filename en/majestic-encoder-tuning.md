# OpenIPC Wiki
[Table of Content](../README.md)

Majestic encoder tuning
-----------------------

Settings that change *how* the video encoder predicts and structures frames,
rather than how many bits it spends. They live in the per-channel `video0:` /
`video1:` sections of `/etc/majestic.yaml`, alongside `gopSize` and `bitrate`.

Nothing here is specific to FPV, despite where these used to live. Spreading a
keyframe over several frames suits any lossy link, and spending bits on one
region of the frame is what a fixed surveillance camera wants.

> **These moved.** They were a global `fpv:` block until August 2026, and a
> config still naming them there is ignored rather than translated. Only
> `fpv.enabled` remains, being a SigmaStar pipeline switch rather than an
> encoder setting. Which channels accept which knob is in
> [Platform support](#platform-support) below.

### Reference structure — surviving packet loss

By default each P frame predicts from the frame before it, so the chain of
dependencies runs the whole length of the GOP. Lose one packet and every frame
after it is wrong until the next keyframe.

Two settings change that. The base-layer period is fixed at 1:

| setting | meaning |
|---|---|
| `video<N>.refEnhance` | enhancement-layer period |
| `video<N>.refPred` | may base-layer frames reference each other |

The combination worth knowing about is:

```yaml
video0:
  refEnhance: 0      # no enhancement layer
  refPred: false     # base frames do not reference each other
  gopSize: 1.0
```

`refPred: false` makes base-layer frames reference the keyframe instead of their
predecessor. With `refEnhance: 0` there is no enhancement layer, so *every* P
frame becomes what the vendor documentation calls a virtual I-frame — nothing
depends on the frame before it.

A lost frame then costs exactly that frame. Measured on a Hi3516CV500, dropping
one NAL mid-GOP leaves the **very next frame bit-exact**, where the normal
prediction chain stays visibly damaged until the next keyframe.

> **`refEnhance` must be 0 here, not 1.** With `1` the encoder splits base and
> enhancement layers and only half the frames reference the keyframe; the rest
> still propagate errors to the end of the GOP. Note also that the vendor rule
> "enhance 0 means normal prediction" only holds while `refPred` is `true`.

#### Why `gopSize` matters more than usual

Predicting from the keyframe gets worse as that keyframe ages, so the cost
depends on how much the scene changes in between. On a completely still scene it
is free — frame sizes are identical across a five-second GOP. Once the scene
moves, frame size climbs steadily through the GOP.

So bitrate against keyframe interval is **U-shaped**, and the minimum moves with
motion:

| `gopSize` | moderate motion | fast motion |
|---|---|---|
| 0.25 | 0.89 Mbps | 1.14 Mbps |
| 0.5 | 0.61 | **1.03** &larr; best |
| 1.0 | **0.59** &larr; best | 1.78 |
| 2.0 | 0.82 | 2.65 |
| 5.0 | 1.61 | 3.14 |

*(640x360 H.265 at 20 fps, identical content, CBR.)*

> **Rule of thumb:** start at `gopSize: 1.0` and shorten it if the scene moves a
> lot. A fixed camera watching a quiet room can go considerably longer. This is
> the opposite of the usual advice, where a longer GOP always saves bitrate.

#### Is it worth it?

Compared against the conventional way of limiting error propagation — normal
prediction with a short GOP — at its best interval:

| scene | reference-to-keyframe | normal, 5-frame GOP | result |
|---|---|---|---|
| static | 1.25 Mbps @ 5.0 | 3.86 Mbps | **3.1x cheaper** |
| moderate motion | 0.59 Mbps @ 1.0 | 0.84 Mbps | **1.4x cheaper** |
| fast motion | 1.03 Mbps @ 0.5 | 0.99 Mbps | about equal |

and in every case it recovers in one frame where the short GOP takes up to five.
A clear win for fixed cameras, a smaller one under moderate motion, roughly a
wash for fast motion — where you still get the better loss behaviour at the same
bitrate.

#### Use it with error correction

Do not pair this with little or no FEC. Every P frame depends on one keyframe,
and that keyframe is around 90 packets at a 1400-byte MTU, so losing it costs
the whole GOP. Simulated over a lossy link, this with no FEC loses **67% of
frames at 1% packet loss**.

Protect the keyframe heavily and the P frames lightly — not the keyframe alone.
Every unprotected P loss still costs a visible frame, so leaving them bare is
worse than spending a little parity on them.

> **Losing the keyframe is silent.** With it gone the decoder never resets its
> picture order count, resolves the following frames against a stale reference
> and reports no error at all. If you are building on this, detect keyframe loss
> in the transport, not from the decoder.

#### Checking it is active

Raise `gopSize` and watch the bitrate. With normal prediction a longer GOP
lowers bitrate; with `refPred: false` it raises it.

### Temporal layers — `video0.svct`

```yaml
video0:
  svct: off        # off | 2x | 4x
```

Splits the stream into a base layer plus a droppable enhancement layer, in one
conformant bitstream. A consumer that drops the enhancement layer gets half
(`2x`) or a quarter (`4x`) of the frame rate without re-encoding, and the result
still decodes.

Majestic can do the dropping per RTSP session — append `?thin=1` to the stream
URL and that session receives the base layer only, while other clients continue
at full rate.

`svct` and `refEnhance` configure the same part of the encoder on the same
channel, so they are mutually exclusive. Setting both logs a warning and `svct` wins.

### Rate-control defaults on the Hi3516EV200 family

From builds dated 2026-10-05, on the Hi3516EV200, Hi3516EV300, Hi3518EV300
and Hi3516DV200, the encoder spends the same bitrate noticeably better. The
defaults behind that change in three places:

| setting | default before | default now | effect |
|---|---|---|---|
| `video<N>.adaptiveQp` | on | **off** | one quantiser across the whole frame, not one that varies block by block with texture |
| `video<N>.ipQpDelta` | 2 | **6** | the keyframe is coded 6 QP better than the P frames that follow it |
| `video<N>.minQp` (VBR and AVBR) | 28 | **18** | lowest QP the rate controller may use |

#### What it buys

Measured on a Hi3516EV300 with an IMX335, using footage recorded from the
camera's own sensor:
- AVBR at a 1 s GOP; the night clips under slow shutter.
- Each setting was encoded from that identical recorded footage, so no
  difference comes from the scene changing between runs.
- Compared by VMAF at equal quality.
- Day and night 1080p used 6 clips each; day and night 5 MP used 3 clips each.

Bitrate needed for the same picture quality, against the old defaults:

| stream | day | night |
|---|---|---|
| 1080p H.265 | -12% to -15%\* | -3% to -7%\* |
| 1080p H.264 | -15% | -7.5% |
| 2592x1944 H.265 | -8% | -6% |

\* 1080p H.265 was measured with keyframe offsets of 2 and 8 rather than 6.
The range spans the two.

Every configuration in the table won on every clip it was measured on, and the
encoder's frame rate was unchanged. The exact new combination, with an offset
of 6, was measured on 1080p H.264 and on both 5 MP sets. 1080p H.265 was
measured only with the neighbouring offsets.

What each change contributes:
- **`adaptiveQp: false`** gives the bulk of the daytime gain. The encoder's
  texture-driven block adjustment costs more bits than it saves at equal VMAF.
- **`ipQpDelta: 6`** helps most at night. Each P frame predicts from the one
  before it, so in a mostly still scene the detail coded into the keyframe is
  carried forward frame to frame rather than coded again. A better keyframe
  lifts the whole GOP for little extra cost. At 5 MP the best value differs: about 4 by day, 8 at night. 6 is never
  far from either.
- **The lower `minQp` floor** does not change efficiency. It changes what a
  generous bitrate buys: with a floor of 28, AVBR given 4 Mbps at 1080p stopped
  improving at about 2.3 Mbps. With 18 it uses more of what it is given.

#### Other chips

On the other chips that have these keys (see
[Platform support](#platform-support)), the defaults are unchanged:
`adaptiveQp` on, `ipQpDelta` 2, `minQp` 28. The keys work there, but switching
adaptive QP off or raising the keyframe offset has only been measured on the
chips above. Try it on your own footage first. Older chips do not have the keys
at all; a build without them answers `404` to setting one.

A default only applies to a key your configuration does not set. A
`majestic.yaml` that already names `minQp: 28` keeps it after the update; remove
the line to take the new default.

#### Setting them

```
curl 'http://localhost/api/v1/set?video0.adaptiveQp=true'
curl 'http://localhost/api/v1/set?video0.ipQpDelta=4'
```

Like the reference-structure keys, a change restarts that stream's encoder:
viewers reconnect, but Majestic is not restarted, and the other stream is left
alone. `ipQpDelta` accepts -10..30; a value outside that is refused with `400`.
It applies to the normal GOP mode. The dual-P and smart-P GOP modes keep their
own offsets.

To check what the encoder is running with, read the driver's own status file
on the camera:

```
cat /proc/umap/rc
```

It lists the QP window (`MinQp`, `MinIQp`) and `IpQpDelta` per channel. The
per-block thresholds read all zero when `adaptiveQp` is off.

#### What was measured and left alone

- **A longer GOP** saves the most: 20% or more at `gopSize: 2` against 1 s,
  and about 40% at 5 MP by day, where the keyframe is most of the bitrate. It
  also delays recovery after loss, so it is not a default. To trade it for disk
  space, use the [storage saver](#storage-saver--videonstoragesaver) rather
  than `gopSize` alone: it keeps viewer joins and motion clips fast. See the
  reference-structure section above for when a short GOP matters.
- **`rcMode: cbr` and `rcMode: vbr`** both needed more bitrate than AVBR for the
  same quality on this footage. AVBR is the default and remains the best of the
  three.
- **A fixed QP** is about 8% (1080p) to 11% (5 MP) more efficient than AVBR
  at night, even with the new defaults. It holds no bitrate target, though, so
  it is not a default.

### Storage saver — `video<N>.storageSaver`

For cameras whose recordings are kept for weeks, on an SD card or an NVR disk,
where the disk costs more than the picture. It serves the same purpose as the
"H.265+" or "H.265X" modes of other cameras. Off by default, set per stream,
in builds from October 2026:

```yaml
video0:
  storageSaver: off    # off | archive | strong | max
```

| level | what changes | bitrate for the same picture | frame rate |
|---|---|---|---|
| `archive` | a keyframe every 10 s; QP floor of at least 24 | -26% | unchanged |
| `strong` | `archive`, plus frames skipped while the stream runs above half of `bitrate`; `maxQp` 44 | -36% (-31% by PSNR) | about 17 of 25 fps on busy footage |
| `max` | `strong`, plus the stream held to about a third of `bitrate`, QP 28-51, and still scenes allowed to go soft | -56% (-58% by PSNR) | 13-25 fps |

*Hi3516EV300 with an IMX335, 1080p H.265 by day, 4 clips recorded from the
camera's own sensor and encoded identically for every level, each played
three times over so a 10 s GOP cycles. Bitrate is compared at equal quality
against the defaults above (1 s GOP), by VMAF. The levels that skip frames are
also given by PSNR, because VMAF undercharges a repeated frame.*

On a quiet scene the saving is larger. A 5 MP stream of a still room at
`bitrate: 5102` delivered 1821 kbps with the saver off, 846 kbps with
`archive`, and 261 kbps at 13 fps with `max`. A camera with the same chip and
sensor, running its own vendor's H.265X mode on the same scene, delivered
426 kbps at 8 fps.

**`archive` keeps the picture.** Everything it saves comes from the longer
keyframe interval. `strong` and `max` sell picture and frame rate for more
disk: `strong` shows motion at a lower frame rate, and `max` looks visibly
softer. Choose `max` for footage you will only search, not watch.

What to expect with it on:
- **Viewers still join quickly.** A new RTSP, WebRTC or web viewer gets a
  fresh keyframe on connecting: about 0.1 s over RTSP and 0.5 s to the first
  WebRTC picture, measured. Keyframe requests less than 3 s apart are combined
  into one, so the long interval cannot be worn down by clients. When several
  viewers connect at once, the later ones can wait up to 3 s.
- **`gopSize` becomes a minimum.** The stream uses 10 s, or your `gopSize` if
  it is longer. ONVIF reports the interval the stream really has. An NVR that
  writes that value back does not change `gopSize`, and a shorter one does not
  shorten the interval while the saver is on.
- **Motion clips start at the trigger.** The recorder asks for a keyframe when
  motion starts, so a clip opens on the trigger rather than up to 10 s later.
  The run-up before it (`records.preRollSec`) is kept only if it holds a
  keyframe, and keyframes are now 10 s apart, or `gopSize` apart if that is
  longer. Set `preRollSec` at or above that interval to keep the run-up; the
  recording guide's advice to keep `gopSize` at or below `preRollSec` is not
  enough on its own with the saver on. The run-up is held in RAM, so on a
  small camera the memory cap can still shorten it — see
  [Recording on motion](majestic-streamer.md).
- **HLS segments get longer.** A segment runs from one keyframe to the next on
  the stream HLS describes, so with the saver on that stream it lasts 10 s, or
  `gopSize` if longer. Players with low-latency HLS stay close to live; others
  start further behind and fetch larger segments.
- **Each level brings its own QP window** unless you set `minQp` or `maxQp`
  yourself. Set to anything other than its default, your value wins at every
  level.
- **Frame skipping needs `isp.lowDelay` off.** With low delay on, `strong` and
  `max` run without it.

The floor of 24 is there because, with a 10 s keyframe interval on a still
scene, the rate controller drives the quantiser down to its floor. At the
Hi3516EV200 family's floor of 18, `archive` delivered twice the bitrate of the
saver being off, the extra bits going on sensor noise. A floor of 24 brings it
back to about half.

Setting it restarts that stream's encoder, like the other keys on this page:

```
curl 'http://localhost/api/v1/set?video0.storageSaver=archive'
```

To check it took effect, `cat /proc/umap/rc` on the camera shows the GOP
length in frames (150 at 15 fps). For `strong` and `max` it also shows frame
dropping switched on, with its threshold in bits per second.

Measured on the Hi3516EV300 only. It is available on the other chips listed
under [Platform support](#platform-support), where the same numbers are
expected but have not been measured.

### The rest of the channel knobs

| setting | type | effect |
|---|---|---|
| `noiseLevel` | int | 3DNR strength on the video pipeline. `0` turns it off, which is a value rather than an absence — leaving the key out is not the same thing. |
| `refEnhance` | int | See above. |
| `refPred` | bool | See above. |
| `intraLine` | int | Cyclic intra refresh: how many macroblock rows are re-encoded as intra each frame. Spreads keyframe cost across the GOP instead of spending it in one burst. |
| `intraQp` | bool | Ask the encoder for an I-frame QP on refreshed rows. |
| `roiRect` | list | Up to 8 regions of interest as `XxYxWxH` strings. Coordinates are rounded to multiples of 32 and clamped to the frame. |
| `roiQp` | string | Comma-separated QP delta per region, in the same order as `roiRect`, each clamped to -30..30. Negative means better quality. At most 16 values are read; the rest are ignored. |
| `bypass` | int | ISP IQ API index whose bypass state is **toggled** when applied. Diagnostic. |

Every integer above is skipped when negative, which is also what an absent key
reads back as — so each one is individually opt-in and leaving it out changes
nothing. That is why none of them carries a default: writing one would turn an
opt-in knob into one that always applies.

`fpv.enabled` is the one setting still in the old place. It turns the SigmaStar
FPV path on and **also disables userspace 3A** (auto exposure and white balance)
at startup, so do not enable it just to reach one of the settings above.

### Setting them

All of these are published in the config schema, so they appear in the web UI
under their channel and can be written through the API:

```
curl 'http://localhost/api/v1/set?video0.refEnhance=0'
curl 'http://localhost/api/v1/set?video0.refPred=false'
```

A value outside the range the schema declares is refused with `400` rather than
written, so `video0.refEnhance=99` fails where you typed it instead of sitting
in the config as a number the encoder was never going to use.

### Platform support

| setting | HiSilicon | SigmaStar |
|---|---|---|
| `svct` | all but the Hi3516CV100 family\*, per channel | per channel |
| `refEnhance`, `refPred` | all but the Hi3516CV100 family\*, **per channel** | `video0` only |
| `adaptiveQp` | Hi3516CV500, AV300, DV300; Hi3516EV200, EV300, DV200, Hi3518EV300; Goke GK7205V200, V210, V300, GK7605V100 — per channel | — |
| `ipQpDelta` | the chips above, and Hi3516CV610 — per channel | — |
| `storageSaver` | the chips listed for `adaptiveQp` — per channel | — |
| `noiseLevel`, `intraLine`, `intraQp`, `roiRect`, `roiQp`, `bypass` | — | `video0` only |

\* Hi3516CV100, Hi3518AV100, Hi3518CV100 and Hi3518EV100. Every other HiSilicon
and Goke chip has these keys.

On HiSilicon each encoder reads its own channel, so `video0` and `video1` can
carry different reference structures. On SigmaStar only the main stream applies
them, so only `video0` has them — and they additionally require
`fpv.enabled: true`, which brings the 3A side effect with it. On HiSilicon there is no FPV module and `refEnhance` on its own
is enough.

A knob absent from your camera's schema is not supported by that build; the API
answers `404` rather than accepting a setting nothing would apply.

> The reference-structure measurements on this page were all taken on
> HiSilicon. SigmaStar is given the same parameters, but the behaviour of `refEnhance: 0` with `refPred: false` has
> not been confirmed there on hardware — use the bitrate check above before
> relying on it.

### Applying changes

The reference structure can only be set while a stream's encoder is being set
up, so Majestic sets that encoder up again to apply it. You do not have to
restart anything yourself. Setting either key is enough on its own:

```
curl 'http://localhost/api/v1/set?video0.refEnhance=1'
```

Majestic is not restarted and the camera does not reboot. What you will see is
the streams drop and come back, so viewers reconnect — do it when that is
acceptable, not while something is recording.

Read the value back afterwards rather than assuming it was taken:

```
curl 'http://localhost/api/v1/config.json' | grep -A2 refEnhance
```
