# OpenIPC Wiki
[Table of Content](../README.md)

## Troubleshooting: Network does not work on hi35xx
If network is not working on your hi35xx device after installing OpenIPC (no link), you may have to tune the MII (Media Independent Interface) settings.  
For U-Boot, this is done by setting values for `phyaddru`, `phyaddrd` and `mdio_intf`.
Possible values for `phyaddru` and `phyaddrd` are: `0-3`. Which values `mdio_intf` takes depends on the SoC:

- **hi3516cv100 / hi3518cv100 / hi3518ev100:** `mii` or `rmii`. The U-Boot for these chips also sets the PHY clock from it: 25 MHz for `mii`, 50 MHz for `rmii` ([board.c](https://github.com/OpenIPC/u-boot-hi3516cv100/blob/master/board/hi3518/board.c)). Its default is `rmii`, so a board wired for MII has no network in U-Boot until it is set to `mii`.
- **Chips with the gigabit MAC (higmac):** `rgmii` or `gmii`.

For the Linux kernel / OS, values can be set through the `extras` boot variable as `hieth.phyaddru`, `hieth.phyaddrd`, `hieth.mdioifu` and `hieth.mdioifd`. The kernel does not read U-Boot's `mdio_intf`, so a board that needs MII has to be told twice: `mdio_intf=mii` for U-Boot, and `hieth.mdioifu=0 hieth.mdioifd=0` in `extras` for Linux, where 0 is MII and 1 is RMII. The kernel's defaults on hi3516cv100 are `mdioifu=1 mdioifd=1 phyaddru=1 phyaddrd=2`, i.e. RMII; `cat /sys/module/hieth/parameters/*` shows what it is running with.

Often the correct values can be found in your stock firmware. Viewing the boot logs or running [ipctool](https://github.com/OpenIPC/ipctool) on your stock firmware may provide clues.

Below are some combinations you can try:

### For ethernet in Linux:

In Linux console run this:
```
fw_setenv extras 'hieth.phyaddru=0 hieth.phyaddrd=1' && reboot
```
If the above settings did not work, try this instead:
```
fw_setenv extras 'hieth.phyaddru=1 hieth.phyaddrd=0' && reboot
```
Or:
```
fw_setenv extras 'hieth.mdioifu=0 hieth.mdioifd=0' && reboot
```
Or:
```
fw_setenv extras 'hieth.mdioifu=1 hieth.mdioifd=1' && reboot
```
Or:
```
fw_setenv extras hieth.mdioifu=0 hieth.mdioifd=0 hieth.phyaddru=1 hieth.phyaddrd=2 && reboot
```
Or:
```
fw_setenv extras hieth.phyaddru=3 hieth.mdioifu=0 && reboot
```

*Note: if a certain combination causes your device to fail to boot, you can clear the variable(s) in the U-Boot prompt by calling `setenv <variable>`, i.e. set the variable using an empty argument, followed by `saveenv`.*

### For ethernet in U-boot:

Set `phyaddru` and `phyaddrd` variables from U-Boot console:
```
setenv phyaddru 0; setenv phyaddrd 1; saveenv; reset
```
If the above settings did not work, try this instead
```
setenv phyaddru 1; setenv phyaddrd 0; saveenv; reset
```
Or:
```
setenv phyaddru 0; setenv phyaddrd 0; saveenv; reset
```
Or:
```
setenv phyaddru 1; setenv phyaddrd 1; saveenv; reset
```

*Note: to initialize and test network connectivity in U-Boot, the `ping` command can be used.*  

Some known combinations for specific boards:

### XiongMai, HI3518EV100 and HI3516CV100
*For U-boot network:*
```
    setenv phyaddru 1
    setenv phyaddrd 2
    setenv mdio_intf rmii
    saveenv
```
*For Linux network:*
```
    setenv extras 'hieth.phyaddru=1 hieth.phyaddrd=2'
    saveenv
```

### XiongMai IPG-53H20AF, HI3516CV100

*For Linux network:*
```
    setenv extras 'hieth.mdioifu=0 hieth.mdioifd=0 hieth.phyaddru=1 hieth.phyaddrd=2'
    saveenv
```

### Hi3518EV100 (HI3518ERBCV100) and Hi3518CV100 boards wired for MII (e.g. ZModo ZP-IBI13)

The Linux settings are reported working in [OpenIPC/firmware#1333](https://github.com/OpenIPC/firmware/issues/1333). The U-Boot ones follow from what its network driver reads (`mdio_intf`, `phyaddru`, `phyaddrd`) and have not yet been confirmed on these boards.

*For U-boot network:*
```
    setenv mdio_intf mii
    setenv phyaddru 1
    setenv phyaddrd 2
    saveenv
```

*For Linux network:*
```
    setenv extras 'hieth.mdioifu=0 hieth.mdioifd=0 hieth.phyaddru=1 hieth.phyaddrd=2'
    saveenv
```

### CamHi/HiChip/Xin, HI3518EV200

*For U-boot network:*
```
    setenv phyaddru 0
    setenv phyaddrd 1
    saveenv
```

### HiWatch, HI3518CV100

*For U-boot network:*
```
    setenv phyaddru 3
    saveenv
```

*For Linux network:*
```
    setenv extras 'hieth.phyaddru=3 hieth.mdioifu=0'
    saveenv
```

### JVT (board IP2001 2014-09-22), HI3516CV100

*For Linux network:*
```
    setenv extras 'hieth.phyaddru=1 hieth.mdioifu=0'
    saveenv
```

### Harex (5013A-CF/5020A-FF), HI3516CV100

*For Linux network:*
```
    setenv extras 'hieth.phyaddru=1 hieth.mdioifu=0'
    saveenv
```

### Brovotech 600102005-BV-H0205, HI3516CV100 + IMX122

*For Linux network:*
```
    setenv extras 'hieth.mdioifu=0 hieth.mdioifd=0'
    saveenv
```

If nothing of the above worked for you, please ask in [our Telegram channels](https://openipc.org/our-channels).
