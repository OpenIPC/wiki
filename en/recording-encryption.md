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
recordings. Everything else keeps something on the camera
that opens the clip — and whoever has the camera has that too.

### The file is still an MP4

Whatever the mode, an encrypted recording is an ordinary fragmented MP4 using
Common Encryption (`cenc`, AES-128-CTR), keeps its `.mp4` name, and plays with:

```
ffmpeg -decryption_key <32 hex characters> -i clip.mp4 -c copy clear.mp4
```

Each clip has its own key, drawn when the file is opened, and carries that key
inside itself — wrapped, once per configured mode. Nothing on the camera has to
remember which key went with which file, and no key is ever reused.

Every fragment also carries a chained HMAC, so a clip that was cut, reordered or
edited is detectable. `records_key.py verify` reports how far the chain holds.

### `passphrase` — protects a card somebody removed

```yaml
records:
  enabled: true
  encryption: passphrase
  key: "a long passphrase"
```

The passphrase is stretched into a key-wrapping key — deliberately slowly, which
is why the first clip after a restart takes about a second to start — and that
wraps each clip's own key.

It does **not** protect a stolen camera: the passphrase is in `majestic.yaml`,
and anyone who can read the flash can read it. Use it when the risk you are
addressing is a card walking out of a device that stays put.

To open a clip, on your own machine, with `records_key.py` — the offline
recovery tool published with Majestic, which needs only a Python 3 install and
never touches the camera:

```
records_key.py dump clip.mp4                                # what this clip carries
records_key.py verify --passphrase 'a long passphrase' clip.mp4
records_key.py unwrap  --passphrase 'a long passphrase' clip.mp4   # prints the hex key
ffmpeg -decryption_key <that key> -i clip.mp4 -c copy clear.mp4
```

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
design, so nothing on it — not root, not a flash image, not the crypto engine —
can open a recording. That is the point, and the costs follow from it: the
camera cannot play its own clips, and after a restart it records beside the
interrupted clip rather than resuming it.

Recovery needs the private key, and never the camera:

```
records_key.py unwrap --rsa-blob blob.bin clip.mp4
openssl pkeyutl -decrypt -inkey owner.pem -in blob.bin -out material.bin \
    -pkeyopt rsa_padding_mode:oaep -pkeyopt rsa_oaep_md:sha256 -pkeyopt rsa_mgf1_md:sha256
records_key.py verify --material material.bin clip.mp4
records_key.py unwrap --material material.bin clip.mp4      # the hex key for ffmpeg
```

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

The clip's key is wrapped by the SoC's key ladder under a key in one-time
programmable memory, and it unwraps only on that die — and only into the crypto
engine, never into memory. A card or a whole flash image is unreadable anywhere
else, because the key is in neither.

It does **not** protect a stolen camera. A key ladder unwraps for whoever can
talk to it, so root on the camera can decrypt; and these boards have no secure
boot, so a stolen camera is a camera with root.

Provisioning is irreversible, once per slot for the life of the chip, and there
are three slots:

```
majestic --otp-status                                  # engine, slots, what is programmed
majestic --otp-burn --otp-slot 1 --dry-run             # everything except the write
/etc/init.d/S95majestic stop
majestic --otp-burn --otp-slot 1 --i-understand-this-is-irreversible
reboot
```

The key is drawn from the chip's hardware random generator mixed with the
kernel's, used once, and never stored or printed. Majestic refuses to burn a
slot that is not blank, refuses to record against a slot that is blank, and
verifies the burn through the ladder afterwards. The daemon has to be stopped
first, because it drives the same hardware.

**Set `publicKey` as well.** A chip clip with nothing else in it cannot be opened
off the camera at all, and cannot be opened by anybody once the camera is dead or
the board is replaced. The public key adds a recovery slot to every clip, opened
exactly as in the `pubkey` section above.

### What no mode protects

- **Live streams.** RTSP, HLS, WebRTC and snapshots serve plaintext to whoever
  authenticates. This is about the card, not the network.
- **The clip being written right now.** Its key is in RAM, or in the crypto
  engine, for as long as that clip is open — in every mode, `pubkey` included.
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
  the same, because both use the crypto engine where the camera has one. Measure
  your own: sum `utime`+`stime` across `/proc/$(pidof majestic)/task/*/stat` over
  a minute with encryption off, then again with it on, at the same bitrate.
- **The web interface cannot play these yet.** Encrypted clips download and open
  on your own machine with the recipes above.

### See also

- [Majestic example config](majestic-config.md) — the whole `records:` block
- [Majestic streamer](majestic-streamer.md) — what else the recorder can do
