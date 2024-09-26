## OpenIPC Wiki
[Mục lục](../README.md)

Khởi động thiết bị bằng NFS
--------------------

Ví dụ cho thiết bị HI3516EV200

```
bootargsnfs=mem=${osmem:-32M} console=ttyAMA0,115200 panic=20 root=/dev/nfs rootfstype=nfs ip=dhcp nfsroot=192.168.1.254:/media/nfs/hi3516ev200,v3,nolock rw ip=192.168.1.55:192.168.1.254:192.168.1.254:255.255.255.0::eth0

nfsboot=tftp 0x42000000 uImage;setenv setargs setenv bootargs ${bootargsnfs};run setargs;bootm 0x42000000

run nfsboot
```

Cách khởi động OpenIPC bằng NFS và TFTP mà không cần thay thế firmware gốc (bài viết tiếng Nga):
https://habr.com/ru/companies/ruvds/articles/774482/
