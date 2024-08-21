# OpenIPC Wiki
[Table of Content](../README.md)

Ingenic SoC research and debugging notes
----------------------------------------

#### Control PWM channels on ingenic devices using `ingenic-pwm` utility included with OpenIPC:

```
INGENIC PWM Control Version: Oct 19 2023_18:01:16_latest-2294-g72f266e7
Usage: ingenic-pwm [options]

Options:
  -c, --channel=<0-7>            Specify PWM channel number
  -q, --query                    Query channel state
  -e, --enable                   Enable channel
  -d, --disable                  Disable channel
  -p, --polarity=<0|1>           Set polarity (0: Inversed, 1: Normal)
  -D, --duty=<duty_ns>           Set duty cycle in ns
  -P, --period=<period_ns>       Set period in ns
  -r, --ramp=<value>             Ramp PWM (+value: Ramp up, -value: Ramp down)
  -x, --max_duty=<max_duty_ns>   Set max duty for ramping
  -n, --min_duty=<min_duty_ns>   Set min duty for ramping
  -h, --help                     Display this help message
```

Example commands:  
Turn on LED, Dim ON: Set PWM Channel 3 enabled, Period to 1000000, min Duty 0, max Duty 1000000, ramp rate + Dim Up, - to Dim down  

`ingenic-pwm -c 3 -e -p 1 -P 1000000 -n 0 -x 1000000 -r 50000`  
`ingenic-pwm -c 3 -e -p 1 -P 1000000 -n 0 -x 1000000 -r -50000`  

---

#### Enable full engineering debuging  

Enable: Run `switch_debug on` to enable debugging  
Disable: Run `switch debug off` or `switch_debug` to surpress debugging output

Enabling will enable **FULL** engineering debuging output in dmesg. 

---

#### Dynamic Debugging

Dynamic Debugging has been enabled on the Linux Kernel for the Ingenic platforms to surpress excess engineering debugging.

https://www.kernel.org/doc/html/v4.14/admin-guide/dynamic-debug-howto.html

Mount debugfs first:  
`mount -t debugfs none /sys/kernel/debug`

Check entries:  
`cat /sys/kernel/debug/dynamic_debug/control`

Example output:  

```
../ingenic-opensdk/kernel/avpu/t31/avpu_main.c:314 [avpu]write_reg =_ "Out-of-range register write: 0x%.4X\012"
../ingenic-opensdk/kernel/avpu/t31/avpu_main.c:304 [avpu]write_reg =_ "Reg write: 0x%.4X: 0x%.8x\012"
../ingenic-opensdk/kernel/avpu/t31/avpu_main.c:302 [avpu]write_reg =_ "Reg write: 0x%.4X: 0x%.8x\012"
../ingenic-opensdk/kernel/avpu/t31/avpu_main.c:290 [avpu]read_reg =_ "Reg read: 0x%.4X: 0x%.8x\012"
../ingenic-opensdk/kernel/avpu/t31/avpu_main.c:234 [avpu]wait_irq =_ "Unblocking channel\012"
../ingenic-opensdk/kernel/avpu/t31/avpu_ip.c:128 [avpu]avpu_hardirq_handler =_ "ENOMEM: Missed interrupt\012"
../ingenic-opensdk/kernel/avpu/t31/avpu_ip.c:117 [avpu]avpu_hardirq_handler =_ "bitfield is 0\012"
/mnt/mips/external_utilities/OpenIPC/openingenic/kernel/sensors/t31/gc2053/gc2053.c:1860 [sensor_gc2053_t31]gc2053_probe =p "probe ok ------->gc2053\012"
/mnt/mips/external_utilities/OpenIPC/openingenic/kernel/sensors/t31/gc2053/gc2053.c:1422 [sensor_gc2053_t31]gc2053_s_stream =p "gc2053 stream off\012"
/mnt/mips/external_utilities/OpenIPC/openingenic/kernel/sensors/t31/gc2053/gc2053.c:1415 [sensor_gc2053_t31]gc2053_s_stream =p "gc2053 stream on\012"
/mnt/mips/external_utilities/OpenIPC/openingenic/kernel/sensors/t31/gc2053/gc2053.c:1288 [sensor_gc2053_t31]gc2053_detect =p "-----%s: %d ret = %d, v = 0x%02x\012"
/mnt/mips/external_utilities/OpenIPC/openingenic/kernel/sensors/t31/gc2053/gc2053.c:1282 [sensor_gc2053_t31]gc2053_detect =p "-----%s: %d ret = %d, v = 0x%02x\012"
```

