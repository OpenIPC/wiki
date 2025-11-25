#yaml-cli -s .isp.sensorConfig /etc/sensors/imx307_i2c_2l_1080p.ini #use this for imx307
yaml-cli -s .isp.sensorConfig /etc/sensors/imx415.bin
yaml-cli -s .isp.exposure 10
yaml-cli -s .video0.size 1920x1080
yaml-cli -s .video0.fps 30
yaml-cli -s .video0.crop 0x0x1920x1080
sleep .2
/root/kill.sh
