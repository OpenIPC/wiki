# OpenIPC Wiki
[Table of Content](../README.md)

## Factory reset and the unclaimed camera

A camera with no root password is *unclaimed*: it streams nothing, answers
nothing, and offers no shell until somebody sets one. [Web
interface](web-interface.md) covers what that means and how to set the password
through the browser. This page is about the parts that catch people out — that a
factory reset puts the camera back into that state, and that some doors cannot
ask you for a password and so are refused outright.

Firmware built on or after **30 August 2026**
([firmware#2342](https://github.com/OpenIPC/firmware/pull/2342)) ships root with
an empty password field. There is no `12345` and no `123456` on a current image;
a password published in a public repository is not a credential.

### A factory reset returns the camera to unclaimed

These three are the same operation:

- **System → Backup & Restore → Reset firmware** in the web interface
- `firstboot` on the camera
- `sysupgrade -n`

All of them erase the overlay partition, and the root password lives in the
overlay along with the network settings, the video settings and everything else
you configured. So a reset camera comes back **with no password**, exactly as if
it had just been flashed, and has to be claimed again before it streams or gives
you a shell.

`firstboot` is literally `sysupgrade -n`, and `-n` on its own writes no
firmware: downloading and flashing happen only when you also pass `-k`, `-r`,
`--url`, `--channel`, `--build` or `--archive`. A reset erases the overlay and
reboots, and that is all it does. (`sysupgrade` with no options at all does
nothing but print the camera's identity — see [Upgrade
firmware](sysupgrade.md).)

Reaching for `12345` after a reset is the most common way to run into this. It
is not that the password is wrong — there is no password for it to be wrong
against, and the connection you are being refused was never going to ask you for
one. Do this instead:

```sh
ssh root@<camera-ip>
```

Send no password at all. The camera accepts the connection and runs a one-time
prompt that asks you to choose one:

```
This camera has not been set up yet. It streams nothing and answers nothing
until root has a password -- set one now to finish setting it up. The same
password is used by the web interface, SSH, RTSP and ONVIF.

Changing password for root
New password:
```

Once it is set you land in a normal shell, and every login after that is an
ordinary one. The serial console behaves identically: log in as `root`, no
password is asked for, the same prompt runs.

If a client insists on sending a password, send an empty one.

### `scp`, `sftp` and `ssh camera command` are refused

The prompt above is root's login shell, so it sits on the path of every door —
including the ones that never show you anything to type into. A file copy or a
remote command has no way to ask you for a password, so instead of a bare
"permission denied" the camera explains itself:

```
This camera has not been set up yet, so it has no shell to offer.
Log in interactively (ssh root@camera, or the serial console),
or open http://camera/ in a browser, to set a root password.
```

This is what WinSCP, `scp`, `rsync`, `ansible` and any provisioning script will
hit on a camera nobody has claimed yet. Claim it first — interactively over SSH,
or on the setup page — and they all work normally afterwards.

Anything that assumed `root:12345` on a fresh camera needs the same treatment:
flashing lines, CI, NVR onboarding, and any third-party guide that still hands
out those credentials. There is no default password to script against, by
design.

### Cameras deliberately run with no password

An empty root password used to mean "authentication off", and some cameras were
deliberately left that way (`passwd -d root`) to serve open RTSP. That meaning is
now inverted — empty means *unclaimed* — so such a camera stops streaming.

The setting that has always meant "serve without authentication" is
`system.unsafe: true` in `/etc/majestic.yaml`; see [Majestic
streamer](majestic-streamer.md). Claim the camera, then turn it on. It is
deliberately not applied for you, because silently keeping a camera open would
defeat the point of the change. It opens every endpoint to anyone who can reach
the port, so it belongs on an isolated bench and nowhere else.

### Forgotten the password?

There is no recovery over the network, and that is the point of it. Reset the
camera to factory state and claim it again — from the web interface, from a
shell with `firstboot`, or, if you cannot reach the camera at all, by erasing
the overlay partition from the bootloader over a serial console. The FAQ entry
[How to reset password for SSH/Web UI?](faq.md) has the `sf erase` addresses.
