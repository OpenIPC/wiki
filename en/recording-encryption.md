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
| the passphrase or private key was lost | readable | **lost** | **lost** without a recovery key | **lost** |
| plays in the web interface | yes | not yet | no | no |

Only `pubkey` survives a stolen camera — for the clips already written, not for
the one still open — and it is the one mode where the camera cannot play its own
recordings. Everything else keeps something on the camera that opens the clip,
and whoever has the camera has that too.

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
