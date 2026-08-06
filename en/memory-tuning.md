# OpenIPC Wiki
[Table of Content](../README.md)

HiSilicon boards
----------------

### Memory allocator: MMZ

HiSilicon SoCs require contiguous physical memory for ISP and video DMA buffers.
This memory is managed by the MMZ (Media Memory Zone) subsystem inside the
`open_osal` kernel module.

There are three allocator backends:

| | hisi (static) | cma (vendor) | cma (mainline) |
|---|---|---|---|
| **Available on** | Kernel 4.9 | Kernel 4.9 | Kernel 6.6+ (neo) |
| **How it works** | Kernel is given a reduced `mem=` size; the remaining RAM is invisible to Linux and owned entirely by MMZ | Kernel sees all RAM (`mem=128M`); vendor `hi_cma.c` manages a CMA region declared via bootargs; pages are reusable by the kernel when video is idle | Kernel sees all RAM; mainline CMA reserves a region via Device Tree; pages are reusable by the kernel when video is idle |
| **Memory efficiency** | Low -- the MMZ region is wasted when video is idle (e.g. during boot, firmware updates, network-only workloads) | High -- CMA pages serve normal allocations and are migrated out on demand when video starts | High -- same as vendor CMA |
| **Allocation latency** | Deterministic -- buffers come from a dedicated pool that is always free | May spike -- CMA must migrate pages out before returning contiguous memory; first allocation can take a few milliseconds | May spike -- same as vendor CMA |
| **Implementation** | Simple range allocator over a hidden memory region | Vendor `hi_cma.c` integration with the kernel's CMA | Kernel built-in CMA framework (`dma_alloc_from_contiguous`) |
| **Configuration** | `mmz_allocator=hisi mmz=anonymous,...` | `mmz_allocator=cma mmz=anonymous,...` | Device Tree `reserved-memory` node; no bootargs needed |
| **Best for** | Memory-constrained (64MB) boards where the kernel must fit in 32MB | 128MB boards on kernel 4.9 (default for hi3516ev300_lite) | 128MB+ boards on kernel 6.6+ (default for neo builds) |

On kernel 4.9, the `hisi` allocator hides memory from the kernel via `mem=32M`,
giving MMZ exclusive ownership of the remaining RAM. The `cma` allocator lets
the kernel see all RAM (`mem=128M`) and shares the MMZ region with normal
allocations via the vendor's `hi_cma.c`. Both are configured via U-Boot
bootargs.

On kernel 6.6+, the vendor `hi_cma.c` does not exist. Instead, the open-source
OSAL module uses the kernel's built-in CMA framework directly, configured
through the Device Tree. Functionally it behaves the same as vendor CMA --
the key improvement is that no bootargs are needed, the region is declared
in the Device Tree and the kernel configures everything automatically.

> **Rule of thumb:** if your board has 128MB+ RAM, use the `cma` allocator
> (vendor CMA on 4.9, mainline CMA on 6.6+ -- both are the default). If you
> have 64MB RAM on kernel 4.9, use `mmz_allocator=hisi` with `mem=32M`.

#### Kernel 4.9 (legacy)

On the stock 4.9 kernel, MMZ uses a vendor-specific allocator controlled by
U-Boot bootargs:

```
mem=32M ... mmz_allocator=cma mmz=anonymous,0,0x42000000,96M
```

- `mem=32M` gives the kernel 32MB; the rest (e.g. 96MB on a 128MB board) is
  reserved for video buffers.
- `mmz_allocator=cma` selects the CMA-based allocator (requires vendor
  `hi_cma.c`).
- `mmz=anonymous,0,0x42000000,96M` tells MMZ the physical address and size of
  the buffer region.

Boards with only 64MB of RAM typically use `mem=32M` with 32MB for MMZ.  Boards
with 128MB use `mem=32M` with 96MB for MMZ.

#### Kernel 6.6+ (neo)

Starting with the `hi3516ev300_neo` build (Linux 6.6 LTS), MMZ uses the
**mainline kernel CMA** (Contiguous Memory Allocator) configured via Device Tree.
No vendor bootargs are needed.

