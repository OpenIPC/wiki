# OpenIPC Wiki
[Table of Content](../README.md)

When something moves: clips, hooks and your own scripts
-------------------------------------------------------

The camera can tell you that something moved, record the moment, and run a
script of yours when the recording is finished. This page is the thread through
those pieces: what the camera notices, what it writes, how your script is
called, and how to get a clip on a camera with no memory card at all.

For the detections themselves — every box rather than one box round all of
them, live over a websocket, inside recordings and over ONVIF — see
[What the camera detects](analytics-metadata.md). For the settings, see
**Motion detection** and **Recording on motion** in
[Majestic streamer](majestic-streamer.md#motion-detection).

## What the camera actually knows

It knows that pixels changed, in a rectangle, and nothing else. There is no cat
in it, no person, no parcel: `motionDetect` reports movement, and a detection it
has not classified carries no class. A camera with face detection built in
classifies faces and only faces.

That is worth saying at the start, because it decides how you write everything
below. You do not ask the camera "was that the cat" — you arrange things so that
movement in a particular place, of roughly a particular size, is *usually* the
cat, and you make the consequence of being wrong small.

## The two moments you can hook

| moment | what runs | what it gets |
|---|---|---|
| movement **starts** | `/usr/sbin/motion.sh` | the bounding box of everything moving, in main-stream pixels |
| a clip is **finished** | the command in `records.onClose` | the clip's path, why it ended, roughly how long it is |

They answer different questions. The first one is early — it fires before there
is anything to send, at most once every five seconds, and it is the only hook a
camera without a card has. The second one is late and carries the file.

### When movement starts

```sh
/usr/sbin/motion.sh [x] [y] [width] [height]
```

Called on the transition into movement, not per frame.

The last two are the box's **size**, not its far corner.

Cameras built before September 2026 sent the far corner there instead —
every make except SigmaStar — and the two readings cannot be told apart from
the numbers alone, since `100 200 500 700` is a plausible box under either. So
if your camera predates that, settle it once rather than guessing: put a
one-line script at that path which logs what it was given, wave at the camera,
and look at the numbers.

```sh
printf '%s\n' "$*" >> /tmp/motion-args.log
```

Small third and fourth numbers, roughly the size of the thing you waved, are a
size. Numbers nearly as large as the frame, and always larger than the first
two, are a far corner — subtract the first two from them and the rest of this
page applies.

### When a clip is finished

```yaml
records:
  enabled: true
  mode: motion
  onClose: /usr/sbin/record.sh
```

```sh
/usr/sbin/record.sh '/mnt/mmcblk0p1/2026-09-13/19-28-cam0.mp4' motion 18
```

Three arguments: the clip's path, the reason it ended, and roughly how many
seconds of video it holds — the clip's own lifetime plus the run-up written into
it. A consumer that needs the exact duration reads it out of the file.

| reason | what happened |
|---|---|
| `motion` | a motion clip reached its post-roll and closed |
| `split` | the recorder cut the clip and another follows |
| `stop` | recording stopped; there is no next clip for now |
| `error` | the clip was cut short by something that failed |

Treat a word you do not recognise as "a clip finished" — the list can grow.

What your script must expect:

- It runs **once per finished clip**, detached, as root, with no terminal. Its
  output goes nowhere, so log what you want to keep.
- It does **not** run for a clip that was empty and removed.
- The path arrives single-quoted, so a recording path with a space in it stays
  one argument.
- **One at a time, camera-wide.** If your script is still running when the next
  clip closes, that clip is not handed over and the camera says so in its log.
  Keep the hook quick, or accept that a long upload costs you the clip behind
  it.
- `records.onClose` and `records.preRollSec` can both be changed while the
  camera is running, and the video keeps flowing. `motionDetect.enabled` is the
  one that needs a reload — `killall -HUP majestic`.

The camera does not read your script's exit status. Nothing retries.

## A worked example: who is eating the cat food

The aim: a message on your phone, with video, when a cat visits the feeder —
and a log you can read later to see whether the new one has been eating at all.

### 1. Watch the bowl, not the room

Restrict detection to the feeder. Coordinates are `XxYxWxH` in main-stream
pixels — the top-left corner, then the size — and the visual editor under
**Settings → Events → Motion detection** in the web interface draws them for
you over the live picture.

```yaml
motionDetect:
  enabled: true
  sensitivity: 5
  roi: 980x1120x520x400
```

Only movement inside a listed region raises an event, so with the rectangle on
the bowl, "an event" and "something is at the food" become close to the same
thing. This one setting does more for your false-alarm rate than any amount of
scripting: a curtain moving across the room is now not an event at all.

`sensitivity` runs 0–8 and higher is more sensitive. Start at 5.

### 2. Record the visit, starting before it

```yaml
records:
  enabled: true
  mode: motion
  path: /mnt/mmcblk0p1/%F
  preRollSec: 5
  postRollSec: 10
  onClose: /usr/sbin/cat-feeder.sh
```

`preRollSec` is what makes the clip watchable: without it, every video starts
with the cat already at the bowl. See
[Don't raise gopSize above preRollSec](majestic-streamer.md#dont-raise-gopsize-above-prerollsec)
— on a camera where the keyframe interval has been lengthened to save bitrate,
the run-up is the thing that silently stops working.

### 3. The script

```sh
#!/bin/sh
# /usr/sbin/cat-feeder.sh — run by the camera when a motion clip is finished.
clip=$1
reason=$2
seconds=$3

# Only visits. A rotation or a shutdown is not a cat.
[ "$reason" = "motion" ] || exit 0
[ -s "$clip" ] || exit 0

log=/mnt/mmcblk0p1/feeding-log.csv
stamp=/tmp/cat-feeder.last
now=$(date +%s)

# A cat at a bowl produces a run of clips. One message per visit is enough,
# so ignore anything within ten minutes of the last one we reported.
if [ -f "$stamp" ]; then
    then_=$(cat "$stamp")
    [ $(( now - then_ )) -lt 600 ] && exit 0
fi
echo "$now" > "$stamp"

printf '%s,%s,%s\n' "$(date '+%F %T')" "$seconds" "$clip" >> "$log"

# Hand the clip to whichever notifiers are switched on in the web interface.
# Removing this, or replacing it with a sender of your own, is the whole point
# of having your own hook.
#
# Written as an `if` rather than `[ -x … ] && …`, which would make the script
# itself exit non-zero on every camera that has no dispatcher installed — the
# camera does not read the status, but you will, the first time you run this
# by hand.
if [ -x /usr/sbin/record.sh ]; then
    /usr/sbin/record.sh "$clip" "$reason" "$seconds"
fi
```

`chmod +x` it, and put it somewhere that survives a reboot — `/usr/sbin` on the
camera's overlay does.

Two things about that last line. `/usr/sbin/record.sh` is the small dispatcher
the web interface installs as `records.onClose` when you switch clip sending on
under **Services → Telegram** or **Services → Ntfy**; calling it keeps those
working underneath your own script. And because you have taken `onClose` for
yourself, those pages will tell you they left it alone rather than overwriting
it — clear the setting if you ever want the plain behaviour back.

### 4. Rejecting what is obviously not a cat

The bowl rectangle still fires when *you* walk past it. If that matters, judge
the size of what moved, which is what the early hook gives you:

```sh
#!/bin/sh
# /usr/sbin/motion.sh — run by the camera when movement starts.
# On a camera older than September 2026 the last two may be the far corner
# rather than the size — check yours once, as described above, and subtract
# here if that is what it sends.
x=$1; y=$2; w=$3; h=$4

# Roughly cat-sized in main-stream pixels, measured on your own camera by
# waving at it and watching the boxes in the web interface. A person at the
# same distance is much taller.
if [ "$w" -lt 900 ] && [ "$h" -lt 700 ]; then
    echo "$(date +%s)" > /tmp/cat-sized
fi
```

and in the clip hook, require a recent marker:

```sh
[ -f /tmp/cat-sized ] &&
    [ $(( now - $(cat /tmp/cat-sized) )) -lt 60 ] || exit 0
```

Measure the numbers on your own camera rather than copying these: they depend
on the lens, the mounting height and the main stream's resolution.

## No memory card? Ask for the clip instead

Recording needs somewhere to write, and a camera without a card has nowhere. It
can still send video: ask the camera's own HTTP server for a clip.

```sh
curl -o visit.mp4 'http://<camera>/video.mp4?duration=10'
```

`GET /video.mp4` is fragmented MP4 for as long as you keep reading;
`?duration=N` ends it cleanly after N seconds of video, up to ten minutes, and
the file is complete the moment the response ends. Nothing has to be switched on
first — no recorder, no HLS playlist — and the camera pays nothing for the
endpoint while nobody is asking.

A few things worth knowing:

- It counts **video**, not wall clock, and the cut lands on a whole fragment, so
  a clip can be a little longer than you asked for. With nothing else running, a
  fragment is a whole keyframe interval — ask for less than that and you get one
  anyway.
- The camera needs a running video channel to record from, which is refused
  before the response starts rather than answered with an empty file.
- `?pre=N` asks for the seconds *before* your request as well, and usually
  answers with none: the camera holds a run-up only while another request that
  asked for one is already open. The reply says what it actually contains in an
  `X-Preroll-Seconds` header, so a script never has to guess. Watching the live
  page does not create a run-up.

So the card-less version of the example above is the early hook doing the whole
job:

```sh
#!/bin/sh
# /usr/sbin/motion.sh — movement started, and there is no card to record to.
clip=/tmp/visit-$(date +%Y%m%d-%H%M%S).mp4

# -f matters: without it curl writes the camera's refusal into the file and
# still exits 0, and the next line happily sends a "clip" that is an error
# message.
curl -sf -o "$clip" 'http://localhost/video.mp4?duration=10' || exit 1
[ -s "$clip" ] || exit 1

/usr/bin/ntfy.sh "$clip"        # or /usr/sbin/telegram "$clip"
rm -f "$clip"
```

Both senders take a file as their argument and send that file, which is how the
clip dispatcher drives them too. `/tmp` is RAM on these cameras — ten seconds at
4 Mbit is about 5 MB — so write the clip there and remove it afterwards.

## Ready-made, without writing anything

Under **Services → Telegram** and **Services → Ntfy** in the web interface,
**Send motion clips** posts the recording itself when movement ends. It needs
recording on motion switched on, and it installs the clip dispatcher for you.

## Checking it works

```sh
curl -s http://<camera>/metrics | grep records_
```

| counter | what it tells you |
|---|---|
| `records_motion_clips_total` | clips closed by an event. Zero, with nothing else moving either, means nothing is triggering — start with `motionDetect.enabled` and `sensitivity` |
| `records_fragments_written_total` | whether anything is being written at all |
| `records_fragments_skipped_total` | climbing by several per event is the keyframe-interval problem linked above |
| `records_preroll_bytes` | what the run-up is holding in RAM right now, and `0` when it is not armed |

`/metrics/motion` reports the detector's own state, and
`/api/v1/analytics` shows the boxes it is drawing right now — poll that while
you wave at the camera to check your region is where you think it is.

If the camera is recording but your script never seems to run, check that the
clip directory is filling up, then that `records.onClose` is still set to your
script: switching clip sending on in the web interface writes the dispatcher
there, but only over an empty setting, and it says so when it declines.
