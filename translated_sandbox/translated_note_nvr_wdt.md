## Disabling watchdog on the recorder

The loader on the recorder starts a dog that reboots it every half hour. To disable, copy [`wdt.ko`](hi3536dv100/lib/wdt.ko) to `/lib` and add to [`/etc/init.d/S95hisilicon`](hi3536dv100/etc/init.d/S95hisilicon) to module loads, unloading immediately:
```
    insmod /lib/wdt.ko
    rmmod /lib/wdt.ko
```

Reboot, watchdog should no longer trigger.