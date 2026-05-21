# OpenIPC Wiki
[Table of Content](../README.md)

## Nightly builds, dated releases, and bisecting regressions

Since the redesign of the [firmware](https://github.com/OpenIPC/firmware) CI pipeline in May 2026, every nightly build is **content-addressable**: it has its own dated GitHub Release, a 90-day history is retained, and a public manifest indexes every artifact. Cameras can pin to a specific historic build, downgrade after a bad update, and bisect to find which nightly introduced a regression.

This article is for users who need to:

- Get the **current** nightly without thinking about it (the default, see [sysupgrade](sysupgrade.md)).
- **List** what builds are available for their camera.
- **Pin** to a specific dated build (downgrade after a bad update, or pin a known-good version on a fleet).
- **Bisect** to find which nightly broke a feature (no image at all, broken device driver, missing UI element, anything).

For the more traditional flag set (offline `--archive`, `--kernel`/`--rootfs` from TFTP/SD/scp), see the [Upgrade firmware](sysupgrade.md) article. This document only covers the manifest-aware additions in `sysupgrade ≥ 1.0.50`.

__ATTENTION! Upgrading firmware can lead to "bricking" your camera. Have a UART adapter and a rescue SD card ready before you start a bisect. The bisect tool itself stores state on your workstation, so a brick during bisect does not lose progress — but you still need to get the camera back online.__

---

## The pieces

### The manifest

A JSON-and-text index of every dated nightly is served from GitHub Pages:

| URL                                                                                       | Format                                            | Audience                          |
|-------------------------------------------------------------------------------------------|---------------------------------------------------|-----------------------------------|
| <https://openipc.github.io/firmware/manifest.json>                                        | Rich JSON                                         | Hosts, agents, CI tooling         |
| <https://openipc.github.io/firmware/manifest.flat>                                        | Whitespace-delimited (busybox awk friendly)       | On-device sysupgrade              |

The flat form has one line per `<build, platform, flash>` triple plus channel pointers:

```
# columns: build_id platform flash size url
nightly-20260520-887328c hi3520dv200_lite nor 4823040 https://github.com/OpenIPC/firmware/releases/download/nightly-20260520-887328c/openipc.hi3520dv200-nor-lite.tgz
nightly-20260520-887328c gk7205v200_lite  nor 7049210 https://github.com/OpenIPC/firmware/releases/download/nightly-20260520-887328c/openipc.gk7205v200-nor-lite.tgz
...
# channels
@channel nightly nightly-20260520-887328c
@channel latest  nightly-20260520-887328c
```

The rich JSON form adds `sha`, `branch`, `built_at`, and `release_url` per build. Both files are regenerated every time a nightly build completes (the workflow that publishes them is `manifest.yml`).

### Build identifiers

A **build id** has the shape `nightly-YYYYMMDD-<short>` (8-digit UTC date + 7-char git commit hash). Example: `nightly-20260520-887328c`. The last 90 builds are retained; older releases and tags are pruned every Monday.

The currently-running build id lives in the camera's `/etc/os-release`:

```sh
$ grep ^BUILD_ /etc/os-release
BUILD_ID=nightly-20260520-887328c
BUILD_SHA=887328caf77479cf45d40fef76d3a5b0f4546993
```

If `BUILD_ID` is absent your firmware predates the redesign — you can still install a manifest-aware nightly with `sysupgrade -k -r`, which always grabs the rolling current build.

### The platform key

The manifest indexes artifacts by `${soc}_${variant}`. Your camera derives these from the U-Boot environment and the rootfs:

```sh
$ soc=$(fw_printenv -n soc); variant=$(grep ^BUILD_OPTION= /etc/os-release | cut -d= -f2)
$ echo "${soc}_${variant}"
hi3520dv200_lite
```

That string is what `sysupgrade --list-builds` and `--build=` will look up in the manifest.

---

## sysupgrade: new flags

`sysupgrade` (in firmware `≥ 1.0.50`) gains three manifest-aware flags. All of them coexist with the existing `--url`, `--archive`, `--kernel`, `--rootfs`, and `-k`/`-r` flags — anything documented in the older [Upgrade firmware](sysupgrade.md) article still works exactly as before.

### `--list-builds[=N]`

Print the last N (default 20) builds available for your camera's platform. The currently-running build is marked with `*`.

```console
$ sysupgrade --list-builds=10
OpenIPC System Updater v1.0.50

Vendor    hisilicon
SoC       hi3520dv200
Kernel    08:37:58 2026-05-18
RootFS    master+887328c, 2026-05-20

Available builds for hi3520dv200_lite (newest first):
    nightly-20260524-1a2b3c4
    nightly-20260523-9876543
  * nightly-20260520-887328c
    nightly-20260519-abcd123
    nightly-20260518-fedcba9
    ...
```

This is the easiest way to confirm the manifest is reachable and to see what build ids are valid for your camera.

### `--channel=<name>`

Update to whatever the named channel currently points at. Two channels are defined:

- `nightly` — newest dated build (refreshed every successful nightly).
- `latest` — alias of `nightly` for now; kept distinct so the project can later carve out a slower "stable" channel without breaking scripts that pinned to `latest`.

```sh
sysupgrade --channel=nightly        # the default destination going forward
```

### `--build=<id>`

Pin to one specific dated build. This is the **downgrade** primitive.

```sh
sysupgrade --build=nightly-20260519-abcd123      # roll back to that exact build
```

The build id must be one that `--list-builds` shows for your platform — `--build` validates against the manifest and refuses to flash if the build id has no artifact for `${soc}_${variant}`.

### Behavioural notes

- `sysupgrade` will self-update before flashing if the script on the camera is older than the one in `master`. After self-update it re-invokes itself with your original arguments.
- Older OpenIPC variants — for example **fpv** — are built and published from the separate [OpenIPC/builder](https://github.com/OpenIPC/builder) repository and do not appear in this manifest. `--channel`/`--build` will report "no builds available" on those cameras; their classic `sysupgrade -k -r` path (which reads `releases/download/latest` directly) still works as it always did.
- The on-device parser uses only busybox `awk`/`grep` — no `jq`, no `jsonfilter`. The manifest schema is deliberately busybox-friendly. You can replicate the same lookup from any shell:
  ```sh
  curl -s https://openipc.github.io/firmware/manifest.flat \
      | awk '$1=="@channel" && $2=="nightly" {print $3}'
  ```

---

## Bisecting a regression

When a recent update breaks something — the camera doesn't boot, an ISP driver vanishes, a web-UI element disappears, video glitches — and you don't know **which** nightly introduced the problem, run a bisect to narrow it down to a single dated build (and the small batch of commits it contains).

### Why a host-side driver

The bisect loop reboots the camera many times. It is unsafe to keep bisect state on the camera itself: a "no boot" verdict means the camera is now unreachable until you recover it via UART/TFTP, and any state on the camera goes with it. The bisect tool therefore runs **on your workstation** and stores its state on disk locally — a brick can never lose progress.

### Install the tool

```sh
# From a checkout of OpenIPC/firmware:
sudo install -m 0755 contrib/openipc-bisect /usr/local/bin/openipc-bisect

# Or with curl (no clone needed):
sudo curl -L -o /usr/local/bin/openipc-bisect \
    https://raw.githubusercontent.com/OpenIPC/firmware/master/contrib/openipc-bisect
sudo chmod +x /usr/local/bin/openipc-bisect
```

Dependencies on the workstation: `sh`, `jq`, `curl`, `ssh`. Nothing extra is needed on the camera beyond `sysupgrade ≥ 1.0.50`.

### Walkthrough

The example below bisects between a build from two weeks ago (known good) and the current nightly (known bad) on a Hisilicon camera.

#### 1. Start the bisect

```sh
openipc-bisect start root@192.168.1.10 \
    --good=nightly-20260506-1111111 \
    --bad=channels.nightly
```

- `--good` is the last build where the feature you care about worked. Pass an exact `build_id`, a short or full git SHA, or `channels.nightly`/`channels.latest`.
- `--bad` defaults to `channels.nightly` if omitted. Anything that fails today.
- Platform is detected automatically (`fw_printenv soc` + `BUILD_OPTION`) — override with `--platform=<id>` if you must.

The tool fetches the manifest, slices the window, picks the median build, flashes it, and waits for the camera to come back. Once the camera is up, it prints the build id and waits for your verdict.

#### 2. Test the camera, then verdict

After each round you decide whether **this** build exhibits the regression:

```sh
openipc-bisect bad     # this build is broken
openipc-bisect good    # this build is OK
openipc-bisect skip    # build itself is broken (build error, partial release), not your bug
```

The tool narrows the window, picks the next median, flashes it, and repeats. A window of N builds converges in about `log2(N)` rounds.

#### 3. Check status any time

```sh
$ openipc-bisect status
{
  "host":     "root@192.168.1.10",
  "platform": "hi3520dv200_lite",
  "good":     "nightly-20260513-7c37df7",
  "bad":      "nightly-20260520-887328c",
  "current":  "nightly-20260517-aabbccd",
  "window_size": 4,
  "est_rounds_left": 2
}
```

#### 4. End of bisect

When the window narrows to a single build the tool prints the **first bad build**:

```
Bisect complete. First bad build: nightly-20260517-aabbccd
```

Use the release URL (`https://github.com/OpenIPC/firmware/releases/tag/nightly-20260517-aabbccd`) or its `sha=` field to pull up the diff against the previous good nightly. Open an issue with the culprit build id and a description of the regression.

#### 5. Reset to the current channel

```sh
openipc-bisect reset
```

Flashes the camera back to `channels.nightly` and clears the host state.

### If the camera bricks mid-bisect

A bisect by definition flashes builds that you don't know are good. If the chosen build doesn't boot at all:

1. The tool will time out waiting for the camera to come back (default 5 minutes — adjust with `OPENIPC_BISECT_WAIT=600`).
2. It prints recovery instructions and exits with code 75. **Your bisect state stays on disk.**
3. Recover the camera by any means — UART + TFTP is the canonical path. See the [Sigmastar unbrick](sigmastar-unbrick.md) or [Ingenic T31 unbrick](ingenic-t31-unbrick-with-sd-card.md) articles for vendor-specific recipes.
4. Once the camera responds to SSH again, mark the iteration:
   ```sh
   openipc-bisect bad     # almost always the right verdict if the camera didn't boot
   ```
5. The loop continues with a narrower window.

The bisect tool **cannot lose progress to a brick** because nothing relevant lives on the camera.

### Resuming after a host restart

State lives at `$XDG_STATE_HOME/openipc/bisect/<host>.json` (typically `~/.local/state/openipc/bisect/`). To re-attach to an in-flight bisect after closing your terminal or rebooting your workstation:

```sh
openipc-bisect resume
```

If you are bisecting more than one camera at the same time, set `OPENIPC_BISECT_HOST=<host>` so the tool knows which one you mean.

---

## Sub-nightly granularity (advanced)

If the regression window narrows to a single nightly but you need to know **which commit inside that day** broke things, use the `build-one.yml` GitHub Actions workflow. It accepts an arbitrary commit SHA and publishes a one-off build to a separate tag namespace (`nightly-bisect-<short>`) that does **not** pollute the dated nightly index and is **not** swept by retention.

```sh
# Build one board at one commit:
gh workflow run build-one.yml \
    -f platform=hi3520dv200_lite \
    -f commit=<sha>

# Then on the camera (one-off, manifest-bypass):
sysupgrade --url=https://github.com/OpenIPC/firmware/releases/download/nightly-bisect-<short>/openipc.hi3520dv200-nor-lite.tgz
```

Combined with `git bisect run` this gives true commit-level resolution, at the cost of one ~5-minute CI job per iteration.

---

## Quick reference

| Goal                                          | Command                                                                |
|-----------------------------------------------|------------------------------------------------------------------------|
| Update to the current nightly                 | `sysupgrade --channel=nightly`                                         |
| Downgrade to a specific historic nightly      | `sysupgrade --build=nightly-YYYYMMDD-<short>`                          |
| List the last 20 builds for this camera       | `sysupgrade --list-builds`                                             |
| List the last N builds for this camera        | `sysupgrade --list-builds=N`                                           |
| Show the current channel pointer (host shell) | `curl -s https://openipc.github.io/firmware/manifest.flat \| awk '$1=="@channel" && $2=="nightly" {print $3}'` |
| Bisect a regression                           | `openipc-bisect start root@<camera> --good=<id> [--bad=<id>]`          |
| Mark a bisect verdict                         | `openipc-bisect good \| bad \| skip`                                   |
| Re-attach after host restart                  | `openipc-bisect resume`                                                |
| Abandon bisect and return to nightly          | `openipc-bisect reset`                                                 |

## Environment variables (host tools)

| Variable                | Default                                                | Purpose                                            |
|-------------------------|--------------------------------------------------------|----------------------------------------------------|
| `OPENIPC_MANIFEST_URL`  | `https://openipc.github.io/firmware/manifest.json`     | Override manifest URL (mirror, fork, local proxy). |
| `OPENIPC_BISECT_STATE`  | `$XDG_STATE_HOME/openipc/bisect`                       | Where the host stores bisect state JSON.           |
| `OPENIPC_BISECT_HOST`   | (auto)                                                 | Pick a host when multiple bisects are in flight.   |
| `OPENIPC_BISECT_WAIT`   | `300`                                                  | Seconds to wait for the camera to come back online.|
| `OPENIPC_SSH_OPTS`      | `-o ConnectTimeout=5 -o StrictHostKeyChecking=accept-new` | Extra SSH options.                              |

## Environment variables (on-device)

| Variable          | Default                                              | Purpose                                                          |
|-------------------|------------------------------------------------------|------------------------------------------------------------------|
| `MANIFEST_URL`    | `https://openipc.github.io/firmware/manifest.flat`   | Override the flat manifest URL for `sysupgrade --channel/--build`. |
