# OpenIPC Wiki
[Table of Content](../README.md)

SigmaStar SoC research and debugging notes
------------------------------------------

#### Control PWM channels on SigmaStar SSC338Q

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

#### 61 pin  red_led PM_GPIO2

```
./devmem 0x1f001CA0 w 0x40

echo 2 > /sys/class/pwm/pwmchip0/export
echo 16000 > /sys/class/pwm/pwmchip0/pwm2/period
echo 50 > /sys/class/pwm/pwmchip0/pwm2/duty_cycle
echo 1 > /sys/class/pwm/pwmchip0/pwm2/enable
```


#### 63 pin  blue_led PM_GPIO3

```
./devmem 0x1f001CA0 w 0x100

echo 3 > /sys/class/pwm/pwmchip0/export
echo 16000 > /sys/class/pwm/pwmchip0/pwm3/period
echo 80 > /sys/class/pwm/pwmchip0/pwm3/duty_cycle
echo 1 > /sys/class/pwm/pwmchip0/pwm3/enable
```
