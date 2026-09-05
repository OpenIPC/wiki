# OpenIPC Wiki
[Table of Content](../README.md)

## Encrypted recordings on the SD card

A camera in a public place records to a card anyone can pull, in a body anyone
can carry off. `records.encryption` decides what a thief gets. This page is what
each setting protects, what it does not, and how to get a clip back afterwards.

Before firmware from **September 2026** there was `records.key`, which XORed the
payload with a repeating key and named the files `.enc`. That was obfuscation,
not encryption — the key sat in `majestic.yaml` in plain text, the same key
repeated over every frame, and nothing could play the result. It has been
removed. If your config still carries `records.key` with `records.encryption`
unset, the clips are being written in the clear and Majestic says so in the log.

### Which mode protects what

| what happened | `none` | `passphrase` | `chip` | `pubkey` |
|---|---|---|---|---|
| the card was pulled, or copied | readable | as strong as the passphrase | unreadable elsewhere | unreadable elsewhere |
| the flash was cloned, `majestic.yaml` included | readable | **readable** | unreadable | unreadable |
| the camera was stolen, and somebody has a shell on it | readable | readable | **readable** | unreadable (clips already closed) |
| the camera died or was replaced | readable | readable, with the passphrase | **lost** without a recovery key | readable with your private key |
| the passphrase or private key was lost | readable | **lost** without a recovery key | **lost** without a recovery key | **lost** |
| plays in the web interface | yes | not yet | no | no |

Only `pubkey` survives a stolen camera — for the clips already written, not for
the one still open — and it is the one mode where the camera cannot play its own
recordings. Everything else keeps something on the camera that opens the clip,
and whoever has the camera has that too.

### Which mode is yours

The table says what each mode survives. This says who each one is for.

#### `passphrase` — the shop, the rental, the hobby camera

A shop with two cameras and a 128 GB card in each. The threat is the obvious
one: somebody yanks a card, or the camera is carried off and sold for parts with
the card still in it. The owner types one passphrase into the settings page,
keeps it in a password manager, and that is the whole setup. When something
happens they pull the card, open the clip on a laptop, and hand a decrypted copy
to the police.

That survives the realistic attack — a thief who wants hardware, not footage —
and fails the unrealistic one, somebody who images the flash to read the
passphrase out of it.

It is also the only mode where a second person gets access with no key handling
at all: tell the manager the passphrase and they can open last night's clip
themselves.

#### `chip` — the fleet, and the camera that comes back from the field

Two hundred cameras on poles. Cards get swapped by field technicians, cameras go
back for repair, old cards get recycled or lost — that is the leak, not a
burglar. A card that falls out of the chain of custody is worthless to whoever
finds it: it opens on the one chip that wrote it, and there is no passphrase for
anybody to forget, share, or paste into a ticket.

It also survives what `passphrase` does not. A camera taken off a pole and its
flash read out gives up nothing, because the key is in the chip and not in the
filesystem.

The reason to prefer it over `passphrase` at this size is that no secret ever
leaves a camera or has to reach the other 199. Burn a slot once at install and
there is nothing to rotate, nothing to type, and nothing an installer can copy
into a spreadsheet. Its honest limit is that a stolen powered-up camera with a
shell on it still decrypts its own clips — which across a pole-mounted fleet is
a smaller worry than two hundred people knowing one passphrase.

#### `pubkey` — the footage itself is the target

A camera on a cash office, a pharmacy dispensary, a contested driveway, a
journalist's front door. Here whoever might take the camera is the person in the
footage, and they will take the whole camera, powered or not. Every other mode
hands them the clips: the passphrase is in the flash, and the chip unwraps for
whoever is holding it.

The owner keeps the private key on a laptop or a stick at home; the camera holds
the public half and cannot play back what it recorded. A thief gets a box of
electronics and a card of noise — including the recording of themselves taking
it.

Two more places it earns the inconvenience:

- **Custody.** Because the camera cannot decrypt, nobody at the camera end can
  quietly edit a clip and seal it up again. With the per-fragment integrity
  chain, "this file is what the camera wrote" is a claim you can defend rather
  than one you hope holds.
- **Somebody else administers the camera.** A landlord or an installer keeps
  SSH, firmware and settings while the tenant holds the private key and is the
  only one who can watch anything. In the other two modes, whoever administers
  the camera can read every recording on it.

#### The combination most installations actually want

`chip` or `passphrase` for everyday protection, plus a recovery key for the day
the everyday one is gone.

