
# Ingenic PTZ Configuration Guide

Ensure your Buildroot configuration includes the Ingenic motors package. In your `defconfig`, verify the following line is present and enabled:

```plaintext
BR2_PACKAGE_INGENIC_MOTORS_T31=y
```

## Loading the Module

Load the motor module with the following command ( adjust the GPIOs as needed for your hardware, see [Module Configuration](https://github.com/OpenIPC/wiki/blob/master/en/ingenic-ptz.md#module-configuration) ):

```bash
modprobe sample_motor hmaxstep=2540 vmaxstep=720 hst1=52 hst2=53 hst3=57 hst4=51 vst1=59 vst2=61 vst3=62 vst4=63
```

To automate this process during boot, add the line `sample_motor hmaxstep=2540 vmaxstep=720 hst1=52 hst2=53 hst3=57 hst4=51 vst1=59 vst2=61 vst3=62 vst4=63` to `/etc/modules`.

## Module Configuration

- `hstX`: Horizontal motor phase GPIO pins.
- `vstX`: Vertical motor phase GPIO pins.
- `hmaxstep` and `vmaxstep`: Specify the maximum number of steps your hardware can handle.

## Controlling the Motors

Use the `t31-kmotor` command-line utility for motor control.

## Note on GPIO Handling

- Be aware that depending on the specific GPIOs your hardware uses for motor control, you might experience limited or non-functional movement due to broken GPIO handling on the Ingenic platform.
- This issue may be addressed in future updates.
```
