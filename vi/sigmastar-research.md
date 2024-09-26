# OpenIPC Wiki
[Mục lục](../README.md)

Ghi chú nghiên cứu và gỡ lỗi SoC SigmaStar
------------------------------------------

#### Điều khiển các kênh PWM trên SigmaStar SSC338Q

Chuyển GPIO1 sang chế độ PWM1 và đặt tham số
```
devmem 0x1F207994 16 0x1121 
echo 1 > /sys/class/pwm/pwmchip0/export
echo 10000 > /sys/class/pwm/pwmchip0/pwm1/period
echo 25 > /sys/class/pwm/pwmchip0/pwm1/duty_cycle
echo 1 > /sys/class/pwm/pwmchip0/pwm1/enable
```


