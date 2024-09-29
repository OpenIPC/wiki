# OpenIPC Wiki
[Table of Content](../README.md)

OpenIPC FPV - mavfwd tool
-------------------------

The idea is to use telemetry ports for a remote setup:
```
echo cli -s .video0.fps 120 | nc -uq0 localhost 14650
```

Update drone key:
```
file="echo $(cat gs.key | base64) | base64 -d > /etc/drone.key"
echo $file | nc -uq0 localhost 14650
```

Update configuration:
```
file="echo $(cat wfb.conf | base64) | base64 -d > /etc/wfb.conf"
echo $file | nc -uq0 localhost 14650
```