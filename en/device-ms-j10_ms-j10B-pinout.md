MS-J10    MS-J10B
![MS-J10_PCB_pinout](/images/board-anjoy-j10b-pinout.jpg)

## Hardware


| Name | pins |Description| GPIO | Usage |
| --- | --- | --- |---|---|
|**c1** |1| ICR| gpio78
||2|ICR | gpio79
||
|**c2** |1| CDS IN| gpio61
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
||7|link led | gpio77
||8|link led| gpio77
||
|**c5** |1| reset|gpio66
||2|GND |
||3|uart TX  | ttyS2(gpio15) | 9600; echo 234 > /dev/ttyS2
||4|uart RX |ttyS2(gpio14) | 9600; cat /dev/ttyS2
||5|uart TX | ttyS1(gpio17)  | 9600; echo 234 > /dev/ttyS1
||6|uart RX| ttyS1(gpio16)  | 9600; cat /dev/ttyS1
||7|mute audio | gpio80 |echo 1 >  /sys/class/gpio/gpio80/value
|||||**"echo > ttyS" muxed UART, "export" muxed GPIO
|**c6** |1| Audio out|
||2|Audio In |
||3|GND |
||
|**c7** |1| 3.3V|
||2| 3.3V |
||3|3.3V |
||4| |gpio47
||5|3.3V |
||6| |gpio58
||7|3.3V |
||8| |gpio55
||9|GND
||10| |gpio54
||11|GND
||12| |gpio56
||13 | |gpio57
||14 | |gpio60 
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






