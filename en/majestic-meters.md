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

The changes take effect on the next reading, without a restart. Up to **four
meters** are read per camera.

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
```

- `majestic_meter_value`: the reading.
- `majestic_meter_per_hour`: how fast the meter counted between its last two
  readings.
- `majestic_meter_age_seconds`: how long ago it was read. Alert on this
  rather than on the value: if the reading goes stale, something is in the
  way.

A meter that has not been read yet has **no** sample rather than a zero, so a
graph never drops to 0 after a reboot.

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
  that agree on one other number, it starts again from that number.
- **Drums between digits.** A drum spends part of its time rolling between
  two digits, and the reader recognises that half-way position as such. With
  dials, the dial settles which of the two digits the drum is on.

### How well it reads

The drum reader was trained on synthetic drums rendered into real meter faces
at many angles and lighting conditions, and on openly licensed (CC BY 4.0)
meter photographs. It was then tested on real pictures it had never seen:

| Test set | Digits read right |
|---|---:|
| Water meter, daylight, 2 MP camera | 100% of 21 |
| Electricity meter, daylight, 2 MP camera | 100% of 18 |
| The same electricity meter under IR, lamps reflecting on the glass | 58% of 24 |
| Open water-meter photographs, many meter models | 87% of 9,234 |
| Open odometer photographs | 90% of 2,034 |

These are single digits read from single frames. The rules above turn that
into a correct running reading. Over a night of an electricity meter, the
reading over time was right at every checked moment, where single frames
alone got 25 of 54. Over a day of a water meter with dials, the reading went
from 121.848 to 122.047 m³ to the litre, never going backwards.

On a SigmaStar SSC325 camera (a single Cortex-A7, 1080p) reading an
electricity meter every 20 seconds, one drum's thin "9" was misread as "1" in
about half the frames. The settling rule sat that out, and the camera
reported the correct 29864.0 kWh and held it. Reading one drum takes about
2.5 ms of one Cortex-A7 core, so reading meters costs the camera almost
nothing between readings.

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

Alert when the camera stops reading:

```
majestic_meter_age_seconds > 600
```
