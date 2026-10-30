# OpenIPC Wiki
[Table of Content](../README.md)

OpenIPC FPV - mavfwd tool
-------------------------

`mavfwd` forwards MAVLink packets between the air unit and the ground station. The same channel can carry commands to the air unit: any text sent to the ground station's MAVLink port is executed as a root shell command on the air unit.

Edit **/etc/wifibroadcast.cfg** and switch the `[gs_mavlink]` peer from outgoing to incoming:
```diff
[gs_mavlink]
-peer = 'connect://127.0.0.1:14550'  # outgoing connection
-# peer = 'listen://0.0.0.0:14550'   # incoming connection
+# peer = 'connect://127.0.0.1:14550'  # outgoing connection
+peer = 'listen://127.0.0.1:14550'   # incoming connection
```

Keep the listener on `127.0.0.1`. With `0.0.0.0`, any host that can reach the ground station can run commands on the air unit.

Update settings:
```
echo curl http://localhost/api/v1/set?video0.fps=120 > /dev/udp/localhost/14550
```

Update drone key:
```
file="echo $(base64 -w0 drone.key) | base64 -d > /etc/drone.key"
echo $file > /dev/udp/localhost/14550
```

Send the air unit's own key (`drone.key`), not the ground station's `gs.key`. A wrong key breaks the link that carries these commands, and recovery requires physical access to the air unit.

Update configuration:
```
file="echo $(base64 -w0 wfb.conf) | base64 -d > /etc/wfb.conf"
echo $file > /dev/udp/localhost/14550
```
