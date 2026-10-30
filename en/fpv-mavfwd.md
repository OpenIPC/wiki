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

Keep the listener on `127.0.0.1`. With `0.0.0.0`, any host that can reach the ground station can run commands on the air unit. This bind is local-only: ground control software on another machine (QGroundControl, Mission Planner) no longer receives telemetry through the ground station. To allow that, bind to the address of a trusted interface or forward the port with a UDP tunnel such as `socat` on both ends. MAVLink is UDP, so `ssh -L` alone does not carry it.

The examples below use `base64 -w0` from GNU coreutils and are intended for a Linux ground station.

Update settings:
```
echo curl http://localhost/api/v1/set?video0.fps=120 > /dev/udp/localhost/14550
```

Update drone key:
```
[ -s gs.key ] || { echo "gs.key not found"; exit 1; }
file="echo $(base64 -w0 gs.key) | base64 -d > /etc/drone.key"
echo $file > /dev/udp/localhost/14550
```

The first line stops the script if the file is missing or empty. Otherwise, the air unit would receive an empty key, the link would drop, and recovery would require physical access. `gs.key` is the key the ground station already uses (installed as `/etc/gs.key`). The two files written by one `wfb_keygen` run share the same secret, so either one works on the air unit as `/etc/drone.key`. A key from a different pair breaks the link that carries these commands.

Update configuration:
```
[ -s wfb.conf ] || { echo "wfb.conf not found"; exit 1; }
file="echo $(base64 -w0 wfb.conf) | base64 -d > /etc/wfb.conf"
echo $file > /dev/udp/localhost/14550
```
