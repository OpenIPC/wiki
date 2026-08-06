# OpenIPC Wiki
[Table of Content](../README.md)

Majestic encoder tuning
-----------------------

Settings that change *how* the video encoder predicts and structures frames,
rather than how many bits it spends. They live in two places in
`/etc/majestic.yaml`: the per-channel `video0:` section, and an `fpv:` section
that despite its name is not only useful for FPV.

All of the `fpv:` settings apply to the **main stream only**.

### Reference structure — surviving packet loss

By default each P frame predicts from the frame before it, so the chain of
dependencies runs the whole length of the GOP. Lose one packet and every frame
after it is wrong until the next keyframe.

Two settings change that. They map directly onto the vendors' shared
reference-parameter call, whose base period is fixed at 1:

| setting | vendor field | meaning |
|---|---|---|
| `fpv.refEnhance` | `u32Enhance` | enhancement-layer period |
| `fpv.refPred` | `bEnablePred` | may base-layer frames reference each other |

The combination worth knowing about is:

```yaml
fpv:
  refEnhance: 0      # no enhancement layer
  refPred: false     # base frames do not reference each other
video0:
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

`svct` and `fpv.refEnhance` drive the same hardware registers, so they are
mutually exclusive. Setting both logs a warning and `svct` wins.

### The rest of the `fpv:` section

| setting | type | effect |
|---|---|---|
| `enabled` | bool | Turns the block on. **Also disables userspace 3A** (auto exposure/white balance) at startup, so do not enable it just to reach one of the settings below. |
| `noiseLevel` | int | 3DNR strength on the video pipeline. |
| `refEnhance` | int | See above. |
| `refPred` | bool | See above. |
| `intraLine` | int | Cyclic intra refresh: how many macroblock rows are re-encoded as intra each frame. Spreads keyframe cost across the GOP instead of spending it in one burst. |
| `intraQp` | bool | Ask the encoder for an I-frame QP on refreshed rows. |
| `roiRect` | list | Up to 8 regions of interest as `XxYxWxH` strings. Coordinates are rounded to multiples of 32 and clamped to the frame. |
| `roiQp` | string | Comma-separated QP delta per region, in the same order as `roiRect`, each clamped to -30..30. Negative means better quality. |
| `bypass` | int | ISP IQ API index whose bypass state is **toggled** when applied. Diagnostic. |

Every integer above is skipped when negative, which is also what an absent key
reads back as — so each one is individually opt-in and leaving it out changes
nothing.

### Platform support

| setting | HiSilicon | SigmaStar |
|---|---|---|
| `video0.svct` | gen 2 and later | yes |
| `fpv.refEnhance`, `fpv.refPred` | gen 2 and later | SSC338Q (infinity6e) |
| everything else under `fpv:` | — | SSC338Q (infinity6e) |

On SigmaStar the `fpv:` settings additionally require `fpv.enabled: true`. On
HiSilicon there is no `fpv` module, so `refEnhance` on its own is enough and the
3A side effect does not apply.

> The reference-structure measurements on this page were all taken on
> HiSilicon. SigmaStar takes the identical parameters through the identical
> vendor call, but the behaviour of `refEnhance: 0` with `refPred: false` has
> not been confirmed there on hardware — use the bitrate check above before
> relying on it.

### Applying changes

The reference structure is programmed between encoder channel creation and the
start of encoding; the SDK ignores a later call. A config reload is not enough —
restart majestic, or reboot the camera, for these to take effect.
