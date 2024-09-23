## MS-J10    MS-J10B
![MS-J10_PCB_pinout](/images/board-anjoy-j10b-pinout.jpg)

## Phần cứng


| Tên | chân | Mô tả | GPIO | Cách sử dụng |
| --- | --- | --- |---|---|
| **c1** | 1 | ICR | | |
|| 2 | ICR | | |
|| | | | |
| **c2** | 1 | CDS IN | | |
|| 2 | GND | | |
|| 3 | 12V ra | | |
|| 4 | GND | | |
|| 5 | IR LED ra | pwm1 | `echo 20000 > /sys/class/pwm/pwmchip0/pwm1/period` <br> `echo 30 >  /sys/class/pwm/pwmchip0/pwm1/duty_cycle` <br> `echo 1 > /sys/class/pwm/pwmchip0/pwm1/enable` |
|| 6 | Đèn LED trắng ra | pwm0 | `echo 30 >  /sys/class/pwm/pwmchip0/pwm0/duty_cycle` |
|| | | | |
| **j3** | 1 | GND | | |
|| 2 | D+ | | |
|| 3 | D- | | |
|| 4 | VCC | gpio46 | Cần 2 transistor cho 3.3V |
|| | | | |
| **c4** | 1 | 12V vào | | |
|| 2 | GND | | |
|| 3 | RJ 6 | | |
|| 4 | RJ 3 | | |
|| 5 | RJ 2 | | |
|| 6 | RJ 1 | | |
|| 7 | đèn LED liên kết | | |
|| 8 | đèn LED liên kết | | |
|| | | | |
| **c5** | 1 | đặt lại | | |
|| 2 | GND | | |
|| 3 | uart TX | ttyS2 | 9600; `echo 234 > /dev/ttyS2` |
|| 4 | uart RX | ttyS2 | 9600; `cat /dev/ttyS2` |
|| 5 | uart TX | ttyS1 | 9600; `echo 234 > /dev/ttyS1` |
|| 6 | uart RX | ttyS1 | 9600; `cat /dev/ttyS1` |
|| 7 | tắt tiếng âm thanh | gpio80 | `echo 1 >  /sys/class/gpio/gpio80/value` |
|| | | | |
| **c6** | 1 | Âm thanh ra | | |
|| 2 | Âm thanh vào | | |
|| 3 | GND | | |
|| | | | |
| **c7** | 1 | 3.3V | | |
|| 2 | 3.3V | | |
|| 3 | 3.3V | | |
|| 4 | | | |
|| 5 | | | |
|| 6 | | | |
|| 7 | | | |
|| 8 | | | |
|| 9 | GND | | |
|| 10 | | | |
|| 11 | GND | | |
|| 12 | | | |
|| 13 | | | |
|| 14 | | | |
|| 15 | AlarmIn | gpio44 | `cat /sys/class/gpio/gpio44/value` |
|| 16 | AlarmOut | gpio45 | | |
|| | | | |
| **j8** | 1 | uart TX | ttyS0 | |
|| 2 | uart RX | ttyS0 | | |
|| | | | |

## Bổ sung
| Mô tả | Cách sử dụng |
|---|---|
| Nhiệt độ CPU | `cat /sys/class/mstar/msys/TEMP_R` |

