# OpenIPC Wiki
[Table of Content](../README.md)

Web interface
---------------------

Web Interface is available on port 80 as _http://camera-ip_.

A new camera has **no password at all**, and it streams nothing until it has
one — RTSP, ONVIF and every page but the setup screen are refused. So the first
thing it does is ask you to choose a password. That password belongs to _root_,
and it is the one the web interface, SSH and RTSP all check.

ONVIF accepts it too from clients that send HTTP Basic or WSSE PasswordText.
Clients that authenticate with a **digest** — WSSE PasswordDigest, which is what
most ONVIF clients try first, or HTTP Digest — cannot use it: a digest is computed
over the cleartext password, and the system password database stores only a one-way
hash. For those clients set `onvif.password` (and `onvif.username`) separately in
Majestic's configuration.

Setting it can also be done over SSH or the serial console: log in
interactively and the camera walks you through `passwd` before giving you a
shell. Whichever door you use, the other sees it immediately.

> Firmware from before August 2026 shipped with a default password of _12345_
> instead, and nagged you to change it after you had signed in with it.

A factory reset erases the password along with the rest of the overlay, so the
camera comes back with none — see [Factory reset and the unclaimed
camera](first-boot.md), which also covers why `scp` and `ssh camera command` are
refused until the camera has been claimed.

### Settings that live on the camera

`/etc/webui/webui.conf` is where the web interface keeps decisions that belong
to the camera rather than to a browser. It is a shell file, read by every page:

```
webui_theme="dark"
webui_lpr_base="https://mirror.example/lpr-wasm/dist/"
```

- `webui_theme` — `light`, `dark` or `auto`. Set from **Access** in the
  interface; there is no reason to edit it by hand.
- `webui_lpr_base` — where the [raw editor](raw-editor.md#plates) fetches the
  number plate reader from. Absent, it uses the release the firmware was built
  against, from a public CDN. Set it to point a camera at a mirror of your own.

`/etc` rather than somewhere under `/var/www`, because updating the web
interface replaces the whole of `/var/www` and a choice made there would not
survive it.

> Web interface builds before 2026-09-18 rewrote this file from scratch when you
> changed the theme, which deleted `webui_lpr_base` along with it. If a camera
> goes back to fetching the reader from the public CDN after a theme change —
> or loses its Plates tab, where it has no route to one — that is what happened:
> add the line again, and update the web interface.

### Another camera's picture on the live view

Where two cameras look at the same place, the live view of one can draw where
the other looks and, on a click, lay the other camera's live video over that
part of its own picture, aligned with it. The **Peer** control appears on the
live view's bar once the camera has a calibration for a camera it can see on
the network; the first click inside the outline asks for the other camera's
password, once. The whole setup is in
[Two cameras, one scene](two-cameras-one-scene.md).

### Focusing a lens by ear on the live view

On a camera that measures focus, the live view's bar has a **By ear** toggle:
the sharpness reading becomes beeps that come faster and higher as the lens
nears the sharpest point, a low note when it has gone past, and one held tone
when it is back on it, so a lens can be set from a ladder without looking at
the phone. What each sound means, and what resets the reference, is in
[Autofocus and manual focus](autofocus.md#focusing-by-ear).

### Updating the web interface from the web interface

In some cases, especially if it seems that something is not working, you might
need to re-install the web interface update by checking the "Install even if
matches the existing version." checkbox.

Double updating of the web interface can be necessary if we've made some changes
to the code of updating procedure per se. In such case, the first update routine
will install the modified code, and the second round will be performed using
that updated code.
