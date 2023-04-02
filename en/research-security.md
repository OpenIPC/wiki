# OpenIPC Wiki
[Table of Content](../README.md)

Access to SSH, telnet, FTP and other services
---------------------------------------------

Very often stock firmware provides access to its operating system but the
access is closed with an undisclosed password. We can recover a cryptographic
hash of that password while extracting a copy of the firmware image.

### Password hash

```
$1$bh2njiGH$4duacOMcXDh6myANzbZTf.
```
The hashed salt password string consists of three parts: hashing algorithm
identifier, salt and password hash, each of which is preceded by a dollar sign.
The first part, `$1`, is the hashing algorithm encoded with one (rarely two)
characters. It denotes the cryptographic method used to generate the hash:

- `$1` - MD5 algorithm.
- `$2` - Blowfish algorithm.
- `$2a` - eksblowfish algorithm
- `$5` - SHA-256 algorithm
- `$6` - SHA-512 algorithm

The second part, `$bh2njiGH`, is a salt - a character string added to the
plaintext password before hashing it in order to randomize the resulting hashes
for the same password and prevent [rainbow table][1] attacks.

The last part, `$4duacOMcXDh6myANzbZTf.`, is the hash. When you enter a
password, it is concatinated with the provided salt then hashed using the
provided hashing algorithm and the result is compared to the hash.
Same password, salt and hashing method will always produce the same result.

Hashing algorithms are one-way encryption methods meaning the hash cannot be
decrypted back to a plaintext password, but it is possible to perform hashing
of available variants of plaintext passwords until the match is found.
This method is called the [brute-force attack][2].

IP cameras tend to utilize a relatively simple and fast MD5 hashing algorithm
so using a password-breaking software and powerful computing resources the
original plaintext password can be picked in a matter of weeks or days, if not
hours, especially using high-quality dictionaries.

In the example above we used password "openipc". You can check the validity of
the password using either `mkpasswd` or `openssl`:
```
$ mkpasswd -m md5crypt -S bh2njiGH openipc
$1$bh2njiGH$4duacOMcXDh6myANzbZTf.
$ openssl passwd -1 -salt bh2njiGH openipc
$1$bh2njiGH$4duacOMcXDh6myANzbZTf.
```

When the password is found, it is wise to share it publicly, so that other
researchers in the field could dedicate their cryptographic resources to
discover even more yet unknown passwords. Sharing is caring, boys!