The kernel's Device Tree declares a `reserved-memory` region:

```dts
reserved-memory {
    #address-cells = <1>;
    #size-cells = <1>;
    ranges;

    mmz: mmz {
        compatible = "shared-dma-pool";
        size = <0x6000000>;              /* 96MB */
        alloc-ranges = <0x40000000 0x8000000>;
        reusable;
        linux,cma-default;
    };
};
```

#### Choosing the right CMA size (kernel 6.6+)

The default CMA reservation is 96MB. This value was carried over from the 4.9
`mem=32M` split where "everything except 32MB" went to video. With CMA this
reasoning no longer applies — let's look at actual usage.

A typical hi3516ev300 streaming session with majestic (2592x1520 H.264 + MJPEG):

```
cat /proc/media-mem
# ---MMZ_USE_INFO:
#  total size=98304KB(96MB), used=34396KB(33MB), remain=63908KB(62MB)
```

The video pipeline uses **~34MB**. The remaining 62MB of the CMA region sits
idle (though reusable by the kernel for movable pages).

**Why does CMA size matter if pages are reusable?**

CMA pages can only hold **movable** allocations (user memory, page cache). They
cannot hold non-movable allocations (kernel slab, page tables, DMA buffers,
kernel stacks). On a 128MB board with 96MB CMA, only 32MB is guaranteed
available for non-movable kernel allocations — effectively the same constraint
as the old `mem=32M`.

Reducing CMA gives the kernel more room for non-movable allocations:

| CMA size | Non-movable headroom | Video headroom | Status |
|---|---|---|---|
| 96MB (default) | 32MB | 62MB spare | Safe, but wastes non-movable headroom |
| 64MB | 64MB | 13MB spare | Tested, recommended for single-stream 4MP |
| 48MB | 80MB | Allocation failures | Too small for 2592x1520 streaming |

**How to override CMA size without rebuilding:**

The kernel accepts a `cma=` bootarg that overrides the Device Tree default:

```bash
# In U-Boot:
setenv bootargs mem=128M cma=48M console=ttyAMA0,115200 panic=20 ...
saveenv
```

The kernel will log `bypass mmz node, using cmdline CMA params instead` and
allocate a CMA pool of the specified size. You can verify:

```bash
# Verify the active CMA size
grep Cma /proc/meminfo
# CmaTotal:       49152 kB    <-- 48MB
# CmaFree:        16384 kB

# Check if video has enough memory
cat /proc/media-mem
# If "used" is close to "total", increase the CMA size

# Monitor for CMA allocation failures
dmesg | grep -i "cma.*alloc.*failed"
```

> **Recommendation:** use `cma=64M` for single-stream 4MP setups. This uses
> ~50MB for video with 13MB spare, and gives the kernel 64MB for non-movable
> allocations (double the default). If you see allocation failures in dmesg or
> majestic fails to start, remove the `cma=` parameter to fall back to the 96MB
> default.

#### What this means for end users

**128MB boards (hi3516ev300):**

With 6.6, you can give the kernel the full 128MB (`mem=128M` or just remove the
`mem=` bootarg entirely). All three configurations work:

```
# Full memory, default CMA (recommended for most users)
mem=128M console=ttyAMA0,115200 ...

# Full memory, tuned CMA (recommended for advanced users)
mem=128M cma=48M console=ttyAMA0,115200 ...

# No mem= at all - kernel gets full RAM from DT
console=ttyAMA0,115200 ...

# Legacy bootargs still work (mmz params are silently ignored)
mem=128M ... mmz_allocator=cma mmz=anonymous,0,0x42000000,96M
```

**64MB boards (hi3516ev200, hi3518ev300):**

The 6.6 kernel with CMA has not yet been tested on 64MB boards. Use `cma=24M`
or `cma=32M` via bootargs if you are experimenting. For production, continue
using the 4.9 kernel with `mem=32M`.

**Checking CMA status on a running system:**

