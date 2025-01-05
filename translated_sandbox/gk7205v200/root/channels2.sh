if [ $1 -eq 7 ]; then
    if [ $2 -gt 1600 ]; then
      /root/ircut.sh on
    elif  [ $2 -gt 1400 ] && [ $2 -lt 1600 ]; then
      /root/ircut.sh off
    fi
fi

if [ $1 -eq 8 ]; then
  if [ $2 -gt 1600 ]; then
    killall venc
    venc -p 5600 -f 30 -r 12288 -c 265cbr -v 200_imx307F -d frame --low-delay &
  elif  [ $2 -gt 1400 ] && [ $2 -lt 1600 ]; then
    killall venc
    venc -p 5600 -f 50 -r 12288 -c 265cbr -v 200_imx307B -d frame &
  fi
fi

exit 1
