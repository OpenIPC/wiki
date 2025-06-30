##IR 
##Y2 !17
##Y1 !6
##X2 !13
##Y3 !8
##X1 !7
##ALARM 10
##REC 11

function gpio_setup {
  if [ ! -e /sys/class/gpio/gpio$1 ]; then
    echo $1 > /sys/class/gpio/export
  fi
  echo $2 > /sys/class/gpio/gpio$1/direction
}

function set_gpio {
  echo $2 > /sys/class/gpio/gpio$1/value
}


function get_gpio {
  return `cat /sys/class/gpio/gpio${1}/value`
}

#buttons
for i in 6 7 8 13 17
do
  gpio_setup $i in
done

#ALARM led
gpio_setup 10 out

while [ true ]
do
  get_gpio 6
  if [ "$?" -eq 0 ]; then
      set_gpio 10 1
      echo 6 >>/tmp/gpio.log
      #ifdown usb0
      #ifup usb0
      /usr/bin/wifibroadcast restart
      sleep .1
      set_gpio 10 0
  fi
  
  get_gpio 7
  if [ "$?" -eq 0 ]; then
      set_gpio 10 1
      echo 7 >>/tmp/gpio.log
      ifconfig eth0:1 192.168.11.1
      sleep .5
      set_gpio 10 0
  fi
  
  get_gpio 8
  if [ "$?" -eq 0 ]; then
      set_gpio 10 1
      echo 8 >>/tmp/gpio.log
      sleep .5
      set_gpio 10 0
  fi
  
  get_gpio 13
  if [ "$?" -eq 0 ]; then
      set_gpio 10 1
      echo 13 >>/tmp/gpio.log
      sleep .5
      set_gpio 10 0
  fi

  get_gpio 17
  if [ "$?" -eq 0 ]; then
      set_gpio 10 1
      echo 17 >>/tmp/gpio.log
      sleep .5
      set_gpio 10 0
  fi

  sleep .2
done