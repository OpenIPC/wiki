# OpenIPC Wiki
[Table of Content](../README.md)

## Changing the SD card on a running camera

A card fills up, or it holds footage somebody needs to take away. The camera is
on a pole, or in a stairwell, or somewhere nobody wants to visit twice. This
page is how to take the card out and put another one in without stopping the
camera for longer than it takes, and what to expect if something goes wrong
half way.

If you only want the short version: open the camera's web interface, go to the
**SD card** page, press **Change the card…**, and follow it.

### Why you cannot simply pull it

Recording holds the clip it is writing. While it does, the card cannot be
unmounted: the **Unmount** button on the SD card page reports it as busy, which
is precisely when you needed it to work. Pulling the card anyway is worse than
it looks:

- The clip being written stops where the card stopped. Recordings are
  fragmented MP4, so the file stays playable up to its last complete fragment
  and you lose about a second rather than the clip — but the camera does not
  know the card has gone until it next tries to write.
- The recorder then has nowhere to write. It reports its storage offline and
  looks again on a fixed interval, so even once a new card is in, recording
  restarts roughly half a minute later rather than at once.
- **On firmware older than September 2026, it also cost you the slot.** The
  mount outlived the card, so the *next* card was never mounted — the camera
  looked fine, streamed fine, and recorded nothing until somebody rebooted it.
  There was no error on screen and nothing in the system log to find
  afterwards, so do not go hunting for the line that explains it: on those
  builds there isn't one. Newer firmware releases the mount when the card
  leaves, and says so when it cannot; on an older build, a reboot clears it.

### The guided swap

The **SD card** page has **Change the card…** whenever a card is mounted and
writable. It runs the whole sequence and tells you which step it is on:

1. **Pausing.** The camera finishes the current fragment, closes the clip so it
   is complete and playable, and stops writing. Nothing is saved to
   `majestic.yaml`, and the video pipeline is not rebuilt — RTSP and WebRTC
   viewers are not disturbed.
2. **Releasing.** The card is unmounted. This is the step that used to be
   impossible while recording.
3. **Safe to remove.** Take the card out. The page waits up to **two minutes**
   for it to leave. It says this only after step 2 reported success — pausing
   alone does not make a card removable, it only makes the unmount possible,
   and a paused camera still has the card mounted.
4. **Waiting.** Put the new card in. The page waits up to **three minutes**,
   then mounts it if the camera has not already.
5. **Resuming.** Recording starts again. Because the pause was deliberate, the
   camera does not sit out the offline retry interval — the next clip opens on
   the next keyframe, normally within a second or two.

The page compares the new card's serial with the old one, so putting the same
card back is noticed and said plainly rather than reported as a successful
change. Not every camera's kernel reports a serial; where it does not, the page
says it cannot tell rather than accusing you of putting the same card back.

**It always starts recording again.** Every way the sequence can end — you
pressed Stop, the card never came out, no new card arrived, the camera stopped
answering — puts the card back if it had unmounted one and starts the recorder.
And if the browser goes away entirely, closed or out of range, the camera
resumes on its own after **ten minutes**.

### Slots that never notice a new card

Some cameras have no card-detect line wired, so the kernel is never told a card
arrived and the slot looks empty with a card sitting in it. If nothing appears
within the waiting period, the page offers to ask the card controller to look
again, and waits a further thirty seconds.

Two things to know about that:

- It cannot run while a card is mounted, and refuses if one is.
- If the controller does not come back, the page says so. Rebooting the camera
  restores it. This is rare, but it is the reason the button is offered rather
  than pressed for you.

A camera that cannot be asked to look again is told apart from a camera that
looked and found nothing — those are different sentences, and the page uses the
one that is true.

### When the new card lands somewhere else

Where clips go is a path, and a mount is named after the device. A card with a
partition mounts as `/mnt/mmcblk0p1`; a card with **no partition table** mounts
as the whole disk, `/mnt/mmcblk0`, and `records.path` still points at the old
name. Recording would then fail with nothing obviously wrong with the card.

