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
apt install -y bison bridge-utils build-essential curl flex bridge-utils
```

### Automatic compilation script

```
#!/bin/bash
#
# OpenIPC.org | v.20240908
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
    mkdir -p /usr/local/sbin
    mv -v vtund /usr/local/sbin/vtund
    cd -
    rm -rf vtun-${vtun_version}
}

prepare && compile && install
```

### Example of /etc/network/interfaces.d/br-openipc for server

```
# Bridge OpenIPC
#
auto br-openipc
iface br-openipc inet static
    address 192.168.11.1
    netmask 255.255.255.0
    bridge_ports zero
    up mkdir -p /var/lock/vtund /var/log/vtund
    up iptables -A FORWARD -j ACCEPT -i br-openipc -o br-openipc
    #up iptables -A FORWARD -t mangle -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
    #up iptables -A POSTROUTING -t mangle -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
    #up iptables -A POSTROUTING -t nat -s 192.168.11.0/24 -j MASQUERADE
    #up iptables -A FORWARD -j ACCEPT -i ens2 -o br-openipc -d 192.168.11.0/24
    #up iptables -A FORWARD -j ACCEPT -o ens2 -i br-openipc -s 192.168.11.0/24
    #up iptables -A PREROUTING -t nat -j DNAT -p TCP -i ens2 --dport 10180 --to-destination 192.168.11.101:80
    #up iptables -A POSTROUTING -t nat -j SNAT -p TCP -o br-openipc -d 192.168.11.101 --to-source 192.168.11.1

```

### Example of /etc/vtund.conf  for server

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

### Alternative

```
#!/bin/sh -x

curl -L -o vtun_3.0.4.orig.tar.gz http://archive.ubuntu.com/ubuntu/pool/universe/v/vtun/vtun_3.0.4.orig.tar.gz
tar xvfz vtun_3.0.4.orig.tar.gz
curl -L -o vtun_3.0.4-2build1.debian.tar.xz http://archive.ubuntu.com/ubuntu/pool/universe/v/vtun/vtun_3.0.4-2build1.debian.tar.xz
tar xvfJ vtun_3.0.4-2build1.debian.tar.xz
cd vtun-3.0.4
cat ../debian/patches/*.patch | patch -p 1
./configure --build=x86_64-linux-gnu --disable-lzo --disable-zlib --disable-ssl --prefix=''
make && strip vtund && cp vtund ../ && cd -
rm -rf vtun_3.0.4.orig.tar.gz vtun_3.0.4-2build1.debian.tar.xz debian vtun-3.0.4
```
