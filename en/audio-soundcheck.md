# OpenIPC Wiki
[Table of Content](../README.md)

Soundcheck: setting audio levels by ear
---------------------------------------

Audio settings are a list of numbers, and nothing in that list says whether the
speaker makes a sound, whether the microphone hears anything, or whether
`audio.volume` is anywhere near right for the room the camera is in. The usual
way to find out is to change a number, save, apply, and walk over to the camera
to listen.

**Soundcheck** is a panel above those fields in **Camera → Settings**, under
**Audio**, that does it from the browser. Three buttons: play a test sound
through the speaker, set the microphone level from what comes back, and listen
to the microphone.

Nothing is added to the camera for it. It plays through
[`/play_audio`](majestic-streamer.md#how-to-play-audio-file-on-cameras-speaker-over-network)
and reads [`/audio.pcm`](majestic-streamer.md#how-to-play-audio-stream), both of
which are there for anything else to use as well — see
[from a shell](#doing-the-same-thing-from-a-shell) below. All the measurement
happens in the browser, because there is no level anywhere in the camera's API:
no meter, no peak, no RMS, nothing in the metrics. A camera with 32 MB of RAM
and no floating-point unit would be paying for one continuously, for a page
almost nobody has open.

Everything the panel reports is in **dBFS** — decibels relative to the loudest
sample the format can hold — so every reading is negative and 0 is where sound
starts to distort.

### Before it will run

The panel checks what the camera has told it and says why it will not start,
rather than measuring something meaningless:

| What it says | What it means | What to do |
| --- | --- | --- |
| *The camera has not said what its audio settings are yet* | The configuration had not arrived when the page was drawn. | Reload the page. |
| *This camera has not said whether its microphone and speaker are switched on* | The camera reports neither switch. That is not the same as reporting them off, and there may be no control to change. | Check the build — `audio:` is absent from FPV builds entirely. |
| *This camera has both its microphone and its speaker switched off* | `audio.enabled` and `audio.outputEnabled` are both `false`. | Turn both on, and see [Enabling the speaker](majestic-streamer.md#enabling-the-speaker). |
| *The speaker is switched off, so the camera cannot play the test sound* | `audio.outputEnabled` is `false`. | Turn it on. |
| *The microphone is switched off, so nothing can measure what the speaker plays* | `audio.enabled` is `false`. **Test the speaker** stays available; the other two do not. | Turn it on if you want a measurement rather than your own ears. |
| *This camera has not said what rate it captures at* | `audio.srate` is unset. The stream carries no header, so a guessed rate would play the test sound at the wrong pitch for the wrong length. | Set `audio.srate`. |

One trap the panel does not catch: with the microphone off it still offers the
speaker test, but audio output needs **both** switches — the speaker is brought
up as part of the audio block, so `audio.enabled: false` leaves it off whatever
`audio.outputEnabled` says. On that camera the test will play into a speaker
that was never powered. Turn both on.

If your board gates the amplifier behind a GPIO, `audio.speakerPin` has to be
set too, or the logs stay clean and nothing comes out. That, and the tenth of a
second of sound lost while the amplifier comes up, are in
[Enabling the speaker](majestic-streamer.md#enabling-the-speaker).

### Test the speaker

**Test the speaker** confirms before it does anything — the sound is loud enough
to hear across a room, and anyone near the camera will hear it.

It then listens to the room for about a second, starts listening again, and
plays a three-second burst while measuring what comes back. The verdict is the
difference between those two readings:

| Verdict | What was measured |
| --- | --- |
| *The speaker works and the microphone hears it* | The room got at least 6 dB louder while the sound played. Both readings are quoted. |
| *The speaker works, but the microphone is overloaded* | It was heard, and it came back distorting. Lower `audio.volume`, or `audio.outputVolume`. |
| *The microphone did not hear the test sound* | The room measured no louder during than before — no more than it varies by on its own. Either nothing came out of the speaker or the microphone cannot hear it. |
| *The microphone is not sending anything* | Its samples are all silence, which is not what a working input produces even in a quiet room. The speaker was not tested, because nothing could listen. |
| *The test could not be measured* | The camera stopped sending samples partway through, so there is nothing to compare. |
| *The camera refused to play the test sound* | Repeated in the camera's own words — a speaker switched off, an upgrade in progress and a clip it had no memory for are different problems. |
| *The camera played the test sound* | The microphone is off, so nothing here could listen. Whether anything came out is something only you can tell from the room. |

A verdict of *did not hear* with a speaker you can hear yourself means the
microphone is the half at fault. That is worth knowing before you start moving
`audio.volume` around.

### Set the microphone level

**Set the microphone level** plays the test sound several times, measures the
microphone while each one plays, and adjusts between rounds. Up to eight rounds,
about half a minute, and it stops as soon as a reading lands where it wants it:
**−20 dBFS**, accepted anywhere within 6 dB of that.

It measures during the sound rather than in the silence between, and that is the
point of it. Calibrating against a quiet room drives the gain up until the air
conditioning reads at the target, which leaves anything anyone actually says
clipping. The speaker is the only sound in the room whose loudness is known.

**Nothing is saved.** Each round applies a level without writing it, the run
puts the saved one back when it finishes, and the value it settles on lands in
the `audio.volume` field for the ordinary **Save Changes** button to keep.
Leaving the page keeps nothing.

That needs a camera that can change a level without rebuilding its video
pipeline, which on current firmware is **HiSilicon/Goke and Ingenic** — on other
SoCs a volume change drops every stream for a moment. The panel asks the camera
rather than assuming: where the answer is no it says *the level could not be
changed for the test* and stops, instead of running a set of rounds that all
measured the saved value and then recommending one that was never in force. Set
it by hand there.

How it closes tells you whether to run it again:

- *Microphone level set to N* — it landed in the window.
- *Microphone level left at N. …That is as close as the dial gets on this
  camera* — the level stopped moving before the reading arrived. Running it
  again will not do better.
- *Microphone level left at N. …It was still moving when the test ran out of
  tries* — the opposite: run it again from where it left off and it will go
  further.

If it cannot put the saved level back at the end it says so, and names what to
do about it. A camera left on a temporary gain without being told is the one
outcome worse than the test failing.

### Listen to the microphone

**Listen to the microphone** opens `/audio.opus` in a player on the page. It is
the same stream [ffplay reads](majestic-streamer.md#how-to-play-audio-stream),
without leaving the browser — useful for hearing what a level change did to the
noise floor, and for telling a dead microphone from a quiet one by ear.

Mind the feedback if you are sitting next to the camera with the speaker on.

### What the numbers mean

| Reading | Where it comes from |
| --- | --- |
| **−20 dBFS** | What the level tuner aims for: quiet parts above the noise floor, loud parts not clipping. |
| **±6 dB** | How close counts as arrived. The right answer depends on the room, so the window is wide. |
| **clipping** | At least one sample in a hundred within about 2% of full scale. One in a thousand is a transient; one in a hundred is a level set too high. |
| **not sending anything** | Virtually all of the reading is exact zeroes — at least 98% of it, including a run of 4800 samples or more. |
| **a rise of 6 dB** | How much louder the room has to get before the speaker is credited with having made a sound. |

A long run of zeroes on its own is *not* a dead input, and treating it as one
called a perfectly good microphone broken on a camera. A capture stream really
does hand over the occasional block of zeroes — at the start of a subscription,
or across a level change — and one of those inside an otherwise loud reading is
a gap. It has to be almost all of what arrived.

### Doing the same thing from a shell

The panel is a convenience; the endpoints underneath it are not private. With
[sox][sox] you can run the same test by hand, in the same units.

Build the same stimulus — three quarters of a second of 1 kHz, then 2.25 seconds
sweeping to 3.2 kHz, at 85% of full scale so the test itself is not what clips.
Match `-r` to `audio.srate`:

```
sox -n -t raw -r 8000 -e signed -b 16 -c 1 tone.pcm  synth 0.75 sine 1000      gain -1.4
sox -n -t raw -r 8000 -e signed -b 16 -c 1 sweep.pcm synth 2.25 sine 1000-3200 gain -1.4
cat tone.pcm sweep.pcm > test.pcm
```

Measure the room, then play it and measure again:

```
curl -s -u root:YOUR_PASSWORD http://192.168.1.10/audio.pcm | head -c 32000 | \
    sox -t raw -r 8000 -e signed -b 16 -c 1 - -n stats

curl -u root:YOUR_PASSWORD --data-binary @test.pcm http://192.168.1.10/play_audio
```

`RMS lev dB` in that output is the number the panel reports, and `Pk lev dB`
near 0 is the clipping it warns about. The comparison that matters is between
the two readings, not either one on its own: a single measurement from one
microphone in an unknown room does not answer "was there sound", and "was there
*more* sound than a moment ago" is answerable.

`head -c 32000` is two seconds at 8 kHz — adjust it with the rate, and note that
`/audio.pcm` never ends on its own.

### Why it measures the way it does

Three things here were settled on a camera rather than on paper, and are worth
knowing if you build your own test.

**The test sound is in the voice band.** The speaker fitted to a camera is a
~30 mm transducer built for speech and rolls off hard below about 400 Hz. A
chord of low tones at full scale is inaudible through one while every meter
agrees it played — measured, with a listener in the room hearing nothing at all.
A tone near the middle of speech and a sweep across it is what a small speaker
can actually reproduce, and the sweep is what stops one bad resonance deciding
the verdict.

**The verdict is a rise, not a level.** Without the quiet reading taken moments
before, a noisy room reads as a working speaker, and the test says yes to a
camera whose speaker is disconnected.

**The step size is read off the camera, not assumed.** What a point of
`audio.volume` is worth in decibels differs per chip and per board, and is not
something a page can know: on one camera twelve points moved the reading by
57 dB, which any fixed points-per-decibel turns into an oscillation between the
two rails that only stops by luck. So the first adjustment is a guess that only
has to be in the right direction, and every one after it takes its slope from
the last two measurements — the camera's own curve, in the region being used.
A clipped reading is the exception: every sample is pinned at the rail, so it
carries no usable level at all, and the only thing to do is step down hard and
climb back on evidence.

Measured on a HiSilicon camera with a speaker and microphone fitted: the room
read −57.4 dBFS, the test sound took it to −8.4, and the level loop converged in
two rounds from both ends of the dial.

[sox]: https://en.wikipedia.org/wiki/SoX