The whole idea in one paragraph. Every clip is locked with its own key, and that
key travels inside the clip in a locked box. What `records.encryption` chooses
is what opens that box: the passphrase you typed, the chip in this particular
camera, or your private key. Setting `publicKey` **as well** puts a second box
into every clip, holding the same key, and that one opens only with your private
key. Two boxes, either one enough. Nobody gets a shortcut — a thief still has to
open one of them — but you now have two ways in instead of one.

You want the second way because the first one lives at the camera, and the
camera is the thing that goes wrong:

- **The board dies.** In `chip` mode the key is inside that chip and nowhere
  else, so a dead camera leaves a stack of cards nobody can ever read again.
  That is not an attack; that is a failed board, and it is the most common way
  people actually lose their footage.
- **The passphrase is forgotten**, or the person who chose it has left, or it
  only ever existed in one password manager on one laptop.
- **The camera is replaced.** The new one has a different chip, and the old
  cards do not open on it.

Setting it up takes three commands, once, on your own computer — not on the
camera:

```sh
openssl genrsa -out owner.pem 2048
openssl rsa -in owner.pem -pubout -out owner.pub
scp owner.pub root@camera:/etc/records-owner.pub
```

`owner.pem` is the recovery key. It must never go on the camera; the entire
point is that it lives somewhere the camera is not. A USB stick in a safe, a
password manager, a printout in a drawer — anywhere it will outlive the camera.
`owner.pub` is the public half and is harmless: it can lock, and it cannot
open.

Then name it in the config beside the mode you are actually running. With
`chip`:

```yaml
records:
  enabled: true
  encryption: chip
  chipSlot: 1
  publicKey: /etc/records-owner.pub   # the recovery slot
```

or with `passphrase`:

```yaml
records:
  enabled: true
  encryption: passphrase
  key: "a long passphrase"
  publicKey: /etc/records-owner.pub   # the recovery slot
```

**It only covers clips recorded after you set it.** The recovery box goes into
each clip as that clip is written, and nothing can go back and add one to a
recording already sitting on the card. Do this on day one, before there is
anything on the card you would miss.

The day you need it, the camera is not involved at all — which is the point,
because in the case you are most likely to be in, the camera is broken or gone.
Take the card, copy the clip to your computer, and open it exactly as the
`pubkey` section below describes: the recovery tool pulls the sealed box out of
the clip and prints the `openssl` line to run against `owner.pem`, and feeding
that result back to the tool prints the key for `ffmpeg`.

Do that once now, on a clip you do not care about. Practising the recovery is
how you find out the safe holds the right file, and the time to find that out is
not the morning you need last night's footage.

It costs nothing you will notice day to day: recording behaves exactly as it did
before, and the extra box is a rounding error in a file measured in megabytes.

If you are already running `pubkey`, you have this — the private key *is* the
recovery key, and there is no second slot to add.

### The file is still an MP4

Whatever the mode, an encrypted recording is an ordinary MP4 using the standard
Common Encryption scheme players already understand. It keeps its `.mp4` name,
and given the key it plays with:

```
ffmpeg -decryption_key <32 hex characters> -i clip.mp4 -c copy clear.mp4
```

Every clip has its own key and carries what is needed to open it, so there is no
key database to keep, nothing to back up per file, and no key shared between two
recordings.

A clip that has been cut short, edited or had parts reordered can be told apart
from an intact one; the recovery tool reports how much of a clip it can vouch
for.

### `passphrase` — protects a card somebody removed

```yaml
records:
  enabled: true
  encryption: passphrase
  key: "a long passphrase"
```

Turning the passphrase into a key is deliberately slow, which is why the first
clip after a restart takes about a second to begin. It happens once, not per
clip.

It does **not** protect a stolen camera: the passphrase is in `majestic.yaml`,
and anyone who can read the flash can read it. Use it when the risk you are
addressing is a card walking out of a device that stays put.

A forgotten passphrase is a total loss on its own. Set `publicKey` alongside it
for a recovery slot, as described above.

To open a clip you copy it to your own machine and use Majestic's offline
recovery tool (`--help` lists its commands; it needs Python 3 and never talks to
the camera). Give it the clip and the passphrase and it prints the clip's key,
which is what `ffmpeg` wants:

```
ffmpeg -decryption_key <the key it printed> -i clip.mp4 -c copy clear.mp4
```

The same tool tells you what a clip carries and whether it is intact, which is
worth running before you need it in earnest.

### `pubkey` — protects a stolen camera

