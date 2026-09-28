# OpenIPC Wiki
[Table of Content](../README.md)

## Playing tunes on the IR-cut filter

Most cameras have no speaker, but nearly all of them have an IR-cut filter: a
small shutter moved by a coil across two GPIO pads (see
[How an IR-cut filter is driven](ircut-filter.md)). Pulse that coil in short
bursts, first one way and then the other, and it clicks; click it a few hundred
times a second and it buzzes at a pitch you choose. That is the trick the 1985
Commodore 1541 "drive music" demo used to play *Daisy Bell* on a floppy drive's
head, and majestic uses it to play tunes.

The camera's own [QR Wi-Fi onboarding](wireless-settings.md#or-show-the-camera-a-qr-code)
uses it to say whether the code worked. This page is about using it from your own
scripts: a sound when something finishes booting, when the network drops, on the
hour, or simply to find out which camera on the roof is which.

### Does my camera do this?

It needs firmware built after
[OpenIPC/firmware#2496](https://github.com/OpenIPC/firmware/pull/2496) and a
filter driven from **two** pads (`nightMode.irCutPin1` and `irCutPin2` both
set). On the camera:

```sh
curl -s http://127.0.0.1/night/chime
```

A camera that can play answers with the list of built-in tunes:

```
{"cues":["scanned","connected","wrongkey","nonetwork","nodhcp","badqr","timeout","daisy"],"busy":false}
```

Older firmware answers a bare `0` and plays nothing.

### Playing something

| request | what happens |
|---|---|
| `/night/chime?cue=daisy` | plays a built-in tune |
| `/night/chime?rtttl=...` | plays any tune written in RTTTL (see below) |
| `/night/chime` | lists the built-in tunes and says whether the filter is `busy` |

A tune that starts answers `{"ms":5991}`, its written length, and plays in the
background. One that cannot start answers with a reason:

| answer | why |
|---|---|
| `409 {"error":"the IR-cut filter is moving"}` | another tune is still playing, or the filter is switching day/night right now |
| `409 ... hourly allowance` | 30 tunes have played in the last hour |
| `409 ... parked` / `... both of its pins` | the filter is switched off (`nightMode.irCut: off`), or wired to one pad |
| `400 {"error":"..."}` | the RTTTL is malformed or too long |
| `404` | no built-in tune by that name |

Requests from the camera itself (`127.0.0.1`) need no password, which is what
makes this usable from scripts. From another machine you log in as usual:

```sh
curl -u root:YOURPASSWORD "http://192.168.1.10/night/chime?cue=daisy"
```

That is handy on its own: with a row of identical cameras on a wall, play a tune
on one and listen for it.

### Limits

These protect the coil. It is built to swing the filter twice a day, not to be
a loudspeaker.

- A tune may last at most **8 seconds**, of which at most **6 seconds** sounds.
  A longer one is refused, not cut short.
- At most **30 tunes an hour**, whoever asks.
- **One at a time.** A second request while one is playing is refused.
- Notes sound between about **130 and 660 Hz** (C3 to E5). A note outside that
  range is moved up or down by whole octaves until it fits, so the tune still
  plays, but a melody that crosses the edge will jump an octave.

While a tune plays the camera is busy. The video stream keeps every frame but
stutters, with gaps of up to about half a second, and slow requests to the web
interface take several times longer. Play tunes when that does not matter.

### A helper script

Save this as `/usr/sbin/chime` and `chmod +x` it. It waits until the filter is
free, plays, and returns when the tune has finished. Calls can then simply
follow one another.

```sh
#!/bin/sh
# chime <cue>          play a built-in cue, e.g. chime connected
# chime -t '<rtttl>'   play a tune in RTTTL
# Waits for the filter to be free before playing and returns once the tune
# has finished, so calls can simply follow one another.
url=http://127.0.0.1/night/chime

wait_free() {
	i=0
	while curl -s "$url" | grep -q '"busy":true' && [ $i -lt 100 ]; do
		sleep 0.2
		i=$((i + 1))
	done
}

case "$1" in
-t) q="rtttl=$(printf '%s' "$2" | sed 's/%/%25/g; s/#/%23/g; s/,/%2C/g; s/:/%3A/g; s/=/%3D/g; s/ /%20/g')" ;;
*) q="cue=$1" ;;
esac

wait_free
r=$(curl -s "$url?$q")
case "$r" in
*'"ms"'*) wait_free ;;
*) echo "chime: ${r:-no answer}" >&2; exit 1 ;;
esac
```

Wait on `busy` rather than sleeping for `ms`. A tune takes a little longer than
its written length, and the filter still has to be put back afterwards. A
script that sleeps exactly `ms` and plays the next tune gets refused.

### Writing tunes: RTTTL

RTTTL is the ringtone format of old Nokia phones: a name, three defaults, and
the notes.

```
Twinkle:d=4,o=4,b=180:c,c,g,g,a,a,2g,f,f,e,e,d,d,2c
```

- `d=4`: a note with no length of its own is a quarter note.
- `o=4`: a note with no octave of its own is in octave 4 (`c` is middle C).
- `b=180`: beats per minute.
- Each note is `[length]letter[#][octave][.]`: `8e5` is an eighth-note E5,
  `4c#.` a dotted quarter C#, and `p` is a rest. The dot may also come straight
  after the length (`2.d`), as many published tunes write it.

Write tunes in octave 4, reaching down to 3 and up to E5, and none of the notes
will be moved. Keep them short, which suits a notification anyway.

### Well-known tunes

All of these are public-domain melodies. Each was played through the helper
above, one after another, on a gk7205v300 camera: every one fits the limits and
played without a refusal.

| tune | RTTTL |
|---|---|
| *Gran Vals* (Tárrega), the Nokia ringtone | `Nokia:d=4,o=4,b=225:8e5,8d5,f#,g#,8c#5,8b,d,e,8b,8a,c#,e,2a` |
| Westminster Quarters (Big Ben) | `Westminster:d=4,o=4,b=200:e,g#,f#,2b3,e,f#,g#,2e,g#,e,f#,2b3,b3,f#,g#,2e` |
| *Ode to Joy* (Beethoven) | `OdeToJoy:d=4,o=4,b=200:e,e,f,g,g,f,e,d,c,c,d,e,e.,8d,2d` |
| *Twinkle, Twinkle, Little Star* | `Twinkle:d=4,o=4,b=180:c,c,g,g,a,a,2g,f,f,e,e,d,d,2c` |
| *Für Elise* (Beethoven) | `FurElise:d=8,o=4,b=140:e5,d#5,e5,d#5,e5,b,d5,c5,4a,p,c,e,a,4b,p,e,g#,b,4c5` |
| *Happy Birthday* | `HappyBirthday:d=4,o=4,b=160:8g.,16g,a,g,c5,2b,8g.,16g,a,g,d5,2c5` |
| *Jingle Bells* | `JingleBells:d=8,o=4,b=180:e,e,4e,e,e,4e,e,g,c.,16d,2e` |
| *Korobeiniki* (the Tetris tune) | `Korobeiniki:d=8,o=4,b=160:4e5,b,c5,4d5,c5,b,4a,a,c5,4e5,d5,c5,4b,b,c5,4d5,4e5,4c5,4a,2a` |
| *In the Hall of the Mountain King* (Grieg) | `MountainKing:d=8,o=4,b=180:a3,b3,c,d,e,c,4e,d#,b3,4d#,d,a#3,4d,a3,b3,c,d,e,c,e,a,g,e,c,e,2g` |
| *Shave and a Haircut* | `ShaveAndAHaircut:d=4,o=4,b=160:c5,8g,8g,g#,g,p,b,c5` |
| "Charge!" | `Charge:d=8,o=4,b=150:c,f,a,4c5,16p,a,2c5` |

Play one with the helper:

```sh
chime -t 'Charge:d=8,o=4,b=150:c,f,a,4c5,16p,a,2c5'
```

The built-in `daisy` is the first phrase of *Daisy Bell*, the tune from the 1985
demo.

### Examples

**A clock that chimes the hour.** Westminster Quarters, then one low note per
hour. The hour is built into a tune on the fly: at twelve o'clock that is still
within the limits.

```sh
#!/bin/sh
# /usr/sbin/cuckoo: Westminster Quarters, then the hour on a low bell.
chime -t 'Westminster:d=4,o=4,b=200:e,g#,f#,2b3,e,f#,g#,2e,g#,e,f#,2b3,b3,f#,g#,2e'
h=$(date +%I)
h=${h#0}
bongs=
for i in $(seq "$h"); do
	bongs="${bongs}e3,p,"
done
chime -t "Hour:d=4,o=3,b=240:${bongs%,}"
```

Run it on the hour with `crontab -e`:

```
0 * * * * /usr/sbin/cuckoo
```

**Say when the camera has finished booting.** In `/etc/rc.local`, before the
final `exit 0`:

```sh
(sleep 30; chime -t 'Charge:d=8,o=4,b=150:c,f,a,4c5,16p,a,2c5') &
```

**Say when the network drops**, once per outage rather than every minute. That
matters because of the hourly allowance:

```sh
#!/bin/sh
# /usr/sbin/netwatch: a sound when the default gateway stops answering.
up=1
while sleep 60; do
	gw=$(ip route | awk '/^default/ {print $3; exit}')
	if [ -n "$gw" ] && ping -c 3 -W 2 "$gw" >/dev/null 2>&1; then
		up=1
	elif [ "$up" = 1 ]; then
		chime nonetwork
		up=0
	fi
done
```

Start it from `/etc/rc.local` with `netwatch &`.

### What you can see from outside

`/metrics` counts what the filter has been asked to do:

| metric | meaning |
|---|---|
| `ircut_chimes_total` | tunes played |
| `ircut_chimes_refused_total` | tunes refused (busy, over the allowance, parked, malformed) |
| `ircut_chime_coil_milliseconds_total` | total time current flowed through the coil while playing |
