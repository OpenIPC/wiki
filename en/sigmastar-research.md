# OpenIPC Wiki
[Table of Content](../README.md)

SigmaStar SoC research and debugging notes
------------------------------------------

#### Control PWM channels on SigmaStar SSC338Q

Switch GPIO? to PWM1 mode and set parameters
```
devmem 0x1f207994 16 0x01102
echo 0 > /sys/class/pwm/pwmchip0/export
echo 1600000 > /sys/class/pwm/pwmchip0/pwm0/period
echo 25 > /sys/class/pwm/pwmchip0/pwm0/duty_cycle
echo 1 > /sys/class/pwm/pwmchip0/pwm0/enable
```

Switch GPIO1 to PWM1 mode and set parameters
```
devmem 0x1F207994 16 0x1121 
echo 1 > /sys/class/pwm/pwmchip0/export
echo 10000 > /sys/class/pwm/pwmchip0/pwm1/period
echo 25 > /sys/class/pwm/pwmchip0/pwm1/duty_cycle
echo 1 > /sys/class/pwm/pwmchip0/pwm1/enable
```

#### Control PWM IR led on 8232SWC-WE-B device, SSC335DE

```
# PINMUX_FOR_PWM4_MODE_3 - set PWM4 on GPIO4
devmem 0x1f203C1C w 0x3000 
echo 4 > /sys/class/pwm/pwmchip0/export
echo 40000 > /sys/class/pwm/pwmchip0/pwm4/period
echo 40 > /sys/class/pwm/pwmchip0/pwm4/duty_cycle
echo 1 > /sys/class/pwm/pwmchip0/pwm4/enable
```

#### 61 pin  red_led PM_GPIO2, SSC335DE

```
./devmem 0x1f001CA0 w 0x40

echo 2 > /sys/class/pwm/pwmchip0/export
echo 16000 > /sys/class/pwm/pwmchip0/pwm2/period
echo 50 > /sys/class/pwm/pwmchip0/pwm2/duty_cycle
echo 1 > /sys/class/pwm/pwmchip0/pwm2/enable
```


#### 63 pin  blue_led PM_GPIO3, SSC335DE

```
./devmem 0x1f001CA0 w 0x100

echo 3 > /sys/class/pwm/pwmchip0/export
echo 16000 > /sys/class/pwm/pwmchip0/pwm3/period
echo 80 > /sys/class/pwm/pwmchip0/pwm3/duty_cycle
echo 1 > /sys/class/pwm/pwmchip0/pwm3/enable
```

#### Control PWM IR led on IPC-HDW1230v3 device, SSC335DE

```
# PINMUX_FOR_PWM0_pin - set PWM0 on GPIO52
devmem 0x1F203C1C w 0x0001
echo 0 > /sys/class/pwm/pwmchip0/export
echo 40000 > /sys/class/pwm/pwmchip0/pwm0/period
echo 40 > /sys/class/pwm/pwmchip0/pwm0/duty_cycle
echo 1 > /sys/class/pwm/pwmchip0/pwm0/enable
```

#### SSC335 Infinity6B0

The kernel driver uses infinity6b0.dtsi for preparing the padmux.
* `PWM0`: `PAD_PWM0` (52)
* `PWM1`: `PAD_PWM1` (53)
* `PWM[2..10]`: no pad assigned

On kernels before OpenIPC/linux#188 (firmware older than 2026-11-09), switching PWM0 from disabled to enabled moves it back to the DTS pad, so the devmem must follow every enable. Newer kernels keep whatever pad is selected and apply the DTS default only when none is.

On SSC335 the `period` is defined in `Hz` and the `duty_cycle` is defined in percent.

If you want to use pad ID 14 (`PAD_FUART_RX`) as PWM0 you must reconfigure the padmux to `PWM0_MODE_3`:
```bash
echo "0" > /sys/class/pwm/pwmchip0/export
echo "50000" > /sys/class/pwm/pwmchip0/pwm0/period
echo "40" > /sys/class/pwm/pwmchip0/pwm0/duty_cycle
echo "1" > /sys/class/pwm/pwmchip0/pwm0/enable
devmem 0x1F203C1C w $(( ($(devmem 0x1F203C1C w) & ~7) | 3 ))
```