`=_` means debugging output is `disabled`, while `=P` will indcate that debugging output is `enabled`.  

Check `dmesg` for output

Note:  Some old kernel modules may complain about missing symbols relating to dynamic debugging:
```
[    4.357160] sample_core: Unknown symbol __dynamic_dev_dbg (err 1)
[    4.361299] sample_hal: Unknown symbol __dynamic_dev_dbg (err 1)
```
To resolve this, make sure you update your entire OpenIPC installation to the latest versions after 10-20-2023, or try to update the individual kernel modules experiencing issues.  As a last restort, you can also disable `CONFIG_DYNAMIC_DEBUG` in your kernel config, but extensive testing has not shown this to be an issue.

---

#### Change sensor clock rate dynamically

`echo "30000000" > /proc/jz/clock/cgu_cim/rate`  
This may be used to change the MCLK clockrate setting for image sensors.  You can use this to get more bandwidth for higher resoluitons for FPS rates.

---

#### Dynamically insert or remove SDIO device

Use these commands to enable or disable SDIO devices after the system has already booted.  

`echo "INSERT" > /sys/devices/platform/jzmmc_v1.2.X/present`  
`echo "REMOVE" > /sys/devices/platform/jzmmc_v1.2.X/present` 

Where X = the MMC device you want to control  MSC0=0 MSC1=1

---

### IMP-Control

IMP-Control is a versatile tool designed for controlling and configuring a wide range of parameters in the Ingenic IMP library, within the Majestic streamer.  This tool allows for fine-tuning of both audio and video settings to achieve optimal performance in various environments.

#### Key Features and Functionalities
1. **Audio Adjustments:**
   - `aihpf`: High Pass Filter toggle (on/off).
   - `aiagc`: Auto Gain Control with adjustable gain levels and compensation.
   - `ains`: Noise Suppression with intensity levels.
   - `aiaec`: Echo Cancellation toggle.
   - `aivol` and `aovol`: Adjusts audio input and output volume respectively.
   - `aigain` and `aogain`: Sets audio input and output gain.
   - `aialc`: Audio Input Automatic Level Control gain setting.

2. **Video Enhancements:**
   - `flip`: Manipulate image orientation.
   - `contrast`, `brightness`, `saturation`, `sharpness`: Adjust basic image qualities.
   - `sinter`, `temper`: Enhance image with sinter and temper strength adjustments.
   - `aecomp`: Auto Exposure Compensation.
   - `dpc`, `drc`: Control DPC and DRC strengths.
   - `hilight`: Adjust highlight intensity.
   - `again`, `dgain`: Set analog and digital gains.
   - `hue`: Modify color hue.
   - `ispmode`: Switch between day and night modes.
   - `flicker`: Anti-flicker settings.

3. **Advanced Controls:**
   - `whitebalance`: Adjust white balance with modes, red and blue gains.
   - `sensorfps`: Configure the sensor frames per second.
   - `backlightcomp`: Backlight Compensation Strength.
   - `defogstrength`: Control defog strength for clearer images.
   - `framerate`, `gopattr`: Manage frame rates and Group of Pictures (GOP) attributes.
   - `setbitrate`, `setgoplength`, `setqp`, `setqpbounds`, `setqpipdelta`: Detailed encoder settings.
   - `rcmode`: Set or get the Rate Control Mode.
   - `aemin`: Set Auto Exposure minimum parameters.
   - `autozoom`, `frontcrop`: Adjust zoom and crop settings.
   - `mask`: Set masking parameters for privacy or emphasis.

4. **OSD and Analytics:**
   - `getosdattr`, `getosdgrpattr`: Retrieve On-Screen Display (OSD) attributes.
   - `getgamma`, `getevattr`, `getaeluma`, `getawbct`, `getafmetrics`, `gettotalgain`, `getaeattr`: Fetch various image processing metrics.

5. **System Information:**
   - `getimpversion`: Get the IMP version.
   - `getcpuinfo`: Retrieve CPU information.

6. **Demonstration and Testing:**
   - `full_demo`: Runs a comprehensive demonstration of various functionalities.

#### How to Use
The general usage syntax is:
```
imp-control [command] [parameters]
```
Parameters vary based on the command, and in some cases, they are optional to retrieve current values.

To get help and see the list of available commands, use:
```
imp-control help
```
---

