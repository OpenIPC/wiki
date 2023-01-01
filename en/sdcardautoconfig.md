# SP Card - Autoconfig
[Table of Content](../index.md)

OpenIPC can be autoconfigured throw an SD Card. This is particularly usefull for IPC with Wifi Only where UART is not acessible.
This mecanism is managed by ```automount.sh```.

The camera need a SD Card slot for this porpose.

## Preparing the SD Card

The SD Card must be formatted in FAT/FAT32/vFAT with at least one partition.
This is the commands on Windows (all data will be deleted) :

```
diskpart

list disk
select disk <number corresponding to your SD Card>
clean
create partition primary
format quick fs=FAT32
list partition
active
assign letter=<letter>
```

## Inserting files to be replaced on the ipc

Corresponding code of ```automount.sh```
```
    # copy files from autoconfig folder
    [ -d "${destdir}/$1/autoconfig" ] && cp -afv ${destdir}/$1/autoconfig/* / | logger -s -p daemon.info -t autoconfig
```
Create a folder ```autoconfig``` and insert the file at the destination path to be copied in OpenIPC.

```<sdcard-path>/autoconfig/<path to file>/file``` will be copied to ```/<path to file>/file```

### example :
```
<sdcard-path>/autoconfig/etc/init.d/interfaces
```
will be copied to
```
/etc/init.d/interfaces
```

## Inserting a script to be run only once

Corresponding code of ```automount.sh```
```
    # execution of the specified commands one time
    [ -f "${destdir}/$1/autoconfig.sh" ] && (sh ${destdir}/$1/autoconfig.sh ; rm -f ${destdir}/$1/autoconfig.sh) | logger -s -p daemon.info -t autoconfig
```
Create a shell script at root of the SD Card named ```autoconfig.sh```.
The content of this script will be run, then the file removed.

## Inserting a script to be run each startup
Corresponding code of ```automount.sh```
```
    # execution of the specified commands
    [ -f "${destdir}/$1/autostart.sh" ] && sh ${destdir}/$1/autostart.sh | logger -s -p daemon.info -t autostart
```
Create a shell script at root of the SD Card named ```autostart.sh```.
The content of this script will be runned at each startup.


