# OpenIPC Wiki
[Mục lục](../README.md)

Gói Vtun
------------

### Giới thiệu

Gói này được thiết kế để tổ chức một đường hầm L2 dựa trên Vtun giữa các camera IP và máy chủ. Để giảm dung lượng chiếm dụng trên bộ nhớ flash NOR, giảm mức tiêu thụ RAM và tăng thông lượng đường hầm, tính năng mã hóa và nén bị vô hiệu hóa hoàn toàn.

### Phần máy khách

Phần máy khách luôn có mặt trong tất cả các firmware OpenIPC chính thức.
Để kết nối với máy chủ, hãy chuyển đến tab phần mở rộng, chỉ định địa chỉ IP hoặc tên miền của máy chủ và lưu cài đặt

### Phần máy chủ

- tạo một giao diện cầu nối, ví dụ: br-openipc
- trong cấu hình vtund.conf, hãy thêm tất cả các kết nối camera vào cầu nối
- nâng bất kỳ máy chủ DHCP nào trên giao diện br-openipc
- liên kết địa chỉ IP của các thiết bị kết nối theo MAC

### Ví dụ về biên dịch vtun cho máy chủ

Cài đặt các thành phần và phụ thuộc cho Debian/Ubuntu

```
apt install -y bison bridge-utils build-essential curl flex
```

### Tập lệnh biên dịch tự động

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

### Ví dụ về /etc/network/interfaces.d/br-openipc cho máy chủ

```
# Cầu nối OpenIPC
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

### Ví dụ về /etc/vtund.conf  cho máy chủ

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

