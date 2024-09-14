# Acronyms and Definitions


### Channel

A Wi-Fi channel is a specific range of frequencies used for communication between wireless devices. Wi-Fi networks typically divide these frequencies into 14 channels in the 2.4 GHz band, 34 channels in the 5 GHz band, and up to 59 channels in the 6 GHz band.


### FEC_K and FEC_N

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

Frequency - Wi-Fi transmits data between your device and a router using radio waves over specific frequencies. Depending on the amount of data being transferred, it can use one of two frequencies: 2.4 gigahertz or 5 gigahertz.

LDPC - LDPC stands for Low-Density Parity-Check code, which is an advanced error-correcting code used in digital communication systems to improve the reliability of data transmission over noisy channels. LDPC codes are designed to detect and correct errors that occur during data transmission, allowing for more efficient and robust communication.

MCS Index - The Modulation Coding Scheme (MCS) index is a standard industry metric that reflects various factors in a Wi-Fi connection between a client device and a wireless access point, such as data rate, channel width, and the number of antennas or spatial streams in the device.

STBC - STBC stands for Space-Time Block Coding, which is a technique used in wireless communication systems to improve signal reliability and data transmission performance, particularly in environments with interference or signal fading.



## Filesystem

### Drone


| File Path            | Description                                          |
|----------------------|------------------------------------------------------|
| Config                                                                     |
| `/etc/wfb.conf`      | Sets up Settings                                    |
| `/etc/drone.key`     | Secret key that is exchanged with Groundstation     |
| `/etc/datalink.conf` | |
| `/etc/majestic.yaml` | Majestic Settings                                   |
| `/etc/mavlink`       | Mavlink Settings                                    |
| `/etc/openipc_banner`| |
| `/etc/openipc_donors`| |
| `/etc/telemetry.conf`| |
| Startup Files                                                             |
| `/etc/init.d/S95majestic` |       |
| `/etc/init.d/S98datalink` ||
| `/etc/init.d/S98datalink` ||
| `/etc/init.d/S98datalink` ||
| `/etc/init.d/S98datalink` ||
| Apps                                                                      |
| `/usr/bin/msposd` ||
| `/usr/bin/font_hd.png` | font file for msposd |
| `/usr/bin/font.png` | font file for msposd |
| `/usr/bin/telemetry` |  |
| `/usr/bin/majestic` |  |


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
| `/home/radxa/resizefs.sh` | |
| `/home/radxa/scripts/screen-mode` | Setup resolution |
| `/home/radxa/scripts/stream.sh` | Starts main process |
| `/home/radxa/scripts/wifi-connect.sh` | Script to setup local wifi connection to home router|
| Media |
| `/home/radxa/Videos/` | Location where flight videos are stored|