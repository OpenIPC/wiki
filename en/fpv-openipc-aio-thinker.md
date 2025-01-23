Thinker Board dimensions

![image](https://github.com/user-attachments/assets/3a4a4605-a2ff-417f-9cc1-12a035f2eb07)

Heat Sink dimensions

![image](https://github.com/user-attachments/assets/2e8b1f4c-5a1b-40c2-b88f-97454b9fb3e8)


Power supply 2S-6S

Top view

![image](https://github.com/user-attachments/assets/50a1d6ee-fe4b-4f11-bd16-012f688c6383)

Bottom View

![image](https://github.com/user-attachments/assets/b60ce1b3-659f-4fd0-b5be-4c44252b7015)


Tiny WIFI Version

![image](https://github.com/user-attachments/assets/66b8e281-bbe5-4b46-a47e-fab66566ed11)


Thinker Board dimensions

![image](https://github.com/user-attachments/assets/3a4a4605-a2ff-417f-9cc1-12a035f2eb07)

Heat Sink dimensions

![image](https://github.com/user-attachments/assets/2e8b1f4c-5a1b-40c2-b88f-97454b9fb3e8)


Power supply 2S-6S

Top view

![image](https://github.com/user-attachments/assets/50a1d6ee-fe4b-4f11-bd16-012f688c6383)

Bottom View

![image](https://github.com/user-attachments/assets/b60ce1b3-659f-4fd0-b5be-4c44252b7015)


Tiny WIFI Version


![image](https://github.com/user-attachments/assets/66b8e281-bbe5-4b46-a47e-fab66566ed11)

Build in RF setting VS output

![image](https://github.com/user-attachments/assets/4edbafca-f737-446b-ab2e-4677f23c6a6d)

![image](https://github.com/user-attachments/assets/44b6810e-67cb-4b66-a3b1-000d402e65da)



Firmware update link

https://github.com/OpenIPC/builder/releases/download/latest/ssc338q_fpv_openipc-thinker-aio-nor.tgz

Default include RTL8812AU and RTL873XBU driver.

<b>Note: "... rtl8731bu has limitations as a recieving unit (does not support ldpc), which requires you to specifically disable it on groundstation if you use tunnel/mavlink. As a transmission unit it seems to be working good for both 2.4ghz and 5.8ghz ..."
https://t.me/c/1809358416/127308/129654</b>

On GS in /etc/wifibroadcast.cfg use:
```
[tunnel]
ldpc = 0
```

For externel wifi RTL8812EU please update Firmware

https://github.com/OpenIPC/builder/releases/download/latest/ssc338q_fpv_openipc-urllc-aio-nor.tgz


Firmware update link

https://github.com/OpenIPC/builder/releases/download/latest/ssc338q_fpv_openipc-thinker-aio-nor.tgz

Default include RTL8812AU and RTL873XBU driver.

<b>Note: "... rtl8731bu has limitations as a recieving unit (does not support ldpc), which requires you to specifically disable it on groundstation if you use tunnel/mavlink. As a transmission unit it seems to be working good for both 2.4ghz and 5.8ghz ..."
https://t.me/c/1809358416/127308/129654</b>

On GS in /etc/wifibroadcast.cfg use:
```
[tunnel]
ldpc = 0
```

For externel wifi RTL8812EU please update Firmware

https://github.com/OpenIPC/builder/releases/download/latest/ssc338q_fpv_openipc-urllc-aio-nor.tgz

