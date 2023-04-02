# OpenIPC Wiki
[Table of Content](../README.md)

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

## Patch file requirements

- Patch file name should follow format `<number>-<description>.patch`.

- Patch file should not contain any reference to package version in its name.

- The `<number>` part of patch's file name refers to the application order
  starting from 1. It is preferred to left-pad the number with zeros up to total
  of four digits, like `git-format-patch` does. _0001-foobar-the-buz.patch_

- Patch file should contain a commentary in its header, explaining what this
  patch does, and why it is needed.

- Add a _Signed-off-by_ statement in the header of each patch file to help
  tracking changes and certify that the patch is released under the same license
  as the software it modifies.
