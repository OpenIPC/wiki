# OpenIPC Wiki
[Mục lục](../README.md)

Syslog từ xa
-------------

Đôi khi cần phải lấy nhật ký từ nhiều thiết bị OpenIPC từ xa.

Điều này không có gì khó khăn, bạn cần cấu hình máy chủ bằng cách bật tùy chọn nhận thông tin và ghi địa chỉ IP của nó trong lệnh gọi đến trình xử lý trên camera.

Sẽ bắt đầu với camera. Thêm tùy chọn -R địa chỉ-ip-máy-chủ:514 với địa chỉ như được hiển thị trong ví dụ và khởi động lại thiết bị.

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

Trong tệp cấu hình máy chủ, hãy ghi lại các tùy chọn về số cổng và giao thức nào để lắng nghe nó và khởi động lại dịch vụ.

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

Hoan nghênh ý kiến ​​và bổ sung. Tạm biệt !

