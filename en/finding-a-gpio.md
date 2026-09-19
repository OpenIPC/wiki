# OpenIPC Wiki
[Table of Content](../README.md)

Finding out what a pin is wired to
----------------------------------

A converted camera comes with no wiring diagram. The board has an IR-cut filter,
an infrared lamp, maybe a reset button, a card slot, a second network port, and
whatever you soldered on yourself — and nothing on the camera knows which pad any
of it is on. The vendor firmware knew, and that knowledge went with it.

**Settings → Pins** is where the camera works it out for you. It draws every pad
the chip has, says what each one is already carrying, and will drive them one at
a time until something changes.

---

### A pad is not a pin until something says so

Every pad on these SoCs can be several things. The same piece of metal is a
serial port, or a camera bus, or a PWM output, or a plain on/off pin — never more
than one at a time, and the chip holds a setting that says which. That setting is
what "pin muxing" means, and it is the reason a pad can look completely free and
still be carrying the serial console you are reading this over.

Two things follow, and both matter before you drive anything:

- **A pad already doing a job must be left alone.** Driving it takes the job away
  — the console goes quiet, the sensor loses its clock, the network drops — and
  nothing announces it. The Pins page asks the chip about every pad and greys out
  the ones that answer with something other than "free".
- **A pad's number is the same number everywhere.** The board tables in
  [Board specific GPIO settings list](gpio-settings.md), the numbers you type
  into settings, and the numbers on the Pins page are one numbering. The kernel's
  `bank_pin` spelling is a second one and appears nowhere in the interface.

**Not every camera can be asked.** The chip answers on HiSilicon, Goke, SigmaStar
and Ingenic. Where it cannot, the page says so rather than showing you an
all-clear it has not earned, and the hunts fall back to the checks that do work.

---

### Two hunts, and they look for different things

The Pins page offers two, each with a sentence saying which one you want. They
differ in **what the camera watches**, and that decides what each can find.

| | What is my pin wired to? | Which pins move the day/night filter? |
|---|---|---|
| drives | one pin at a time | two pins at a time |
| watches | what is plugged into the camera | the picture |
| finds | anything the camera enumerates | the IR-cut filter |
| needs | nothing | daylight |
| takes | a second or two per pin, both levels | about a second per pair |

#### What is my pin wired to?

The camera writes down everything attached to it, holds one pin, and looks again.
If something came online — or went away — that pin is the one.

What it can see arriving: a network interface, a device on a USB bus, a card on
the memory-card controller, a disk, a chip that a driver binds to on an add-on
bus. That covers most of what people wire to a spare pad: **a wireless card, a
card slot, a second network port, a USB module**.

It reports the arrival in the device's own words where the device has any. A USB
module carries a product string, so the answer reads as a sentence:

> Pin 47, held high, switched on 802.11n WLAN Adapter (1-1) and a wireless
> adapter (wlan0).

**Things that leave count too**, and this is the half that saves an afternoon. A
pad wired to an ethernet PHY's reset takes the network away while it is held; the
camera notices the interface go, hands the pad straight back, and names the pin.
Without that the only symptom is a hunt that mysteriously stops.

It tries every candidate pin **high**, then every candidate **low**, because an
enable line is usually active high and a reset usually active low. It **stops at
the first find**: whatever just came online is still online when the next pin is
held, so carrying on would report the same arrival over and over. Act on the
find, then run it again if you want another.

#### Which pins move the day/night filter?

The filter is the one thing on these pads the camera can see through its own
lens, so this hunt watches the picture instead, and drives pads **in pairs**. The
usual arrangement is an H-bridge across two pads, and no single-pad operation
moves one of those — which is why pairs, and why this hunt cannot find a filter
wired to a single pad. [How an IR-cut filter is driven](ircut-filter.md) explains
the bridge itself.

