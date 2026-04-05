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

| CMA size | Non-movable headroom | Video headroom | Good for |
|---|---|---|---|
| 96MB | 32MB (tight) | 62MB spare | Maximum video buffers, multiple streams |
| 64MB | 64MB (comfortable) | 30MB spare | Typical single-stream use |
| 48MB | 80MB (generous) | 14MB spare | Minimal video + heavy network/app workload |

**How to override CMA size without rebuilding:**

The kernel accepts a `cma=` bootarg that overrides the Device Tree default:

```bash
# In U-Boot:
setenv bootargs mem=128M cma=48M console=ttyAMA0,115200 panic=20 ...
saveenv
```

This sets the CMA pool to 48MB regardless of what the DT declares. You can
experiment with different values and check the result:

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

> **Recommendation:** start with `cma=48M` for single-stream setups. If you see
> allocation failures in dmesg or majestic fails to start, increase to `cma=64M`.
> The default 96MB is safe but wastes non-movable headroom.

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
