yaml-cli -s .video0.size 3840x2160
yaml-cli -s .video0.crop 575x330x2560x1440
yaml-cli -s .video0.fps 20
yaml-cli -s .isp.sensorConfig /etc/sensors/imx415.bin
yaml-cli -s .isp.exposure 10
sleep .2
/root/kill.sh
