# OpenIPC Wiki
[Table of Content](../README.md)

Remote syslog
-------------

Sometimes it is necessary to get logs from multiple OpenIPC devices remotely.

There is no difficulty in this, you need to configure the server by enabling the option to receive information and write its IP address in the call to the handler on the camera.

Will start with the camera. Add the option -R server-ip:514 with the address as shown in the example and reboot the device.

```bash
root@openipc-hi3516ev300:~# differ /etc/init.d/S01syslogd
```

```diff
--- /rom/etc/init.d/S01syslogd
+++ /etc/init.d/S01syslogd
@@ -3,7 +3,7 @@
 DAEMON="syslogd"
 PIDFILE="/var/run/$DAEMON.pid"
.
-SYSLOGD_ARGS="-C64 -t"
+SYSLOGD_ARGS="-C64 -t -R 172.19.32.17:514"
.
 # shellcheck source=/dev/null
 [ -r "/etc/default/$DAEMON" ] && . "/etc/default/$DAEMON"
```

In the server configuration file, write down the options of which port numbers and protocols to listen to it and make a restart of the service.

```diff
--- rsyslog.conf.orig 2022-09-30 16:41:52.081353630 +0300
+++ rsyslog.conf 2023-05-01 12:44:06.098032982 +0300
@@ -14,12 +14,12 @@
 #module(load="immark") # provides --MARK-- message capability
.
 # provides UDP syslog reception
-#module(load="imudp")
-#input(type="imudp" port="514")
+module(load="imudp")
+input(type="imudp" port="514")
.
 # provides TCP syslog reception
-#module(load="imtcp")
-#input(type="imtcp" port="514")
+module(load="imtcp")
+input(type="imtcp" port="514")
.
 # provides kernel logging support and enables non-kernel klog messages
 module(load="imklog" permitnonkernelselfacility="on")
```

Comments and additions welcome. Bye !
