# OpenIPC Wiki
[Table of Content](../README.md)

Frequently Asked Questions
---------------------------

### I have a camera which is not on the list of supported devices. Will you make it work for me?

The short answer is no.

If you have the skills and desire to make OpenIPC to work on the new hardware, we can share the knowledge we have.
If not, get yourself a supported camera.

### How can I tell what hardware is inside the camera before I buy it?

Most of the time you can't. Especially if it is a cheap Chinese clone of a clone of a rebranded camera. 
For reputable name brands that go through certification of the hardware, there is a chance to look at the 
inside the camera in the certification documents. Look for the FCC ID on the camera's box or case
and then look it up in the [FCC ID database](https://fccid.io/).

### Differences between Lite and Ultimate

- Amazon server support
- QR code recognition support (basic), integrated into Lite in Builder firmware
- iptables support (firewall)
- ZeroTier tunnel support
- MQTT (telemetry) support, integrated into Lite in Builder firmware
- WiFi support (there are no drivers for network cards), integrated into Lite in Builder firmware
- lame (mp3) and libwebsockets support
- experimental WebRTC support (only recent Hisi/Goke)

$\color{red}{\text{We always recommend using only Lite firmware with 8M}}$

### What is the difference between Firmware and Builder repositories?

The Firmware repository is the basis of the OpenIPC project and contains universal basic configurations for 
devices, regardless of the device manufacturer and usually contains many drivers for sensors, i.e. it is universal.

The Builder repository is a system that uses the basic Firmware repository when assembling firmware, while 
adding profiles for specific devices from manufacturers and usually already has presets for all GPIOs, 
contains the necessary WiFi drivers and contains only those sensor drivers that are used in a given model.

### How to strip U-Boot Image wrapper header from a binary image

Sometimes vendor's firmware consists of binary images intended
for use with U-Boot image loader and prepended with headers in
[U-Boot Image wrapper format](https://formats.kaitai.io/uimage/).
The header should be stripped off before you can use such an image
as a raw binary file. Here's how you can strip the first 64 bytes
from a file:

```bash
dd if=inputfile.img of=outputfile.bin bs=64 skip=1
```

alternatively

```bash
tail -c +65 inputfile.img > outputfile.bin
```

### How to get into bootloader shell?

[There is a handful of ways to get access to a locked bootloader shell](help-uboot.md#bypassing-password-protected-bootloader)

### How to reset camera settings from U-Boot

Sometimes improper settings make the camera unstable to the point where it is
impossible to log in or not enough time before rebooting to fix the settings.
Here's how to completely erase the overlay partition in the OpenIPC firmware,
right from the bootloader shell, to bring the camera back to its pristine state:

> __only for 8MB flash partitioning__

```
sf probe 0; sf erase 0x750000 0xb0000; reset
```

> __only for 16MB flash partitioning__

```
sf probe 0; sf erase 0xd50000 0x2b0000; reset
```

### How to sign in into camera via SSH?

`ssh root@<camera_ip_address>`

A camera that has not been set up has no password. The first interactive login asks you to
choose one and only then gives you a shell; after that, use the password you chose. Send no
password at all on that first login — `12345` no longer exists, and a factory reset puts the
camera back into that state. See
[Factory reset and the unclaimed camera](first-boot.md).

### How to sign in into camera Web UI?

Open http://<camera_ip_address>. A camera that has not been set up has no password and
streams nothing until it has one, so it asks you to choose one straight away — there is
nothing to sign in with before that. Afterwards, sign in as _root_ with the password you chose.

__Please note, this is also your ssh root password, and what RTSP checks!__

ONVIF accepts it from clients sending HTTP Basic or WSSE PasswordText. Clients that
authenticate with a digest need `onvif.password` set separately — see
[Web interface](web-interface.md).

### How to reset password for SSH/Web UI?

Create a serial connection to the camera using a UART adapter and a terminal
program. After turning on the camera, press Ctrl-C to interrupt the boot
sequence and enter the bootloader shell.

For a camera with 8MB flash chip, run

```bash
sf probe 0; sf erase 0x750000 0xb0000; reset
```

For a camera with 16MB flash chip, run

```bash
sf probe 0; sf erase 0xd50000 0x2b0000; reset
```

### How to connect to camera with SSH using keys / no password 

See seperate wiki page [here](en/sshusingkeys.md)

### How to find information about the camera hardware and software?

Sign in on camera via `ssh` and run `ipctool`.

### I don't see ipctool on camera. Why?

You don't see it because initially it is not there, but there is a shell
command of the same name.

_(Since it's a shell command, it won't work from Web Console in web UI.
Sign in to the camera via SSH and run the command in there.)_

When you run this command, the latest available version of `ipctool` utility
gets downloaded into `/tmp/` directory and runs from there. Since the utility
resides in `/tmp/`, it won't survive a reboot, thus won't take any useful space
on the camera afterwards.

If you need to know what is in the command, search for `ipctool` in the
`/etc/profile` file.

### Replace the bootloader from Linux

Commands are executed separately by each line with a wait for the end of execution.
The full name of the replacement bootloader and its availability can be checked [here][3]

Before running the commands, don't forget to enter the correct bootloader name!

```
FILE=u-boot-SOC-TYPE.bin
curl -k -L https://github.com/OpenIPC/firmware/releases/download/latest/${FILE} -o /tmp/${FILE}
flashcp -v /tmp/${FILE} /dev/mtd0
flash_eraseall /dev/mtd1
```

Save wireless credentials:
```
FILE=/usr/share/openipc/wireless.sh
echo "#!/bin/sh" > ${FILE}
echo "fw_setenv wlandev $(fw_printenv -n wlandev)" >> ${FILE}
echo "fw_setenv wlanssid $(fw_printenv -n wlanssid)" >> ${FILE}
echo "fw_setenv wlanpass $(fw_printenv -n wlanpass)" >> ${FILE}
chmod 755 ${FILE}
```

### How to update ancient OpenIPC firmware?

Commands are executed separately by each line with a wait for the end of execution.
The first command updates a utility whose algorithm was changed in February 2023. 
If you need to update the utility on T31 processors, please add the -mips suffix to the URL of the downloaded utility.
The second command updates the firmware components themselves. 

```
curl -L -o /tmp/ipcinfo https://github.com/OpenIPC/ipctool/releases/download/latest/ipcinfo && chmod +x /tmp/ipcinfo; /tmp/ipcinfo -csF
curl -s https://raw.githubusercontent.com/OpenIPC/firmware/master/general/overlay/usr/sbin/sysupgrade | sh -s -- -k -r -n
```

### Is it possible to switch from “lite” to “ultimate” via “Over the Air”?

On Ingenic and Sigmastar it is possible to split the ultimate rootfs.squashfs and flash it to the rootfs (mtd3) and overlay (mtd4) partition.

```
dd if=rootfs.squashfs of=mtd3.bin bs=1k count=5120
dd if=rootfs.squashfs of=mtd4.bin bs=1k skip=5120
flashcp mtd3.bin /dev/mtd3 -v
flashcp mtd4.bin /dev/mtd4 -v
```

### How to dump full firmware to an NFS share

This could work if you are lucky, you gained access into Linux shell on stock
firmware, and it does support NFS mounting:

```bash
fw=$(mktemp -t)
nfs=$(dirname $fw)/nfs
mkdir -p $nfs
mount -t nfs -o tcp,nolock 192.168.1.123:/path/to/nfs/share $nfs
cat /dev/mtdblock? > $fw
mv $fw ${nfs}/firmware_full.bin
```

Make sure to use your own IP address and path to the NFS share!

### How to find original MAC address in a firmware dump

```bash
strings dumpfile.bin | grep ^ethaddr
```

### How to build an image and firmware components ?

To build an image to upload via TFTP or a programmer, you will need several components:
- U-Boot bootloader for your device type
- Linux kernel taken from the firmware archive
- root file system in squashfs format taken from the firmware archive

You can use either the full build script from the Firmware archive:
https://raw.githubusercontent.com/OpenIPC/firmware/refs/heads/master/general/scripts/repack_firmware.sh

Or its simplified copy with an example here:

```bash
#!/bin/sh

uboot=u-boot-ssc338q-nor.bin      # Get from https://github.com/OpenIPC/firmware/releases/download/latest/u-boot-ssc338q-nor.bin
kernel=uImage.ssc338q             # Get from https://github.com/OpenIPC/builder/releases/download/latest/ssc338q_fpv_openipc-urllc-aio-nor.tgz
rootfs=rootfs.squashfs.ssc338q    # Get from https://github.com/OpenIPC/builder/releases/download/latest/ssc338q_fpv_openipc-urllc-aio-nor.tgz
output=fullflash-openipc-ssc338q-openipc-fpv-nor.bin

dd if=/dev/zero bs=1K count=5000 status=none | tr '\000' '\377' > ${output}
dd if=${uboot} of=${output} bs=1K seek=0 conv=notrunc status=none
dd if=${kernel} of=${output} bs=1K seek=320 conv=notrunc status=none
dd if=${rootfs} of=${output} bs=1K seek=2368 conv=notrunc status=none
```

### How to restore kernel or root file system from SD card ?

Please note that this method is currently only suitable for SigmaStar and Ingenic devices in which the SD card is initialized in the bootloader.

Download the files of the firmware you need, unzip them, put them on the SD card. 
Also put the file with instructions for the U-Boot bootloader on the SD card. 
You can take my ready-made file or create your own in Linux using the mkimage command:

```bash
echo -e "setenv updatetool fatload mmc 0\nrun uknor\nrun urnor" >./bootcmd.txt
mkimage -A arm -T script -d ./bootcmd.txt ./boot.scr
```

The principle of operation is very simple:
at startup, the bootloader searches for a file with commands on the SD card, if it is found, the commands will be executed and the device will be flashed.
In this example, this is firmware from the SD card, but no one forbids modifying the script for advanced functions and introducing new variables, such as WiFi settings, and other things that we use now in the any firmware.


### Majestic

#### How to get a memory dump for debugging?

Enable and configure Core Dump in the menu **Majestic** > **Majestic Debugging**.

#### Camera image has a pink tint

You need to specify GPIO pins to control the infrared filter.
Settings for some cameras can be found in [this table][1].

If your camera is not in that table, **how you find the pins depends on which
firmware is on the camera right now**, because the two routes work for opposite
reasons.

##### Already running OpenIPC

Open **Settings → Pins** in the web interface and press *Which pins move the
day/night filter?*. The camera drives pads itself and watches its own picture for
the filter to move, then hands the pair it finds to **Day / Night** with the Save
bar up. It needs daylight — at night nothing looks like it moved.

**If it finds nothing, one pad may be the reason.** This hunt drives pads in
pairs, because the usual filter is an H-bridge across two of them — so it cannot
actuate a filter wired to a *single* pad, and on such a board it runs to the end
and reports nothing. The board table tells you which kind you have: a row with
both an IRCUT1 and an IRCUT2 is a two-pad bridge, a row with only IRCUT1 is a
single-pad filter. For a single pad, set it by hand on **Day / Night**, turn on
`Single IRcut is inverted` if the picture is backwards, and let **Test the
filter** adjudicate.

[Finding out what a pin is wired to][4] covers the rest: what the camera refuses
to drive and why, how to recover if a pad does take it down, and the second hunt
for everything that is not a filter — a wireless card, a card slot, a second
network port.

`ipctool gpio scan` is **not** the tool for this case; see below for why.

##### Still on the stock firmware

`ipctool gpio scan` is the cheapest answer there is, and it stops working the
moment you convert the camera: it recognises the filter pads because the stock
application leaves them configured as driven outputs, and after conversion
nothing has claimed them and that evidence is gone. **So do this before you
flash, if you still can.**

You will need to download the [ipctool utility][2] to the camera yourself using
any tools available in the system: wget, curl, tftp etc.

For example, download the ipctool utility to TFTP server on the local network,
then download it to the camera:

```bash
tftp -g -r ipctool -l /tmp/ipctool 192.168.1.1
chmod +x /tmp/ipctool
/tmp/ipctool
```

If the camera has access to the internet, you can try to mount a public NFS
sharing and run the utility from it, without downloading to the camera:

```bash
mkdir -p /tmp/utils
mount -o nolock 95.217.179.189:/srv/ro /tmp/utils/
/tmp/utils/ipctool
```

After the utility is downloaded to the camera, run the `ipctool gpio scan`
command in the terminal and open-close the camera lens a couple of times with
your palm. Covering the lens is what makes the stock application switch the
filter, and the pads it drives while doing so are what the scan reports — without
it there is nothing for the scan to see.

Watch the output of ipctool to determine the pins responsible for controlling
the IR filter curtain.

Enter the values obtained in the settings for the night mode Majestic. If the
pink tint still persists, you may need to enable sensor signal inversion.

Don't forget to add the camera model and found GPIO values to the table! It
helps the next person, and the filter hunt reads that table too — it tries the
pairs recorded for your SoC first.

> On a camera that is already converted, `ipctool` is still worth having for
> other questions: the OpenIPC firmware downloads it to `/tmp` on its own the
> first time `ipctool` is invoked, and `ipctool reginfo` prints every pad with
> its current function marked.

#### Is it possible to display the data for setting the auto focus of lenses
instead of the current sample_af in the standard /metrics?

No, this is a difficult algorithm, it does not have a sense to run it this way.

#### Copy files from Linux system to camera

Sometimes you need to transfer files to the camera. In addition to the above
method using NFS (Network File System) you can use the standard Linux `scp`
command to copy files over an SSH connection:
```bash
scp ~/myfile root@192.168.1.65:/tmp/
```
This command will copy `myfile` from the home directory to the `/tmp/`
directory on the camera.

On recent Linux systems the following error may occur:
```console
sh: /usr/libexec/sftp-server: not found
scp: Connection closed
```
In this case, add `-O` option to the command:
```bash
scp -O ~/myfile root@192.168.1.65:/tmp/
```

On a camera nobody has claimed yet, `scp` is refused before any of that: a file
copy cannot ask you for a password, so it is turned away with a message saying
to log in interactively first. See
[Factory reset and the unclaimed camera](first-boot.md).

[1]: https://openipc.org/wiki/en/gpio-settings.html
[2]: https://github.com/OpenIPC/ipctool/releases/download/latest/ipctool
[3]: https://github.com/OpenIPC/firmware/releases/tag/latest
[4]: https://openipc.org/wiki/en/finding-a-gpio.html
