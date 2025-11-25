## Добавляем плавности видео
На режимах 1080p@30fps заметно легкое подергивание видео, а при замедленной съемке таймера видно что картинка замирает на какое то время и далее обновляется. Это происходит из за неравномерности потока, который резко возрастает на ключевых кадрах.
Исправить это можно, перенастроив на камере два параметра энкодера.
Спасибо за проделанную работу TipoMan и widgetii!

Нам нужно положить файл [gkrcparams](https://github.com/OpenIPC/sandbox-fpv/raw/master/user_TipoMan/gkrcparams) в /usr/sbin, дать права на выполнение `chmod +x /usr/sbin/gkrcparams` и вставить запуск его после старта majestic в /etc/init.d/S95majestic:

```
	start-stop-daemon -b -m -S -q -p "$PIDFILE" -x "/usr/bin/$DAEMON" -- $DAEMON_ARGS
	sleep 1                        <=== ЭТО ВСТАВИТЬ
	gkrcparams --MaxQp 30 --MaxI 2 <=== ЭТО ВСТАВИТЬ
	status=$?
```
После перезапуска картинка должна стать плавной. Прочие настройки в majestic.yaml для режима mcs1:

```
video0:
  enabled: true
  bitrate: 7168
  codec: h265
  rcMode: cbr
  gopSize: 1.0
  size: 1920x1080
```

Если же картинка все равно иногда подергивается, придется изменить mcs на 3 в `/etc/wfb.conf` потеряв в дальности либо уменьшать битрейт.
