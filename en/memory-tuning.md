# OpenIPC Wiki
[Table of Content](../README.md)

HiSilicon boards
----------------

### Memory allocator: MMZ

HiSilicon SoCs require contiguous physical memory for ISP and video DMA buffers.
This memory is managed by the MMZ (Media Memory Zone) subsystem inside the
`open_osal` kernel module.

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

Key differences from 4.9:

| | Kernel 4.9 | Kernel 6.6+ |
|---|---|---|
| Allocator | Vendor `hi_cma.c` | Mainline CMA |
| Configuration | U-Boot bootargs | Device Tree `reserved-memory` |
| `mem=` bootarg | **Required** (`mem=32M`) | **Optional** (can use `mem=128M` or omit) |
| `mmz=` bootarg | **Required** | **Ignored** (kernel logs "Unknown kernel command line parameters") |
| Memory sharing | Static partition | Reusable (kernel can use CMA pages when video is idle) |

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

Vendor kernel modules take about 5 megabytes of RAM (code with dynamic memory
for buffers) and some of them are pretty useless unless you need specific
functionality like OSD, motion detection, support of audio, or H264/265/JPEG
codecs.

| Feature                               | Modules                                                                                                 | Size |
|---------------------------------------|---------------------------------------------------------------------------------------------------------|------|
| Audio output                          | hi3516ev200_ao, hi3516ev200_adec                                                                        |      |
| Audio input                           | hi3516ev200_ai, hi3516ev200_aenc                                                                        |      |
| Audio support (both input and output) | hi3516ev200_acodec, hi3516ev200_adec, hi3516ev200_aenc, hi3516ev200_ao, hi3516ev200_ai, hi3516ev200_aio |      |
| I2C sensor support                    | hi_sensor_i2c                                                                                           |      |
| SPI sensor support                    | hi_sensor_spi                                                                                           |      |
| PWM support                           | hi_pwm                                                                                                  |      |
| Motion detection                      | hi3516ev200_ive                                                                                         |      |
| JPEG snapshots                        | hi3516ev200_jpege                                                                                       |      |
| H.264 codec support                   | hi3516ev200_h264e                                                                                       |      |
| H.265 codec support                   | hi3516ev200_h265e                                                                                       |      |
| OSD support                           | hi3516ev200_rgn                                                                                         |      |
