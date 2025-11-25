#!/bin/sh

ARG="`cat /etc/vdec.conf`"
value=${ARG#*mode=}
value2=${value%%p60*}
if [ $value2 == '720' ]; then
    sed -i -e 's/mode=720p60/mode=1080p60/g' /etc/vdec.conf
elif [ $value2 == '1080' ]; then
    sed -i -e 's/mode=1080p60/mode=720p60/g' /etc/vdec.conf
fi
reboot  # Please probe this for re-read config: killall -1 vdec

