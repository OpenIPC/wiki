## Connecting the camera to a tablet or PC via LTE (4G) modem

Flying via 4G is a very interesting topic for aircraft under stabilization or automatic route. Let's break the setup process down into tasks:

* set up internet via modem on camera
* set up your own zerotier server (you can use a public one)
* connect the camera and PC to the same zerotier network and set up a stream

Following [these instructions](usb-modeswitch.md), we will configure usb_modeswitch and the eth1 network interface on the camera with OpenIPC LTE firmware. If you have FPV or LITE firmware, you will need to change it online first:
```
#here we change fpv to lte in the file /etc/os-release, you can do it manually
sed -i 's/BUILD_OPTION=fpv/BUILD_OPTION=lte/' /etc/os-release
#and this is if you have the lite version
sed -i 's/BUILD_OPTION=lite/BUILD_OPTION=lte/' /etc/os-release

sysupgrade --force_ver -k -r -n
```
We get a camera with factory settings and LTE firmware, in which, unlike FPV, WFB is removed and a Zerotier-One client is installed instead.
In fact, the correct solution would be not to use usb_modeswitch but to configure the secondary modem composition directly to cdc_ethernet. Then the modem will cease to be universal and will immediately be displayed as a network card, but the probability of a number of problems will disappear.

#### zerotier
This is software for combining multiple devices into one local network. There is a public server for creating your own network, but it is better to raise your own.
This will require a vps server running ubuntu.
```
apt-get install -y apt-transport-https gnupg mc iftop #install dependencies
curl -s https://install.zerotier.com | sudo bash #install the client part

curl -O https://s3-us-west-1.amazonaws.com/key-networks/deb/ztncui/1/x86_64/ztncui_0.7.1_amd64.deb #install the control panel
apt-get install ./ztncui_0.7.1_amd64.deb

echo 'HTTPS_PORT=6443' > /opt/key-networks/ztncui/.env #port for web interface
echo 'NODE_ENV=production' >> /opt/key-networks/ztncui/.env #operating mode
echo 'HTTPS_HOST=nn.mm.ff.dd' >> /opt/key-networks/ztncui/.env #external IP address of our server

systemctl restart ztncui
```

Log in using the link https://ip_addr:6443, login admin, password password.
Next, create a network and configure the address issuance parameters that you like best, the rest of the settings are default.
In private mode, after the client connects, you need to check the Authorized box to allow the client to connect.

![ZTNCUI](https://github.com/OpenIPC/sandbox-fpv/raw/master/notes_files/ZTNCUI.png)

There is an alternative in the form of a [public server](https://my.zerotier.com/), but the issue of reliability and speed remains suspended. Client programs for Windows, Android can be downloaded [here](https://www.zerotier.com/download/).

Connection to the network is made by specifying the Network ID, a 16-digit character string, which we take from the control panel. For the camera, we specify it in /etc/datalink.conf
```
use_zt=true
zt_netid=a8867b0bxxxxxxxxx
```
then reboot the camera. If there is an Internet connection, either LTE or Ethernet, the camera should connect to the zerotier network. This can be checked through the web control panel and on the camera with the ifconfig command.
```
ztuplek3wb Link encap:Ethernet HWaddr 92:31:B1:54:8B
          inet addr:10.7.0.1 Bcast:10.7.0.255 Mask:255.255.255.0
          inet6 addr: fe80::9031:b1ff:fe54/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST MTU:2800 Metric:1
          RX packets:93 errors:0 dropped:0 overruns:0 frame:0
          TX packets:1236835 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueue:1000
          RX bytes:5677 (5.5 KiB) TX bytes:1493618333 (1.3 GiB)
```

 For a PC or Android device, [install](https://www.zerotier.com/download/) the program and similarly add the network by its id, authorize the device in the web panel. Try cross ping, it should pass. If there is a firewall/brandmauer, such as under Windows, you need to add a permit rule with our subnet.

#### Setting up a stream
All that remains is to specify the IP address of the ground station from the zerotier network in /etc/majestic.yaml and the video can be received. Don't forget to agree on the codecs.
```
outgoing:
- udp://ip_from_zerotier:5600
```

#### Telemetry
I haven't checked the telemetry yet, but everything should work something like this.
Mavlink-routerd is used with the config /etc/mavlink.conf. You need to specify endpoints for local serial and ground by the zerotier IP address:
```
[General]
TcpServerPort = 0

[UartEndpoint drone]
Device = /dev/ttyAMA0
Baud = 115200

[UdpEndpoint qgroundcontrol]
Mode = Normal
Address = gs_ip_from_zerotier
Port = 14550
```

Since the connection is bidirectional, we automatically receive telemetry in both directions.