**Which kind you have is a fact about the board**, and the quickest answer is
[the board table](gpio-settings.md): a row with both an IRCUT1 and an IRCUT2 is a
two-pad bridge, a row with only IRCUT1 is a single-pad filter. If your board is
not listed and the pair hunt comes up empty, a single pad is one of the reasons —
set that one by hand and let **Test the filter** adjudicate it.

It tries the pairs [the board table](gpio-settings.md) records for your SoC
first, so a board already listed there is usually found in seconds. **It needs
daylight**: at night nothing looks like it moved.

When it finds the pair it hands the numbers to **Settings → Day / Night** with
the Save bar up. Nothing is written to the camera until you press Save — the
filter test on that page is only honest about wiring the camera has actually been
given, so the find arrives as a proposal rather than a change made behind you.

---

### What the camera will not drive, and why

Before the first pad moves, the confirm card counts what is being skipped:

> **37 pins out of 80 will be tried, at two levels each.** 43 are being left
> alone — they already have a job, or you told the camera to stay off them.

Those numbers are from an Hi3516EV300 board, and the proportion is normal: on a
typical part **about half the pads are carrying something** — the flash, the
sensor's bus and clock, the serial console, JTAG, the core regulator's PWM.

A pad is skipped when any of these is true:

- the chip says it is carrying something other than a plain pin
- a kernel driver holds it — a PHY reset, a regulator enable, something wired on
  purpose
- the camera is already configured to use it: the infrared lamp, the daylight
  sensor, the PTZ motor driver
- it is on the camera's own leave-alone list (below)

**Two of those questions stop the hunt outright if they cannot be answered**:
which pads a kernel driver holds, and which pads the PTZ motor driver is on. Not
knowing is not the same as there being nothing there, so the camera refuses to
drive anything at all rather than treating unknown as free, and the page says
which question it could not ask. Setting a pin by hand still works — that writes
a number into a field and moves nothing.

**Not being able to ask the chip what a pad is carrying does not stop it.** The
hunts still run on the checks that do work; there are simply fewer pads ruled out
in advance, and the page says so instead of showing you a count that implies a
check it never made. This is the one to keep in mind on a part whose pads cannot
be read: nothing has changed about the risk except how much of it was screened
off for you.

> **This still drives pads whose job is unknown.** One of them may reset the
> network, cut power to the sensor, or stop the camera answering. That risk
> cannot be removed, only made survivable — see below. If your board is in
> [the table](gpio-settings.md), typing the numbers in is always the safer route.

---

### When it goes wrong

It is a hunt across hardware nobody documented, so assume it will, at least once.

**The camera stops answering.** Restart it. It comes back knowing what it was
driving and puts that on a **leave-alone list** — permanently. Nothing will touch
it again, not the hunt and not anything else. You do not have to be watching for
this to work, and you do not have to reopen the page: the reboot may have been
hours before you next look, and the exclusion is already in place when you get
there.

**What lands on the list is what was being driven**, which differs by hunt: the
single-pin hunt excludes the one pin it was holding, and the pair hunt excludes
**both** pins of the pair. The pair hunt cannot tell which of the two did it — it
drives them together — so it rules out both rather than guess, and neither is
offered again in any later pair. If you have reason to believe one of them was
innocent, take that one back by hand from the list below.

**The connection drops but the camera is fine.** This is the awkward one: from
the camera's side nothing went wrong, so it has no record. Your browser does — it
notes which pin was in flight before each request — so when you come back the
page names that pin and offers *never try it again* or *it was fine, carry on*.

**You already know a pin is trouble.** Click it in the drawing and rule it out.

The list is the camera's, not the browser's, which is the point: it has to
outlive the reboot that filled it in. The Pins page shows it in words —

> The camera is leaving 2 pins alone — 1 you excluded, 1 that stopped the camera.

— with *try it again* on each entry, and one **Forget the whole list** that asks
twice before it spends anything. An entry the camera earned by going down is
worth more than one you typed: there is no other copy of it anywhere, and the
only way to earn it again is to let the camera go down again.

