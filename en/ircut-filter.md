# OpenIPC Wiki
[Table of Content](../README.md)

## How an IR-cut filter is driven

The IR-cut filter is a small glass shutter in front of the sensor. Daylight needs
it **closed**, or infrared reaches the sensor through the Bayer dyes and every
colour goes pink. Night needs it **open**, or the infrared illuminator is wasted
on a filter that blocks the very light it emits.

Getting this wrong is unusually quiet. The camera streams, records, answers ONVIF
and reports healthy counters the whole time; the only symptom is the picture, and
the picture only tells you at the wrong time of day. The commonest fault is not a
wrong value but a **missing** one — with no `nightMode.irCutPin1` majestic never
drives the filter at all, so it stays wherever it powered up.

This article is the hardware half. For the settings, see
[Majestic example config](majestic-config.md); for the pin numbers other people
have found, [Board specific GPIO settings list](gpio-settings.md).

---

### It takes two pads, not one

The filter is moved by an H-bridge across **two** GPIO pads. No single-pad
operation actuates it. Measured on a XiongMai 85H50AI (Hi3516EV300, pads 11 and
10), every state one pad can reach:

| what you do | what the filter does |
|---|---|
| float either pad | **opens** — the brake is released |
| drive both pads low | **holds** its position, drawing no current |
| pad A high, pad B low | moves one way |
| pad B high, pad A low | moves the other way |

So `irCutPin1` and `irCutPin2` are not two independent switches, and pulsing one
of them on its own proves nothing. They are the two ends of one bridge, and the
direction of travel is decided by *which* of them is driven high while the other
is held low.

### Two kinds of filter, and telling them apart

**Latching (bistable).** A pulse moves it and it stays where it was put. The pads
can be released afterwards and the filter holds.

**Brake-held.** Driving both pads low is a brake that holds the position; letting
the pads float releases the brake and the filter springs open. The 85H50AI is
this kind. On such a board majestic must keep both pads exported and driven for
the day position to survive — so if you see it holding GPIOs it is not leaking
them, it is holding the filter shut.

You can tell which you have in one step: close the filter, then release both pads
to inputs and look at the picture. If it goes pink, the filter is brake-held. If
it stays correct, it latches. The WebUI does exactly this as part of its pin scan
and reports the answer.

### The metrics do not read the way you expect

```
night_enabled 0     # majestic is in DAY mode
ircut_enabled 0     # the filter is CLOSED  (correct colour in daylight)
ircut_enabled 1     # the filter is OPEN    (pink in daylight)
```

**`ircut_enabled` is 1 when the filter is out of the light path**, not when the
filter is "on". It tracks the night position. Verified by toggling
`/night/ircut` in daylight and watching the picture: `0` gives normal colour, `1`
gives magenta.

`night_enabled` and `ircut_enabled` should agree — `0/0` is day with the filter
closed, `1/1` is night with it open. A camera sitting at `night_enabled 0` and
`ircut_enabled 1` in daylight is showing you the pink picture and saying so.

Note that a majestic build that does not publish these gauges omits them
entirely. An absent gauge is not a zero: "no day/night state reported" and "day
with the filter closed" are different answers, and anything reading `/metrics`
should distinguish them.

---

### Setting it up

Since the Day / Night rebuild, the WebUI does most of this for you. On
**Settings → Day / Night** you get a map of the camera's GPIO pads (built from
what the kernel reports, so it is the right size on every SoC) with four things
to connect: the filter's closing coil, its opening coil, the infrared lamp and
the daylight sensor. Click a pad, pick what it is.

Two buttons matter:

- **Find them for me** drives candidate pairs and watches the picture for the
  filter to move. It tries the pairs this wiki's
  [GPIO table](gpio-settings.md) has recorded first, so a board already listed
  there is usually found in seconds. **It needs daylight** — the test reads the
  picture, and at night nothing looks like it moved.
- **Test the filter** moves it and compares the picture in both positions. This
  is the only way to tell "wired backwards" from "not wired" without waiting for
  nightfall, and it will tell you which you have.

If the test says **wired backwards**, swap the two coils on the map. On a board
with a single coil pad, turn on `Single IRcut is inverted` instead.

The dashboard also raises a banner on its own when the configuration cannot work
— no pin set, a light monitor with nothing to watch, thresholds with no
hysteresis, or day and night disagreeing for long enough to be real.

> **The scan drives pads whose job is unknown**, and one of them may reset the
> network, cut power to the sensor or stop the camera answering. That risk cannot
> be removed, only made survivable: the pads being driven are written to flash
> before any register is touched, so a camera that has to be restarted comes back
> knowing which pair did it and excludes them. Pads a kernel driver holds are
> refused outright. Prefer entering known pins from the table when you have them.

### Doing it by hand

The pin numbers other people have found are in
[Board specific GPIO settings list](gpio-settings.md); `IRCUT1` is `irCutPin1`
and `IRCUT2` is `irCutPin2`. If your board is not listed, adding it there helps
the next person **and** the scanner, which uses that table as its search order.

If you are still on the vendor firmware, run `ipctool` **before** you flash: the
stock application leaves the IR-cut pads configured as driven outputs, which is
how `ipctool gpio scan` recognises them. After conversion that evidence is gone —
nothing has claimed those pads and the registers know nothing about the wiring.

### If the picture is pink in daylight

In order of likelihood:

1. **No pins set.** The filter is wherever it powered up and nothing moves it.
   Check `nightMode.irCutPin1`.
2. **Pins reversed.** The filter opens when it should close. Run the filter test;
   it names this outcome.
3. **Wrong pins.** They drive something else, or nothing. The test reports the
   filter as stuck, because it does not move in either position.
4. **Night mode is on.** Check `night_enabled`. An open filter at night is the
   filter working correctly, and in a dark room a camera in night mode looks
   exactly like a camera with a broken filter.