```bash
# Verify CMA reservation at boot
dmesg | grep -i cma
# Expected: "Reserved memory: created CMA memory pool at 0x42000000, size 96 MiB"

# Check CMA usage
grep Cma /proc/meminfo
# CmaTotal:       98304 kB
# CmaFree:        65536 kB

# Check MMZ allocations
cat /proc/media-mem
```

#### Upgrading from kernel 4.9 to 6.6

If you are upgrading a hi3516ev300 from 4.9 to 6.6, update your U-Boot
environment:

```
# Recommended: give kernel full memory, optionally tune CMA
setenv bootargs mem=128M console=ttyAMA0,115200 panic=20 ...
saveenv
```

Old bootargs with `mmz_allocator=cma mmz=anonymous,...` still work on 6.6 —
they are silently ignored. There is no need to change U-Boot before upgrading,
but you will benefit from updating `mem=` to `128M` afterwards.

---

### Streamer memory settings

The sections above size the memory *region*. This one covers what the video
pipeline puts **into** it, and the settings that change how much it takes.

These are applied like any other setting, through the HTTP API described in
[Majestic streamer](majestic-streamer.md). They differ from most in one
respect worth knowing: they decide how the video pipeline's buffers are laid
out, so changing one rebuilds the pipeline and the stream drops for a moment.

All of the region's usage is visible at runtime:

```bash
cat /proc/media-mem
# ---MMZ_USE_INFO:
#  total size=98304KB(96MB),used=53032KB(51MB),remain=45272KB(44MB)
```

Most of `used` is frame buffers: a pool of full-size video frames that the ISP,
the scaler and the encoder pass between them. A 1080p frame is about 3 MB and a
5 MP frame about 5.6 MB, so the pool dominates everything else on the board.

The streamer sizes that pool itself, from the pipeline your configuration asks
for — one frame per encoding channel, plus what the capture path holds. So the
largest savings come from telling it about channels you do not want, rather than
from tuning the pool directly:

