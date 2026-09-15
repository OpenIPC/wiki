# What the camera detects, and how to read it

Majestic's detectors find things in the picture — movement on every SoC family
that supports it, and on one platform faces as well. Until recently the only
things that reached the outside world were a shell script invocation, a coarse
cell grid over ONVIF, and boxes burnt into the video by the overlay hardware.

The camera now publishes each detection once, in one shape, and everything that
wants it reads the same answer: a live websocket, a polling endpoint, a browser
overlay, an ONVIF metadata stream, a track inside the recording, and a per-day
index the recordings page paints a timeline from.

This page is the format and the endpoints. For turning detection on at all, and
for recording a clip per event, see **Motion detection** and **Recording on
motion** in [Majestic streamer](majestic-streamer.md).

## The detectors

| detector | reported as | where it runs |
|---|---|---|
| motion | `motion` | HiSilicon/Goke, Ingenic, SigmaStar — wherever `motionDetect` works |
| face | `face` | Hi3516CV500 only, and only where the firmware offers it. Off by default. See [Face detection](#face-detection) |

A detector is only a source of events. Nothing downstream is written per
detector: turn face detection on and its boxes appear in the browser overlay,
in the ONVIF metadata stream and over the endpoints below without any further
configuration. They reach **recordings** on the same terms as motion's do —
only if `records.metadata` is on, which it is not by default. So a camera can
be reporting faces live while its clips contain no detections at all.

## Reading it live

### `GET /api/v1/analytics`

The latest event from each detector, as one JSON object. Good for a script, or
for looking at the thing with `curl`.

```console
$ curl -s -u root:PASSWORD http://CAMERA/api/v1/analytics
{"sources":[
  {"src":"motion","active":true,"w":3840,"h":2160,"n":3,"total":3,
   "pts":5773196434,"t":1789396178290757,"q":"k",
   "r":[[1200,300,240,180,0,0],[980,520,120,90,0,0],[2360,442,40,56,0,0]]},
  {"src":"face","active":false,"w":3840,"h":2160,"n":0,"total":0,"r":[]}
]}
```

A detector that has never published is absent from `sources` rather than
present and empty.

### `GET /ws/analytics`

A websocket carrying one text frame per event, in the same shape as a single
`sources` entry. This is what the browser overlay reads. Expect a few frames a
second while something is moving, plus one "nothing is happening" frame a
second between bursts, which also keeps the connection alive.

At most four websocket sessions are served at once; a fifth gets **503**. A
client that stops reading is disconnected rather than queued for ever — for a
live overlay a box that arrives late is drawn over a picture that has moved on,
so events are dropped rather than buffered, and a session that stays blocked is
closed.

Both endpoints are behind the camera's normal credentials, and both are
readable by a **media-scoped account** as well as by `root` — the reasoning
being that boxes drawn over a picture such an account may already watch reveal
nothing further. That is an exception to the rule that non-root accounts cannot
touch the API; see **Who may call the camera** in
[Majestic streamer](majestic-streamer.md) for the full path list. On a camera
nobody has claimed yet, both answer **401** like everything else.

## The format

| field | meaning |
|---|---|
| `src` | which detector spoke |
| `active` | whether that detector currently sees anything |
| `w`, `h` | the picture the boxes were measured against |
| `r` | the boxes — see below |
| `n` | boxes carried in `r` |
| `total` | boxes the detector actually found |
| `pts` | presentation timestamp of the analysed frame |
| `t` | when that frame was captured, microseconds since the epoch |
| `q` | how well `t` is known |

Each box is a **fixed-order array**, not an object:

```
[x, y, w, h, class, score]
```

At thirty-two boxes several times a second the key names would be most of the
bytes, and this runs on cameras where that is a real number. `class` is `0`
when the detector does not classify, which is what the motion detector always
reports; face detections carry the face class and a `score` from 1 to 100.

**Coordinates are main-stream pixels.** That is the space every detector
normalises to, and the one an application decoding the main stream can crop
with directly — which is the point if you want to run your own inference on
part of a picture rather than all of it. Working from the sub-stream, scale by
the ratio you already know; `w` and `h` are in the event so you never have to
ask the camera.

**`n` and `total` are not the same number.** A camera pointed at trees on a
windy night produces dozens of blobs. An event carries at most **32** boxes and
tells you how many there were, because a consumer shown "32 of 32" would
reasonably believe it had the whole picture.

### Two timestamps, answering different questions

`pts` names the **frame**. It is the same presentation timestamp the video
carries, so you can attach a box to the picture it describes rather than to
whatever is on screen when the box arrives. Where the camera cannot say which
frame it looked at, `pts` is absent — never zero, never invented.

`t` is when that frame was **captured**, in wall-clock terms, and `q` grades
it: `k` when the capture instant is anchored to the kernel's frame timing, `e`
when it is an estimate. Both are absent rather than zero when the camera cannot
say. A reader that treats a missing timestamp as 1970 is obviously wrong; one
handed a zero has no way to tell it from a time.

### How often

`analytics.publishFps` (default `5`, range 1–30) bounds how often subscribers
are told that something is *still* there. Some detectors run once per analysed
frame, so without a bound a camera hands twenty events a second to every
consumer, each of which renders a document.

**A transition is never dropped.** The limit bounds repetition, not news:
movement starting and movement stopping always get through. Rate-limiting a
stop would leave a box drawn over an empty room until the next event, which on
a quiet camera may be tomorrow.

## In the browser

The web interface draws the boxes over the live picture on **Settings → Events
→ Motion detection**, and on the **Live** page. Nothing is burnt into the
video: the overlay is drawn in the page, over the stream, so it costs the
encoder nothing, has no per-chip limit on how many boxes it can show, and does
not fight with privacy masks.

The caption beside the picture distinguishes four states, because they mean
different things: waiting for the camera, nothing moving, boxes on screen, and
the camera has gone quiet for longer than it should have.

`motionDetect.visualize` — the boxes drawn **into** the video by the overlay
hardware — is unchanged and still there for RTSP and VMS viewers. It is the
capped one: what it can draw depends on the chip, and on some it cannot draw
boxes at all.

## Inside a recording

```yaml
records:
  enabled: true
  metadata: true        # default false
```

With `records.metadata` on, each clip carries the detections as a timed
metadata track alongside the video: an ISO/IEC 14496-12 `meta` track whose
sample entry declares `application/json`, one sample per event, in the video's
own timescale. An analysis tool or a CV application reads the boxes straight
out of the file, with no camera and no network.

```console
$ ffprobe -hide_banner clip.mp4
  Stream #0:0(und): Video: h264 ...
  Stream #0:1(und): Data: none (mett / 0x7474656D)

$ ffmpeg -i clip.mp4 -map 0:d -f data - 2>/dev/null | head -c 200
{"s":0,"a":1,"w":3840,"h":2160,"n":2,"t":2,"r":[[1200,300,240,180,0,0],...]}
```

A sample carries the same information as a websocket event but with **shorter
keys**, because it is written into every fragment for the life of the
recording. The timestamps are gone — the sample already sits at its own instant
in the track — and one key means something different, so read the table rather
than assuming:

| in a clip | on the wire | meaning |
|---|---|---|
| `s` | `src` | which detector, as a **number**: `0` motion, `1` face |
| `a` | `active` | whether it saw anything |
| `w`, `h` | `w`, `h` | the picture the boxes were measured against |
| `n` | `n` | boxes carried in `r` |
| **`t`** | **`total`** | boxes found — **not a timestamp** |
| `r` | `r` | the boxes, same `[x, y, w, h, class, score]` order |

A fragment in which nothing was detected still carries one sample saying so,
which is how a reader tells "the camera saw nothing" from "the camera stopped
writing".

Size it from the event rate, not from a single figure. A sample is roughly
90 bytes, and the camera writes at most `analytics.publishFps` of them a second
while the recorder is running — so the worst case at the default of 5/s is
about **39 MB a day** of metadata, and a camera that only records on motion, or
that mostly sees nothing, writes a small fraction of that. Either way it is
noise beside the tens of gigabytes a day of 4K video it sits in.

Encrypted clips protect this track with everything else. Leaving it in the
clear would tell anyone holding the card when and where somebody moved, which
is most of what the encryption is for — see
[Encrypted recordings](recording-encryption.md).

### Why it is off by default

**Safari 26.6 refuses a recording carrying this track alongside H.264.** The
video fails to decode at the first frame and nothing plays. The same Safari
accepts the identical track alongside H.265, and Safari on macOS 14 accepts
both; Chrome accepts everything. That was measured in real Safari on both
macOS versions, each fixture played against the same recording *without* the
track as its own control, with a synthetic H.265 clip produced by the same
command as the H.264 one to separate the codec from the file's provenance.

Majestic records H.264 by default on most cameras, so this is not a corner
case. The web interface removes the track as it plays, so a camera whose web
interface is current can turn the setting on; an older interface against a
newer camera cannot, which is why the default cannot be `true`.

Two other consequences worth knowing before you enable it:

- **Live HLS stops being served from the card** while this is on, and is served
  from memory instead, which costs the RAM that path always costs. Card-served
  HLS describes byte ranges of the clip itself, so the track would reach a
  browser that has nothing to remove it with.
- The track is written **last** in every fragment, and its samples sit at the
  **tail** of each media block. That is a contract, not an accident: it is what
  lets a player drop the track with two truncations instead of rewriting the
  file.

## Over ONVIF

The `vnd.onvif.metadata` stream that accompanies RTSP carries two descriptions
of the same detections, because two different kinds of client read it:

- `tt:MotionInCells` — the cell-motion rule's own shape, a bitmap over a fixed
  grid, which is what a VMS subscribed to that rule expects.
- `tt:Object` / `tt:Shape` / `tt:BoundingBox` with `tt:Class` — the scene
  description every analytics client understands, carrying what the grid throws
  away: where each detection actually was, how many there were, and what the
  detector believes each one to be.

Its RTP timestamps come from the analysed frame's own presentation timestamp,
in the same clock domain as the video track, so the two can be lined up.

**A word on the coordinates, because they are not pixel coordinates.** ONVIF's
normalised frame runs −1 to +1 on both axes, with the origin at the **centre**
and y increasing **upward** (Analytics specification §5.2.2). So `top` is the
**larger** value — the opposite of every pixel coordinate on a camera. The
boxes are emitted as plain pixels behind a `tt:Transformation` that maps them
onto that frame, which is the shape the specification's own example uses: the
numbers stay exact, and a reader that ignores the transformation still has
something interpretable.

A detection nothing has classified carries no `tt:Class` at all. Saying
"Other" would be a claim where the truth is a gap.

Presence transitions are ONVIF property events, one topic per detector:

| detector | topics |
|---|---|
| motion | `tns1:VideoSource/MotionAlarm`, `tns1:RuleEngine/CellMotionDetector/Motion` |
| face | `tns1:RuleEngine/FaceDetector/Face` |

A subscriber narrowed to one topic is not woken by the others, and a new
subscription is seeded with every detector's current state — these are property
events, so a client holds a copy and has to be given a complete one.

## A day at a time

Reading a whole day out of the clips means reading the clips, since the samples
are interleaved through every one. So the camera keeps the derived answer as
well:

```console
$ curl -s -u root:PASSWORD "http://CAMERA/api/v1/analytics/day?d=2026-09-14"
{"day":"2026-09-14","source":"memory",
 "spans":[[44610,44758,579],[44772,44779,25],[44944,45203,950]],
 "watched":[[0,45957],[46021,46177]],
 "events":1554,"seconds":416,"merged":0,"capped":false,"torn":false,
 "detector":true}
```

Times are **wall-clock seconds into the camera's local day**, the same
coordinate system `%H-%M` filenames already use — so the timeline and the clip
list cannot disagree, and a daylight-saving day is ambiguous in exactly the
places the filenames already are.

| field | meaning |
|---|---|
| `spans` | `[from, to, events]` per interval in which something moved |
| `watched` | intervals in which the camera was keeping this index |
| `events`, `seconds` | totals over `spans` |
| `merged` | how many intervals were coalesced to make room |
| `capped` | the answer is coarser or shorter than the day |
| `torn` | part of the stored index could not be read |
| `source` | where the answer came from — see below |
| `detector` | whether motion detection is on *now*. Present only for today |

`d` defaults to today and is validated as a real calendar date, so
`d=2026-02-31` is **400** rather than quietly becoming March. `POST` is
**405**. The endpoint sits behind the same credential as the configuration: an
index of when the camera saw movement describes the premises.

### `watched` is the field that makes it honest

Inside a watched window, no span means nothing moved. Outside every window,
nothing is claimed. Without it, a day recorded before the camera kept an index
and a genuinely quiet day would look identical and mean opposite things. A
window belongs to one run of the camera, so a day spanning a reboot comes back
as the windows either side of it with the gap left unclaimed.

`source` carries the same distinction for the whole answer:

| `source` | meaning |
|---|---|
| `memory` | answered from what the camera is holding |
| `card` | read back from storage |
| `none` | we looked and there is nothing |
| `unreadable` | we could not look |

`none` and `unreadable` are different states, and a page that painted the
second as the first would show a reassuring empty day for a camera that had
gone blind.

### Presence only — no geometry, in any mode

**The day index carries intervals and event counts. No rectangle enters it.**
That is not a simplification, it is what lets it exist beside encrypted
recordings: the in-clip track is sealed with the media, and an index in the
clear saying *where* in frame somebody moved would hand back exactly what the
encryption withholds. *When* is readable in every mode; *where* is readable
only by whoever can open the clip.

It is written beside the day's clips as the recorder closes them, so a camera
that is not recording keeps today's answer in memory and stores nothing. The
index is small and bounded — a few kilobytes held per day, and it does not
grow. When it runs out of room it coalesces the closest neighbouring intervals
rather than forgetting the oldest, so resolution degrades and history does not.
The error direction is fixed and worth knowing when you read a timeline: it can
say *"something moved over a slightly wider window"*, never *"nothing moved"*.

### On the recordings page

The lane under the zoomable band on the recordings page draws this: amber blips
where something moved, hatching for stretches nobody was watching, and hatching
over the whole lane when the camera gave no answer at all. Clicking a blip
seeks there, with a few seconds of lead-in when the camera is recording on
motion, since the run-up is deliberately inside the clip.

At a whole day across a few hundred pixels a ten-second event is a fraction of
a pixel, so blips are widened to stay visible and near neighbours are merged —
but a click still resolves to the event actually under the pointer rather than
to the first of a clump.

## Face detection

**Status: MVP, one platform, off by default, and not in every firmware.**

Majestic can detect faces on the camera's own CPU on **Hi3516CV500**. It is an
optional capability rather than a standard one: a firmware without it offers no
`faceDetect` settings and advertises no face topic over ONVIF, and nothing
about a camera changes until you both run a firmware that has it and switch it
on.

To tell whether yours has it, ask for the settings:

```console
$ curl -s -u root:PASSWORD http://CAMERA/api/v1/config.json | grep -c faceDetect
```

`0` means this firmware does not offer it. The **Settings → Events** page shows
a FaceDetect entry on a camera that does, and none on one that does not.

```yaml
faceDetect:
  enabled: true
  confidence: 50        # 0-100, minimum score to report a face
  debug: false
motionDetect:
  enabled: true         # required — see below
```

**It is gated on motion, and that is the design.** Inference runs only on
frames where the hardware motion detector fired. Motion is the cheap
always-on gate, so a static scene spends nothing; with `motionDetect` off, the
face detector never runs at all. Measured on a Hi3516CV500 with a 4K sensor,
one scan of the aspect-correct 320-pixel-wide analysis frame takes roughly
**430 ms**, which is why it is gated rather than run per frame.

A face detection is an ordinary event on every channel above: a box with the
face class and the detector's confidence as `score`, `"src":"face"` over the
websocket and the endpoint, `tt:Class` "Face" over ONVIF, a sample in the
recording, its own ONVIF topic, and its own colour in the browser overlay.

There is deliberately **no `faceDetect.visualize`** beside
`motionDetect.visualize`. Drawing is a property of a consumer, not of a
detector, and the browser overlay is where face boxes are meant to be seen.

What "MVP" means here, plainly: one SoC, one detector, no tracking, no
identification, no recognition — it reports that a face-shaped thing is in a
place, with a confidence, and nothing about whose it is.

## Settings

| key | default | range | what it does |
|---|---|---|---|
| `analytics.publishFps` | `5` | 1–30 | how often repeat detections are handed to consumers |
| `records.metadata` | `false` | | write detections into each clip |
| `faceDetect.enabled` | `false` | | run face detection (Hi3516CV500, if built in) |
| `faceDetect.confidence` | `50` | 0–100 | minimum score to report a face |
| `faceDetect.debug` | `false` | | extra logging from the face detector |

`motionDetect.*` is documented under **Motion detection** in
[Majestic streamer](majestic-streamer.md), and every key with its defaults is
in [the example config](majestic-config.md).

## Turning it off

Nothing here is on unless you turn it on. With `motionDetect.enabled: false`
and no face detector, the endpoints answer with an empty `sources` list, the
overlay says the camera is not detecting, recordings carry no metadata track,
and the day index has nothing to report.
