# OpenIPC Wiki
[Table of Content](../README.md)

Reading utility meters with Majestic
------------------------------------

Point a camera at a water, gas or electricity meter, tell Majestic where the
meter's number is, and the camera reports the **reading** instead of a
picture of it. The reading appears as Prometheus metrics on `/metrics` and as
JSON on `/api/v1/meters`, refreshed every minute by default. Any monitoring
system that already scrapes the camera can then chart consumption or raise an
alarm on a leak.

The camera reads two kinds of display:

- **Mechanical drum counters** (the rolling digits of an odometer). Water
  meters, membrane gas meters and older induction electricity meters use them.
  Each drum is read by a small neural network that runs on the camera's own
  CPU, so nothing leaves the camera and no cloud service is involved.
- **Red pointer dials**, the small clock-like dials many water meters have
  for litres. These are read from the needle's direction and give the reading
  digits beyond the last drum.

Electronic LCD displays and LED pulse counting are not supported yet.

### What you need

- **A supported camera.** The reader takes uncompressed frames from the main
  stream, which HiSilicon and SigmaStar cameras can hand over. On other
  cameras the meter shows the state *this camera cannot hand over a frame*.
- **A Majestic build that reads meters.** On one that does not, the WebUI
  has no **Meters** section under **Events**, and `meters` settings in
  `/etc/majestic.yaml` are ignored.
- **The drum model file**, `/usr/share/majestic/drum.qnet` by default. It is
  shipped in the firmware together with a Majestic that reads meters. If the
  file is missing, the camera logs that it cannot load the model and the
  meter stays *not read yet*.
