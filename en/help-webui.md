# OpenIPC Wiki
[Table of Content](../README.md)

Help: Web UI
------------

### Updating Web UI from Web UI.

In some cases, especially if you think that something does not work as it should,
try to update Web UI once more, overriding version checking for the second update.
This may be required because of some changes we have possibly made to the updating
routine, thus you shall retrieve the updating routine code with the first update,
and then use it for the consecutive update.

### Web UI Development.

If you want to help us with developing of the web interface for our
firmware, here is what you need to know beforehands. Cameras are very
limited in terms of space and performance. The only available option
we have now in the firmware which is more or less suitable for dynamic
generating of HTML pages is `haserl`, a fancy cousin of `ash` bent for
serving as a CGI wrapper. Did I say `ash`? Right, because we don't have
`bash`, `tcsh`, `zsh` in our Linux. Ash it is. As in A shell, full name
Almquist shell. Tiny, lightweight, and kinda limited. System is limited,
too -- in most parts it is `busybox`. So, if you still feel comfortable
to make your hands dirty with a very 80s style of web development then
welcome aboard.

Recent interface is built around [Bootstrap](https://getbootstrap.com/)
CSS framework which is a little overkill for the purpose but allowed us
to fast-track from the original microbe web to what we have now. We would
like to slim down the original Bootstrap bundle and create a custom pack
with only the features we use. If you posses such a skill, come and work
with us.

Also, we're considering the possibility of switching to a client-side
web interface builder, leaving only data-tossing to the server. Vue.js
or similar. Have something to add here? Spill it out.

Any other ideas? We would like to listen them, too.

### Running a development version of Web UI.

To start improving the web interface, clone its GitHub repo locally and
 set up an NFS mount on your camera to the root directory of the local copy:

```bash
mkdir -p /tmp/dev
mount -t nfs -o nolock,tcp 192.168.1.123:/full/path/to/web/files /tmp/dev
```

> _(replace 192.168.1.123 and /full/path/to/web/files with your own IP and path)_

Then start another instance of httpd daemon to serve your version of Web UI
on another port of the camera, say port 86:

```bash
httpd -p 86 -h "/tmp/dev/var/www" -c /dev/null
```

Now you can work on Web UI source code in your favorite IDE or a text editor
on your workstation, and immediately test the changes with a web browser
pointed to port 86 on the camera. _(E.g. http://192.168.1.10:86/)_

Remember that you substitute only web server contents, but there are also
supporting scripts residing outside web directory. These scripts might require
updating on camera in case you make changes to them, as well. To update a
script on camera, open ssh session to the camera and copy updated version of
the script from `/tmp/dev/usr/sbin/` to `/usr/sbin/`.
