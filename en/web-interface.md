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

### Updating the web interface from the web interface

In some cases, especially if it seems that something is not working, you might
need to re-install the web interface update by checking the "Install even if
matches the existing version." checkbox.

Double updating of the web interface can be necessary if we've made some changes
to the code of updating procedure per se. In such case, the first update routine
will install the modified code, and the second round will be performed using
that updated code.