- **Light on the meter.** The camera reads what it sees. A meter in a dark
  cupboard needs either the camera's IR lamps or a light (see
  [Placing the camera](#placing-the-camera)).
- **A sharp, reasonably large view of the digits.** As a guide, each digit
  should be at least about 15 pixels tall in the main stream. The meter does
  not have to be square to the camera; tilted and rotated views are fine.

### Setting it up

The settings are in the WebUI under **Events → Meters**, or in
`/etc/majestic.yaml`:

```yaml
meters:
  enabled: true
  model: /usr/share/majestic/drum.qnet
  interval: 60                  # seconds between readings, 5 to 3600
  list:
  - name: power
    window: 670,62,900,120,885,180,657,110
    drums: 7
    decimals: 1
    unit: kWh
    maxPerHour: 15
  - name: cold
    window: 619,333,809,329,809,358,620,362
    drums: 8
    decimals: 3
    unit: m3
    maxPerHour: 1.5
    dial1: 0.0001,860,440,30    # x0.0001: tenths of a litre
```

Changes made in the WebUI or through the API take effect on the next
reading, with no restart, and a meter whose own row is unchanged keeps its
history. After editing `/etc/majestic.yaml` by hand, make Majestic re-read it
with `killall -HUP majestic`; that briefly restarts the video as well. Up to
**four meters** are read per camera.

| Key | Required | Meaning |
|---|---|---|
| `name` | yes | What the metrics and the API call the meter: up to 31 letters, digits, `.`, `_` or `-` |
| `window` | yes | The four corners of the window the drums show through, as `x,y` pairs (see below) |
| `drums` | yes | How many drums the window holds, the decimal ones included (1 to 10) |
| `decimals` | no, `0` | How many of those drums are after the decimal point |
| `unit` | no, `m3` | `m3`, `kWh` or `Gcal` |
| `maxPerHour` | yes | The most the meter can possibly count in an hour, in its unit |
| `typicalPerHour` | no | What it usually counts in an hour. It defaults to a tenth of `maxPerHour` |
| `dial1`..`dial4` | no | One red pointer dial each: `multiplier,x,y,radius` (see below) |

#### Marking the drum window

`window` is the four corners of the window the digits show through, given
**clockwise starting from the top left of the digits as you read them**:
top left, top right, bottom right, bottom left. The coordinates are in
pixels of the **main stream** (`video0.size`). If the meter is upside down
in the picture, its "top left" is at the bottom right of the image, and
you start from there.

Draw the box around the whole row of drums, edge to edge, including the
thin dividers between them. The camera splits the box into `drums` equal
cells, one per drum, so the box should not include the "m³" label or
anything else beside the row.

To get the coordinates, grab one full-size frame of the main stream and open
it in any image editor that shows the cursor position:

```sh
ffmpeg -rtsp_transport tcp -i rtsp://<user>:<password>@<camera>/stream=0 -frames:v 1 frame.png
```

A few pixels of error in the corners does no harm; the reader was trained to
tolerate a hand-placed box.

#### `maxPerHour`: the meter's speed limit

This is how the camera tells a misread from real consumption, so set it to
what the meter could really do, not what you expect. Some typical values:

| Meter | `maxPerHour` |
|---|---|
| Household water meter (DN15) | `1.5` to `3` m3 |
| Gas meter G4 | `6` m3 |
| Household electricity, 60 A single phase | `15` kWh |

#### Red dials

Each dial is written as its **multiplier**, then its centre and its radius
in main-stream pixels. The multiplier is the number printed on the dial's
face (×0.1, ×0.01, ×0.001, ×0.0001). It is what one step of the needle, from
one numeral to the next, counts in the meter's unit, so one full turn counts
ten times that.

For example, take a water meter whose drums read whole m³ (`decimals: 0`)
and that has four dials:

```yaml
    drums: 5
    decimals: 0
    unit: m3
    dial1: 0.1,412,300,28       # x0.1: tenths of a m3
    dial2: 0.01,470,342,28      # x0.01
    dial3: 0.001,452,410,28     # x0.001: litres
    dial4: 0.0001,390,430,28    # x0.0001: tenths of a litre
```

Give the radius of the dial's printed scale, out to the numerals. The camera
finds the hub inside it by itself, so the centre does not have to be exact.

The dials add finer digits to the reading only when the coarsest one steps
in **tenths of the last drum**: ×0.1 when the drums end at whole m³, ×0.0001
when the last red drum counts litres (`decimals: 3`). Each further dial
should be ten times finer than the one above it. Without that coarsest dial,
the reading keeps the drums' resolution, and each dial's needle is still
reported in the API.

### What it reports

On `/metrics`:

```
majestic_meter_value{meter="cold",unit="m3"} 301.676450
majestic_meter_per_hour{meter="cold",unit="m3"} 0.000355
majestic_meter_age_seconds{meter="cold"} 12
majestic_meter_state{meter="cold"} 0
majestic_meter_view_match{meter="cold"} 0.941
majestic_meter_margin{meter="cold"} 3.912
majestic_meter_followed_pixels{meter="cold",axis="x"} 0
majestic_meter_followed_pixels{meter="cold",axis="y"} 0
majestic_meter_readings_total{meter="cold"} 1440
majestic_meter_history_restarts_total{meter="cold"} 0
```

- `majestic_meter_value`: the reading.
- `majestic_meter_per_hour`: how fast the meter counted between its last two
  readings.
- `majestic_meter_age_seconds`: how long ago it was read. Alert on this
  rather than on the value: if the reading goes stale, something is in the
  way.
- `majestic_meter_state`: what the meter is doing.

  | Value | Meaning |
  |---|---|
  | 0 | Reading |
  | 1 | Settling |
  | 2 | The window looks different, and is being checked again |
  | 3 | The view moved |
  | 4 | The window no longer shows the meter |
  | 5 | Nothing legible in the window |
  | 6 | Anything else, such as not read yet or no frame |

  It is there for every meter, before its first reading too, as are
  `majestic_meter_followed_pixels`, `majestic_meter_readings_total` and
  `majestic_meter_history_restarts_total`.
- `majestic_meter_view_match` and `majestic_meter_margin`: as `viewMatch`
  and `margin` in the API below.
- `majestic_meter_followed_pixels`: how far the window has followed a camera
  that moved.
- `majestic_meter_readings_total`: readings taken since Majestic started.
- `majestic_meter_history_restarts_total`: how many times the camera started
  again from a new number (see below). On a healthy meter this stays at or
  near zero, so it is worth graphing.

A meter that has not been read yet has **no** `majestic_meter_value`,
`majestic_meter_per_hour`, `majestic_meter_age_seconds` or
`majestic_meter_margin` sample rather than a zero, so a graph never drops to
0 after a reboot.

`GET /api/v1/meters` needs the same login as the rest of the API and gives
the detail:

```json
{
  "enabled": true,
  "meters": [
    {
      "name": "power",
      "unit": "kWh",
      "value": 29864.0,
      "drums": "0298640",
      "dialsRead": false,
      "perHour": 0.21,
      "margin": 3.9,
      "at": 1792154400,
      "age": 12
    }
  ]
}
```

| Field | Meaning |
|---|---|
| `value` | The reading. It is given to the meter's resolution, plus four more decimals when the dials add them |
| `drums` | Every drum as read, without the decimal point. A trailing `.5` means the last drum was half way between two digits |
| `dialsRead` | Whether the dials' fraction is included in `value` |
| `dials` | One entry per configured dial: its `multiplier`, the `needle` position (0 to 10) and the `clarity` of the needle |
| `perHour` | As in the metrics |
| `margin` | How far this reading came ahead of the next most likely one. The higher, the surer; a margin that stays near 0 means the view is poor |
| `viewMatch` | How alike the window is to what it showed when the meter settled: about 1 the same, near 0 nothing like it (see [If the camera moves](#if-the-camera-moves)) |
| `followed` | Present once the window has followed a moved camera: how far, as `[x, y]` pixels at the window's centre, from where it was marked |
| `at`, `age` | When it was read (Unix time), and how long ago in seconds |
| `state` | Present only while there is no fresh reading, and says why |

The `state` values you may see:

| `state` | Meaning |
|---|---|
| `not read yet` | Waiting for the first reading. If this persists, check the model file |
| `settling: read 0298640` | The first readings have not agreed yet (see below) |
| `nothing legible in the window` | Too dark, no contrast, or something in front of the meter |
| `the window is degenerate` | The four corners do not make a usable box |
| `another capture is in progress` | A snapshot was being taken at the same moment; the camera retries next time |
| `this camera cannot hand over a frame` | The camera's SoC is not supported |
| `the window looks different: checking again` | One reading did not look like the meter; the next one decides |
| `the window looks different: trying where the view went` | The meter was found nearby; the next reading checks whether the window can follow it there |
| `the view moved: the drums are -192,-29 px from the window; mark it again` | The camera has moved; the drums are now that many pixels from where the window was marked (right and down are positive) |
| `... they read another count there; mark it again` | Something like the meter was found nearby, but its drums do not read this meter's count (a mirrored picture, a look-alike), so the window did not follow it |
| `the window no longer shows the meter; mark it again` | The window shows something else entirely: the camera was turned or taken down, or the meter is covered |

### On the video

The reading can also be drawn over the picture, for a demo or a camera on a
public wall: the digit the camera read above each drum, and the value
underneath. It is an ordinary OSD overlay, set up and switched off on the
camera's OSD settings like the clock. It is burnt into the video, so
whoever sees the video sees the meter.

Use an overlay whose template starts with `%{drums:power}` (the name of the
meter, or `%{drums}` for the first one). Any text after it becomes a caption
under the value. The extra overlays are numbered 1 to 7 under
`osd.overlays`, next to the clock's own `osd.template`, and like the clock
they need the OSD switched on with `osd.enabled`:

```yaml
osd:
  enabled: true
  overlays:
    2:
      template: "%{drums:power} read by the camera itself"
      meterOutline: always
      meterDigits: confidence
```

What it draws:

- **A digit above each drum**, as the camera read it. With
  `meterDigits: confidence` (the default) it is green when the drum was read
  clearly, amber when the camera was unsure or the drum was half way
  between two digits, and grey before the first reading. `plain` draws
  them all white, and `off` leaves them out.
- **An outline** around the area the camera watches to notice that it has
  been moved: the drum window with a margin round it. It is green while the
  meter is read, grey while it settles, and red while the window no longer
  shows the meter. `meterOutline: always` (the default) draws it all the
  time, `alert` only while the meter is out of view, and `off` never.
  Nothing is drawn inside it, so the camera never reads its own overlay.
- **The value** under the outline, or what the meter is doing instead
  ("settling", "the view moved"), then the caption.

The overlay's other settings apply as usual: an empty template removes it,
`size` scales the digits and the text, `font` changes the typeface, and
`video0.osd`, `video1.osd` and `jpeg.osd` choose the streams that carry it.
Its position follows the meter, so the anchor and offsets do not move it.
If you mark the meter's window again somewhere else, the overlay moves
there the next time the OSD settings are saved, or the camera restarts.

To put only the number in a line of text, use `%{meter}` (the first meter)
or `%{meter:power}` in any overlay's template, next to the usual date and
time codes:

```yaml
osd:
  enabled: true
  overlays:
    3:
      template: "%{meter:power}"
```

This prints `29904.4 kWh`, or a dash per digit (`------.- kWh`) before the
first reading.

Drawing the digits over the drums is available on SigmaStar cameras. On
other cameras a `%{drums}` overlay prints the value as text instead.

### How a reading is made, and why you can trust it

A meter only ever counts forward, and only as fast as it can. The camera
holds every reading to those two rules, so one bad frame never becomes a bad
number:

- **Three frames per reading.** The camera takes three frames a third of a
  second apart and combines what each one saw. A reflection or a moment of
  noise in one frame is outvoted.
- **The whole number at once.** The drums are read together as one number. A
  drum only rolls over when every drum below it shows 9, so a combination
  that a real odometer cannot show is never reported.
- **Settling.** After a start or a change of settings, a meter reports
  nothing until two readings in a row agree (`state: settling`). Otherwise a
  first misread would become the reference for everything after it.
- **Never backwards, never too fast.** Once settled, a reading that would go
  down, or climb faster than `maxPerHour`, is treated as a misread, and the
  last good reading stands. The camera also distrusts climbs faster than
  `typicalPerHour`, without rejecting them.
- **Recovery.** If the meter is replaced, or the history was started on a
  wrong number, the camera does not stay stuck. After five readings in a row
  that agree on one other number, it starts again from that number. The same
  applies when only the last drum disagrees, for example when the reading
  has fallen behind the meter.
- **Carries.** When a meter rolls over, say from 29899.9 to 29900.0,
  several drums turn at once and a slow meter can take many minutes over it.
  While a drum is between digits it may be read as either of them, or as
  neither: a 1 turning into a 2 shows the foot of the 1 under the head of
  the 2, which can look like a 7.
  - Neither sends the reading backwards or makes it jump. While a carry
    may be under way, the reading stays at the last good number and moves
    on once the drums have turned.
  - The camera goes on reading every round meanwhile, so
    `majestic_meter_age_seconds` stays fresh.
  - If the drums keep showing another number for more than an hour, the
    camera starts again from it, as under **Recovery**. So a meter that
    really has stopped at a round number under a wrong reading still gets
    its number back.
  - Each time the camera starts again from a new number, it writes the old
    and new numbers to its log, and the count shows up as
    `majestic_meter_history_restarts_total` on `/metrics`.
- **Drums between digits.** A drum spends part of its time rolling between
  two digits, and the reader recognises that half-way position as such. With
  dials, the dial settles which of the two digits the drum is on.

### If the camera moves

The window stays where it was marked. If the camera is knocked, turned or
taken down, the window covers something else, and the camera would happily
read digits into plastic, a label or the wall. Left alone, a misread that
every frame repeats would after five readings become the meter's history.

So once a meter has settled, the camera remembers what the window and the
meter face around it looked like. Every reading starts by checking the
picture against that:

- **The picture is where the window is:** the reading goes ahead.
- **It is found nearby, somewhere else** (up to about four drums to either
  side, or a window's height up or down): the camera reports
  `the view moved` and by how many pixels.
- **It is nowhere near:** the camera reports that the window no longer shows
  the meter.

One odd reading is held back and reported as *checking again*; two in a row
are reported as above. While the camera says so, it reads nothing: the last
good reading stays, and its age keeps growing, so an alert on
`majestic_meter_age_seconds` fires.

**A camera turned a little needs no new marking.** When the meter is found
nearby, the next reading also looks through a window placed where it went.
If the meter's face is there and its drums read a count this meter could
have reached (no lower than its last reading, no higher than `maxPerHour`
allows since), the window follows the camera there and reading carries on,
usually within half a minute. The API's `followed` says by how much. Both
checks are needed: a mirrored picture still looks like the meter, but its
digits read backwards, so it is not followed.

Otherwise, **mark the window again** where the drums are now (any change to
the meter's window starts afresh), or put the camera back, and reading
resumes on its own.

A change of exposure or gain does not count as a different picture, and
neither do the drums turning as the meter counts. The same meter under IR at
night can look quite different from daylight, though. The camera tells this
apart: if the picture looks different but the drums still read the count it
already holds, it is the same meter in other light, and the camera learns
that look as well. A moved camera's drums never read the right count.

**Across restarts.** What the window looked like and the meter's last count
are both kept on the camera. A restarted camera takes the count back, so it
reads from its first round, checks a camera moved while it was switched off
(and follows it, as above), and learns other light at once. The count is
kept when the meter settles and then about hourly, and is trusted only once
the camera's clock has been set: a count older than 90 days, or stamped
before the clock was set, is not used, and the meter settles afresh.

**Measured:**
- On a SigmaStar SSC325 camera restarted with its window marked 60 px left
  and 12 px up of the drums, the window followed them (by 63 and 11 px) and
  the meter read again 30 seconds after the start. Mirrored, the same camera
  tried the window where the mirror put the drums and refused it every time.
- A still camera's readable frames over a day and a night all matched (0.53
  and up).
- A camera taken off its meter and pointed at the room never matched above
  0.03.
- A camera whose view had shifted by 192 px was found 197 px away.
- On a SigmaStar SSC325 camera, mirroring the picture was caught in two
  readings, both while it ran and after a restart. The camera settled again
  as soon as the mirror was turned off.

### How well it reads

**How it was measured.** Each figure is the share of single drums read right
from single pictures the reader had never seen, against the digit a person
read off the same picture. The first three rows are crops from recorded
snapshots of real meters, taken across several days
and lit as found. The last two are the test splits of two public photo
collections on Roboflow Universe (CC BY 4.0), water meters of many makes and
car-style odometers, which hold drums of every digit at every stage of a
roll.

| Test set | Digits read right |
|---|---:|
| Water meter, daylight | 100% of 21 |
| Electricity meter, daylight | 100% of 18 |
| The same electricity meter under IR, lamps reflecting on the glass | 58% of 24 |
| Public water-meter photographs, many meter models | 87% of 9,234 |
| Public odometer photographs | 90% of 2,034 |

A meter's reading is better than these single digits, because the rules
above hold it to what a meter can do. Two runs show this:

- **Recorded water-meter snapshots, read offline with the same rules.** Over
  one day, the water meter's snapshots, dials included, gave a reading that
  went from 121.848 to 122.047 m³ to the litre and never went backwards.
- **Live, on a camera.** A SigmaStar SSC325 camera (a single Cortex-A7,
  1080p main stream) read an electricity meter every 20 seconds. One drum's
  thin "9" read as "1" in about half the frames. The settling rule sat that
  out: the camera reported 29864.0 kWh, which is what the drums showed, held
  it, and its `margin` grew from 0.5 to 3.9 over two minutes.

Reading one drum takes about 2.5 ms of one Cortex-A7 core, so meters cost
the camera almost nothing between readings.

### Placing the camera

- **Avoid the IR reflection.** The IR lamps beside the lens reflect in the
  meter's glass. Square on, the reflection lands right on the drums and makes
  them unreadable at night. Tilt the camera **15 to 20 degrees** off the
  glass so that the reflection falls outside the drum window. Read that way,
  IR works as well as daylight.
- **Fill the frame sensibly.** The digits need to be legible. Being closer,
  or using the zoom, beats a wide view.
- **Mind the fixed glare.** A lamp or window that reflects on the glass at a
  fixed spot is worse than a passing one. Move the camera until the drum
  window is clear in the live view.
- **Check `margin` after setting up.** A meter whose margin stays low is
  telling you that the view is poor. A sharper or closer view raises it.

### Integration examples

Chart the hourly consumption in Grafana from Prometheus:

```
delta(majestic_meter_value{meter="cold"}[1h])
```

Alert on a likely leak: water kept running through the quiet hours of the
night. This example checks at 05:00 UTC whether more than 2 litres went
through in the four hours before:

```
delta(majestic_meter_value{meter="cold"}[4h]) > 0.002 and on() hour() == 5
```

Alert when the camera stops reading. The second line catches a meter that
has never been read at all, which has no sample to be old:

```
majestic_meter_age_seconds > 600
absent(majestic_meter_age_seconds{meter="cold"})
```
