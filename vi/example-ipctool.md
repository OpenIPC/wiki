# OpenIPC Wiki
[Mục lục](../README.md)

Chạy ipctool
-----------

```bash
root@ipcam:/# ipctool
```

```yaml
---
bảng mạch:
  nhà cung cấp: OpenIPC
  phiên bản: 2020.02
chip:
  nhà cung cấp: Xiongmai
  model: XM530
ethernet:
  mac: "00:12:41:xx:xx:xx"
rom:
  - loại: nor
    khối: 64K
    phân vùng:
      - tên: boot
        kích thước: 0x40000
        sha1: e2c7973d
        chứa:
          - tên: uboot-env
            vị trí: 0x30000
      - tên: env
        kích thước: 0x10000
        sha1: fb6f2de6
      - tên: kernel
        kích thước: 0x200000
        sha1: 1130ee7a
      - tên: rootfs
        kích thước: 0x500000
        đường dẫn: /,squashfs
        sha1: 890552b4
      - tên: rootfs_data
        kích thước: 0xb0000
        đường dẫn: /overlay,jffs2,rw
    kích thước: 8M
ram:
  tổng: 64M
  media: 32M
firmware:
  kernel: "3.10.103+ (SMP Fri Apr 23 21:29:40 UTC 2021)"
  toolchain: gcc phiên bản 7.5.0 (Buildroot 2020.02-gb5b7c71)
  god-app: ipctool
cảm biến:
- nhà cung cấp: SmartSens
  model: SC2315E
  kiểm soát:
    bus: 0
    loại: i2c
    địa chỉ: 0x30
```


