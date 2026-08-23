# OpenIPC Wiki
[Table of Content](../README.md)

Majestic plugins
----------------

Majestic can load one shared library of your own at startup and expose the
functions inside it as text commands on a local socket. It is the supported way
to reach a knob the streamer itself does not expose — a vendor `/proc` control, a
GPIO, an SDK call — without patching Majestic, which is closed source.

The plugin sources live in [OpenIPC/majestic-plugins][repo], with a working
sample per SoC vendor. They are licensed under the Prosperity Public License
3.0.0 (noncommercial use, thirty-day commercial trial).

### How it works

With `system.plugins` enabled, Majestic `dlopen`s `/usr/lib/<vendor>.so` — the
vendor being `hisilicon`, `ingenic` or `sigmastar`, matching the directory the
plugin was built from — and starts a command server on `127.0.0.1:4000`:

```
07:33:17 DEBUG <majestic> [plugins] plugin_init@46: Loading: /usr/lib/sigmastar.so
```

```
root@openipc-ssc30kq:~# netstat -ltn | grep 4000
tcp        0      0 127.0.0.1:4000          0.0.0.0:*               LISTEN
```

Each line you send is split into a command and a value, matched against the
plugin's command table, and the answer comes back on the same connection:

```
root@openipc-ssc30kq:~# echo help | nc -w 2 localhost 4000
Usage: precrop node help
```

The socket is bound to the loopback address, so commands can only come from the
camera itself. To reach it from elsewhere, proxy it deliberately — for example
through a CGI script under `/var/www/cgi-bin/`, with whatever authentication
that deserves.

### Building and installing

The package is `general/package/legacy/majestic-plugins/` in the firmware tree.
No board configuration selects it, so **no stock image ships a plugin**: build it
for your board and upload it yourself.

```
make BOARD=ssc377qe_lite br-majestic-plugins-rebuild
scp -O output/build/majestic-plugins-HEAD/sigmastar.so root@192.168.1.10:/usr/lib/
```

Then, on the camera, switch plugin support on and restart Majestic so it loads
the library:

```
curl -s 'http://localhost/api/v1/set?system.plugins=true'
killall -HUP majestic
echo help | nc -w 2 localhost 4000
```

Nothing else is needed on the camera side: `nc` is part of the BusyBox build
shipped in every image.

### What a plugin is allowed to call

A plugin is `dlopen`ed into the running Majestic process and links against
nothing itself, so it can only call functions that are *already* in that
process. Whether the vendor SDK is among them depends on how Majestic was built
for that platform:

| Platform | Vendor libraries Majestic links | SDK calls from a plugin |
|---|---|---|
| HiSilicon / Goke | `libmpi.so`, `libisp.so`, `libive.so`, … | resolve |
| Ingenic | `libimp.so`, `libsysutils.so`, … | resolve |
| SigmaStar | none — the SDK is linked into the binary | **do not resolve** |

On SigmaStar the image carries no `libmi_*.so` at all (the vendor driver package
installs them only when Majestic is absent), so a plugin calling into the MI API
fails to load, and Majestic says so and carries on without it:

```
WARN  <majestic> [plugins] plugin_init@50: /usr/lib/sigmastar.so: undefined symbol: MI_ISP_IQ_GetBrightness
```

That is what happens today with the sample `sigmastar/custom.c`, whose commands
are written against `MI_ISP_IQ_*`. Majestic links no MI library on Infinity6B0,
6C or 6E, so the sample cannot load on any SigmaStar board as it stands. A
SigmaStar plugin has to drive the hardware through the kernel modules'
`/proc/mi_modules/` interface instead, which is also what the vendor debug
commands use.

### Adding a command

A command is a function taking the rest of the line as its argument, plus one row
in the table at the bottom of `<vendor>/custom.c`. `RETURN` is a `snprintf` into
the shared answer buffer:

```c
#include <errno.h>   /* plugin.h pulls in stdio/stdlib/string/unistd only */

#define SCL_NODE "/proc/mi_modules/mi_scl/mi_scl0"

static void set_precrop(const char *value) {
	FILE *f = fopen(SCL_NODE, "w");
	if (!f) {
		RETURN("open %s failed: %s", SCL_NODE, strerror(errno));
	}

	int n = fprintf(f, "setprecrop %s\n", value);
	fclose(f);

	RETURN("wrote 'setprecrop %s' to %s (%d bytes)", value, SCL_NODE, n);
}

static table custom[] = {
	{ "precrop", &set_precrop },
	{ "help", &get_usage },
};
```

Which gives a crop control the streamer does not have, callable from any script.
The node names are family-specific, and this one does not exist on every
SigmaStar — the same command on an Infinity6E board answers:

```
root@openipc-ssc30kq:~# echo "precrop 0 0 0 220 2560 1480" | nc -w 2 localhost 4000
open /proc/mi_modules/mi_scl/mi_scl0 failed: No such file or directory
```

`mi_scl` is the Infinity6C (SSC37x) scaler; Infinity6E scales through `mi_vpe`
and `mi_divp` instead. Check `ls /proc/mi_modules/` on the camera before
hardcoding a path, and report the failure rather than ignoring it — a plugin that
returns `strerror(errno)` is far easier to debug over `nc` than one that silently
does nothing.

The answer buffer is 512 bytes and is sent in full, padded with spaces; pipe the
reply through `tr -s ' '` if the padding bothers you.

### Running code on every Majestic start

A plugin is loaded again on every start, so a constructor in it is effectively a
"Majestic has just started" hook — the closest thing to a lifecycle script the
streamer offers today:

```c
__attribute__((constructor)) static void on_load(void) {
	/* runs on every dlopen, i.e. every Majestic start and every SIGHUP */
}
```

Where that falls in the startup sequence, and what does *not* re-trigger it:

| Event | Plugin (re)loaded |
|---|---|
| Majestic start, after SDK init and encoder channel creation, just before the RTSP server | yes |
| `killall -HUP majestic` (what the WebUI and `cli` use to apply a change) | yes |
| A parameter set live through the HTTP API, such as `?video0.size=1920x1080` | no |

So settings applied through the vendor's `/proc` interface, which a pipeline
rebuild resets, can be re-applied from the constructor without any external
timer. A live parameter change is applied in place by Majestic and does not pass
through the plugin, so a knob that must follow the resolution has to be
re-applied by whoever changes it — send the plugin command right after the API
call that changed the setting.

The one script hook Majestic has of its own is
[`/usr/sbin/motion.sh`](majestic-streamer.md), run on a motion event.

### Vendor headers

`<vendor>/include` in the plugin repository is a symlink into a pinned submodule
(`glutinium/sigmastar-osdrv-ssc335`, `glutinium/hisi-osdrv4`, `capjpeg`), so the
samples compile against one SDK generation per vendor — SSC335-era headers for
all SigmaStar boards, for instance. Structure layouts drift between SDK versions,
which is one more reason to prefer the `/proc` interface on a platform whose SDK
is newer than the headers.

### See also

- [Majestic streamer](majestic-streamer.md) — HTTP API, motion script, control signals
- [Majestic example config](majestic-config.md) — where `system.plugins` lives

[repo]: https://github.com/OpenIPC/majestic-plugins
