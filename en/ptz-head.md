# OpenIPC Wiki
[Table of Content](../README.md)

A pan/tilt head beside the lens, on a wire or over the network
--------------------------------------------------------------

Some cameras have two motors on two wires: a zoom/focus lens, and a pan/tilt base (a "head") under it. majestic drives both. Pan and tilt go to the head, and zoom and focus go to the lens, one move at a time as if they were on a single wire. The **Live** page shows one pad for both, and ONVIF and the `/ptz` endpoint reach both.

This page covers:
- how to name the head;
- where it is wired: the lens's serial port, a serial port of its own, or a serial gateway on the network;
- what to check when it doesn't move.

It needs [majestic-af](https://github.com/OpenIPC/majestic-af), the motor plugin. A head on its own port (`ptz.headPort`) needs majestic-af from November 2026 or later ([majestic-af#52](https://github.com/OpenIPC/majestic-af/pull/52)).

### Which cameras

| Camera | Lens | Head |
|---|---|---|
| XiongMai HI3516D_N81820 speed dome | MS41908M stepper on SPI (`ms41908`) | Pelco-D on UART1, CN2 pins 3/4 |
| XiongMai JZC-N51813L zoom block (Hi3518CV100) | Sony VISCA on its own MCU on UART0 (`visca`) | none built in; a Pelco-D base on UART1, or one on the network |

Today the head is always Pelco-D: `ptz.head: pelco-d`.

### The keys

| Key | Meaning |
|---|---|
| `ptz.actuator` | The lens: `ms41908`, `visca`, … |
| `ptz.head` | The head's protocol: `pelco-d`, or `none` (the default: one motor, driven exactly as before). |
| `ptz.port` | The serial port. It is the lens's when the lens is serial (`visca`), otherwise the head's. |
| `ptz.headPort` | The head's own port, when the lens has `ptz.port`: another tty such as `/dev/ttyAMA1`, or `tcp://<ip>:<port>` for a serial gateway. Empty (the default): the head uses `ptz.port`. |
| `ptz.baud` | The serial speed of `ptz.port`. |
| `ptz.headBaud` | The speed of a `headPort` that is a tty, when it differs from the lens's (a VISCA block at 9600, a Pelco-D base at 2400). 0 (the default): `ptz.baud`. |
| `ptz.address` | The head's Pelco-D address, as set on its DIP switches. Default 1. |
| `ptz.rs485Pin` | The GPIO that turns an RS-485 transceiver round, on a board that has one (high while a frame goes out). -1 (the default): a plain serial line. |
| `ptz.panInvert`, `ptz.tiltInvert` | For a head mounted so that the arrows move it the wrong way. |

The WebUI draws the pad only when the U-Boot variable `ptz_control` names the lens: `fw_setenv ptz_control ms41908` or `fw_setenv ptz_control visca`. Set it once on a camera that doesn't have it, then reload the Live page. The web interface knows `visca` from November 2026; an older one draws no pad for it.

### A head on the lens's serial port

Use this when the lens is not on a serial line. For example, the N81820's lens is on SPI and its base is on UART1:

```yaml
ptz:
  enabled: true
  actuator: ms41908      # the lens: zoom, focus, autofocus
  head: pelco-d          # the base: pan and tilt
  port: /dev/ttyAMA1     # the head's serial line
  baud: 9600
  address: 1
```

### A head on a serial port of its own

The N51813L's lens MCU speaks VISCA on `ptz.port` (UART0), so a head can't share that wire. Give it its own port:

```yaml
ptz:
  enabled: true
  actuator: visca
  port: /dev/ttyAMA0     # the lens
  baud: 9600
  head: pelco-d
  headPort: /dev/ttyAMA1 # the head
  headBaud: 2400
  address: 1
```

A `headPort` that names `ptz.port` again isn't a port of its own. majestic refuses the head then.

> **The "485" port on these XiongMai modules is not RS-485.** CN2 pins 3/4 on the N81820 and the N51813L are the SoC's UART1 at 3.3 V TTL, with no transceiver on the board. The module manual says as much: "TTL串口 (原来的485接口)", a TTL serial port that used to be a 485 one. A TTL Pelco base works straight off them. An RS-485 base needs a 3.3 V TTL↔RS-485 module between CN2 and the A/B pair, of the auto-direction kind (MAX3485 / SP3485 class, e.g. XY-K485). Wiring CN2 straight onto an RS-485 pair does nothing, and can damage the pins.

### A head on the network

The base doesn't have to be wired to the camera at all. Put its RS-485 pair on any machine with a serial port: a single-board computer with a USB-RS485 adapter, or a ready-made serial server. Have that machine copy a TCP connection onto the pair, and point the camera at it:

```yaml
ptz:
  enabled: true
  actuator: visca
  port: /dev/ttyAMA0
  baud: 9600
  head: pelco-d
  headPort: tcp://192.168.1.20:4001
  address: 1
```

On the gateway, `socat` is all it takes. Set the speed the base expects:

```sh
socat TCP-LISTEN:4001,reuseaddr,fork,range=192.168.1.10/32 \
  FILE:/dev/ttyUSB0,raw,echo=0,b9600,cs8,clocal=1,cstopb=0,parenb=0
```

`range=` lets only the camera (here 192.168.1.10) connect. Without it, anyone who can reach the port can turn the head.

How the camera treats the connection:
- **The address is an IP, not a name.** `tcp://gateway.lan:4001` is refused; write the gateway's IP address.
- **The line speed and the RS-485 turnaround are the gateway's.** `headBaud` and `rs485Pin` don't apply over TCP.
- **A gateway that restarts** closes the connection. The camera connects again for the next frame and sends it there.
- **A gateway that vanishes without closing** (power, cable) is noticed within about 2 s, and the next frame reconnects. A frame sent in the moment before that may be lost: TCP only confirms that the bytes left the camera, not that the base got them.
- **A gateway that isn't there** is tried again at most every 2 s, with 300 ms for each try, so the lens and the stream don't wait on it. majestic says once in its log that it can't reach the gateway, and once when it does again.
- **Saving the PTZ settings** reconnects at once.

Pelco-D bases don't answer, so nothing comes back down the connection. Anything that does is read and dropped.

### Checking it

`GET /ptz` is the capability line:

```
actuator=visca port=/dev/ttyAMA0 speed=9600 addr=1 pulse=500 state=ready
verbs=stop,near,far,tele,wide,up,down,left,right,upleft,upright,downleft,downright
speeds=1-100 presets=1-32 head=pelco-d headstate=ready
headport=tcp://192.168.1.20:4001 headaddr=1
```

(It is one line; it is wrapped here.)
- **`head=`** names the head's protocol, and **`headstate=`** says whether it is `ready` or `closed`.
- **`headport=`** and **`headaddr=`** appear when the head is on its own port. While it is closed, `headport=` says where it will be connected.
- **`verbs=`** lists the head's verbs once it is open. The WebUI draws pan and tilt only for the verbs listed here. A VISCA block with no head gets zoom and focus buttons only.

To move it from a shell on the camera:

```sh
curl -X POST 'http://127.0.0.1/ptz?move=left&ms=2000&speed=60'   # pan left for 2 s at 60 %
curl -X POST 'http://127.0.0.1/ptz?move=stop'
```

### Troubleshooting

**`headstate=closed`, and majestic's log says it can't reach the gateway.** Nothing accepts the connection on the gateway's port. Start `socat`, and check that its `range=` covers the camera's address. The camera connects on its own within 2 s once it can.

**The capability line has no `head=` at all, though `ptz.head` is set.** majestic didn't take the head, and its log says why. Beside a serial lens such as `visca`, the usual reason is that `ptz.headPort` is empty or names `ptz.port` again: set it to the head's own port. If it is set and the head is still missing, the firmware predates `headPort`: update it.

**`headstate=ready`, but the head doesn't move.** Test the gateway alone. Send a Pelco-D frame from the camera's shell (or from any machine that `range=` lets in). `-w 1` makes `nc` hang up a second after the frame, so the stop is never left waiting behind it:

```sh
printf '\xff\x01\x00\x04\x20\x00\x25' | nc -w 1 192.168.1.20 4001   # address 1, pan left
printf '\xff\x01\x00\x00\x00\x00\x01' | nc -w 1 192.168.1.20 4001   # stop
```

If the first command is interrupted, run the stop line anyway: a Pelco-D head keeps turning until it gets one.

If the head doesn't move, look at the gateway's side:
- the speed (`b9600` against the base's DIP switches);
- the address (`ptz.address`);
- A and B swapped on the pair.

**The pad has no pan and tilt buttons.**
- **The head isn't open:** check `headstate=` on the capability line.
- **No pad at all:** `ptz_control` is unset. The WebUI shows no PTZ pad without it.
- **`ptz_caps` is set** and leaves out `pan` or `tilt`. The pad draws only the axes it names. Unset it (`fw_unsetenv ptz_caps`), or name all of them.
- **The WebUI predates `visca`:** older web interfaces don't draw the pad for `visca` at all. Update the firmware.

See also [Motor control](motors.md), [Pan and tilt from the Live page](ptz-live.md) and [Autofocus and manual focus](autofocus.md).
