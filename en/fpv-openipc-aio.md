# OpenIPC Wiki
[Table of Content](../README.md)

OpenIPC AIO "UltraSight"
---
<a href="https://store.openipc.org"><img src="../images/fpv-openipc-aio.webp"></a>

## What's in the box
<a href="https://raw.githubusercontent.com/OpenIPC/wiki/master/images/fpv-openipc-aio-content-1.webp"><img src="../images/fpv-openipc-aio-content-1.webp" width="60%"></a>
<a href="https://raw.githubusercontent.com/OpenIPC/wiki/master/images/fpv-openipc-aio-content-2.webp"><img src="../images/fpv-openipc-aio-content-2.webp" width="60%"></a>

## How to mount the heatsink
The package comes with a heatsink and thermal pad. The thermal pad is covered in 3M double sided tape on both sides. Two screws are included with the set that can be used to mount the heatsink. The heatsinks purpose is to dissipate heat from the WiFi components on the PCB. The thermal pad and heatsink therefore need to be placed on the side that has the WiFi components on it (e.g. antenna connectors, WiFi chip and power amplifiers).

## Connections

<img src="../images/fpv-openipc-aio-pinout-1.png" width="60%"></a>
<img src="../images/fpv-openipc-aio-pinout-2.png" width="60%"></a>

### Power
The board needs a steady power supply of at least **3A at 5V DC**. This figure will be higher if higher RF power levels are selected.

Before powering on AIO board, the power pad must be soldered or connected to a reliable 5V power source or BEC. When there is not enough load capacitance on the BEC, it is recommended to add a 470uF electrolytic capacitor (included in the set) between the BEC and AIO board to protect the AIO board from surge damage and provide decoupling. Install the capacitor as close to the AIO-PCB as possible. 

### Debug/Ethernet
A Ethernet/Debug adapter is included. The flat-flex cable is used to connect it to the AIO-PCB. The connectors pins are located on the PCB side of the connector, pay attention to connect the flat flex cable with the exposed connections towards the PCB. The "handle" strips on the flat-flex cable will point towards the heatsink side on the AIO-PCB and away from the RJ45 connector on the Debugger PCB.

### Camera
The MIPI connector can pe pushed into the corresponding socket on the AIO-PCB vertically. No great force is needed and there are no levers to move or clips to disengage. For removal, the connector has two little prongs on the sides to aid with gripping it.

## First start

* Connect the WiFi antennas and mount the heatsink
* Connect the Debug PCB and connect a network cable
* Ensure proper cooling, airflow will be necessary to protect the board from overheating
* Power the board and either check your DHCP-Server (often your router) for a new device and it's IP address, the board will try to get an IP assigned throug DHCP
* You can login to the web UI of OpenIPC using the username **admin** and the password **12345** to check for connectivity
