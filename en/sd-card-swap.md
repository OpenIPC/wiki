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
  mount outlived the card, so the *next* card was silently never mounted — the
  camera looked fine, streamed fine, and recorded nothing until somebody
  rebooted it. Nothing was logged either, because the hotplug helper runs with
  nowhere to write messages. Newer firmware releases the mount when the card
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
   for it to leave.
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

Two endpoints pause and resume the recorder. Both are **POST**, both take
effect immediately, and — unlike every other way of changing what Majestic is
doing — **neither writes anything to `majestic.yaml`**:

```
curl -X POST http://localhost/api/v1/records/standdown
{"stoodDown":true,"resumesInSec":600}

curl -X POST http://localhost/api/v1/records/resume
{"stoodDown":false,"resumesInSec":0}
```

These run on the camera. From another machine, address the camera and supply
its credentials — `curl -u root:PASSWORD -X POST
http://<camera-address>/api/v1/records/standdown` — and note that a `GET` is
refused with **405** and a request arriving from another site with **400**, so
neither a prefetched link nor a page on someone else's site can stop your
camera recording.

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
curl -s http://localhost/metrics | grep records_stood_down
records_stood_down 1
```

A full manual swap is then:

```
curl -X POST http://localhost/api/v1/records/standdown
umount /mnt/mmcblk0p1
# swap the card
mount -t vfat /dev/mmcblk0p1 /mnt/mmcblk0p1
curl -X POST http://localhost/api/v1/records/resume
```

Name the filesystem when you mount by hand. An unqualified `mount` asks the
kernel to guess, and it guesses in the order `/proc/filesystems` happens to
list — on some cameras that offers a FAT card to a flash filesystem driver
before it reaches `vfat`.

### Things that will surprise you

- **One swap at a time, per camera.** A second browser is refused rather than
  allowed to mount the card back while the first one is still telling somebody
  it is safe to remove. If a browser dies mid-swap, the camera releases the
  claim about a minute and a half later.
- **Older cameras cannot do this.** The button is shown disabled, with the
  reason, on a build whose Majestic has no pause endpoint. Unmount, change the
  card and mount it again instead — on firmware from September 2026 that is
  safe, it is just not guided.
- **A pause is not `records.enabled: false`.** Setting that key persists, so a
  swap abandoned half way leaves recording switched off after the next reboot
  with nothing in the configuration to show why. It is also charged as a full
  pipeline rebuild on most SoCs, which re-syncs every RTSP viewer — twice per
  swap. Use the endpoints above for anything temporary.
- **The dashboard says so.** While a swap is running, the storage banner reads
  as an expected pause rather than a fault, so a deliberate card change does not
  page whoever is watching the camera.

### See also

- [Encrypted recordings on the SD card](recording-encryption.md) — what a thief
  gets if they take the card you just pulled.
- [Majestic streamer](majestic-streamer.md) — the recorder's own counters, and
  what survives a power cut.