The page checks this and says so rather than reporting a tidy ending. Use
**Format** on the SD card page — which writes a partition table — and change the
card again.

### From a shell, or from your own script

> **Check your camera has this first.** A build without these endpoints does
> not return an error — it answers **200 with an empty body** and does nothing,
> so a script that trusts the status code will believe it paused a camera that
> is still recording. What tells you is the reply, or the metric:
>
> ```
> curl -s http://localhost/metrics | grep -c '^records_stood_down'
> 1        # 1 means this camera can pause; 0 means it cannot
> ```
>
> Anchor the pattern. `/metrics` prints a `# HELP` and a `# TYPE` line for
> every gauge, so an unanchored `grep -c` counts three on a camera that has
> the feature and still zero on one that does not — the test works either way,
> but only one of the numbers means what it looks like.

Two endpoints pause and resume the recorder. Both are **POST**, both take
effect immediately, and — unlike every other way of changing what Majestic is
doing — **neither writes anything to `majestic.yaml`**:

```
curl -X POST http://localhost/api/v1/records/standdown
{"stoodDown":true,"resumesInSec":600}

curl -X POST http://localhost/api/v1/records/resume
{"stoodDown":false,"resumesInSec":0}
```

These run on the camera itself, where no credentials are needed. From another
machine, address the camera and let `curl` ask for the password rather than
putting it in the command:

```
curl -u root -X POST http://<camera-address>/api/v1/records/standdown
Enter host password for user 'root':
```

`-u root:PASSWORD` would work too, and it is what older examples here use, but
it leaves the camera's root password in your shell history and in the process
list of whatever machine you typed it on — and this is the same password SSH
accepts. Plain HTTP also carries it across the network in the clear, so do this
from the camera, or over a management network you trust, and not across the
internet.

A `GET` is refused with **405**, and a request arriving from another site with
**400** — so neither a prefetched link nor a page on somebody else's site can
stop your camera recording on a session your browser attaches by itself.

`stoodDown` is what actually happened, not what you asked for. A camera that
could not arm its own resume timer refuses the pause and answers `false` — the
safe way to fail, since the card is then still in the slot and still being
written to.

`resumesInSec` is how long the pause lasts if nothing resumes it. A pause that
outlives its reason is a camera quietly not recording, which is the failure the
whole sequence exists to avoid, so there is no way to ask for one that never
expires.

The state is published as a metric, so a script can wait for it rather than
guess:

```
curl -s http://localhost/metrics | grep '^records_stood_down'
records_stood_down 1
```

A full manual swap, as a script to run on the camera. Every step checks what it
was told rather than assuming it worked — each of the three checks below is a
way to end up with a camera that looks fine and records nothing:

```sh
#!/bin/sh
MP=/mnt/mmcblk0p1          # where the card is mounted
DEV=/dev/mmcblk0p1         # the partition on it
FS=vfat                    # what it is formatted as

# 1. Pause, and check that it took. `stoodDown` is the answer; the status code
#    is not, because a build without this endpoint answers 200 and does
#    nothing.
case "$(curl -s -X POST http://localhost/api/v1/records/standdown)" in
	*'"stoodDown":true'*) ;;
	*) echo "this camera did not pause — stopping"; exit 1;;
esac

# 2. Release the card. If something still holds it, put the recorder back to
#    work and stop: nothing has been taken away from anyone yet.
if ! umount "$MP"; then
	curl -s -X POST http://localhost/api/v1/records/resume >/dev/null
	echo "the card is still in use — nothing was changed"; exit 1
fi

echo "safe to remove — swap the card, then press enter"; read -r _

# 3. Mount the new one where the recording path expects it. Name the
#    filesystem: an unqualified `mount` asks the kernel to guess, and it
#    guesses in the order /proc/filesystems happens to list — on some cameras
#    that offers a FAT card to a flash filesystem driver before it reaches
#    vfat.
mount -t "$FS" "$DEV" "$MP"

# 4. Only resume onto a card that is actually there. A card with no partition
#    table has no $DEV at all, so this is the step that catches it.
if mountpoint -q "$MP"; then
	curl -s -X POST http://localhost/api/v1/records/resume
else
	echo "the new card is not mounted at $MP — format it, mount it, then resume"
	exit 1
fi
```

