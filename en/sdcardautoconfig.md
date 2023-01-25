# OpenIPC Wiki
[Table of Content](../index.md)

SD Card Autoconfig
------------------

OpenIPC can be configured automatically from an SD card. This method is particularly useful for WiFi-only
IP cameras equipped with and SD card slot and where UART is not acessible.

### Format an SD card with at least one FAT/FAT32/vFAT partition.

Attention! All existing data on the SD card will be deleted!

On Windows:
```
diskpart

list disk
select disk <number corresponding to your SD card>
clean
create partition primary
format quick fs=FAT32
list partition
active
assign letter=<letter>
```

### Create `automount.sh` file in the root directory of the card.

```
echo "#!/bin/sh" > <sdcard-path>/automount.sh
```

### Add files to inject into firmware.

Create a folder named `autoconfig` at the root of your SD card and place there files that should
be copied inside OpenIPC firmware with their paths following this pattern:
`<sdcard-path>/autoconfig/<target-path>/file` => `/<target-path>/file`.

E.g. `<sdcard-path>/autoconfig/etc/init.d/interfaces` will be copied to `/etc/init.d/interfaces`.

Add this code to `automount.sh` to handle the copying:
```
if [ -d "${destdir}/$1/autoconfig" ]; then
  cp -afv ${destdir}/$1/autoconfig/* / | logger -s -p daemon.info -t autoconfig
fi
```

### Add a one-time configuration script.

Create `autoconfig.sh` file at the root of the SD card. This script will be run once, then removed.

Add this code to `automount.sh` to handle the one-time execution:
```
if [ -f "${destdir}/$1/autoconfig.sh" ]; then
  (sh ${destdir}/$1/autoconfig.sh; rm -f ${destdir}/$1/autoconfig.sh) | logger -s -p daemon.info -t autoconfig
fi
```

### Add a permanent script to run on every start

Create `autostart.sh` file at the root of the SD card. This script will run on every start.

Add this code to `automount.sh` to hande the execution on every start:
```
if [ -f "${destdir}/$1/autostart.sh" ]; then
  sh ${destdir}/$1/autostart.sh | logger -s -p daemon.info -t autostart
fi
```

Your resulting `automount.sh` file should look like this:
```
#!/bin/sh

if [ -d "${destdir}/$1/autoconfig" ]; then
  cp -afv ${destdir}/$1/autoconfig/* / | logger -s -p daemon.info -t autoconfig
fi

if [ -f "${destdir}/$1/autoconfig.sh" ]; then
  (sh ${destdir}/$1/autoconfig.sh; rm -f ${destdir}/$1/autoconfig.sh) | logger -s -p daemon.info -t autoconfig
fi

if [ -f "${destdir}/$1/autostart.sh" ]; then
  sh ${destdir}/$1/autostart.sh | logger -s -p daemon.info -t autostart
fi
```

Unmount the card, eject if from PC and insert it into the IPC camera. Reboot the camera.
