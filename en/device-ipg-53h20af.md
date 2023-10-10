# XiongMai IPG-53H20AF

2.0M Autofocal Module

## Hardware

| System | Description                          |
|--------|--------------------------------------|
| SoC    | HI3516CV100                          |
| Sensor | IMX322                               |
| Flash  | 16Mb (MX25L12835F)                   |

### Network
Ethernet working only with these parameters
```
    setenv phyaddru 1
    setenv phyaddrd 2
    setenv mdio_intf rmii
    saveenv
```

### GPIOs

WARNING!!! Motor gpio pin states incorrect after boot, motor windings may burn out, init with [these](#motor-test) asap, or unplug motors connector before powering up.

| Nr        | Description   | Color   |
|-----------|---------------|---------|
| 38        | irCut_1       |         |
| 39        | irCut_2       |         |
| 9         | Zoom motor A1 | Green   |
| 48        | Zoom motor A2 | Orange  |
| 51        | Zoom motor B1 | Yellow  |
| 43        | Zoom motor B2 | Violet  |
| 52        | Foc motor A1  | Black   |
| 55        | Foc motor A2  | Blue    |
| 53        | Foc motor B1  | White   |
| 54        | Foc motor B2  | Red     |

### Motor test

Very slow movement due sysfs gpio manipulation

```
#!/bin/sh

# motor test for ipg-53h20af

gpio_WT_Am=9
gpio_WT_Ap=48
gpio_WT_Bm=51
gpio_WT_Bp=43

gpio_FN_Am=52
gpio_FN_Ap=55
gpio_FN_Bm=53
gpio_FN_Bp=54


sleep_time=100

mux() {
  ipctool gpio mux $gpio_WT_Am
  ipctool gpio mux $gpio_WT_Ap
  ipctool gpio mux $gpio_WT_Bm
  ipctool gpio mux $gpio_WT_Bp
  ipctool gpio mux $gpio_FN_Am
  ipctool gpio mux $gpio_FN_Ap
  ipctool gpio mux $gpio_FN_Bp
  ipctool gpio mux $gpio_FN_Bm
}

unexport() {
  echo "$gpio_WT_Am" >/sys/class/gpio/unexport
  echo "$gpio_WT_Ap" >/sys/class/gpio/unexport
  echo "$gpio_WT_Bm" >/sys/class/gpio/unexport
  echo "$gpio_WT_Bp" >/sys/class/gpio/unexport
  echo "$gpio_FN_Am" >/sys/class/gpio/unexport
  echo "$gpio_FN_Ap" >/sys/class/gpio/unexport
  echo "$gpio_FN_Bp" >/sys/class/gpio/unexport
  echo "$gpio_FN_Bm" >/sys/class/gpio/unexport
}

export_() {
  echo "$gpio_WT_Am" >/sys/class/gpio/export
  echo "$gpio_WT_Ap" >/sys/class/gpio/export
  echo "$gpio_WT_Bm" >/sys/class/gpio/export
  echo "$gpio_WT_Bp" >/sys/class/gpio/export
  echo "$gpio_FN_Am" >/sys/class/gpio/export
  echo "$gpio_FN_Ap" >/sys/class/gpio/export
  echo "$gpio_FN_Bp" >/sys/class/gpio/export
  echo "$gpio_FN_Bm" >/sys/class/gpio/export
}

dir() {
  echo "out" >/sys/class/gpio/gpio$gpio_WT_Am/direction
  echo "out" >/sys/class/gpio/gpio$gpio_WT_Ap/direction
  echo "out" >/sys/class/gpio/gpio$gpio_WT_Bm/direction
  echo "out" >/sys/class/gpio/gpio$gpio_WT_Bp/direction
  echo "out" >/sys/class/gpio/gpio$gpio_FN_Am/direction
  echo "out" >/sys/class/gpio/gpio$gpio_FN_Ap/direction
  echo "out" >/sys/class/gpio/gpio$gpio_FN_Bp/direction
  echo "out" >/sys/class/gpio/gpio$gpio_FN_Bm/direction
}

init() {
  mux
  unexport
  export_
  dir
}

set_zero_FN() {
  echo "0" >/sys/class/gpio/gpio$gpio_FN_Am/value
  echo "0" >/sys/class/gpio/gpio$gpio_FN_Ap/value
  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bp/value
  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bm/value
}
set_zero_WT() {
  echo "0" >/sys/class/gpio/gpio$gpio_WT_Am/value
  echo "0" >/sys/class/gpio/gpio$gpio_WT_Ap/value
  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bm/value
  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bp/value
}
set_zero() {
  set_zero_FN
  set_zero_WT
}

far() {
#  echo "1" >/sys/class/gpio/gpio$gpio_FN_Ap/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Am/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bp/value
  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bm/value
  usleep $sleep_time
  
#  echo "1" >/sys/class/gpio/gpio$gpio_FN_Ap/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Am/value
  echo "1" >/sys/class/gpio/gpio$gpio_FN_Bp/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bm/value
  usleep $sleep_time

  echo "0" >/sys/class/gpio/gpio$gpio_FN_Ap/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Am/value
#  echo "1" >/sys/class/gpio/gpio$gpio_FN_Bp/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bm/value
  usleep $sleep_time

#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Ap/value
  echo "1" >/sys/class/gpio/gpio$gpio_FN_Am/value
#  echo "1" >/sys/class/gpio/gpio$gpio_FN_Bp/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bm/value
  usleep $sleep_time

#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Ap/value
#  echo "1" >/sys/class/gpio/gpio$gpio_FN_Am/value
  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bp/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bm/value
  usleep $sleep_time

#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Ap/value
#  echo "1" >/sys/class/gpio/gpio$gpio_FN_Am/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bp/value
  echo "1" >/sys/class/gpio/gpio$gpio_FN_Bm/value
  usleep $sleep_time

#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Ap/value
  echo "0" >/sys/class/gpio/gpio$gpio_FN_Am/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bp/value
#  echo "1" >/sys/class/gpio/gpio$gpio_FN_Bm/value
  usleep $sleep_time

  echo "1" >/sys/class/gpio/gpio$gpio_FN_Ap/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Am/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bp/value
#  echo "1" >/sys/class/gpio/gpio$gpio_FN_Bm/value
  usleep $sleep_time
}

near() {
#  echo "1" >/sys/class/gpio/gpio$gpio_FN_Ap/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Am/value
  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bp/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bm/value
  usleep $sleep_time
  
#  echo "1" >/sys/class/gpio/gpio$gpio_FN_Ap/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Am/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bp/value
  echo "1" >/sys/class/gpio/gpio$gpio_FN_Bm/value
  usleep $sleep_time

  echo "0" >/sys/class/gpio/gpio$gpio_FN_Ap/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Am/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bp/value
#  echo "1" >/sys/class/gpio/gpio$gpio_FN_Bm/value
  usleep $sleep_time

#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Ap/value
  echo "1" >/sys/class/gpio/gpio$gpio_FN_Am/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bp/value
#  echo "1" >/sys/class/gpio/gpio$gpio_FN_Bm/value
  usleep $sleep_time

#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Ap/value
#  echo "1" >/sys/class/gpio/gpio$gpio_FN_Am/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bp/value
  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bm/value
  usleep $sleep_time

#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Ap/value
#  echo "1" >/sys/class/gpio/gpio$gpio_FN_Am/value
  echo "1" >/sys/class/gpio/gpio$gpio_FN_Bp/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bm/value
  usleep $sleep_time

#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Ap/value
  echo "0" >/sys/class/gpio/gpio$gpio_FN_Am/value
#  echo "1" >/sys/class/gpio/gpio$gpio_FN_Bp/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bm/value
  usleep $sleep_time

  echo "1" >/sys/class/gpio/gpio$gpio_FN_Ap/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Am/value
#  echo "1" >/sys/class/gpio/gpio$gpio_FN_Bp/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bm/value
  usleep $sleep_time
}

tele() {
#  echo "1" >/sys/class/gpio/gpio$gpio_WT_Ap/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Am/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bp/value
  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bm/value
  usleep $sleep_time
  
#  echo "1" >/sys/class/gpio/gpio$gpio_WT_Ap/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Am/value
  echo "1" >/sys/class/gpio/gpio$gpio_WT_Bp/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bm/value
  usleep $sleep_time

  echo "0" >/sys/class/gpio/gpio$gpio_WT_Ap/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Am/value
#  echo "1" >/sys/class/gpio/gpio$gpio_WT_Bp/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bm/value
  usleep $sleep_time

#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Ap/value
  echo "1" >/sys/class/gpio/gpio$gpio_WT_Am/value
#  echo "1" >/sys/class/gpio/gpio$gpio_WT_Bp/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bm/value
  usleep $sleep_time

#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Ap/value
#  echo "1" >/sys/class/gpio/gpio$gpio_WT_Am/value
  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bp/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bm/value
  usleep $sleep_time

#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Ap/value
#  echo "1" >/sys/class/gpio/gpio$gpio_WT_Am/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bp/value
  echo "1" >/sys/class/gpio/gpio$gpio_WT_Bm/value
  usleep $sleep_time

#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Ap/value
  echo "0" >/sys/class/gpio/gpio$gpio_WT_Am/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bp/value
#  echo "1" >/sys/class/gpio/gpio$gpio_WT_Bm/value
  usleep $sleep_time

  echo "1" >/sys/class/gpio/gpio$gpio_WT_Ap/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Am/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bp/value
#  echo "1" >/sys/class/gpio/gpio$gpio_WT_Bm/value
  usleep $sleep_time

}

wide() {
#  echo "1" >/sys/class/gpio/gpio$gpio_WT_Ap/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Am/value
  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bp/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bm/value
  usleep $sleep_time
  
#  echo "1" >/sys/class/gpio/gpio$gpio_WT_Ap/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Am/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bp/value
  echo "1" >/sys/class/gpio/gpio$gpio_WT_Bm/value
  usleep $sleep_time

  echo "0" >/sys/class/gpio/gpio$gpio_WT_Ap/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Am/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bp/value
#  echo "1" >/sys/class/gpio/gpio$gpio_WT_Bm/value
  usleep $sleep_time

#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Ap/value
  echo "1" >/sys/class/gpio/gpio$gpio_WT_Am/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bp/value
#  echo "1" >/sys/class/gpio/gpio$gpio_WT_Bm/value
  usleep $sleep_time

#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Ap/value
#  echo "1" >/sys/class/gpio/gpio$gpio_WT_Am/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bp/value
  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bm/value
  usleep $sleep_time

#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Ap/value
#  echo "1" >/sys/class/gpio/gpio$gpio_WT_Am/value
  echo "1" >/sys/class/gpio/gpio$gpio_WT_Bp/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bm/value
  usleep $sleep_time

#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Ap/value
  echo "0" >/sys/class/gpio/gpio$gpio_WT_Am/value
#  echo "1" >/sys/class/gpio/gpio$gpio_WT_Bp/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bm/value
  usleep $sleep_time

  echo "1" >/sys/class/gpio/gpio$gpio_WT_Ap/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Am/value
#  echo "1" >/sys/class/gpio/gpio$gpio_WT_Bp/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bm/value
  usleep $sleep_time
}

if [ $# -lt 1 ]; then
  echo "usage : ./motor <direction> [step]"
  echo "        -i init gpio"
  echo "        -f far"
  echo "        -n near"
  echo "        -w wide"
  echo "        -t tele"
  
  exit
fi

if [ $1 = "-i" ]; then
  init 
  set_zero
  exit
fi

if [ $1 = "-f" ]; then
  direction="far"
  echo "1" >/sys/class/gpio/gpio$gpio_FN_Ap/value
elif [ $1 = "-w" ]; then
  direction="wide"
  echo "1" >/sys/class/gpio/gpio$gpio_WT_Ap/value
elif [ $1 = "-n" ]; then
  direction="near"
  echo "1" >/sys/class/gpio/gpio$gpio_FN_Ap/value
elif [ $1 = "-t" ]; then
  direction="tele"
  echo "1" >/sys/class/gpio/gpio$gpio_WT_Ap/value
fi

if [ $# -eq 2 ]; then
  max=$2
else
  max=10
fi

echo $max

i=0
while [ $i -lt $max ]
do
  $direction >/dev/null
  true $(( i++ ))
done


# turn to full step and disable motor
if [ $1 = "-f" ]; then
  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bm/value
  usleep $sleep_time
  set_zero_FN
elif [ $1 = "-w" ]; then
  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bp/value
  usleep $sleep_time
  set_zero_WT
elif [ $1 = "-n" ]; then
  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bp/value
  usleep $sleep_time
  set_zero_FN
elif [ $1 = "-t" ]; then
  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bm/value
  usleep $sleep_time
  set_zero_WT
fi
```