**Nothing is lost when you stop.** Both hunts remember which pins they have
already tried, and the range you limited them to, so *carry on* picks up where it
left off rather than starting over. Starting over is a separate button, and it
keeps the leave-alone list.

**Only try pins _from_ to _to_** narrows the whole thing to part of the chip,
which is what you want when you already know which end of the board your wire
went to. Leave both empty for the whole chip.

---

### What it cannot find

Worth knowing before you spend twenty minutes on it:

- **Anything that does not announce itself.** A plain lamp, a relay with nothing
  behind it, a buzzer, a MOSFET driving a LED strip — the camera has no way to
  see any of that. Drive the pin from the Pins page and look at the thing.
- **A filter driven from a single pad.** The pair hunt works by pulsing pairs; a
  single-pad filter is moved by holding one pad at a level. Set that one by hand
  and confirm it with **Test the filter**.
- **Pads that are already carrying something.** If what you soldered went onto
  the serial console's pad, the hunt will refuse it — correctly. Move the wire.

---

### Without the web interface

**On the vendor firmware, before you flash.** This is the cheapest answer there
is, and it stops being available the moment you convert the camera: the stock
application leaves the IR-cut pads configured as driven outputs, and after
conversion nothing has claimed them and that evidence is gone.

Run `ipctool gpio scan` and **cover and uncover the lens with your palm a couple
of times** while it runs — that is what makes the stock firmware switch the
filter, and the pads it drives are what the scan then reports. The
[FAQ's pink-tint entry](faq.md#camera-image-has-a-pink-tint) has the whole
routine including getting the tool onto a camera you have not flashed yet. Read
it as the **stock-firmware** route: the same commands on a converted camera find
nothing, for the reason in the paragraph above.

**Asking about muxing from a shell.** `ipctool reginfo` prints every pad with its
current function marked, which is the same question the Pins page answers when it
greys a pad out — and it works on a converted camera too, when you want the answer
without a browser.

`ipctool gpio mux <pin>` asks about one pad. Give it a second argument and it
**changes** the pad's function rather than reporting it, so leave that off unless
that is what you mean.

**From a shell on a converted camera.** The same hunts are HTTP, so they script:

```
# what the camera has, what it is carrying, and what is attached to it
curl http://localhost/api/v1/gpio

# hold pin 47 high for a moment and say what turned up
curl -X POST 'http://localhost/api/v1/gpio?hold=47&level=high'

# leave a pin alone, and take that back
curl -X POST 'http://localhost/api/v1/gpio?avoid=13'
curl -X POST 'http://localhost/api/v1/gpio?unavoid=13'
```

Driving a pad is a `POST`; reading is a `GET`. A pad the camera will not drive
comes back with `200` and a sentence saying why, so a script can carry on past it
rather than stopping. Anything malformed — an empty pin number, a level that is
not `high` or `low` — is `400` and nothing moves.

**From the board tables.** [Board specific GPIO settings list](gpio-settings.md)
is what other people have already found, and it is worth checking first every
time. If your board is not there, **add it once you know** — it helps the next
person and it makes the filter hunt faster on that SoC, because those pairs are
what it tries first.

---

### When you have found it

A find is a fact about the board, not a setting. To make the camera *do*
something with it, pick the pin in the drawing on **Settings → Pins** and give it
a job:

- **Hold high** or **hold low** keeps the pin at that level from every start,
  before anything else runs, and it survives a power cut. This is what a wireless
  module's enable line wants.
- **Don't drive** leaves the pin alone, which is the default and what an input
  wants.

For the day/night filter, the two coil pins belong on **Settings → Day / Night**
instead, where **Test the filter** can adjudicate them — the hunt proposes, the
test decides. If the test says *wired backwards*, swap the two coils there.

---

What to do with the answer: a pin you have identified belongs in the device's own
`gpio.conf`, so every script on that camera refers to it by name. See
[Per-device settings: customizer.sh, muxes.sh and gpio.conf](per-device-settings.md).
