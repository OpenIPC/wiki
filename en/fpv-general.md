# OpenIPC Wiki
[Table of Content](../README.md)

Be sure to use the [FAQ](../en/fpv-faq.md) as well.

# Acronyms and Definitions

* BEC - BEC stands for Battery Eliminator Circuit. It is used to provide a stable voltage supply to components in a device, often in place of a battery. 

* Channel - A Wi-Fi channel is a specific range of frequencies used for communication between wireless devices. Wi-Fi networks typically divide these frequencies into 14 channels in the 2.4 GHz band, 34 channels in the 5 GHz band, and up to 59 channels in the 6 GHz band.

* [Configurator](https://github.com/OpenIPC/configurator) OpenIPC controller for setting up FPV and URLLC devices

* Datalink - Datalink is oncerned with managing data communication links and ensuring reliable data transfer between the device and external systems.

* FEC_K and FEC_N

    FEC_K and FEC_N are parameters used in Forward Error Correction (FEC) to define the structure and efficiency of error correction codes.

    #### FEC_K

    K refers to the number of information (or data) bits in a block before error correction encoding is applied.
    This is the actual data that needs to be transmitted without any redundancy added for error correction.

    #### FEC_N

    N refers to the total number of bits after error correction encoding has been applied.

    This includes both the original data bits (K) and the redundant bits that are added for error detection and correction.
    Relationship Between FEC_K and FEC_N

    The difference between N and K represents the redundancy added by the error correction code. In other words, the redundant bits are used to detect and correct errors in the transmitted data.

    ```mathematica
    N = K + Number of Redundant Bits
    ```

    Example

    If FEC_K = 1000 and FEC_N = 1200, this means 200 redundant bits were added to the original 1000 data bits, creating a total of 1200 transmitted bits.

    Code Rate

    The ratio of information bits (K) to the total bits (N) is called the code rate:

    ```mathematica
    Code Rate = K / N
    ```

    For example, if K = 1000 and N = 1200, the code rate would be:

    ```yaml

    Code Rate = 1000 / 1200 = 0.833
    ```
    This means that 83.3% of the transmitted bits are actual data, and 16.7% are used for error correction.


    #### Usage in Communication Systems

    FEC_K and FEC_N are commonly used to describe how data is handled in wireless communication standards such as Wi-Fi, 5G, satellite communication, and broadcast systems.

    The values of K and N determine how much error correction is added to the data, impacting both the transmission reliability and bandwidth efficiency.

* FPV - FPV stands for First-Person View, a technology that allows users to experience a live video feed from a camera mounted on a drone or other remote-controlled device as if they were in the pilot's seat. FPV provides a real-time, immersive perspective, enhancing control and situational awareness during flight or remote operation.

* Frequency - Wi-Fi transmits data between your device and a router using radio waves over specific frequencies. Depending on the amount of data being transferred, it can use one of two frequencies: 2.4 gigahertz or 5 gigahertz.

* H265/H264 - Video compression standards used to encode and decode video streams.

    * H.265 (HEVC): Provides improved compression efficiency compared to H.264, allowing for higher video quality at lower bit rates, which is ideal for 4K and high-definition video streaming.
    * H.264 (AVC): A widely used video compression standard that offers good compression and video quality, commonly used for streaming, recording, and video conferencing.

* LDPC - LDPC stands for Low-Density Parity-Check code, which is an advanced error-correcting code used in digital communication systems to improve the reliability of data transmission over noisy channels. LDPC codes are designed to detect and correct errors that occur during data transmission, allowing for more efficient and robust communication.

* [Majestic](https://github.com/OpenIPC/majestic-webui) - Provides web interface for OpenIPC Firmware, and is available on port 80 of your camera. It used for managing and configuring various aspects of the system. It is also a command-line tool.

* MCS Index - The Modulation Coding Scheme (MCS) index is a standard industry metric that reflects various factors in a Wi-Fi connection between a client device and a wireless access point, such as data rate, channel width, and the number of antennas or spatial streams in the device.

* [MSPOSD](https://github.com/OpenIPC/msposd) - OpenIPC implementation of MSP Displayport OSD for INAV/Betaflight/ArduPilot.

* OpenIPC - is a firmware project focused on enhancing and customizing the functionality of IP cameras. IPC acronym means IP Camera.

* [PixelPilot](https://github.com/OpenIPC/PixelPilot) - PixelPilot is an Android app packaging multiple pieces together to decode an H264/H265 video feed broadcast by wfb-ng over the air.

* [PixelPilot_rk](https://github.com/OpenIPC/PixelPilot_rk) - Application that decodes an RTP Video Stream and displays it on screen, for Rockchip devices (aka Radxa).

* STBC - STBC stands for Space-Time Block Coding, which is a technique used in wireless communication systems to improve signal reliability and data transmission performance, particularly in environments with interference or signal fading.

* WFB - Wireless Framebuffer (WFB) is a component that enables remote display and control of a device’s graphical interface over a wireless network. 

## Filesystem

### Drone


| File Path            | Description                                          |
|----------------------|------------------------------------------------------|
| Config                                                                     |
| `/etc/wfb.conf`      | Configure settings for the Wireless Framebuffer (WFB). WFB is a component that allows remote display and control of the device's graphical interface over a wireless network.                                    |
| `/etc/drone.key`     | Used to store a secret key that is exchanged with a Groundstation. This key plays a crucial role in securing communications between the drone and the Groundstation.     |
| `/etc/datalink.conf` | Used to configure settings related to data link communication. This file plays a role in defining how data is managed and transmitted between various components within the system.|
| `/etc/majestic.yaml` | Majestic Settings                                   |
| `/etc/mavlink`       | Mavlink Settings                                    |
| `/etc/openipc_banner`| |
| `/etc/openipc_donors`| |
| `/etc/telemetry.conf`| Used to configure settings related to telemetry. Telemetry involves the collection and transmission of data from the device to an external system for monitoring and analysis.|
| Startup Files                                                             |
| `/etc/init.d/S95majestic` | Startup script used to manage the initialization and execution of the Majestic service during system boot.      |
| `/etc/init.d/S98datalink` |  Startup script used to manage the initialization of the Datalink service during system boot.|
| Apps                                                                      |
| `/usr/bin/wfb-cli` | used to interact with or configure the Wireless Framebuffer (WFB) service specifically in the context of a ground station. i.e `wfb-cli gs` |
| `/usr/bin/msposd` | MSPOSD binary|
| `/usr/bin/font_hd.png` | font file for msposd |
| `/usr/bin/font.png` | font file for msposd |
| `/usr/bin/telemetry` | Telemetry script |
| `/usr/bin/majestic` | Majestic binary |


### Ground Station

### Radxa
| File Path            | Description                                          |
|----------------------|------------------------------------------------------|
| Config    |
| `/etc/gs.key` |  Shared key|
| `/etc/wifibroadcast.cfg` |  Define Connection Parameters|
| Startup |
| `/etc/systemd/system/openipc.service` | Main process Start at boot
| Apps |
| `/home/radxa/wfb_keygen` |  Generates shared key|
| `/home/radxa/resizefs.sh` | Resize root filesystem |
| `/home/radxa/scripts/screen-mode` | Setup resolution |
| `/home/radxa/scripts/stream.sh` | Starts main process |
| `/home/radxa/scripts/wifi-connect.sh` | Script to setup local wifi connection to home router|
| Media |
| `/home/radxa/Videos/` | Location where flight videos are stored|