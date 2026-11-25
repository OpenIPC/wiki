# OpenIPC Wiki
[Table of Content](../README.md)

Home Assistant over MQTT
------------------------

Majestic can announce the camera to Home Assistant by itself: its lights, motion,
day or night, how bright the scene is, and its microphone and speaker volume
appear as entities of one device, with nothing to write in `configuration.yaml`.
It needs a Lite or Ultimate build of Majestic from 25 November 2026 or later.
No extra package is needed on the camera.

It does not carry video. Add the stream separately, through
[Frigate](howto-frigate-integration.md) or as a
[generic camera](home-assitantant-view.md).

### Setting it up

1. In Home Assistant, install the **Mosquitto broker** add-on and the **MQTT**
   integration, and make a user for the camera to log in as. Any other MQTT broker
   on your network works too, with or without a login.
2. On the camera, fill in the MQTT section under **Settings → Network &
   Integrations**, or write it into `/etc/majestic.yaml`:

```yaml
mqtt:
  enabled: true
  server: 192.168.1.20        # the broker: an address or a name
  port: 1883
  username: USER              # leave both out for a broker with no login
  password: PASSWORD
  #discoveryPrefix: homeassistant   # only if you changed it in Home Assistant
```

Saving applies it at once, and the video is not interrupted. The camera then shows
up under **Settings → Devices & services → MQTT**, named after its hostname.

The password is kept in the clear in `/etc/majestic.yaml`.

### What you get

Each entity is there only on a camera that has it.

| Entity | What it is |
| --- | --- |
| White light | A light you can switch, with `nightMode.whiteLight: manual`, or on a colour night with `auto`. Under the other modes it is a read-only sensor. See [Two lamps](majestic-streamer.md#two-lamps-infrared-and-white) |
| Infrared light | A light you can switch. Dusk and dawn still move it unless `nightMode.backlight` is `manual`. Absent with `backlight: off`, and on a colour night where the white light is the night's own |
| Night mode | Whether the camera is in night mode |
| Motion | While something moves. Needs `motionDetect.enabled`, and goes with it: if Frigate does your detection, leave it off |
| Scene brightness | What the exposure meter sees, 0-255. It is not lux, and it changes with the exposure |
| Microphone volume, Speaker volume | 0-100. Only where the camera applies the level without restarting the video |
| Uptime | Seconds since the camera booted, once a minute. All entities become unavailable when the camera drops off the broker |

States are sent as they change, up to a second late. One light is moved a second at
most, and the last request wins. A volume is saved once it has been left alone for two
seconds, at most 30 times an hour; a change past that waits.

### Who can control the camera

Whoever can publish on the broker can switch the lights and set the volume. Nothing
else can be changed over MQTT. The connection is not encrypted, so keep the broker on
your own network. TLS is not supported.

### Topics

`ID` is the camera's MAC address without colons.

| Topic | Payload |
| --- | --- |
| `openipc/ID/status` | `online` or `offline` |
| `openipc/ID/white/state`, `.../ir/state`, `.../night/state`, `.../motion/state` | `ON` or `OFF` |
| `openipc/ID/white_state/state` | the white light where it cannot be switched |
| `openipc/ID/brightness/state`, `.../mic_volume/state`, `.../speaker_volume/state`, `.../uptime/state` | a number |
| `openipc/ID/white/set`, `openipc/ID/ir/set` | `ON` or `OFF`, to switch it |
| `openipc/ID/mic_volume/set`, `openipc/ID/speaker_volume/set` | `0` to `100` |

A retained command is ignored, so an old one cannot switch a light when the camera
reconnects.

### When it does not work

The camera keeps trying, and its log (`logread`) says once per outage why it is not
connected.

| What the log says | What to check |
| --- | --- |
| The login was refused | `mqtt.username` and `mqtt.password` |
| It cannot connect | The address and port, and that the broker is running |
| Nothing answers | A firewall, or an address on another network |
| The login may not receive commands | The broker's access rules: states arrive, commands do not |

Turning `mqtt.enabled` off, or moving to another broker, removes the device from Home
Assistant. If the camera is not connected at that moment, remove the device there by
hand.
