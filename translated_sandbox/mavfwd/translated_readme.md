### Why you need mavfwd
`mavfwd` is primarily necessary for the connection of the telemetry stream wifibroadcast, 
divided into incoming and outgoing on different udp ports, from a uart camera, which 
connected to the uart flight controller UAV, configured to exchange telemetry. 
maxlink 1 and 2 versions are supported. Details of the parameters are available for `mavfwd --help`.

In the second place, mavfwd is able to monitor transmitted in the mavlink-pack [RC_CHANNELS #65](htts://mavlink.io/en/messages/common.html#RC_CHANNELS) 
the channel value with 4 and above, specified in the --channels number parameter. By changing the values of the channels, the bash-script /root/channels.sh is called, 
passing the channel number and its value. This is necessary to organize some kind of control of the host system (camera), for example, its reboot 
or setting up some streamer parameters. The attached example makes:
* 180p / 720p resolution switching;
* Turning on and off the ircut camera;
* threshold change of brightness, three modes, for selecting the necessary under current conditions of illumination (strong day, ordinary day, night).