### Some passwords that we found in different firmware
```
| Hash                                  | Plain text |
|---------------------------------------|------------|
| $1$MoCJ1nRA$NfsI1wlYcWoF5MbU4t3Og0    | ivdev      |
| $1$ZebZnWdY$QZ1Aa.7hwBshCS5k40MUE1    | xc12345    |
| $1$d3VPdE0x$Ztn09cyReJy5Pyn           | runtop10   |
| $1$qFa2kfke$vJob19l64Q6n8FvP8/kvJ0    | wabjtam    |
| $1$rHWQwR5V$i4FVDvwhuzau8msvAfHEt.    | 2601hx     |
| $1$tiaLlxGM$byeTUfQgqyET5asfwwNjg0    | hichiphx   |
| $1$0Me7S3z5$.uQ4Pr/QjJQ/0JUZI0w4m.    |            |
| $1$4dAkkeWK$HCy0K1z8E.wAuwgLV8bWd/    |            |
| $1$7bfnUEjV$3ogadpYTDXtJPV4ubVaGq1    |            |
| $1$7BqzlCqK$nQXIfc53c1ACEwzNg7G3D.    |            |
| $1$cNGGWwI/$5/mZTMlcVfJlpE5DGrdsl/    |            |
| $1$FMNq4QIj$lJg6WzZxy1HWl3sL.YwIq1    |            |
| $1$IZfqary9$IrG6loat5pDTBLr6ksKTD0    |            |
| $1$ocmTTAhE$v.q2/jwr4BS.20KYshYQZ1    |            |
| $1$OIKWDzOV$WjZNcNtHSKVscbi9WQcpu/    |            |
| $1$rnjbbPTD$tR9oAIWgUp/jRrhjDuUwp0    |            |
| $1$RYIwEiRA$d5iRRVQ5ZeRTrJwGjRy.B0    |            |
| $1$uF5XC.Im$8k0Gkw4wYaZkNzuOuySIx/    |            |
| $1$vN9F.lHa$E09mbCRo70834AUfkytpX     |            |
| $1$wbAnPk8f$yz0PI9vnyLRmWbENUnce3/    |            |
| $1$ybdHbPDn$ii9aEIFNiolBbM9QxW9mr0    |            |
| $1$yq01TaSp$lkN/azu3IxE97owy27pve.    |            |
| $1$yFuJ6yns$33Bk0I91Ji0QMujkR/DPi1    |            |
| $1$yi$FS7W5j1RJmbRHDe0El/zX/          |            |
| $1$yi$MiivC6pLdwS0zp0pa0cUq1          | qw1234qw   |
| $Dg.cUjtWGTIVkuFS0ZYbN1               | fx1805     |
| $enWsv2cbxPCrd0WeXUXtX0               | nobody     |
| $qZV4X6DTqMHUDIyZG.8PH.               |            |
| $z2VkRbfNoE/xHLBj8i2cv.               | ftp        |
| 7wtxBdUGBnuoY                         | runtop10   |
| 9B60FC59706134759DBCAEA58CAF9068      | Fireitup   |
| LHjQopX4yjf1Q                         | ls123      |
| ab8nBoH3mb8.g                         | helpme     |
| absxcfbgXtb3o                         | xc3511     |
| xt5USRjG7rEDE                         | j1/_7sxw   |
| $1$EmcmB/9a$UrsXTlmYL/6eZ9A2ST2Yl/    |            |
| $1$soidjfoi$9klIbmCLq2JjYwKfEA5rH1    |            |
```

### Hijacking the default password
_tested on Goke_

Over the UART interface, it is possible to temporarily interrupt the normal
booting sequence and drop into a limited Linux shell at early stage of
system startup.
```
setenv bootargs ${bootargs} single init=/bin/sh
boot
```
This shell won't load the full working system, so you have to amend it manually.
First, mount `/rom` filesystem:
```
mount -t jffs2 /dev/mtdblock3 /rom
```
Mount the rest of mounting points from `/etc/fstab`:
```
mount -a
```
Also mount the SD card to copy files to and from:
```
mount /dev/mmcblk0p1 on /mnt/s0
```
On `/rom` filesystem, you can edit the `/room/etc/passwd` file but once the
device restarts it will be reset to default. This happens because there is a
guide bin file recreating `passwd` file on each start, so we need to modify
that executable.

Copy `system.dat` to an SD card:
```
cp /rom/system.dat /mnt/s0
```
On a linux computer, unpack `system.dat` file using `unsquashfs`:
```
mkdir squashfs-temp
cd squashfs-temp
unsquashfs system.dat
```
Find guide file and edit its content in a hex-editor to modify the name of the
file where password is written on every restart. Search for `/etc/passwd` and
change a letter in its name to something different, like `/etc/passwT`.

Pack the squash file system using `mksquashfs`:
```
mksquashfs ./squashfs-root ./file -comp xz -no-xattrs -noappend -no-exports -all-root -quiet -b 131072
```
and copy it from the SD card back to `/rom` directory on the camera.

Now you can replace the password in `/rom/etc/passwd` with your own password, and when
you restart the device, you will have full working system with your own password.


### Software

- [Hashcat](https://hashcat.net/)
- [John The Ripper](https://www.openwall.com/john/)
- [Hydra](https://github.com/vanhauser-thc/thc-hydra)

[1]: https://en.wikipedia.org/wiki/Rainbow_table
[2]: https://en.wikipedia.org/wiki/Brute-force_attack




---------------------------------------------------
