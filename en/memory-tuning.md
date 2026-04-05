# OpenIPC Wiki
[Table of Content](../README.md)

HiSilicon boards
----------------

### Memory allocator: MMZ

HiSilicon SoCs require contiguous physical memory for ISP and video DMA buffers.
This memory is managed by the MMZ (Media Memory Zone) subsystem inside the
`open_osal` kernel module.

There are two allocator backends. The choice depends on your kernel version:

| | hisi (static) | CMA (mainline) |
|---|---|---|
| **Available on** | Kernel 4.9 | Kernel 6.6+ (neo) |
| **How it works** | Kernel is given a reduced `mem=` size; the remaining RAM is invisible to Linux and owned entirely by MMZ | Kernel sees all RAM; CMA reserves a region marked `reusable` that Linux can use for movable pages until video needs it |
| **Memory efficiency** | Low -- the MMZ region is wasted when video is idle (e.g. during boot, firmware updates, network-only workloads) | High -- CMA pages serve normal allocations and are migrated out on demand when video starts |
| **Allocation latency** | Deterministic -- buffers come from a dedicated pool that is always free | May spike -- CMA must migrate pages out before returning contiguous memory; first allocation after boot can take a few milliseconds |
| **Configuration** | U-Boot bootargs (`mmz_allocator=cma mmz=anonymous,...`) | Device Tree `reserved-memory` node; no bootargs needed |
| **Best for** | Low-latency or memory-constrained (64MB) boards where every millisecond of ISP startup matters | General use, especially 128MB+ boards where wasting 96MB on a static pool is painful |

> **Rule of thumb:** if your board has 128MB+ RAM and runs kernel 6.6+, use CMA
> (it is the default for `neo` builds). If you are on kernel 4.9 or have 64MB
> RAM, use the hisi allocator with `mem=32M`.

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

#### What this means for end users

**128MB boards (hi3516ev300):**

With 6.6, you can give the kernel the full 128MB (`mem=128M` or just remove the
`mem=` bootarg entirely). The 96MB CMA region is marked `reusable`, meaning the
kernel can use those pages for normal allocations when video is not running.
When video starts, CMA migrates pages out and provides contiguous buffers.

All three configurations work on 6.6:

```
# Full memory (recommended) - kernel manages everything via CMA
mem=128M console=ttyAMA0,115200 ...

# No mem= at all - kernel gets full RAM from DT
console=ttyAMA0,115200 ...

# Legacy bootargs still work (mmz params are silently ignored)
mem=128M ... mmz_allocator=cma mmz=anonymous,0,0x42000000,96M
```

**64MB boards (hi3516ev200, hi3518ev300):**

The 6.6 kernel with CMA has not yet been tested on 64MB boards. The DT
`reserved-memory` region size may need adjustment (32MB instead of 96MB).  For
now, continue using the 4.9 kernel with `mem=32M`.

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

#### Upgrading U-Boot bootargs

If you are upgrading a hi3516ev300 from 4.9 to 6.6, you can update your U-Boot
environment to give the kernel full memory:

```
setenv bootargs mem=128M console=ttyAMA0,115200 panic=20 ...
saveenv
```

Old bootargs with `mmz_allocator=cma mmz=anonymous,...` still work on 6.6, they
are simply ignored.  There is no need to change U-Boot before upgrading.

---

### Disable subsystems you don't use

Kernel modules take about 5 megabytes of RAM (code with dynamic memory for
buffers) and some of them are useless unless you need specific functionality like
OSD, motion detection, audio, or specific codecs.

The table below shows both legacy vendor module names (kernel 4.9) and the modern
open-source module names (kernel 6.6+ / opensdk).

| Feature | Legacy modules (4.9) | Open modules (6.6+) | Size |
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
| Rate control | -- | open_rc | 111 KB |
| Encode device | -- | open_vedu | 29 KB |
| OSD / regions | hi3516ev200_rgn | open_rgn | 86 KB |
| ISP | hi3516ev200_isp | open_isp | 201 KB |
| Video input | -- | open_vi | 373 KB |
| VPSS | -- | open_vpss | 332 KB |
| VGS | -- | open_vgs | 143 KB |
| MIPI receiver | -- | open_mipi_rx | 37 KB |
| Watchdog | -- | open_wdt | 12 KB |

To disable a module, comment out or remove the corresponding `modprobe` line in
`/usr/bin/load_hisilicon`. For example, to disable audio entirely, comment out
the `insert_audio` call and the individual `modprobe open_aio`, `open_ai`,
`open_ao`, `open_aenc`, `open_adec`, `open_acodec` lines.

> **Note:** `open_osal`, `open_sys_config`, `open_base`, and `open_sys` are core
> modules required by all other subsystems and must not be removed.
