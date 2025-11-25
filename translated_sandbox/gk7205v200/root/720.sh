#yaml-cli -s .isp.sensorConfig /etc/sensors/720p30_imx307_50.ini #use this for imx307
#yaml-cli -s .video0.fps 50 #use thise for imx307
yaml-cli -s .video0.size 1280x720
yaml-cli -s .video0.fps 30
yaml-cli -s .isp.sensorConfig /etc/sensors/imx415.bin
yaml-cli -s .isp.exposure 10
yaml-cli -s .video0.crop 0x0x1280x720
sleep .2
/root/kill.sh
