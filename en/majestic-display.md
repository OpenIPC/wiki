# OpenIPC Wiki
[Table of Content](../README.md)

Video output: HDMI, CVBS and BT.1120 from Majestic
--------------------------------------------------

A camera whose board has a video connector can show its own live picture on a
monitor or a TV while it streams as usual. On many cameras that connector is
HDMI, through an adapter board on development kits. On older SD-class chips it
is often a composite (CVBS) output, and some boards bring out the digital
BT.1120 or BT.656 bus for an external encoder. Majestic drives the connector
from one `display` section.

### It works without settings

```yaml
display:
  enabled: true   # the default
  output: auto    # auto (default) | hdmi | cvbs | bt1120 | bt656
  mode: auto      # auto (default), or a timing from the table below
  sensor: 0       # two-sensor boards only: which camera to show
```

With the defaults, Majestic uses the connector it finds wired on the board. A
camera with no display connector, which is most of them, is not affected: no
memory and no part of the video pipeline is taken.

A connector Majestic cannot detect has to be named. The usual case is a CVBS
jack, which has nothing to detect:

```yaml
display:
  output: cvbs
```

Or through the HTTP API:

```
http://<camera>/api/v1/set?display.output=cvbs
http://<camera>/api/v1/set?display.mode=720p60
```

Changing any `display` key restarts only the display. The picture on the
monitor blanks for a moment. The RTSP, HLS and WebRTC streams, recording and
everything else carry on without a break.

### Keys

| Key | Default | Values |
|---|---|---|
| `display.enabled` | `true` | `false` turns the display off, even on a board where one is wired |
| `display.output` | `auto` | `auto`, `hdmi`, `cvbs`, `bt1120`, `bt656` |
| `display.mode` | `auto` | `auto`, `1080p60`, `1080p50`, `1080p30`, `1080p25`, `1080i60`, `1080i50`, `720p60`, `720p50`, `576p50`, `480p60`, `pal`, `ntsc`, `1024x768`, `1280x1024` |
| `display.sensor` | `0` | `0` or `1`; offered on two-sensor boards only |

`mode: auto` picks the connector's usual timing in the camera's rate family, so
the display neither drops nor repeats frames on a steady beat:
- a sensor running at 25 or 50 fps gets `1080p50` on HDMI and BT.1120, and
  `pal` on CVBS and BT.656;
- any other rate gets `1080p60`, or `ntsc`.

Name a mode when the monitor does not take 1080p, or to match a TV:
- **CVBS** carries `pal` or `ntsc` and nothing else.
- **HDMI and BT.1120** have no analogue timing. For standard definition they
  take `576p50` or `480p60`.
- Anything else is refused, and the reason is written to the log.

Majestic does not read the monitor's capabilities (EDID). If the screen stays
blank, try `720p60` before anything else.

### Where it is offered

What each chip's video output can drive, from the chip vendor's documentation:

| Chip | Connectors |
|---|---|
| Hi3516A / Hi3516D V100 | BT.1120, CVBS, BT.656 |
| Hi3519V101 / Hi3516AV200 | BT.1120, CVBS, BT.656 |
| Hi3518EV200 / Hi3516CV200 | BT.656 |
| Hi3516CV500 | BT.1120, BT.656 |
| Hi3516DV300 | BT.1120, BT.656. Its own HDMI output is not supported yet |
| GK7205V200 / V300, GK7205V500 | BT.1120, BT.656 |
| Hi3519DV500 / Hi3516DV500 | BT.1120, BT.656, and HDMI through a bridge (below) |

Not offered:
- **Hi3516CV300**, although the chip has CVBS;
- **Hi3516EV200 / EV300**;
- **Hi3516CV610 / CV608**, which have no video output at all;
- the other chip vendors.

On those builds the `display` section is refused: a file may still carry it,
but a write to it is rejected. So a build without the feature rejects
`http://<camera>/api/v1/set?display.mode=720p60`.

`hdmi` on a chip without HDMI of its own means a bridge chip that turns BT.1120
into HDMI. A connector the chip does not have is refused with a log line saying
so.

### HDMI on the Hi3519DV500 demo kits

The Hi3519DV500 / Hi3516DV500 demo kits come with an HDMI adapter board, a
Lontium LT8618SXB bridge. The firmware looks for it at every boot and prepares
the video output only when it answers. So a camera without the adapter boots
exactly as before, and with it Majestic shows the picture on HDMI at 1080p60
with no settings at all.

The firmware's choice can be overridden in the U-Boot environment:

```
fw_setenv vo_intf bt1120    # prepare BT.1120 even when nothing was detected
fw_setenv vo_intf none      # no video output, even with the adapter fitted
fw_setenv vo_intf           # back to detection
```

It takes effect at the next boot.

The bridge has no PAL, NTSC or interlaced SD timings. Use `576p50` or `480p60`
for standard definition.

Don't plug the adapter or a sensor board in or out while the board is powered.
Power off first, then boot again so the adapter is detected.

### Two-sensor boards

On a board with two sensors, `display.sensor: 1` shows the second camera. The
picture is scaled to the display's timing. Both streams carry on as before.

### Limits

- **Verified so far:** HDMI through the bridge on a Hi3519DV500 kit with an
  OS04A10 and an OS08A20, at 1080p60 and 720p60, showing either sensor. The
  output was measured at the bridge.
- **Not verified on hardware:** CVBS (Hi3516A, Hi3519V101) and the other
  chips. Their outputs are built the same way, but their pictures were not
  checked.
- **Rotation is not applied.** The display shows the sensor's own orientation.
  Mirror and flip are followed.
- **LCD panels and MIPI DSI screens are not offered.** Each needs its panel's
  own timing and start-up sequence.
- **No overlays on the display.** The timestamp, the other text overlays and
  the **privacy masks** are drawn on the streams only. The display shows the
  sensor's whole picture, so a masked area **is visible on the monitor**.
  Switch the display off (`display.enabled: false`) on a camera whose masks
  must hold everywhere.
