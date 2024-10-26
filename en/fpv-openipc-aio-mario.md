# OpenIPC Wiki
[Table of Contents](../README.md)

## OpenIPC AIO "Mario"
### [Product Link](https://store.openipc.org/OpenIPC-AIO-Mario-v1-0-p633320808)

![OpenIPC AIO Mario](https://github.com/user-attachments/assets/ad675599-61ce-4cec-a9bf-5933d907c53a)

**Note:** Remove the lens cover film before use.

![Lens Cover Film](https://github.com/user-attachments/assets/9ead08a6-f4eb-45a0-bc63-19d3abd3ec1e)

---

### Installation Overview
The OpenIPC AIO "Mario" integrates seamlessly with various RC planes and drones. To ensure proper functionality, follow these installation steps carefully:

#### Step 1: Secure the Camera Case
- **Mounting:** Use the provided four M1.2 screws to secure the camera case. The side mount holes are compatible with M2 screws.

#### Step 2: Antenna Installation
- **Install Antennas:** Attach the antennas designed for AIO to ensure optimal signal reception.

![Antenna Installation](https://github.com/user-attachments/assets/e10e6671-553f-4840-aacd-16816be0813b)

#### Step 3: Cable Connections
Connect the following cables from the OpenIPC AIO "Mario" to your flight controller (e.g., SpeedyBee F405 WING):

- **GND (Ground):** Connect to the ground pin on the flight controller. This is crucial for stable power and signal integrity.
- **VCC (Power):** Connect to the VCC pin on the flight controller. This pin typically provides the necessary power supply (make sure the voltage matches your flight controller specifications).
- **RX (Receive):** Connect to the TX pin on the flight controller. This allows the AIO to receive data from the flight controller.
- **TX (Transmit):** Connect to the RX pin on the flight controller. This enables the AIO to send data back to the flight controller.

Ensure that all connections are secure and insulated to prevent any shorts or signal interference.

---

### Additional Setup Considerations
- Before powering on, double-check all connections for correctness.
- Refer to your flight controller's manual for specific pin locations and configurations.
- If applicable, configure your flight controller to recognize the AIO camera in its settings for optimal performance.

---

### LED Functions
The status LEDs indicate different power states:
- **Red (Glimmering):** Power on with battery
- **Red:** Wired connection established
- **Blue (Flashing):** RF transmitter active
- **Green:** To Be Determined (TBD)

#### Board Specifications
- **Board Size:** 30mm x 32mm with 4 M2 mount holes
- **Heat Sink Size:** 20mm x 20mm mount holes

![Board Specifications](https://github.com/user-attachments/assets/1c7e34c1-76a9-45ee-9caf-ffd33261e154)

---

### Power Section
#### Power Input:
- Accepts 2S-6S battery input.

#### On-Board BEC Capacity:
- **RF BEC:** Up to 3A, 5V output
- **MSIC BEC:** Up to 2A, 5V output

To enter U-Boot, connect a UART device to the top of the AIO board (R0, T0 pads).

#### Adjusting Voltage Input
To achieve lower voltage input for DC:
- A 2S-3S battery requires four wires connected for adequate current. Higher voltage (4S+) may only need a two-wire connection.
- Remove two resistors to lower the input voltage to as low as 5.4V.

![Voltage Input Adjustment](https://github.com/user-attachments/assets/24218925-fca8-47e2-bc4a-1326dabeaa68)

---

### Connecting USB Debug Port
1. **Connect USB Cable:** Attach the USB cable between the AIO and your PC.
2. **Power On:** Turn on the DC or use USB power only.

If your computer detects unknown USB devices, install the required [corechip-sr9900 drivers](https://github.com/user-attachments/files/16829005/corechip-sr9900-usb20-to-fast-ethernet-adapter-1750095.zip).

#### Mac OS Operations
![Mac Operations Screenshot](https://github.com/user-attachments/assets/15fde52d-8f14-4377-87ed-cec6e05dc70a)

![Mac Operations Screenshot](https://github.com/user-attachments/assets/ce029aab-7505-41f8-81fc-283e41dfe84a)

![Mac Operations Screenshot](https://github.com/user-attachments/assets/97aff8d8-1a1b-4682-a304-4af58a29e68a)

---

### Auto Setup on Windows
1. Download the [Auto_Set_Mario_CDC.zip](https://github.com/user-attachments/files/17010487/Auto_Set_Mario_CDC.zip) file, unzip it, and run it as an administrator.
2. Alternatively, set it up manually:
   - Go to **Control Panel** > **Internet** > **Network**.
   - Find the USB 2.0 to Fast Ethernet Adapter.
   - Set the IPv4 address to `192.168.1.11` and mask to `255.255.255.0`.
   - Apply the settings.
3. Open SSH to connect to the AIO at address `192.168.1.10` with the following credentials:
   - **User:** root
   - **Password:** 12345

#### Internet Access for AIO
1. Open **Network Connections** on Windows.
2. Right-click your main network adapter and select **Properties**.
3. Under **Sharing**, allow other network users to choose USB CDC.

![Network Sharing](https://github.com/user-attachments/assets/e3f41122-7601-4dff-b599-a325e0693b8c)

Apply settings, and the CDC Ethernet will automatically receive an IP address of `192.168.137.1`.

![Automatic IP Address](https://github.com/user-attachments/assets/bac7350b-399e-419c-8a4a-557d4378cf79)

4. Open an admin terminal and use `arp -a` to find the AIO's IP.

![Find AIO IP](https://github.com/user-attachments/assets/f6d2641e-a5e9-45cd-90cb-5328d423a6c7)

*Example AIO IP:* `192.168.137.147`

Now you can use SSH to connect to AIO.

![SSH Connection](https://github.com/user-attachments/assets/48f44a3d-ae04-4780-aac7-b878a043c3e6)

You can now execute `sysupgrade -r -k -n --force_ver` to update your firmware.

---

### Firmware Upgrade
Firmware updates can be performed via SD card or using WinSCP to drag the root filesystem and kernel files to `/tmp`.

Use the following command to upgrade:
You can download firmware for updates [here](https://github.com/OpenIPC/wiki/blob/master/en/fpv-openipc-aio-ultrasight.md#software).

For discussions and suggestions, visit:
- [Telegram Discussion 1](https://t.me/c/1809358416/98818/103632)
- [Telegram Discussion 2](https://t.me/c/1809358416/98818/108052)

You may also use the configurator available at: [OpenIPC Configurator](https://github.com/OpenIPC/configurator).

---

### RF Section
#### RF Antenna Characteristics
![RF Antenna Characteristics](https://github.com/user-attachments/assets/d54050b4-2769-4942-95d7-8aad3b5e2e21)
![RF Antenna Characteristics](https://github.com/user-attachments/assets/0a709f70-ac8b-4880-93f5-49e1d958eb1b)

#### Recommended RF Settings
- **Max RF Power:** 18dBm for onboard PA input.
- For **1T1R RF settings:** Range from 1-63; ensure firmware is updated to the latest version.
- Set `stbc=0` and `ldpc=0` with recommended RF power values below 45.
- Use MCS index 1,3 (0-7 for 1T1R; 8+ for 2T2R).
- **Video Bitrate Options:** 4096 / 8192 / 12688 (for MCS 3+).
- When using `stbc=1` and `ldpc=1`, recommend RF power settings for MCS3 between 8-15 for testing.
- Keep RF power at or below 15 during bench tests (when only USB is connected).

---

### SD Slot for Air Camera Record
During bench testing or debugging, the recording function is disabled by default. To enable recording, set the `record value` to `true` in `majestic.yaml`. Ensure the SD card is inserted before powering on.

**Onboard Heat Sink and Cooling Fan:**
- Cooling fan output power is up to 500mA max.
- Adjust `thermal throttle` as needed.

---

### Additional Resources
For further assistance and updates, refer to:
- [OpenIPC Wiki](https://github.com/OpenIPC/wiki)
- [OpenIPC Community](https://t.me/OpenIPC)

---

