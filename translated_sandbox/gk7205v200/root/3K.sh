yaml-cli -s .video0.size 3200x1800
yaml-cli -s .video0.crop 250x150x2560x1440
yaml-cli -s .video0.fps 30
yaml-cli -s .isp.sensorConfig /etc/sensors/imx415.bin
yaml-cli -s .isp.exposure 10
sleep .2
/root/kill.sh
