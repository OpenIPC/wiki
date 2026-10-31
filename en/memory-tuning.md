# OpenIPC Wiki
[Table of Content](../README.md)

Every camera reserves a slice of its RAM for video buffers, and on most boards that
slice is larger than the pipeline needs. How it is reserved depends on the SoC:
[HiSilicon](#hisilicon-boards) uses MMZ over `mem=`/CMA, [SigmaStar](#sigmastar-boards)
uses a static MMA heap sized by U-Boot. The
[streamer settings](#streamer-memory-settings) that decide how much the pipeline puts
*into* that region are the same settings on either, though the figures there were
measured on HiSilicon and Goke parts.

HiSilicon boards
----------------

### Memory allocator: MMZ

HiSilicon SoCs require contiguous physical memory for ISP and video DMA buffers.
This memory is managed by the MMZ (Media Memory Zone) subsystem inside the
`open_osal` kernel module.

There are four allocator backends:

| | hisi / ot (static) | cma (vendor) | cma (mainline) | hybrid |
|---|---|---|---|---|
| **Available on** | Kernel 4.9 (`hisi`); hi3516cv6xx, kernel 5.10 (`ot`, the default there) | Kernel 4.9 | Kernel 6.6+ (neo) | hi3516cv6xx, kernel 5.10 |
| **How it works** | Kernel is given a reduced `mem=` size; the remaining RAM is invisible to Linux and owned entirely by MMZ | Kernel sees all RAM (`mem=128M`); vendor `hi_cma.c` manages a CMA region declared via bootargs; pages are reusable by the kernel when video is idle | Kernel sees all RAM; mainline CMA reserves a region via Device Tree; pages are reusable by the kernel when video is idle | A fixed carve-out holds the streamer's buffers; a small CMA zone beside it is Linux's until a peak borrows it |
| **Memory efficiency** | Low -- the MMZ region is wasted when video is idle (e.g. during boot, firmware updates, network-only workloads) | High -- CMA pages serve normal allocations and are migrated out on demand when video starts | High -- same as vendor CMA | Medium-high -- the part of the zone the pipeline does not hold all the time (8 MB by default) serves Linux |
| **Allocation latency** | Deterministic -- buffers come from a dedicated pool that is always free | May spike -- CMA must migrate pages out before returning contiguous memory; first allocation can take a few milliseconds | May spike -- same as vendor CMA | Deterministic for the pipeline; only a peak past the carve-out waits for CMA |
| **Implementation** | Simple range allocator over a hidden memory region | Vendor `hi_cma.c` integration with the kernel's CMA | Kernel built-in CMA framework (`dma_alloc_from_contiguous`) | Media buffers go to the fixed carve-out first; one that does not fit there borrows from the CMA share and returns it when freed |
| **Configuration** | `mmz_allocator=hisi mmz=anonymous,...`; on hi3516cv6xx `set_allocator ot` | `mmz_allocator=cma mmz=anonymous,...` | Device Tree `reserved-memory` node; no bootargs needed | `set_allocator hybrid [osmem] [cma share]` |
| **Best for** | Memory-constrained (64MB) boards where the kernel must fit in 32MB | 128MB boards on kernel 4.9 (default for hi3516ev300_lite) | 128MB+ boards on kernel 6.6+ (default for neo builds) | 64MB hi3516cv608/cv610 boards that want more Linux memory without CMA's start-up risk |

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

On hi3516cv6xx (kernel 5.10) the kernel lays out the media memory itself and
offers a third choice beside the carve-out (`ot`) and `cma`: [`hybrid`](#hybrid-allocator-hi3516cv6xx),
a fixed carve-out for what the streamer always holds and a small CMA zone that
Linux uses until a peak needs it.

> **Rule of thumb:** if your board has 128MB+ RAM, use the `cma` allocator
> (vendor CMA on 4.9, mainline CMA on 6.6+ -- both are the default). If you
> have 64MB RAM on kernel 4.9, use `mmz_allocator=hisi` with `mem=32M`.
> On a 64MB hi3516cv6xx, the carve-out (`ot`) is the default;
> [`hybrid`](#hybrid-allocator-hi3516cv6xx) gives Linux about 8 MB more while
> streaming, and plain `cma` is not recommended there.

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

On the **gk7205v500 family**, the firmware decides between the two at boot. A
command line that names no allocator is rewritten for the next boot so that
Linux sees the whole DDR and the media region becomes a CMA zone inside it
(`mem=128M ... mmz_allocator=cma mmz=anonymous,0,0x42000000,96M` on a 128 MB
board), which gives Linux about four times the memory it had. Boards with 64 MB
or less are left on the fixed split: the media region is 32 MB either way there,
and CMA would lend Linux only what a wide-sensor pipeline leaves free
([OpenIPC/firmware#2620](https://github.com/OpenIPC/firmware/pull/2620)).

A 64 MB board switched to CMA before that keeps it. To put it back on the fixed
split, remove the allocator **and** give `mem=` a literal 32M — removing the
allocator alone leaves Linux all 64 MB and the media region nothing. That holds
whatever `mem=` says now, a number or a variable such as `${osmem}`, which may
itself have been set to the whole DDR:

```bash
fw_printenv bootargs
fw_setenv bootargs "$(fw_printenv -n bootargs | sed -E -e 's/(^| )mem=[^ ]*/\1mem=32M/' -e 's/ mmz_allocator=[^ ]*//' -e 's/ mmz=[^ ]*//')"
fw_printenv bootargs   # mem=32M, and no mmz_allocator= or mmz=, before you reboot
reboot
```

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

#### Hybrid allocator (hi3516cv6xx)

The carve-out and CMA each give something up on a 64 MB camera.

- **The carve-out (`ot`)** keeps the whole media zone away from Linux. A 1080p
  streamer holds 15-18 MB of the 28 MB zone, so about 10 MB sits idle, and Linux
  runs with 12-13 MB available.
- **CMA** lends the whole zone to Linux, which then has about 22 MB available
  while streaming. But every time the streamer starts or rebuilds its pipeline
  (a restart, a settings change), the kernel has to take that memory back,
  migrating whatever Linux put there. When userland has filled the zone, that
  migration can fail to make progress. On a hi3516cv608 about one start in six
  stalled for good, with no out-of-memory kill and nothing logged, until the
  watchdog reset the camera.

`hybrid` takes the part of each that works. The media memory is split into two
zones:

- **a carve-out**, sized for what the streamer holds all the time. Linux never
  sees it, so the pipeline always finds it free.
- **a CMA zone** above the OS share, which serves Linux like any other memory
  until a peak needs it.

The media allocator fills the carve-out first. Only a buffer that does not fit
there, such as a snapshot in flight on a busy configuration, borrows from the
CMA zone, and it gives the memory back when it is freed. As long as the
carve-out holds the whole pipeline, a start or a restart of the streamer never
has to migrate it out of Linux's memory, which is where CMA got stuck. See
[Choosing the CMA share](#choosing-the-cma-share) for sizing it that way.

```
 0x40000000                  0x42400000     0x42C00000                 0x44000000
 |-------- Linux (36M) --------|--- CMA (8M) ---|------ carve-out (20M) ------|
                               Linux's until a   the streamer's pipeline,
                               peak borrows it   never Linux's
```

##### Measured

hi3516cv608 + SP2308 (1080p), 64 MB, the same streamer configuration and the
same memory-pressure tests for each layout, with a 36 MB OS share in all three:

| | `ot` | `cma` | `hybrid` 20M + 8M |
|---|---|---|---|
| Available to Linux while streaming | 12-13 MB | 22 MB | 20.9 MB |
| Streamer start, unloaded | 0.38 s | 0.39 s | 0.39 s |
| Start with 11 MB of userland in use | 1 of 3 | 3 of 3 | 3 of 3 |
| 20 pipeline rebuilds | 20 of 20 | 20 of 20 | 20 of 20 |
| Pipeline migrated out of Linux's memory at a start | never | every start | never |
| Start with memory exhausted, watchdog off | recovered 3 of 3, after 2-9 min | 5 of 6 in ~10 s, 1 stuck for 22+ min | recovered 12 of 12, after 2-9 min |
| Self-upgrade with the streamer running | fits, 6.8 MB left | fits, 27.4 MB left | fits, 7.6 MB left |

- At the default configuration every media buffer stays in the carve-out.
- With the sub stream, snapshots and motion detection on, and snapshots
  requested back to back, use peaked at 27.0 MB. 4.7 MB of that came from the
  CMA zone and went back afterwards.
- When memory is exhausted, `hybrid` still stalls the way `ot` does: there the
  system itself is out of memory, and the out-of-memory killer has to act.
  What `hybrid` removes is CMA's own failure, a stall that does not end.
- The samples are small: a few runs per row, on one board with one sensor.

##### Using it

It needs a firmware that includes
[OpenIPC/firmware#2740](https://github.com/OpenIPC/firmware/pull/2740): the
`set_allocator hybrid` command, and the kernel and `open_mmz` that know the
layout. Switch an existing camera to `hybrid` and reboot:

```bash
set_allocator hybrid          # OS share as it is now, 8M of CMA
reboot
```

Both sizes can be given: `set_allocator hybrid 36M 12M` keeps a 36 MB OS share
and lends 12 MB. That leaves a 16 MB carve-out on a 64 MB board (28 MB of
media memory minus 12), less than the 15-18 MB a 1080p pipeline holds: check
the carve-out against your own pipeline first, as below, or the difference is
borrowed from CMA at every start. The CMA share is rounded up to whole 4 MB, must be at least
4 MB, and must leave at least 4 MB for the carve-out. `set_allocator ot` or
`set_allocator auto` goes back.

After the reboot:

```bash
cat /sys/module/hisi_mem/parameters/allocator   # hybrid
cat /sys/module/hisi_mem/parameters/mmz         # cma,0,0x42400000,8M:anonymous,0,0x42c00000,20M
dmesg | grep -E 'hisi_mem|mmz hybrid'           # 1 CMA and 1 carve-out zones
grep -E 'CmaTotal|CmaFree' /proc/meminfo        # the CMA share, and how much of it is free
cat /proc/umap/media-mem                        # which zone each media buffer is in
```

##### Choosing the CMA share

The carve-out should hold what the streamer uses all the time; the CMA share
is what is left of the zone. Check the steady use with the streamer running
your real configuration and a snapshot or two taken:

```bash
grep 'total size' /proc/umap/media-mem    # used=... is the steady figure
```

- If the carve-out (the zone minus the CMA share) is larger than that figure,
  the pipeline never touches CMA, and Linux gets the whole CMA share.
- If it is smaller, the difference is borrowed from the CMA zone at every
  start. That works, and was tested, but the more is borrowed at a start, the
  closer it comes to plain `cma`. Lower the share instead.
- The 8 MB default suits a 1080p sensor on a 64 MB board, whose pipeline holds
  15-18 MB. Sensors with wider frames hold more: measure them before you lend
  more.

##### Limits

- **hi3516cv6xx only.** It needs a kernel and an `open_mmz` that know
  `hybrid`. A firmware without them ignores the setting and runs both zones as
  plain CMA.
- **Not the default.** The default layout stays `ot`. Only hi3516cv608 with a
  1080p sensor has been measured.
- **Self-upgrade unpacks into RAM**, not into the media zone as it does under
  `ot`. Under `hybrid` that left 7.6 MB to flash from.

---

### Streamer memory settings

The sections above size the memory *region*. This one covers what the video
pipeline puts **into** it, and the settings that change how much it takes.

These are applied like any other setting, through the HTTP API described in
[Majestic streamer](majestic-streamer.md). They differ from most in one
respect worth knowing: they decide how the video pipeline's buffers are laid
out, so changing one rebuilds the pipeline and every stream drops for a moment.
`videoN.enabled` is the exception — it is applied to its own channel alone, and
viewers of the other stream stay connected.

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
| [`jpeg.enabled: false`](#jpegenabled--snapshots-and-the-mjpeg-stream) | no snapshots at all | **one frame** where a frame is reserved for snapshots; current HiSilicon and Goke builds reserve none, except on hi3516cv100 and hi3516cv6xx |
| [`video1.enabled: false`](#one-frame-per-channel) | drops the second stream and its frame | **one frame** |
| [`isp.yuvCompression: seg`](#ispyuvcompression--compressing-the-frame-pool) | stores the pooled frames compressed | 2–6 MB, some SoCs |
| [`jpeg.tuned`](#jpegtuned--parameterised-snapshots) | caps parameterised snapshots to a size you choose | avoids a full frame; ignored on HiSilicon and Goke parts that reserve nothing for snapshots |
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
if enabled, and the JPEG/MJPEG channel if `jpeg.enabled` is on, on the parts that
still reserve one for snapshots (see [`jpeg.enabled`](#jpegenabled--snapshots-and-the-mjpeg-stream)).
Plus whatever
the capture path holds: nothing if it feeds the scaler directly, two blocks if
it writes raw frames through memory, four if it writes processed frames through
memory.

Every channel costs a whole frame whether or not it is producing one at the
moment, because the pool is fixed when the streamer starts — a channel raised on
demand still needs its block sitting there waiting. That is why switching a
channel off is worth more than any amount of tuning: `video1.enabled: false`
returns a full frame, and so does `jpeg.enabled: false` on the parts that still
reserve one for snapshots — not on current HiSilicon and Goke builds, which
reserve none (see [`jpeg.enabled`](#jpegenabled--snapshots-and-the-mjpeg-stream)).

Either frees it for the *next* start rather than immediately:
the pool keeps whatever size it was given when the streamer came up, so
switching a stream off on a running camera does not hand its block back. The
figures above are what you measure after a restart. The same holds for
[idle suspension](majestic-streamer.md#stopping-the-sensor-and-isp-when-nothing-is-watching),
which stops the sensor and ISP outright — a large power saving, and not a
memory one at all.

Which of those applies is decided by the sensor's width, not by the model of
SoC, and it is why two cameras with the same chip can need different amounts:

| Camera | Capture path | Blocks it holds | Pipeline total |
|---|---|---|---|
| gk7205v200 + 1920x1080 sensor | straight through | 0 | 3 |
| hi3516ev300 + 2592x1520 sensor | raw through memory | 2 | 4 |
| hi3516av300 + 3840x2160 sensor | processed through memory | 4 | 6 |

A sensor wider than the capture pipe's limit has to go through memory, and that
costs whole frames. It is the single largest reason a 5 MP camera needs more than
a 1080p one, beyond the frames being bigger. The limit belongs to the chip:

| Chip | Widest sensor that goes straight through |
|---|---|
| hi3516ev200, hi3516ev300, gk7205v200, gk7205v300 | 2304 |
| gk7205v500, gk7205v510, gk7205v530 | 3072 |

On the gk7205v500 family, builds before mid-October 2026 applied the 2304
limit, so a 2560-wide sensor such as the SC401AI went through memory and held
three extra frames. On a 64 MB board that is the difference between a main
stream and none; see [Wide sensors on 64 MB boards](#wide-sensors-on-64-mb-boards).

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

#### Wide sensors on 64 MB boards

A 64 MB camera usually gives the media region 32 MB (`osmem=32M`). With a
1080p sensor that is comfortable; with a wider one, every frame is bigger and
the region has to be counted. The case that prompted this section is a
gk7205v500 with an SC401AI at 2560x1440 — a frame there is about 5.5 MB — running
a main and a sub stream ([OpenIPC/majestic#350](https://github.com/OpenIPC/majestic/issues/350),
[OpenIPC/firmware#2587](https://github.com/OpenIPC/firmware/issues/2587)).

Roughly where 32 MB goes on that camera, main stream H.265 at 2560x1440 and a
sub stream at 800x448:

| | Frames in the pool | Pool | Noise-reduction reference | Main encoder | Sub stream, buffers, ISP | Total |
|---|---|---|---|---|---|---|
| capture through memory (builds before mid-October 2026) | 6 | ~34 MB | | | | does not fit — **no main stream** |
| capture straight through, automatic pool | 4 | ~23 MB | ~4 MB | ~6 MB | ~3 MB | ~36 MB — does not fit |
| capture straight through, one frame given back | 3 | ~18 MB | ~4 MB | ~6 MB | ~3 MB | **~31 MB — fits** |
| [memory-saving main stream](#memory-saving-main-stream), if the chip accepts it (builds from 18 October 2026) | 3, incl. the spare | ~18.5 MB | ~4 MB | ~6 MB | ~3 MB | **~31 MB — fits first time** |

These are estimates, built from per-frame and per-encoder figures measured on a
gk7205v200 and an hi3516ev300; they have not been measured on a gk7205v500 yet.
The memory-saving row costs the same as giving a frame back, but gets there
without the failed start and keeps the spare frame that snapshots draw on. It
applies only if the chip accepts the mode for these streams; if it declines, the
camera is on the whole-frame rows above and the automatic fallback below.

What the streamer does about the middle row is automatic. When the pool leaves
the image pipeline or the main encoder no room, it gives one frame back and
rebuilds the pipeline at the smaller size, once per frame it can spare, down to
the least the pipeline can stream on. Video comes up a few seconds late, and the
log says what was given back and that a restart tries the larger pool again. A
pool at that floor behaves as described under
[`isp.blkCnt`](#ispblkcnt--how-many-frames-are-pooled): video runs, and a snapshot
can occasionally find no free frame.

If it still does not fit:

- **`video1.enabled: false`** returns a frame and the sub stream's encoder — the
  largest saving available.
- **A smaller `video0.size`** makes the main encoder smaller, but not the frames
  in the pool: they follow the sensor, not the stream.
- On the gk7205v500 family, prefer the fixed split to CMA on 64 MB — see
  [Kernel 4.9](#kernel-49-legacy). It does not change how big the region is, but
  allocations in it never wait on Linux to move pages out first.

#### Memory-saving main stream

On the gk7205v200, gk7205v300, gk7201v200 and the gk7205v500 family (v500,
v510, v530), builds from 18 October 2026 have a memory-saving mode for the main
stream. It takes about one frame's worth less media memory, the way the stock
Xiongmai firmware on these boards fits a 4 MP camera into its media region.

Nothing needs switching on. The camera uses it when all of these hold:

- the main stream is at the sensor's own size, with no crop and no rotation;
- the capture goes straight through (the sensor is no wider than the chip's
  limit in [the table above](#one-frame-per-channel)) and the sensor runs one
  exposure, not WDR;
- the sub stream (`video1`) is on;
- none of these is in use: motion detection, privacy masks, `image.flip` or
  `image.mirror`, `isp.yuvCompression`, or an object detector the camera can
  actually run (on NPU-equipped parts).

Measured on lab cameras with the sub stream on:

| Camera | Main stream | Media memory, mode off | Mode on |
|---|---|---|---|
| gk7205v200 + IMX307 | 1080p25 | 21676 KB | **19016 KB** |
| gk7205v300 + IMX335 (1080p mode) | 1080p50 | 20984 KB | **18612 KB** |
| gk7205v510 + MIS2008 | 1080p25 | 20328 KB | **17668 KB** |
| gk7201v200 + MIS2008, 64 MB | 1080p20 | 21860 KB | **19316 KB** |

Both streams kept their frame rates. A 2560-wide sensor such as the SC401AI
has not been measured yet; there a frame is about 5.5 MB.

What changes for the built-in camera while the mode is on:

- `/image.jpg` and `/mjpeg` are made from the **sub stream**, at its size,
  whatever `jpeg.size` says. A request for a larger picture gets the sub
  stream's. Snapshots of another source chosen with `?channel=` are not
  affected.
- `/image.yuv420` returns the sub stream's frame, at its size.
- [Automatic image tuning](automatic-image-tuning.md) (`image.tuning`) cannot
  measure the picture. Its panel reads *No reading*, then *No answer*, as it
  does on a camera whose main stream is compressed.

Turning `video1`, `image.flip`, `image.mirror`, a privacy mask or object
detection on or off on a running camera moves it in or out of the mode by
itself. That rebuilds the pipeline, so the streams drop for a moment. Motion
detection, as everywhere, takes effect only after a reload. Full-size snapshots
and raw YUV come back as soon as a condition stops holding; turning `video1` off
is the simplest way.

The chip can decline the mode when the streams are more than its encoder can
keep up with. A gk7205v300 accepted it for a 1080p50 main stream beside a
640x360 sub stream at 10 fps, and declined it beside a 720p50 sub stream. When
it declines, the main stream works exactly as it did before, with no failed
start.

#### `jpeg.enabled` — snapshots and the MJPEG stream

Controls whether the camera serves JPEG at all. How much memory that is worth
depends on the platform:

- **HiSilicon and Goke, except hi3516cv100 and the hi3516cv6xx family** (builds
  from late September 2026 on): **nothing is reserved for snapshots.** A JPEG is
  made from a frame the video stream already has, and memory is taken only while
  snapshots are being served — on a gk7205v200 with a 1080p sensor, about 2 MB
  for the JPEG encoder once the first one is asked for. Turning `jpeg.enabled`
  off there frees no frame; it only refuses the requests.
- **hi3516cv100, the hi3516cv6xx family, and older HiSilicon/Goke builds**: a
  full frame is reserved for the snapshot channel from start-up, and turning it
  off is the single biggest saving on a small board.

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

| SoC | Sensor | Build | Media memory with JPEG on | Off | Freed |
|---|---|---|---|---|---|
| gk7205v200 | 1920x1080 | before late Sep 2026 | 12156 KB (pool) | 9116 KB | **3.0 MB** |
| hi3516ev300 | 2592x1520 | before late Sep 2026 | 28860 KB (pool) | 23088 KB | **5.6 MB** |
| gk7205v200 | 1920x1080 | current | 16632 KB (all of it) | 16632 KB | none |

On the current build the gk7205v200 goes to 18680 KB while it serves snapshots
— the JPEG encoder — and with JPEG off it stays at 16632 KB and answers **503**.

#### `jpeg.tuned` — parameterised snapshots

On the HiSilicon and Goke parts that reserve nothing for snapshots (see
[`jpeg.enabled`](#jpegenabled--snapshots-and-the-mjpeg-stream)), this setting
is **ignored**, and so is everything below about caps and restarts: a snapshot
of any size, crop or quality is made the same way as a plain one, takes memory
only while it is being made, and needs nothing set first. The streamer says so
at start-up when the key is still set. What such a request gets is described
in [Majestic streamer](majestic-streamer.md#width-height-and-qfactor-and-everything-on-lite).
The rest of this section applies to the other platforms.

`/image.jpg` accepts `width`, `height`, `qfactor`, `gray` and `crop`, which are
served by a **second** snapshot encoder on its own geometry. That encoder needs
frames of its own, so it is off by default:

```bash
# largest parameterised snapshot to serve; off (the default) refuses them
curl 'http://localhost/api/v1/set?jpeg.tuned=640x360'
```

On an **Ultimate** build only `width`, `height` and `qfactor` still come this
way. `crop` and `gray` are cut out of the frame the camera has already made,
which reserves nothing and costs no quality — so if a smaller picture is what
you are after, a crop asks for one without any of the memory below. On Lite and
FPV all five parameters go through the second encoder.

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
- the raw `/image.yuv420` and `/image.webp` endpoints — these read raw pixels,
  and nothing on these SoCs can turn a compressed frame back into pixels.

[`image.tuning`](automatic-image-tuning.md) is the one that yields the other
way round. It also needs raw pixels, but compression is not turned off for it:
the camera keeps the frames compressed as asked and switches automatic tuning
off instead, putting your saved picture settings back. Compressing the pool is
a memory decision on a board that may not have the memory, and it is not
overridden by a picture feature you can equally well leave off.

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

---

SigmaStar boards
----------------

### Memory allocator: MMA

SigmaStar SoCs put every ISP, scaler and encoder buffer in the **MMA** heap —
the vendor multimedia allocator's pool, a contiguous region U-Boot carves out of
DRAM before Linux starts. It is why a camera with 256 MB of RAM reports about 90 MB —
this is what one owner's ssc377qe printed, in
[firmware#2443](https://github.com/OpenIPC/firmware/issues/2443):

```
Memory: 89592K/262144K available (2404K kernel code, 347K rwdata, 1068K rodata,
        124K init, 114K bss, 170504K reserved, 2048K cma-reserved)
```

Unlike HiSilicon's CMA-backed MMZ, **MMA is a static carve-out**. The pages are
reserved whether or not video is running, and the kernel cannot borrow them back
while the camera is idle. Shrinking the reservation is the only lever there is.

#### Where the size comes from

OpenIPC's U-Boot builds its bootargs from two variables
(`include/configs/sstar-common.h`):

```
... LX_MEM=${memlx} mma_heap=mma_heap_name0,miu=0,sz=${memsz} cma=2M
```

`LX_MEM` is how much DRAM Linux manages and `sz` is the MMA heap reserved
*inside* it. `board_late_init()` in `arch/arm/cpu/armv7/infinity6c/chip.c` — and
the matching `infinity6`, `infinity6b0` and `infinity6e` files — fills both in
from the DRAM size it detects at boot:

`infinity6`, `infinity6b0` and `infinity6c` share one set of sizes:

| DRAM | `memsz` (MMA heap) | `MemTotal` that leaves |
|---|---|---|
| 256 MB | `0xA000000` — 160 MB | 91640 kB (measured, infinity6c) |
| 128 MB | `0x4600000` — 70 MB | 53848 kB (measured, infinity6c) |
| 64 MB | `0x2000000` — 32 MB | ~27 MB (arithmetic) |

`infinity6e` is the exception. It reserves slightly *less*, and it has rows for
512 MB and 1 GB that the others do not:

| DRAM | `memsz` (MMA heap) | `MemTotal` that leaves |
|---|---|---|
| 1 GB | `0x1FE9C000` — 510 MB | |
| 512 MB | `0x0FE9C000` — 255 MB | |
| 256 MB | `0x9E9C000` — 158 MB | 92768 kB (measured) |
| 128 MB | `0x4E9C000` — 79 MB | |
| 64 MB | `0x1E9C000` — 31 MB | |

So two 256 MB cameras can report different totals — 91640 kB on an infinity6c
and 92768 kB on an infinity6e — purely because the families reserve 160 MB and
158 MB respectively. `LX_MEM` differs cosmetically too: `infinity6c` hands Linux
all of DRAM, the other three a fraction under it.

The `Memory:` line at the top of this section accounts for itself exactly — it
is a 256 MB infinity6c:

```
 262144K  DRAM, all of it given to Linux by LX_MEM=0x10000000
-163840K  mma_heap sz=0x0A000000
-  2048K  cma=2M, reported separately as "cma-reserved"
-  4057K  kernel image (2404 code + 347 rwdata + 1068 rodata + 124 init + 114 bss)
-  2607K  mem_map, page tables, early allocations
= 89592K  available
```

`MemTotal` in `/proc/meminfo` is 91640 kB — the 89592K plus the 2 MB of CMA,
which counts as ordinary memory until something asks for a contiguous buffer.

#### Reading what the pipeline actually uses

```bash
cat /proc/mi_modules/mi_sys_mma/mma_heap_name0
```

The first two lines are a header and a row for the heap. Read two of its
columns, both byte counts in hex: **`length`**, the size of the heap, and the
last column, how much of it is still free — named `avail` on infinity6c and
`chunk_mgr_avail` on infinity6e, depending on the firmware generation. What the
pipeline is using is the difference between them.

Everything below that row is one line per allocation, each attributed to the
part of the video pipeline and the process holding it, which is how the figures
below were measured.

> **Exercise the camera before you read it.** A pipeline that has just started
> and never served a snapshot reports far less than its steady state. Pull a
> handful of stills and connect a client first.

Measured with majestic running its normal configuration:

| Board | Sensor and streams | Heap | Used | Spare |
|---|---|---|---|---|
| ssc377d (infinity6c, 128 MB) | imx335, video0 2560x1920 + JPEG | 70 MB | **40 MB** | 30 MB |
| ssc30kq (infinity6e, 256 MB) | imx335, video0 full-res + video1 704x576 + JPEG 1280x720 | 158 MB | **56 MB** | 102 MB |

A 5 MP pipeline needs something in the region of 40–56 MB. The 256 MB profile
reserves about three times that.

#### The trap: `memsz` is reset on every boot

`memlx` and `memsz` live in the saved environment, and `fw_printenv` will read
your value back happily — but `board_late_init()` calls `setenv()` on both
**unconditionally, on every boot, before `bootcmd` runs**. Anything you write
there is overwritten before the kernel command line is assembled:

Set `memsz` to anything you like and reboot, and all three of these disagree
with each other:

```bash
fw_printenv memsz      # your value, still in flash where you wrote it
cat /proc/cmdline      # the stock size, which is what the kernel was given
free                   # unchanged, because the heap never moved
```

`/proc/cmdline` is the only honest answer of the three. Check it, and not the
environment, whenever you want to know how the heap is actually sized.

#### Changing the split

Rewrite `bootargs` itself so the size is literal. Substitute only the heap size
and leave every other token byte-identical — in particular leave
`LX_MEM=${memlx}` and `${rootmtd}` as placeholders, so that `mtdparts` is never
retyped by hand:

```bash
fw_printenv -n bootargs > /root/bootargs.orig          # keep the original

sed 's/\(mma_heap=[^ ]*,sz=\)[^ ,]*/\10x06000000/' /root/bootargs.orig > /tmp/ba
diff /root/bootargs.orig /tmp/ba                       # must show sz= and nothing else
fw_setenv bootargs "$(cat /tmp/ba)"
fw_printenv -n bootargs                                # read it back BEFORE rebooting
reboot
```

To undo it: `fw_setenv bootargs "$(cat /root/bootargs.orig)"`.

> **Copy `bootargs.orig` off the camera as well.** `firstboot`, and any
> `sysupgrade -n`, wipe the overlay that `/root` lives on — while the U-Boot
> environment you just changed survives untouched. That is the one combination
> that leaves a camera booting a value you can no longer look up.

**Run the `diff`, do not skip it.** The substitution matches the `sz=` inside
`mma_heap` whatever it holds, so it works on an installation whose `bootargs`
still carries `${memsz}` and on an older one that was set up with a literal size
and `mma_memblock_remove=1`. But a `bootargs` shaped differently again will pass
through unchanged, `fw_setenv` will write it back happily, and the camera will
reboot with the size it already had. An empty `diff` means nothing was replaced.

The bootargs stored in the environment keep their `${...}` placeholders; U-Boot
expands them at boot through `setenv setargs setenv bootargs ${bootargs}; run
setargs`, which is why substituting one of them works and why the rest can be
left alone.

Every byte taken off the heap goes back to Linux, one for one:

| Board | Heap | `MemTotal` | Heap still free |
|---|---|---|---|
| ssc30kq, 256 MB, stock | 158 MB | 92768 kB | 102 MB |
| ssc30kq, 256 MB, `sz=0x06000000` | 96 MB | **156880 kB** | 40 MB |
| ssc377d, 128 MB, stock | 70 MB | 53848 kB | 30 MB |
| ssc377d, 128 MB, `sz=0x3800000` | 56 MB | **68184 kB** | 16 MB |

Both kept streaming, served snapshots at full sensor resolution and logged no
allocation failures.

#### Choosing a size

Take the measured peak and leave real headroom over it — on a 256 MB board
`sz=0x06000000` (96 MB) is a reasonable starting point for a single 5 MP sensor,
and on a 128 MB board `sz=0x3800000` (56 MB).

Measure with **everything you actually use** switched on. The heap is sized once,
at startup, and overlays, a second stream, LDC and parameterised snapshots all
come out of it. The [streamer settings](#streamer-memory-settings) that decide
how much the pipeline puts into the region apply here as much as on HiSilicon —
`video1.enabled`, `jpeg.enabled` and `jpeg.tuned` are each worth a whole frame.

> **Running short does not fail loudly.** The vendor allocator returns an error
> deep inside the stack, so the symptom is a stream that never starts or a
> snapshot that is never answered — and it can appear only at a later mode
> change, such as a night-mode switch or a resolution change, rather than at
> boot. Keep the original `bootargs` somewhere you can paste it back from, and
> test the camera through a full day/night cycle before you trust a new value.
