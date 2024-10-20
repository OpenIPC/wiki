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
- QR code recognition support (basic)
- iptables support (firewall)
- ZeroTier tunnel support
- MQTT (telemetry) support
- WiFi support
- lame (mp3) and libwebsockets support
- experimental WebRTC support (only recent Hisi/Goke)

$\color{red}{\text{We always recommend using only Lite firmware}}$

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

There is _12345_ password by default.

### How to sign in into camera Web UI?

Open http://<camera_ip_address> and sign in using default username _root_
and default password _12345_. You will be asked to change the password after
successful login.

__Please note, it will also change your ssh root password!__

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

### Majestic

#### How to get a memory dump for debugging?

Enable and configure Core Dump in the menu **Majestic** > **Majestic Debugging**.

#### Camera image has a pink tint

You need to specify GPIO pins to control the infrared filter.
Settings for some cameras can be found in [this table][1].
If your camera is not in the table then you need to use [ipctool utility][2].

The OpenIPC firmware will automatically download the latest version of the
utility to the /tmp directory when `ipctool` is invoked first time.

On stock firmware, you will need to download the utility to the camera yourself
using any tools available in the system: wget, curl, tftp etc.

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
your palm.

Watch the output of ipctool to determine the pins responsible for controlling
the IR filter curtain.

Enter the values obtained in the settings for the night mode Majestic. If the
pink tint still persists, you may need to enable sensor signal inversion.

Don't forget to add the camera model and found GPIO values to the table!

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

[1]: https://openipc.org/wiki/en/gpio-settings.html
[2]: https://github.com/OpenIPC/ipctool/releases/download/latest/ipctool
[3]: https://github.com/OpenIPC/firmware/releases/tag/latest
