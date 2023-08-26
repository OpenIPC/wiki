# OpenIPC Wiki
[Table of Content](../README.md)

How to send files over UART
---------------------------

If SD card reader failt and there is no network configured on your cam you may need to send a new firmware over UART interface to update the camera.

__Sender:__

First we encode the files

```bash
base64 uImage > uImage.b
```

Now make sure your com send-file command is, ascii-xfr, this was my connection command line

```bash
picocom -f n -p n -d 8 -b 115200  --send-cmd "ascii-xfr -snv" /dev/ttyUSB0

```

Normally we want ascii-xfr on the receiving side, but since we don't have it, that -n works around this by maintaining correct line endings.


__Receiver::__

Now that we've connected, go to the directory where you want the received file.
```bash
cd /tmp/
```

```bash
cat > uImage.b
```
On picocom, I just CTRL+a+s, and enter the full path of the file I'm sending. Once the transfer completes, you'll need to CTRL+c to break that cat.

Now we decode the file,

```bash
base64 -d uImage.b > uImage
```

```bash
base64 -d rootfs.squashfs.b > rootfs.squashfs
```
Do whatever you can to verify that file is IDENTICAL to the one you sent, because an ASCII transfer has no checksum protection. Openipc had sha512sum, but any checksum command would suffice. Once you manually confirm the sums match, you can assume the transfer was successful!
```bash
sha256sum uImage
```

Repeat for rootfs, and now you will be able to upgrade with sysupgrade

```bash
sysupgrade --kernel=/tmp/uImage --rootfs=/tmp/rootfs.squashfs --force_ver -z
```

