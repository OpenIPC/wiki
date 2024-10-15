## AIO Mario firmware update over usb via internet forwarding
This method will work on Linux due to specific network commands. The key idea is to use the local PC as a network bridge betwen AIO board ethernet interface and your local internet interface.

## Steps
1. Connect AIO Mario to USB
2. Identify your PC address. On your local PC run:
```bash
ip -c a
...
3: enx00e099fead02: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 00:e0:99:fe:ad:02 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.11/24 brd 192.168.1.255 scope global noprefixroute enx00e099fead02
       valid_lft forever preferred_lft forever
    inet6 fe80::de74:78fc:9af0:f031/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
```
Here: `192.168.1.11` is my local PC address on AIO ethernet interface.

3. Connect to AIO Mario over ssh. On PC:
```bash
ssh root@192.168.1.10
```
4. List AIO routes. On AIO run:
```bash
root@openipc-ssc338q:~# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
192.168.1.0     0.0.0.0         255.255.255.0   U     0      0        0 eth0
```
5. We need to add a route to our local PC, so traffic could get route over. On AIO run:
```bash
root@openipc-ssc338q:~# route add default gw 192.168.1.11 eth0
```
Here: `192.168.1.11` is the local PC address.

6. Verify that route was added correctly:
```bash
root@openipc-ssc338q:~# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         192.168.1.11    0.0.0.0         UG    0      0        0 eth0
192.168.1.0     0.0.0.0         255.255.255.0   U     0      0        0 eth0
```

7. On the local PC we need to forward all the traffic from `enx00e099fead02` AIO Mario ethernet interface to our local connection.
This can be `wlp2s0` for wifi. To check the interface name, on the local PC run again:
```bash
ip -c a
2: wlp2s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether f8:34:41:af:55:37 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.8/24 brd 192.168.1.255 scope global noprefixroute wlp2s0
       valid_lft forever preferred_lft forever
    inet6 fe80::8d6a:f2f6:c850:cf9d/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
```
Here: `wlp2s0` is my internet connection, it could be also `eth0` on other setups.

8. Traffic forwarding. Create a bash script `~/forward.sh`:
```bash
#!/bin/bash

# Get the interface name of the wireless card by stdin
# $1 is the interface name of the AIO card

USB_AIO=$1
INTERNET_IF=$2

sudo iptables -A FORWARD -i $USB_AIO -o $INTERNET_IF -j ACCEPT
sudo iptables -A FORWARD -i $INTERNET_IF -o $USB_AIO -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables --table nat -A POSTROUTING -o $INTERNET_IF -j MASQUERADE
```
This script will receive as input `$1` the AIO ethernet interface, and forward the traffic to `$2`.

Enable IP forwading by editing `/etc/sysctl.conf` on your local PC and adding:
```
net.ipv4.ip_forward = 1
```
And enable the changes with:
```bash
sudo sysctl -p /etc/sysctl.conf
```

on Debian/Ubuntu systems this can be also done restarting the procps service:
```
sudo /etc/init.d/procps restart
```

9. Run the script on your local PC:
```bash
chmod u+x ./forward.sh
sudo ./forward.sh enx00e099fead02 wlp2s0
```
Here: `enx00e099fead02` is AIO ethernet interface, and `wlp2s0` local PC interface.

10. On AIO Mario we need to configure DNS servers. Edit `/etc/resolv.conf` and add:
```
nameserver 8.8.8.8
nameserver 8.8.4.4
```

11. Test internet acces. On AIO run `ping 8.8.8.8` and `ping openipc.org`:
```bash
root@openipc-ssc338q:~# ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8): 56 data bytes
64 bytes from 8.8.8.8: seq=0 ttl=116 time=23.611 ms
64 bytes from 8.8.8.8: seq=1 ttl=116 time=28.683 ms
^C
--- 8.8.8.8 ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
round-trip min/avg/max = 23.611/26.147/28.683 ms
root@openipc-ssc338q:~# ping openipc.org
PING openipc.org (5.161.116.152): 56 data bytes
64 bytes from 5.161.116.152: seq=0 ttl=51 time=290.381 ms
64 bytes from 5.161.116.152: seq=1 ttl=51 time=207.881 ms
64 bytes from 5.161.116.152: seq=2 ttl=51 time=232.049 ms
^C
--- openipc.org ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 207.881/243.437/290.381 ms
```

12. Update firmware:
```bash
root@openipc-ssc338q:~# sysupgrade -r -k -n --force_ver
OpenIPC System Updater v1.0.41

Vendor	sigmastar
SoC	ssc338q
Kernel	03:35:18 2024-09-27
RootFS	master+d69195a, 2024-09-27

Synchronizing time
ntpd: setting time to 2024-09-28 00:05:42.525372 (offset +73821.493151s)
Sat Sep 28 00:05:42 GMT 2024

Checking for sysupgrade update...
Same version. No update required.

Stop services, sync files, free up memory
Stopping crond: OK
Stopping ntpd: OK
Stopping klogd: OK
Stopping syslogd: OK
...
```

