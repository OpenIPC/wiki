# OpenIPC Wiki
[Table of Content](../README.md)

## Is the SD card actually storing your footage?

A camera can stream, record, answer ONVIF and report healthy counters while the
card underneath it keeps nothing at all. That is not a rare failure — it is the
ordinary way these cards end their lives, and almost nothing you would normally
look at will tell you it has happened.

The **SD card** page in the web interface has a **Card health** panel that
answers the question in three lines. This page is what each of them means, what
the two checks underneath actually do, and what to do about each answer.

If you have arrived here because your recordings are missing, skip to
[When the archive stopped growing](#when-the-archive-stopped-growing).

### Why a card can fail silently

Three things make SD cards different from a disk, and all three work against
you.

**There is no SMART.** A hard disk keeps a running account of its own health
that you can read. SD has nothing equivalent. The card's own registers report
its speed ratings — Class, UHS grade, Video Class, App Class — and say nothing
whatsoever about wear, remaining life or errors. The SD card page shows those
ratings because they are worth knowing, but they describe what the card was sold
as, not what condition it is in now.

**A dying card does not always report an error.** The failure that matters most
is the one with no symptom: the card acknowledges every write, returns no I/O
error, logs nothing in the kernel ring buffer, still reports itself writable —
and hands back different bytes every time you read the same place. Measured on
one such card: three reads of the same sector gave three different checksums,
and zeroes written and flushed read back as garbage. Every test that asks only
"is there a filesystem?" says yes.

**A card can be smaller than it says it is.** Counterfeit cards are a small real
flash die presented as a much larger one, with every address past the real end
folded back onto the start. Such a card formats, mounts and records perfectly —
until it laps itself, at which point new recordings silently destroy old ones
and the archive stops going back more than a few hours. Nothing about it looks
wrong: capacity, free space and the file listing all agree with each other.

### The three lines

The panel says which of three states each line's evidence is in. **"Never
checked" is not the same as "fine"**, and the panel is careful never to print
the second when it means the first.

#### Keeping up with the recorder

This one is free and continuous: it reads the counters the camera already
publishes, so it is true whether or not anyone is looking at the page. It says
the card is keeping up only when every counter it needs has actually been read
and come back clean. A camera whose firmware does not publish them says so
rather than being reported as healthy.

What it can say, roughly worst first:

| It says | What has happened |
|---|---|
| cannot open the card | The recorder cannot get at the storage at all. It retries on a fixed interval, so recording resumes on its own once the card is back. |
| writes are failing | The camera gave up on the clip it was writing after repeated errors. |
| failing intermittently | Recording continues, and footage is being lost while it does. |
| has not kept up | Whole clips have been dropped because the card could not take them in time. |
| falling behind | Clips are **queuing** — the card is behind, but nothing has been lost yet. This is the only one that arrives while there is still time to act. |
| keeping up | Every counter was read and none of them reports a problem. |

The "falling behind" line is worth reacting to. Once clips are being dropped the
footage is already gone; a queue that will not drain is the same card a few
minutes earlier. Faster storage or a lower bitrate is the fix, in that order —
see [Majestic encoder tuning](majestic-encoder-tuning.md).

You can read the same counters from a shell:

```sh
curl -s http://<camera>/metrics | grep '^records_'
```

`records_fsync_us_max` is the one to watch on a card that is merely slow: it is
the longest the camera has waited for a flush since it started, and a stalling
card shows there before it shows anywhere else.

#### Stores what it is given

This is a check you run, and it is **destructive**: it writes markers across the
card's whole claimed size and reads them back. It takes seconds.

It runs as part of **Format** on every camera, so if you have formatted the card
from this page recently you have already had the answer. It is also offered on
its own — as **Check this card** — but only when the card has no filesystem the
camera can read, because anywhere else it would erase somebody's archive. On a
card with recordings on it, format is the way to run it, and format erases the
card anyway.

What it catches that nothing else does:

- **A card that keeps nothing.** The markers do not come back. No amount of
  reformatting will fix this; the card, or the slot, needs replacing.
- **A card that is smaller than it claims.** A marker written near the top of
  the card comes back *near the bottom*, and the page says which two addresses.
  That sentence is worth keeping: it is the difference between "this card is
  broken" and "this card is not what it was sold as", and it is the second that
  you can take to whoever sold it to you.

It deliberately does not print a figure for the card's real capacity. Working
one out properly takes a much longer search, and the obvious shortcut gives a
wrong answer on exactly the cards this is for.

#### Reads back what it holds

This is the long one: it reads every byte the card is holding and reports what
cannot be read. It is not destructive and the camera keeps recording throughout.

It runs in two phases, and the first is the one worth waiting for.

**Your recordings** are read first, file by file. A finding here names the clip
and where in it the read failed — `2026-09-18/20-13.mp4`, so many megabytes in
— which is something you can act on: copy what is still readable, and know what
is not.

**The rest of the card** is swept afterwards, for the space no recording
occupies. Findings there can only be an address, because working out which file
sits on which address means reading the filesystem by hand. This phase
necessarily re-reads the first phase's bytes as well; that is the honest cost of
not parsing the filesystem, and you can stop after phase one and keep
everything it found.

**It takes a while, and it competes with recording.** Measured on an hi3516av300
with a 29 GB card and a live recorder: 56 GB read in 32 minutes at about
31 MB/s. During that pass no footage was dropped and no write failed, but the
recorder's longest flush roughly doubled. Budget about half an hour per 30 GB of
card for both phases, longer on a slower card, and expect the camera to be a
little less responsive while it runs.

You can stop it at any point, and what it found up to then is kept. A stopped
run says so, and is never reported as a clean result.

**A clean result means what it says and nothing more:** everything the card is
currently holding was read back. It is not a statement about space nothing has
been written to yet, and it is not a prediction. Run it again after a few weeks
if the card is old.

### When the archive stopped growing

In rough order of how quickly they settle the question.

1. **Open the SD card page and read the Card health panel.** If the first line
   is anything but "keeping up", that is your answer and the wording tells you
   which.
2. **Check the card is not mounted read-only.** A card the kernel has dropped to
   read-only still reports its old free space, so capacity, the storage bar and
   the clip list all read exactly as they did before recording stopped. The page
   says so explicitly when it happens.
3. **Check where recording is actually pointed.** `records.path` is a free
   string and can point anywhere. A camera recording to a path that is not on
   the card will have a perfectly healthy card and no new footage.
4. **Run the read-back check** if the card is mounted and the counters look
   fine. This is the case where nothing else will tell you.
5. **Format, and read the result.** Format runs the capacity check first and
   reports it. If the card cannot store what is written to it, this is where
   you find out.

### How much footage is left

The storage line on the **Recordings** page reads, for example:

```
26.5 GB of 29.2 GB used · about 52 min of footage left before the oldest is deleted
```

That figure is the room before the camera **starts deleting**, not the room
before the card is full. The camera removes the oldest recording once the card
reaches `records.maxUsage` (95% by default), so the free space below that line
is held in reserve and never gets used for new footage.

Once the card is past the threshold there is no figure to give: the archive
becomes a rolling window that trades the oldest clip for the newest, and the
page says that instead of a duration. That is normal operation, not a fault —
how far back the archive reaches is then set by the card's size and your
bitrate, not by anything you can top up.

Lower `records.maxUsage` if you want more headroom for other files on the card;
raise it towards 100 if the card is doing nothing else. Note that the space it
reserves has to be comfortably larger than a single clip, or the camera can run
out of room between one cleanup and the next — `records.split` controls how long
a clip is, and therefore how big.

### What the speed ratings mean, and what they do not

The page prints the card's markings as `Class 10 · U1 · V10 · A1`, or — on a
card that has no A-class — `Class 10 · U1 · V10 · no A1/A2 rating`, flagged
**sequential only**. That flag is the useful part. Class, UHS grade and Video
Class are all **sequential** promises: a minimum sustained rate on one long
streaming write. Only the A-class says anything about random I/O, which is what
a filesystem actually does while a recorder deletes old clips underneath it. A
card with no A-class rating is not a bad card, but it is rated for something
other than the job, and "use a faster card" is advice nobody could act on
without that distinction.

Two cameras can disagree about the same card, and the page is careful about
whose fault that is: the ratings come from a structure some kernels do not
expose at all. Where the camera cannot read them it says so, rather than
reporting a card that publishes its ratings perfectly well as unrated.

The page also measures the card, and will tell you when the measurement comes in
well under the markings. It deliberately declines to say which of the two is at
fault: the ratings are quoted for a card reader, and on some cameras the slot
itself is the slower half. Measured on an hi3518ev200, a Class 10 card managed
4.7 MB/s — and a raw read straight off the block device managed exactly the same
4.7 MB/s, so the card was never the limit.

### Things that will surprise you

- **A full card is normal.** Cameras are meant to fill their cards and then roll.
  A storage bar at 94% is not a warning.
- **A clean read-back does not certify the card.** It says everything currently
  stored came back. Flash that has not been written to yet is not covered, and
  cannot be.
- **Silence about the picture is deliberate.** There is no "the card looks fine"
  banner, because a card that has stopped storing looks fine to every counter a
  camera publishes. The page says what it has established, and says nothing
  about what it has not.
- **The capacity check will not run on a card with a filesystem**, mounted or
  not. An unmounted card with an archive on it is still somebody's archive.
- **The read-back check re-reads your recordings in its second phase.** That is
  not a bug; see above.

### See also

- [Changing the SD card on a running camera](sd-card-swap.md) — taking one out
  and putting another in without stopping the camera.
- [Encrypted recordings on the SD card](recording-encryption.md) — what a thief
  gets if they take the card.
- [Majestic streamer](majestic-streamer.md) — the recorder's own counters in
  full, and what survives a power cut.
- [Web interface](web-interface.md) — the rest of the pages this one is part of.
