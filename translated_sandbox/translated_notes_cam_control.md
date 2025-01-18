### Camera control from the ground

As an experiment, [`mavfwd`](mavfwd) was supplemented with a parser for the mavlink RC_CHANNELS packet (RC channel values ​​sent from any RC link, such as from a ground station [(joystick)](https://github.com/whoim2/arduremote) via a [Mission Planner joystick](https://ardupilot.org/copter/docs/common-joystick.html)) or from a [connected](rcjoystick.md) joystick to the recorder.

It monitors changes in channels specified in the `--channels X` or `-c X` argument, counting from the first 4, and if any, calls the [`/root/channels.sh`](gk7205v200/root) script, passing two parameters (channel number and value) to it, and which performs the necessary operations. For example, `-c 1` will monitor only channel 5, and `-c 4` will monitor channels 5,6,7,8. In the current [example](gk7205v200/root/channels.sh) this is changing the camera mode (1080p@30fsp / 720p@5-fps) on channel 5, changing luminance to 7m (three-position switch) and ircut switch (polarizing filter). By default `-c 0`, i.e. disabled.

To install it on the camera, replace the standard mavfwd in `/usr/sbin/` with the [modified](mavfwd/mavfwd), and add the `-c` parameter to [`/usr/bin/telemetry`](gk7205v200/usr/bin/telemetry#L39). At the same time, you will be able to set the telemetry speed for communication with the flight controller higher than 115200, of course at your own risk!
Ideas and suggestions on this matter are welcome and can be expressed [here](https://t.me/+BMyMoolVOpkzNWUy).

upd 31.03.2023 Added recognition of mavlink 2 protocol.