```yaml
records:
  enabled: true
  encryption: pubkey
  publicKey: /etc/records-owner.pub
```

Make the pair on your machine, and put **only the public half** on the camera:

```
openssl genrsa -out owner.pem 2048
openssl rsa -in owner.pem -pubout -out owner.pub
scp owner.pub root@camera:/etc/records-owner.pub
```

Each clip's key is sealed to that public key. The camera has no private half, by
design, so nothing on it — not the root account, not a copy of its flash —
can open a recording. That is the point, and the costs follow from it: the
camera cannot play its own clips, and after a restart it records beside the
interrupted clip rather than resuming it.

Recovery needs the private key, and never the camera. The recovery tool extracts
the sealed blob from the clip and prints the exact `openssl pkeyutl -decrypt`
line to run against it; feed what openssl produces back to the tool and it prints
the clip's key for `ffmpeg`. Three commands, none of which involve the camera.

**Keep `owner.pem` somewhere you will still have it in three years.** Lose it and
every clip ever written in this mode is gone. There is no other copy anywhere.

### `chip` — binds the clip to this camera's silicon

HiSilicon gen 4 only for now (hi3516cv500/av300, hi3516ev200/ev300, gk7205v200),
and only after a key has been burned into the chip.

```yaml
records:
  enabled: true
  encryption: chip
  chipSlot: 1
  publicKey: /etc/records-owner.pub   # strongly recommended, see below
```

The camera's chip carries a key that was written into it once and cannot be read
back out — not by software on the camera, not by anything reading the flash.
Recordings are locked to that one chip: a card, or a whole copy of the flash,
opens on no other camera.

It does **not** protect a stolen camera. The chip will still do the unlocking for
whoever is holding it, and these boards have no verified boot to stop someone
getting a shell, so a stolen camera is a camera that decrypts its own clips.

Provisioning is irreversible, once per slot for the life of the chip, and there
are three slots:

```
majestic --otp-status                                  # engine, slots, what is programmed
majestic --otp-burn --otp-slot 1 --dry-run             # everything except the write
/etc/init.d/S95majestic stop
majestic --otp-burn --otp-slot 1 --i-understand-this-is-irreversible
reboot
```

The key is random, used once, and never stored or shown to anybody — there is no
copy of it, on the camera or off it. Majestic refuses to write to a slot that is
already used, refuses to record against a slot that is still empty, and checks
afterwards that the key really took. Stop the daemon first: it uses the same
hardware, and the write needs it to itself.

**Set `publicKey` as well.** A chip clip with nothing else in it cannot be opened
off the camera at all, and cannot be opened by anybody once the camera is dead or
the board is replaced. The public key adds a recovery slot to every clip, opened
exactly as in the `pubkey` section above.

### What no mode protects

- **Live streams.** RTSP, HLS, WebRTC and snapshots serve plaintext to whoever
  authenticates. This is about the card, not the network.
- **The clip being written right now.** Its key is on the camera for as long as
  that clip is open — in every mode, `pubkey` included.
  What `pubkey` protects is the recordings already closed on the card; someone
  who takes a running camera and gets a shell still has the current clip, the
  live video, and everything recorded from then on.
- **Metadata.** File names carry the time, sizes carry the bitrate, and the frame
  boundaries stay readable. Someone with the card knows when the camera recorded
  and roughly how much was moving — not what.

### Things that surprise people

- **A mode Majestic cannot honour stops the recording** rather than writing in
  the clear: a passphrase that is empty, a public key it cannot read, a blank
  chip slot. The reason is in the log, and `records_state` in `/metrics` is not
  zero. This is deliberate.
- **Changing the mode costs up to one GOP of video.** The new clip has to start
  on a keyframe, so on a camera with a 30-second GOP you lose up to 30 seconds at
  the switch. Change it when nothing important is happening.
- **The cost while recording** is about 7% of one CPU core per MB/s written, so
  roughly 3-4% of a core at 4 Mbit/s on a Cortex-A7 class SoC. Most of that is
  the integrity chain rather than the cipher, and `chip` and `passphrase` cost
  the same, because both use the camera's own encryption hardware where it has
  some. Measure
  your own: sum `utime`+`stime` across `/proc/$(pidof majestic)/task/*/stat` over
  a minute with encryption off, then again with it on, at the same bitrate.
- **The web interface cannot play these yet.** Encrypted clips download and open
  on your own machine with the recipes above.

### See also

- [Majestic example config](majestic-config.md) — the whole `records:` block
- [Majestic streamer](majestic-streamer.md) — what else the recorder can do