Check that `records.path` actually starts with `$MP` before you rely on this:
the values above are the common ones, not the only ones, and recording writes
where the configuration says rather than where you mounted the card.

If you leave it at step 4 without resuming, the pause expires by itself after
ten minutes and the recorder comes back to whatever is — or is not — at that
path. Fix the card or resume deliberately; do not walk away from it.

### On a build without the pause

Older cameras have no way to stop the recorder for a moment, so the card has to
be freed the long way: by switching recording off. This persists and it
interrupts more than a pause does, which is exactly why the endpoints exist —
but it is safe, and it is what to do until the camera is updated.

```sh
# 1. Turn recording off. This is written to majestic.yaml and survives a
#    reboot, so remember that you will be turning it back on.
cli -s .records.enabled false

# 2. Now the card can be released. If it still cannot, something other than
#    the recorder is holding it -- `lsof | grep mmcblk0p1` names what.
#    (busybox here has lsof but not fuser.)
umount /mnt/mmcblk0p1 || { cli -s .records.enabled true; exit 1; }

# --- swap the card ---

mount -t vfat /dev/mmcblk0p1 /mnt/mmcblk0p1
mountpoint -q /mnt/mmcblk0p1 || { echo "the new card did not mount"; exit 1; }

# 3. And back on.
cli -s .records.enabled true
```

On most SoCs writing `records.enabled` is charged as a full rebuild of the
video pipeline, so RTSP viewers re-sync and WebRTC sessions are dropped — once
when you turn it off and again when you turn it on. A live stream is worth
watching over while you do this.

**If you stop half way, recording stays off.** That is the trap the runtime
pause was added to close: there is nothing in `majestic.yaml` afterwards to
suggest the camera was ever meant to be recording, and the camera will not
switch it back on by itself. Check before you walk away:

```
cli -g .records.enabled
true
```

An **empty** answer is not `false` — it means the key is not in
`majestic.yaml` at all, which is also recording off, because the built-in
default is `false`. Either way, set it explicitly rather than leaving it
unset.

### Things that will surprise you

- **One swap at a time, per camera.** A second browser is refused rather than
  allowed to mount the card back while the first one is still telling somebody
  it is safe to remove. If a browser dies mid-swap, the camera releases the
  claim about a minute and a half later.
- **Older cameras cannot do this.** The button is shown disabled, with the
  reason, on a build whose Majestic has no pause endpoint. There is a
  procedure for those below; a bare unmount is not it, because recording will
  still be holding the card.
- **A pause is not `records.enabled: false`.** Setting that key persists, so a
  swap abandoned half way leaves recording switched off after the next reboot
  with nothing in the configuration to show why. It is also charged as a full
  pipeline rebuild on most SoCs, which re-syncs every RTSP viewer — twice per
  swap. Use the endpoints above for anything temporary.
- **The dashboard says so.** While a swap is running, the storage banner reads
  as an expected pause rather than a fault, so a deliberate card change does not
  page whoever is watching the camera.

### See also

- [Is the SD card actually storing your footage?](sd-card-diagnostics.md) —
  before you swap a card because you suspect it, and what to check on the one
  you put in.
- [Encrypted recordings on the SD card](recording-encryption.md) — what a thief
  gets if they take the card you just pulled.
- [Majestic streamer](majestic-streamer.md) — the recorder's own counters, and
  what survives a power cut.
