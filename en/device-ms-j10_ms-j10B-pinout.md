MS-J10    MS-J10B
![MS-J10_PCB_pinout](https://github.com/sansarus/wiki/assets/6712863/b409989c-2e96-42fa-9d09-d50adcf7ecd8)

## Hardware


| Name | pins |Description| GPIO | Usage |
| --- | --- | --- |---|---|
|**c1** |1| ICR|
||2|ICR |
||
|**c2** |1| CDS IN|
||2|GND |
||3|12V out |
||4|GND |
||5|IR LED out | pwm1 |echo 20000 > /sys/class/pwm/pwmchip0/pwm1/period123
|||||echo 30 >  /sys/class/pwm/pwmchip0/pwm1/duty_cycle
|||||echo 1 > /sys/class/pwm/pwmchip0/pwm1/enable
||6|White LED out | pwm0 | echo 30 >  /sys/class/pwm/pwmchip0/pwm0/duty_cycle
||
|**j3** |1| GND|
||2|D+ |
||3|D- |
||4|VCC | gpio46 | need 2 transistors for 3.3V
||
|**c4** |1| 12V IN|
||2|GND |
||3|RJ 6 |
||4|RJ 3  |
||5|RJ 2 
||6|RJ 1
||7|link led
||8|link led|
||
|**c5** |1| reset|
||2|GND |
||3|uart TX  | ttyS2 | 9600; echo 234 > /dev/ttyS2
||4|uart RX |ttyS2 | 9600; cat /dev/ttyS2
||5|uart TX | ttyS1  | 9600; echo 234 > /dev/ttyS1
||6|uart RX| ttyS1  | 9600; cat /dev/ttyS1
||7|mute audio | gpio80 |echo 1 >  /sys/class/gpio/gpio80/value
||
|**c6** |1| Audio out|
||2|Audio In |
||3|GND |
||
|**c7** |1| 3.3V|
||2| 3.3V |
||3|3.3V |
||4|
||5
||6
||7
||8
||9|GND
||10
||11|GND
||12
||13
||14
||15|AlarmIn | gpio44 | cat /sys/class/gpio/gpio44/value 
||16|AlarmOut | gpio45
||
|**j8** |1|uart TX|ttyS0
||2|uart RX |ttyS0
||

## Additional
|desc|use|
|---|---|
cpu temp|  cat /sys/class/mstar/msys/TEMP_R|





