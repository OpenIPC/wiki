# OpenIPC Wiki
[Table of Content](../README.md)

Overview
--------

Each SoC manufacturer has its own software to adjust picture quality:

* HiSilicon - PQTools
* Novatek - isptool
* Fullhan - Coolview

## HiSilicon based boards

### EV300 family

#### Run server module on OpenIPC boards

```console
$ pqtools

.....

dev mounted
libs mounted
pqtools:begin to run
the s32Result is 1
g_bUseSpecAWB is 0
port is : 4321

<HI_PQT_Network_Init>(1486)bind ok!
pqtools:server(port:4321)begin to listen
pqtools:Waiting for connection from client!
```

#### Run server module on XM boards

For sake of simplicity we wse public NFS server:

```console
$ mount -o nolock 95.217.179.189:/srv/ro /utils/
$ cd /utils/ittb_ev300_V1.0.1.2/
$ LD_LIBRARY_PATH=lib ./ittb_control

...
pqtools:Waiting for connection from client!
```

#### Run client software on Windows

Download and install [MATLAB Compiler Runtime][mcr].

Download [PQTools][pqt] and extract a zip archive somewhere on your PC.

Launch `HiPQTools.exe`, select `Hi3516EV200_V1.0.1.2`, type IP address of your
camera and click `OK`.


[mcr]: https://ssd.mathworks.com/supportfiles/MCR_Runtime/R2012a/MCR_R2012a_win32_installer.exe
[pqt]: https://openipc.org/utilities

