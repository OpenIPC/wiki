#use: ./ircut.sh on | off

function gpio_setup {
  if [ ! -e /sys/class/gpio/gpio$1 ]; then
    echo $1 > /sys/class/gpio/export
  fi
  echo $2 > /sys/class/gpio/gpio$1/direction
}

function set_gpio {
  echo $2 > /sys/class/gpio/gpio$1/value
}

function ircut_on {
  set_gpio 8 0
  set_gpio 9 1
  sleep 0.1
  set_gpio 8 0
}

function ircut_off {
  set_gpio 8 1
  set_gpio 9 0
  sleep 0.1
  set_gpio 8 0
}

gpio_setup 8 out
gpio_setup 9 out
ircut_$1


