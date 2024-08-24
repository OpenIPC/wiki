# OpenIPC Wiki
[Table of Content](../README.md)

Package Vtun
------------

### Introduction

This package is designed to organize a Vtun-based L2 tunnel between IP cameras and a server. 
In order to reduce the space occupied on the NOR flash, reduce RAM consumption, and increase the tunnel throughput, encryption and compression are completely disabled.

### Client part

The client part is always present in all official OpenIPC firmware.
To connect to the server, go to the extensions tab, specify the IP address or domain of the server and save the settings

### Server part

- create a bridge interface, for example br-openipc
- in the vtund.conf config add all camera connections to the bridge
- raise any DHCP server on the br-openipc interface
- bind the IP addresses of the connecting devices by MAC

### Example of vtun compilation for server

Installing components and dependencies for Debian/Ubuntu

```
apt install -y bison build-essential curl flex
```

Automatic compilation script

```
#!/bin/bash
#
# OpenIPC.org | v.20240824
#

LANG=C

vtun_version="3.0.2"
vtun_download="http://prdownloads.sourceforge.net/vtun/vtun-${vtun_version}.tar.gz"

prepare() {
    curl -L -o vtun-${vtun_version}.tar.gz ${vtun_download}
    tar xvfz vtun-${vtun_version}.tar.gz
    rm vtun-${vtun_version}.tar.gz
    cd vtun-${vtun_version}
}

compile() {
    ./configure --build=x86_64-linux-gnu --disable-lzo --disable-zlib --disable-ssl --prefix=''
    make && strip vtund
}

install() {
    mkdir -p ../_binary
    mv -v vtund ../_binary/vtund_i386
    cd -
    rm -rf vtun-${vtun_version}
}

prepare && compile && install
```


### Example of vtun config for server

```
options {
  syslog daemon;
  timeout 60;
  ip /bin/ip;
}
default {
  type tun;
  proto tcp;
  persist yes;
  keepalive yes;
  timeout 60;
  compress no;
  encrypt no;
  speed 512:512;
  multi killold;
}
#
### Cam-1
#
E60BFB000001 {
  type ether;
  speed 0:0;
  password bla-bla-pass;
  device v-E60BFB000001;
  up {
    ip "link set %% up multicast off mtu 1500";
    program "brctl addif br-openipc %%";
  };
  down {
    program "brctl delif br-openipc %%";
    ip "link set %% down";
  };
}
#
### Cam-2
#
729051000001 {
  type ether;
  speed 0:0;
  password bla-bla-pass;
  device v-729051000001;
  up {
    ip "link set %% up multicast off mtu 1500";
    program "brctl addif br-openipc %%";
  };
  down {
    program "brctl delif br-openipc %%";
    ip "link set %% down";
  };
}
#
```