| Setting | What it does | Typical saving |
|---|---|---|
| [`jpeg.enabled: false`](#jpegenabled--snapshots-and-the-mjpeg-stream) | no snapshots at all, and no frame reserved for them | **one frame** |
| [`video1.enabled: false`](#one-frame-per-channel) | drops the second stream and its frame | **one frame** |
| [`isp.yuvCompression: seg`](#ispyuvcompression--compressing-the-frame-pool) | stores the pooled frames compressed | 2–6 MB, some SoCs |
| [`jpeg.tuned`](#jpegtuned--parameterised-snapshots) | caps parameterised snapshots to a size you choose | avoids a full frame |
| [`isp.blkCnt`](#ispblkcnt--how-many-frames-are-pooled) | overrides the frame count outright | one frame per step |
| [`isp.memMode`](#ispmemmode--what-reduction-actually-changes) | encoder-side buffers, not the pool | a few MB |

A frame is about 3 MB at 1080p, 5.6 MB at 5 MP and 11.9 MB at 4K, so on a small
board one of these is worth more than all the tuning below it.

#### `isp.blkCnt` — how many frames are pooled

The number of frames reserved for the pipeline, and the biggest single lever on
the board — each one is a whole frame.

**You do not normally need to set it.** The streamer works out how many the
pipeline holds and reserves that plus one spare. It logs the arithmetic on every
start:

```bash
logread | grep 'VB sizing'
# VB sizing: 4 blocks for the pipeline (2 of them held by the VI path),
#            default 5, isp.blkCnt 5 in effect
```

##### One frame per channel

Two things go into that figure. One block per encoding channel — video0, video1
if enabled, and the JPEG/MJPEG channel if `jpeg.enabled` is on. Plus whatever
the capture path holds: nothing if it feeds the scaler directly, two blocks if
it writes raw frames through memory, four if it writes processed frames through
memory.

Every channel costs a whole frame whether or not it is producing one at the
moment, because the pool is fixed when the streamer starts — a channel raised on
demand still needs its block sitting there waiting. That is why switching a
channel off is worth more than any amount of tuning: `video1.enabled: false` and
`jpeg.enabled: false` each return a full frame.

Which of those applies is decided by the sensor's width, not by the model of
SoC, and it is why two cameras with the same chip can need different amounts:

| Camera | Capture path | Blocks it holds | Pipeline total |
|---|---|---|---|
| gk7205v200 + 1920x1080 sensor | straight through | 0 | 3 |
| hi3516ev300 + 2592x1520 sensor | raw through memory | 2 | 4 |
| hi3516av300 + 3840x2160 sensor | processed through memory | 4 | 6 |

A sensor wider than the capture pipe's limit — 2304 pixels on most parts — has
to go through memory, and that costs whole frames. It is the single largest
reason a 5 MP camera needs more than a 1080p one, beyond the frames being bigger.

##### When you would override it

```bash
curl 'http://localhost/api/v1/set?isp.blkCnt=6'
```

Raise it if you serve many snapshots at once, or run something that holds frames
for longer than the pipeline expects. Lower it only if you are short of memory
and willing to test — and know what running short looks like, because it is not
obvious:

> **A pool one block short does not stop the video.** The stream encodes
> perfectly and snapshots return nothing at all. Anyone judging the camera by
> its RTSP feed will conclude it is healthy.

Nothing fails when you set it too low — the pool is reserved exactly as asked
and every call succeeds — so the streamer checks the figure against what the
pipeline needs and says when it does not reach:

```
VB short: 3 blocks for a pipeline that holds 4 — expect snapshots to go
unanswered while video keeps running. Raise isp.blkCnt, or lower the
resolution or the stream count
```

Setting it too high is handled rather than fatal. If the reservation does not
fit the region, the streamer falls back to its own computed figure instead of
taking everything that will fit — the frame pool is the only allocation big
enough to starve the encoders, and one that swallows the region leaves a camera
that starts, reports no errors and streams nothing.

##### Checking the headroom you actually have

`/proc/umap/vb` records the low-water mark of every pool, so you can see how
close the camera came to running out rather than guessing:

```bash
cat /proc/umap/vb
# PoolId  ...  BlkCnt  Free  MinFree
# 0            5       4     1
```

`MinFree` is the fewest blocks that have been free at any point since boot. `1`
means the pool never had more than one to spare. `0` means every block was in
use at once, so anything asking for one more at that moment went without — which
is survivable, and is what a camera running at exactly its computed figure looks
like, but leaves nothing for a burst.

Exercise the camera before reading it — take several snapshots, connect a client
— since a pool that has done nothing yet reports plenty free.

The same file attributes each block to the subsystem holding it, which is how
the table above was measured.

#### `jpeg.enabled` — snapshots and the MJPEG stream

Controls whether the camera serves JPEG at all, and it is the single biggest
saving available on a small board: with it off, no frame is reserved for the
snapshot channel.

```bash
curl 'http://localhost/api/v1/set?jpeg.enabled=false'
```

Off means off, so be sure nothing you use needs it:

- `/image.jpg` answers **503**
- the `/mjpeg` HTTP stream answers "MJPEG is unavailable"
- the RTSP JPEG track is left out of the stream description

That includes **ONVIF snapshot URIs and the web UI preview**, which both fetch
`/image.jpg`. If a home-automation integration pulls stills from this camera,
leave it on. Video over RTSP is unaffected either way.

Measured, on cameras with one h264 stream and no snapshot ever taken:

| SoC | Sensor | Pool with JPEG on | Off | Freed |
|---|---|---|---|---|
| gk7205v200 | 1920x1080 | 12156 KB | 9116 KB | **3.0 MB** |
| hi3516ev300 | 2592x1520 | 28860 KB | 23088 KB | **5.6 MB** |

On a gk7205v200, whose whole media region is 24 MB, that is an eighth of it.

The startup log states both halves, so the saving is never a mystery and neither
are the refusals:

```
JPEG off: no block reserved for it, and /image.jpg and the MJPEG stream will
be refused. Set jpeg.enabled to true to restore them
```

#### `jpeg.tuned` — parameterised snapshots

`/image.jpg` accepts `width`, `height`, `qfactor`, `gray` and `crop`, which are
served by a **second** snapshot encoder on its own geometry. That encoder needs
frames of its own, so it is off by default:

```bash
# largest parameterised snapshot to serve; off (the default) refuses them
curl 'http://localhost/api/v1/set?jpeg.tuned=640x360'
```

The value is a size rather than a switch because the memory follows it. Frames
are reserved for the size you name, not for the sensor — at 5 MP a full frame is
5.6 MB, where three 640x360 frames come to 1013 KB:

| `jpeg.tuned` | Reserved on a 5 MP camera |
|---|---|
| `off` (default) | nothing; requests refused **503** |
| `640x360` | ~1.0 MB |
| `1280x720` | ~4.0 MB |
| `1920x1080` | ~8.9 MB — more than a full frame; prefer a crop |

Pick the largest picture you actually fetch. Anything above the size is refused
**400** naming the cap, rather than quietly served from the pipeline's own
frames:

```
snapshot is larger than jpeg.tuned allows; ask for a smaller size or raise
jpeg.tuned and restart
```

A request at or above the sensor's own resolution is always refused, whatever
the cap: the full frame is already going to video0 and the MJPEG channel, and a
third copy of it is never produced. Ask for a smaller size, or use `crop` to cut
a region at 1:1.

Plain `/image.jpg` with no parameters does not need this setting — it is served
by the MJPEG channel that `jpeg.enabled` already pays for.

#### `isp.memMode` — what "reduction" actually changes

Defaults to `reduction`. Despite the name it does **not** shrink the frame
pool. It changes three things on the encoder side:

- **Mini-buffer mode** — the encoder works from smaller internal buffers.
- **Smaller output buffers** — the compressed-stream buffer is sized at about
  half of what `normal` reserves (with a floor, so very small streams still get
  a workable buffer).
- **Reference-frame sharing** — the encoder reuses one buffer for reconstructed
  and reference frames instead of holding both.

`normal` reserves more headroom for all three. It is worth trying if you see
frames being dropped or re-encoded under a bitrate spike — for example with a
high-motion scene at a high bitrate — at the cost of a few megabytes.

```bash
curl 'http://localhost/api/v1/set?isp.memMode=normal'
```

#### `isp.yuvCompression` — compressing the frame pool

The pipeline's frames can be stored **compressed** in memory. Where the SoC
allows it, the pool is then reserved at the compressed size and the difference
is returned to the system.

```bash
curl 'http://localhost/api/v1/set?isp.yuvCompression=seg'
```

`auto` (the default) leaves compression off, so nothing changes unless you ask
for it. Measured on a 128 MB board, comparing `/proc/media-mem` before and
after:

| SoC | Sensor | Before | After | Freed |
|---|---|---|---|---|
| hi3516ev300 | 2592x1520 | 53032 KB | 47108 KB | **5.8 MB** |
| gk7205v200 | 1920x1080 | 21560 KB | 19460 KB | **2.1 MB** |

Roughly 1 MB per pooled frame at 1080p and 2 MB at 5 MP. Your absolute figures
will differ — total usage depends on resolution, second stream, snapshots and
the rest of the configuration — so compare the **difference** across the restart
rather than matching the numbers above.

Only the main encoding channel reads compressed frames; everything else in the
pipeline still needs ordinary ones. The streamer works out how many frames it
can move to the compressed pool while keeping the rest supplied, so this does
not need pairing with a lower `isp.blkCnt`. If there is nothing to spare it
leaves the pool alone and says so, and you get the compression without the
saving:

```
VB split skipped: 4 blocks available (3 must stay linear), seg 3927 B vs
linear 5771 B
```

**Not every chip benefits.** The saving comes from reserving less, and only
some SoCs' buffer arithmetic will reserve less for a compressed frame — the
rest reserve the full uncompressed size no matter what, on the basis that
compression is not guaranteed to achieve any particular ratio. On those parts
the frames are still compressed (less data crosses the memory bus, which is
useful in its own right) but `/proc/media-mem` will not move.

| SoC | Frees memory? |
|---|---|
| hi3516ev200, hi3516ev300, gk7205v200, gk7205v500 | **Yes** — 2 to 6 MB |
| hi3516cv500, hi3516av300 | No — reserved size is unchanged |
| hi3516cv300, hi3519v101 | No — marginally larger |
| hi3516av100, hi3518ev200, hi3516cv610 | Setting not available |

**It is ignored when it would break something.** Compression is silently
incompatible with several features, so the streamer turns it off rather than
let them fail, and logs the reason:

- `image.rotate` (90 or 270) and `image.mirror` — the pipeline cannot rotate or
  mirror a compressed frame. Note that `image.flip` is fine.
- `osd.privacyMasks` — privacy masks are **not drawn** on a compressed frame.
  This one matters: without the safeguard the stream would look correct while
  publishing the very area you meant to hide.
- `image.tuning` and the raw `/image.yuv420` and `/image.webp` endpoints — these
  read raw pixels, and nothing on these SoCs can turn a compressed frame back
  into pixels.

Overlays, timestamps, motion detection, digital image stabilisation and low
delay all work normally alongside it.

To confirm it took effect, compare `/proc/media-mem` before and after. If the
numbers do not move, the SoC is one of those that reserves the full size anyway,
the pool had nothing to spare, or one of the settings above overrode it — the
log says which.

---

### Disable subsystems you don't use

Kernel modules take about 5 megabytes of RAM (code with dynamic memory for
buffers) and some of them are useless unless you need specific functionality like
OSD, motion detection, audio, or specific codecs.

The table below shows vendor SDK module names, open-source module names (used by
both 4.9 and 6.6 kernels in OpenIPC), and approximate sizes.

| Feature | Vendor SDK modules | OpenIPC modules | Size |
|---|---|---|---|
| Audio output | hi3516ev200_ao, hi3516ev200_adec | open_ao, open_adec | 78 KB |
| Audio input | hi3516ev200_ai, hi3516ev200_aenc | open_ai, open_aenc | 106 KB |
| Audio codec | hi3516ev200_acodec | open_acodec | 16 KB |
| Audio I/O (shared) | hi3516ev200_aio | open_aio | 33 KB |
| I2C sensor support | hi_sensor_i2c | open_sensor_i2c | 12 KB |
| SPI sensor support | hi_sensor_spi | open_sensor_spi | N/A |
| PWM support | hi_pwm | open_pwm | 12 KB |
| Motion detection | hi3516ev200_ive | open_ive | 188 KB |
| JPEG snapshots | hi3516ev200_jpege | open_jpege | 53 KB |
| H.264 codec | hi3516ev200_h264e | open_h264e | 131 KB |
| H.265 codec | hi3516ev200_h265e | open_h265e | 156 KB |
| Video encoder core | hi3516ev200_venc | open_venc | 274 KB |
| Rate control | hi3516ev200_rc | open_rc | 111 KB |
| Encode device | hi3516ev200_vedu | open_vedu | 29 KB |
| OSD / regions | hi3516ev200_rgn | open_rgn | 86 KB |
| ISP | hi3516ev200_isp | open_isp | 201 KB |
| Video input | hi3516ev200_vi | open_vi | 373 KB |
| VPSS | hi3516ev200_vpss | open_vpss | 332 KB |
| VGS | hi3516ev200_vgs | open_vgs | 143 KB |
| MIPI receiver | hi_mipi_rx | open_mipi_rx | 37 KB |
| Watchdog | hi_wdt | open_wdt | 12 KB |

To disable a module, comment out or remove the corresponding `modprobe` line in
`/usr/bin/load_hisilicon`. For example, to disable audio entirely, comment out
the `insert_audio` call and the individual `modprobe open_aio`, `open_ai`,
`open_ao`, `open_aenc`, `open_adec`, `open_acodec` lines.

> **Note:** `open_osal`, `open_sys_config`, `open_base`, and `open_sys` are core
> modules required by all other subsystems and must not be removed.
