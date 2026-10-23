# Uniojo T5826HCA-M01

The Uniojo T5826HCA-M01 is a Wi-Fi IP camera based on the HiSilicon Hi3518EV200 SoC paired with a Silicon Optronics JX-F22 image sensor and Realtek RTL8188FU USB Wi-Fi module.

## Hardware Specifications

| Component | Description |
|-----------|-------------|
| SoC | HiSilicon Hi3518EV200 (ARM926EJ-S) |
| Sensor | Silicon Optronics (SOI) JX-F22 (1080p, MIPI) |
| Flash | 16MB SPI NOR Flash |
| Wi-Fi | Realtek RTL8188FU (USB 802.11n, driver: `rtl8188fu`) |
| Storage | MicroSD card slot |
| Night Vision | IR-Cut filter in M12 lens mount + IR LED ring with photodiode |

---

## OpenIPC Support Status

| Feature | Status | Notes |
|---------|--------|-------|
| Video Stream | Working | 1080p H.264 via `majestic` |
| Wi-Fi | Working | RTL8188FU module via `wlan0` (requires GPIO 54 HIGH) |
| IR-Cut Filter | Working | Single-pin control on **GPIO 2** |
| IR Illumination | Working | Switched in unison with filter on **GPIO 2** |
| Day/Night Sensor | Working | Photodiode input on **GPIO 62** |
| MicroSD Card | Working | Standard SDIO interface |

---

## GPIO Pinout and Hardware Configuration

### Critical: Wi-Fi Power Control (GPIO 54)
> [!CAUTION]
> **GPIO 54 controls power to the onboard USB bus and RTL8188FU Wi-Fi module.**
> Driving GPIO 54 LOW (`0`) cuts power to the Wi-Fi adapter immediately, terminating network access and requiring a hard power cycle.
> 
> Keep GPIO 54 in the GPIO avoid list when testing or sweeping pins:
> `POST /api/v1/gpio?avoid=54`

### Night Mode: IR-Cut Filter and IR LEDs (GPIO 2)
The camera utilizes a single-pin control topology for night vision:
* **GPIO 2 HIGH (`1`):** Engages Night mode. Moves the IR-cut filter out of the optical path and energizes the IR LED illuminator ring.
* **GPIO 2 LOW (`0`):** Engages Day mode. Releases the filter (spring returns it in front of the sensor) and de-energizes the IR LED illuminator.

In Majestic, configure this as a single-pin filter without `irCutPin2`:
* `irCutPin1: 2`
* `irCutSingleInvert: false`

### Daylight Sensor: Photodiode (GPIO 62)
The daylight sensor on the IR LED ring connects to **GPIO 62**:
* **Logic Levels:**
  - Daylight / bright illumination: LOW (`0`)
  - Darkness / night: HIGH (`1`)
* Because bright light produces a LOW state, invert the sensor polarity in Majestic:
  - `lightSensorPin: 62`
  - `lightSensorInvert: true`
  - `lightMonitor: true`

---

## Majestic Configuration

Add the following configuration to `/etc/majestic.yaml`:

```yaml
nightMode:
  irCutPin1: 2
  irCutSingleInvert: false
  lightSensorPin: 62
  lightSensorInvert: true
  lightMonitor: true
```

---

## Firmware Build Notes

When building an image with OpenIPC Buildroot for this camera, select the `hi3518ev200_ultimate_defconfig` target and ensure the RTL8188FU package is selected:

```text
BR2_PACKAGE_RTL8188FU_OPENIPC=y
```
