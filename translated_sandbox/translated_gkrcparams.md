## Adding Smoothness to Video
In 1080p@30fps modes, slight video twitching is noticeable, and when shooting in slow motion, the timer shows that the picture freezes for some time and then refreshes. This is due to the unevenness of the stream, which increases sharply at key frames.
This can be corrected by reconfiguring two encoder parameters on the camera.
Thanks for the work done TipoMan and widgetii!

We need to put the [gkrcparams](https://github.com/OpenIPC/sandbox-fpv/raw/master/user_TipoMan/gkrcparams) file in /usr/sbin, give it execute permissions `chmod +x /usr/sbin/gkrcparams` and insert its launch after majestic startup in /etc/init.d/S95majestic:

```
	start-stop-daemon -b -m -S -q -p "$PIDFILE" -x "/usr/bin/$DAEMON" -- $DAEMON_ARGS
	sleep 1 <=== INSERT THIS
	gkrcparams --MaxQp 30 --MaxI 2 <=== INSERT THIS
	status=$?
```
After restarting the picture should become smooth. Other settings in majestic.yaml for mcs1 mode:

```
video0:
  enabled: true
  bitrate: 7168
  codec: h265
  rcMode: cbr
  gopSize: 1.0
  size: 1920x1080
```

If the picture still twitches sometimes, you will have to change mcs to 3 in `/etc/wfb.conf`, losing range, or reduce the bitrate.