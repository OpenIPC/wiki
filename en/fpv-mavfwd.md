# OpenIPC Wiki
[Table of Content](../README.md)

OpenIPC FPV - mavfwd tool
-------------------------

Edit **/etc/wifibroadcast.cfg**:
```diff
[gs_mavlink]
peer = 'connect://127.0.0.1:14550'  # outgoing connection
-# peer = 'listen://0.0.0.0:14550'   # incoming connection
+peer = 'listen://0.0.0.0:14550'   # incoming connection
```

Update settings:
```
echo cli -s .video0.fps 120 > /dev/udp/localhost/14550
```

Update drone key:
```
file="echo $(cat gs.key | base64) | base64 -d > /etc/drone.key"
echo $file > /dev/udp/localhost/14550
```

Update configuration:
```
file="echo $(cat wfb.conf | base64) | base64 -d > /etc/wfb.conf"
echo $file > /dev/udp/localhost/14550
```
