# OpenIPC Wiki
[Table of Content](index.md)

Help: U-boot
------------

### Environment

If you get `Too many args` error while trying to set an environment variable,
try to do that from within Linux using `fw_setenv` instead of `setenv` in U-boot.

__U-boot console:__
```
hisilicon # setenv uk 'mw.b 0x82000000 ff 1000000; tftp 0x82000000 uImage.${soc}; sf probe 0; sf erase 0x50000 0x200000; sf write 0x82000000 0x50000 ${filesize}'
** Too many args (max. 16) **
```

__OpenIPC Linux:__
```
root@openipc-hi3518ev100:~# fw_setenv uk 'mw.b 0x82000000 ff 1000000; tftp 0x82000000 uImage.${soc}; sf probe 0; sf erase 0x50000 0x200000; sf write 0x82000000 0x50000 ${filesize}'
root@openipc-hi3518ev100:~#
```
