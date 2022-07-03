# OpenIPC Wiki
[Table of Content](../index.md)

Additional requirements for kernel configuration
------------------------------------------------

```
CONFIG_BLK_DEV=y
CONFIG_BLK_DEV_LOOP=y

CONFIG_IP_MULTICAST=y

CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y

CONFIG_ROOT_NFS=y
```

## Patch files

Patch files should be named `<number>-<description>.patch`.
- The patch files should not contain any package version reference in their filename.
- The field `<number>` in the patch file name refers to the apply order, and shall start at 1.
It is preferred to pad the number with zeros up to 4 digits, like git-format-patch does. E.g.: _0001-foobar-the-buz.patch_
- A message explaining what the patch does, and why it is needed, should be added in the header commentary of the patch.
- You should add a Signed-off-by statement in the header of each patch to help with keeping track of the changes and to certify that the patch is released under the same license as the software that is modified.
