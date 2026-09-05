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

Two settings change that. They map directly onto the vendors' shared
reference-parameter call, whose base period is fixed at 1:

| setting | vendor field | meaning |
|---|---|---|
| `video<N>.refEnhance` | `u32Enhance` | enhancement-layer period |
| `video<N>.refPred` | `bEnablePred` | may base-layer frames reference each other |

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

`svct` and `refEnhance` drive the same hardware registers on the same channel,
so they are mutually exclusive. Setting both logs a warning and `svct` wins.

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
| `svct` | gen 2 and later, per channel | per channel |
| `refEnhance`, `refPred` | gen 2 and later, **per channel** | `video0` only |
| `noiseLevel`, `intraLine`, `intraQp`, `roiRect`, `roiQp`, `bypass` | — | `video0` only |

On HiSilicon each encoder reads its own channel, so `video0` and `video1` can
carry different reference structures. On SigmaStar the code that applies these
returns early for anything but the main stream, so only `video0` declares them —
and they additionally require `fpv.enabled: true`, which brings the 3A side
effect with it. On HiSilicon there is no FPV module and `refEnhance` on its own
is enough.

A knob absent from your camera's schema is not supported by that build; the API
answers `404` rather than accepting a setting nothing would apply.

> The reference-structure measurements on this page were all taken on
> HiSilicon. SigmaStar takes the identical parameters through the identical
> vendor call, but the behaviour of `refEnhance: 0` with `refPred: false` has
> not been confirmed there on hardware — use the bitrate check above before
> relying on it.

### Applying changes

The reference structure is programmed between encoder channel creation and the
start of encoding; the SDK ignores a later call. That does *not* mean you have
to restart anything. Setting either key restarts the video pipeline on its own
and the new value is picked up as encoding starts again, so this is enough:

```
curl 'http://localhost/api/v1/set?video0.refEnhance=1'
```

Majestic is not restarted and the camera does not reboot. The real cost is that
the streams drop and come back, so viewers see a reconnect — do it when that is
acceptable, not while something is recording. Confirm the new setting took
effect with the bitrate check above rather than assuming it did.
