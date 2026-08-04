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
pipeline puts **into** it, and the three settings that change how much it takes.

All three settings below are read when the video pipeline starts, so a change
only takes effect after the streamer restarts:

```bash
/etc/init.d/S95majestic restart
```

Setting one through the API persists it and returns `200`, but the running
pipeline keeps its existing buffers until that restart — so always check the
result rather than assuming the call was enough.

All of the region's usage is visible at runtime:

```bash
cat /proc/media-mem
# ---MMZ_USE_INFO:
#  total size=98304KB(96MB),used=53032KB(51MB),remain=45272KB(44MB)
```

Most of `used` is frame buffers: a pool of full-size video frames that the ISP,
the scaler and the encoder pass between them. A 1080p frame is about 3 MB and a
5 MP frame about 5.6 MB, so the pool dominates everything else on the board.

#### `isp.blkCnt` — how many frames are pooled

The number of frames reserved for the pipeline. Lowering it frees whole frames
at a time, which makes it the biggest single lever — and the easiest one to
overshoot: too few buffers and the encoder starves, producing a stream that
stalls or never starts.

```bash
curl 'http://localhost/api/v1/set?isp.blkCnt=4'
/etc/init.d/S95majestic restart
```

Change it one step at a time and confirm the stream still runs.

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
/etc/init.d/S95majestic restart
```

#### `isp.yuvCompression` — compressing the frame pool

A recent majestic update can store the pipeline's frames **compressed** in
memory. Where the SoC allows it, the pool is then reserved at the compressed
size and the difference is returned to the system.

```bash
curl 'http://localhost/api/v1/set?isp.yuvCompression=seg'
/etc/init.d/S95majestic restart
```

`auto` (the default) leaves compression off, so nothing changes unless you ask
for it. Measured on a 128 MB board, comparing `/proc/media-mem` before and
after:

| SoC | Sensor | Before | After | Freed |
|---|---|---|---|---|
| hi3516ev300 | 2592x1520 | 53032 KB | 47108 KB | **5.8 MB** |
| gk7205v200 | 1920x1080 | 21560 KB | 19460 KB | **2.1 MB** |

Roughly 1 MB per pooled frame at 1080p and 2 MB at 5 MP, for two or three
frames depending on `isp.blkCnt`. Your absolute figures will differ — total
usage depends on resolution, second stream, snapshots and the rest of the
configuration — so compare the **difference** across the restart rather than
matching the numbers above.

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

To confirm it took effect, compare `/proc/media-mem` before and after the
restart. If the numbers do not move, either the SoC is one of those that
reserves the full size anyway, or one of the settings above overrode it — the
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
