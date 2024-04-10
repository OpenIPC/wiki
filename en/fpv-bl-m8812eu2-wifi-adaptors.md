# OpenIPC Wiki
[Table of Content](../README.md)

Instructions for Using BL-M8812EU2 (or other RTL8812EU-based) Wi-Fi Module in FPV Firmware
---
[LB-LINK's BL-M8812EU2 module](https://www.lb-link.com/product_36_183.html)  
Another FPV Wi-Fi adaptor choice with high TX power (>29dBm) and low cost.   
![image](https://github.com/libc0607/openipc-wiki/assets/8705034/8aed1797-8f58-4e8f-95d7-b8d055c3519a)


### Hardware 
#### Where to buy
Since the RTL8812EU chip is fairly new, there are no sellers on Aliexpress now.   
But when considering that it comes from the same supplier as the widely sold BL-R8812AF1, it's only a matter of time before it becomes readily available.   
However, you can still find any Taobao agent and buy the module from [here](https://item.taobao.com/item.htm?id=764510955987). 

#### Wiring
![image](https://github.com/libc0607/openipc-wiki/assets/8705034/0511de9a-bd3a-42c1-8f35-0f5ec72a1121)  

Connect ```USB2.0+DP```, ```USB2.0-DM``` with a twisted wire pair to the IPC's USB. A GND connection to IPC is also required.   
Connect ```GND``` and ```VDD5.0``` to a 5V/>3A power supply to power the module.   
Connect two 5GHz antennas to the IPEX connector J0 and J1 before transmission.   
The Pin 9~18 are GND and can be left floating.  

Ref.: https://oshwhub.com/libc0607/bl-m8812eu2-demoboard-v1p0  

### Add the Driver to OpenIPC Firmware
Because of the very limited flash space, the driver is disabled by default.  
You need to compile firmware from source code to enable it.  

#### Step 1. Prepare
Follow the guide in [source-code.md](https://github.com/libc0607/openipc-wiki/blob/master/en/source-code.md) till you successfully build your firmware.

#### Step 2. Add BR2_PACKAGE to Board Config  
Find your target board config in ```br-ext-chip-*/config```, then add  ```BR2_PACKAGE_RTL88X2EU_OPENIPC=y``` to it. 
If your IPC has an 8M/16M NOR Flash, you may need to disable other drivers (e.g. RTL8812AU) to save space. 

#### Step 3. Check CONFIG_WIRELESS_EXT in Kernel Config
The driver needs ```CONFIG_WIRELESS_EXT``` enabled in kernel config, which can be found at ```br-ext-chip-*/board/*/kernel/*-fpv.config```.
This macro has been set in SigmaStar, but you should check it when using Hisilicon or GOKE.

#### Step 4. Build the firmware 
```
make
```
Then you can use ```output/images/rootfs.squashfs.*``` and ```output/images/uImage.*``` with ```sysupgrade```.

### Usage
It's almost the same as RTL8812AU adaptors. 

#### Set TX Power  
There are two ways to set TX power.   
- ```driver_txpower_override``` in ```/etc/wfb.conf```. The range is ```0~63```
- ```iw dev <wlan0> set txpower fixed <mBm>```. The range is ```0~3150```, and can be set dynamically when transmitting.

For the BL-M8812EU2 module, I recommend setting ```driver_txpower_override``` to ```40~50``` as a higher value causes the amplifier to be saturated.  
The power consumption of a BL-M8812EU2 module can reach 5V/2.xA when ```driver_txpower_override > ~40```.  
Use a proper 5V power supply and a HEAT SINK WITH FAN.

