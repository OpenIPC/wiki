# OpenIPC Wiki
[Table of Content](../README.md)

Run ipctool
-----------

```bash
root@ipcam:/# ipctool
```

```yaml
---
board:
  vendor: OpenIPC
  version: 2020.02
chip:
  vendor: Xiongmai
  model: XM530
ethernet:
  mac: "00:12:41:xx:xx:xx"
rom:
  - type: nor
    block: 64K
    partitions:
      - name: boot
        size: 0x40000
        sha1: e2c7973d
        contains:
          - name: uboot-env
            offset: 0x30000
      - name: env
        size: 0x10000
        sha1: fb6f2de6
      - name: kernel
        size: 0x200000
        sha1: 1130ee7a
      - name: rootfs
        size: 0x500000
        path: /,squashfs
        sha1: 890552b4
      - name: rootfs_data
        size: 0xb0000
        path: /overlay,jffs2,rw
    size: 8M
ram:
  total: 64M
  media: 32M
firmware:
  kernel: "3.10.103+ (SMP Fri Apr 23 21:29:40 UTC 2021)"
  toolchain: gcc version 7.5.0 (Buildroot 2020.02-gb5b7c71)
  god-app: ipctool
sensors:
- vendor: SmartSens
  model: SC2315E
  control:
    bus: 0
    type: i2c
    addr: 0x30
```
