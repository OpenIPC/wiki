# OpenIPC Wiki
[Table of Content](../README.md)

## Is the SD card actually storing your footage?

A camera can stream, record, answer ONVIF and report healthy counters while the
card underneath it keeps nothing at all. How often that happens is not something
this page can tell you — nobody here has failure rates for the cards people
actually put in cameras. What it can tell you is that the failure exists, that
almost nothing you would normally look at will surface it, and how to ask the
card directly.

The **SD card** page in the web interface has a **Card health** panel that
answers the question in three lines, and adds a fourth saying how hard the card
has been worked. This page is what each of them means, what the two checks
underneath actually do, and what to do about each answer.

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

Some industrial card ranges answer a vendor health command; consumer cards
either ignore it or, on some camera slots, hang the process that asks. So the
one figure available on every card is the one the camera can keep itself: how
much it has written. That is the fourth line of the panel, and
[what it is and is not](#written-by-this-camera) is worth reading before
drawing a conclusion from it.

**A card can fail without reporting an error.** This is the failure worth
knowing about, because it has no symptom: the card acknowledges every write,
returns no I/O error, logs nothing in the kernel ring buffer, still reports
itself writable — and hands back different bytes every time you read the same
place. One card measured here did exactly that: three reads of the same sector
gave three different checksums, and zeroes written and flushed read back as
garbage. That is one card, not a statistic. It is offered as proof that the
state is reachable at all, because every test that asks only "is there a
filesystem?" answers yes on a card in it.

**A card can be smaller than it says it is.** Counterfeit cards are a small real
flash die presented as a much larger one, with every address past the real end
folded back onto the start. Such a card formats, mounts and records perfectly —
until it laps itself, at which point new recordings silently destroy old ones
and the archive stops going back more than a few hours. Nothing about it looks
wrong: capacity, free space and the file listing all agree with each other.

### The lines

Three of them are verdicts, and the panel says which of three states each one's
evidence is in. **"Never checked" is not the same as "fine"**, and the panel is
careful never to print the second when it means the first. The fourth is not a
verdict at all — see below.

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

There are two ways to reach it, and only one of them will touch a card that has
an archive on it.

**Format runs it, on any card.** Format erases the card as its whole purpose, so
the check costs nothing extra there: it runs first, before the partition table
is written, and its result appears in the format log. If you have formatted this
card from this page recently, you have already had the answer. **This is the way
to check a card that has recordings on it** — copy off anything you want to keep
first, because format is what it says it is.

**Check this card** runs it on its own, and appears only when the card has no
filesystem the camera can read. That is a deliberate restriction on the button
rather than on the check: a card with a filesystem is somebody's archive,
mounted or not, and a button that quietly erased one would be the wrong thing to
put on a page. Where the button is missing, Format is the route.

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

**A clean result means what it says and nothing more:** every byte it read was
readable *at the moment it read it*. It is not a snapshot of the card at the
end of the run, and it cannot be — the camera keeps recording throughout, so
clips appear after the walk has passed the place they landed, and old ones are
deleted from under it. A clip written during the pass is simply not covered by
it, and the page counts and reports any clip the recorder removed while it was
being read rather than blaming the card for it.

It is also not a statement about space nothing has been written to yet, and it
is not a prediction. For a result that covers a fixed set of files, pause
recording first — the **Change the card…** flow does exactly that, and
[the swap page](sd-card-swap.md) shows how to do it from a shell. Otherwise,
just run it again after a few weeks if the card is old.

#### Written by this camera

The other three lines are verdicts. This one is a fact, and the difference
matters: a card that has taken a great deal of writing is not thereby a card
with a problem.

> This camera has written 3.4 TB to this card since 2 November.

The camera keeps that total in a small file **on the card itself**, so it
survives a restart and belongs to the card rather than to the camera. Put a
different card in and the count starts again from nothing; put the original
back and it picks up where it left off.

Read it from a shell as `records_card_bytes_written_total`, with
`records_card_start_time_seconds` as the moment it began:

```sh
curl -s http://<camera>/metrics | grep '^records_card'
```

**Three things it is not**, and all three are ways to misread it:

- It is **a lower bound on the card's wear, not a measure of it.** This is what
  the camera handed the card. What the card's own controller then wrote is more
  — it moves data around to spread wear, and a small update can cost it a much
  larger erase. How much more is not knowable from outside.
- It counts **only what a camera running this firmware wrote**, not everything
  the card has been through. A card that arrives with a year of somebody else's
  footage on it reads as new here, and there is no way to ask it otherwise.
  The line says "this camera" because that is the ordinary case — one card
  living in one camera. Move a card that already has a count to a second
  camera and that camera carries on adding to it, so the total then covers
  both. That is the useful behaviour for a card being tracked, and it is worth
  knowing before you read the figure as one camera's work.
- It is **not a prediction, and there is no percentage to be had.** No SD card
  states its rated endurance anywhere a host can read, so there is nothing to
  divide the total by. Anything offering you "70% life remaining" for an SD card
  is deriving it from an assumption about the card, not from the card.

What it is good for is comparison and rate. A card that has taken 40 TB has done
more work than one that has taken 400 GB, and the total divided by the time it
covers tells you how fast this camera is consuming whichever card you put in —
which is the number to reach for when deciding how often to replace one, or
whether a lower bitrate would buy you a longer-lived card.

The date is left off when the camera has never had a clock it could believe.
Most of these boards have no battery-backed clock, so until something sets the
time the total is real and the date it started is simply unknown, which the line
says by not claiming one.

The count restarts if the file is damaged or deleted — it is checked when read,
and a damaged one is treated as absent rather than believed. Nothing else is
affected: it is a record about recording, not part of it.

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
before the card is full. `records.maxUsage` (95% by default) is the level at
which the camera begins removing the oldest recording — a trigger, not a
ceiling. Cleanup is a periodic job — `records.purgeSeconds`, 60 by default —
rather than something checked on every write, so the card settles around that
level rather than stopping below it, and the space above it is the buffer that
absorbs whatever gets written between one pass and the next. What that space is
not is room for the archive to grow into, which is why counting it as footage
still to come overstates what you are going to get.

Once the card is past the threshold there is no figure to give: the archive
becomes a rolling window that trades the oldest clip for the newest, and the
page says that instead of a duration. That is normal operation, not a fault —
how far back the archive reaches is then set by the card's size and your
bitrate, not by anything you can top up.

Lower `records.maxUsage` if you want to keep more of the card for other files;
raise it towards 100 if the card is doing nothing else. Either way the space
above the line has to be comfortably larger than one clip, because that is what
has to fit between one cleanup and the next — on a small card with a high
bitrate, 5% may not be. `records.split` sets how long a clip is and therefore
how big; the SD card page lists both settings, and the Recordings page shows
what your clips actually weigh.

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
- **A clean read-back does not certify the card.** It says each byte it read was
  readable when it read it. Flash nothing has written to yet is not covered and
  cannot be, and neither is a clip that arrived after the walk went past.
- **Silence about the picture is deliberate.** There is no "the card looks fine"
  banner, because a card that has stopped storing looks fine to every counter a
  camera publishes. The page says what it has established, and says nothing
  about what it has not.
- **The Check this card button is missing on most cards.** It appears only where
  there is no readable filesystem to destroy. That is a restriction on the
  button, not on the check — Format runs the same check on any card, which is
  how you check one that has recordings on it.
- **The read-back check re-reads your recordings in its second phase.** That is
  not a bug; see above.
- **The camera writes a little more to the card than the clips.** Alongside the
  recordings it keeps a small amount of its own bookkeeping — the written total
  above, and an index of when it saw movement. They are a few kilobytes, they
  are not footage, and the camera does not delete them to make room the way it
  deletes old clips. Removing them by hand costs only what they record.
- **A card that has taken terabytes is not a worn-out card.** Cameras write
  continuously; that is the job. The written total is there to be compared and
  to give you a rate, not to be read as a warning.

### See also

- [Changing the SD card on a running camera](sd-card-swap.md) — taking one out
  and putting another in without stopping the camera.
- [Encrypted recordings on the SD card](recording-encryption.md) — what a thief
  gets if they take the card.
- [Majestic streamer](majestic-streamer.md) — the recorder's own counters in
  full, and what survives a power cut.
- [Web interface](web-interface.md) — the rest of the pages this one is part of.
