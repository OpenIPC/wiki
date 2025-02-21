## Receiving and displaying video on windows

In "classic mode" (majestic streams on the camera, and the NVR sends the video stream to the PC, do not forget to specify the IP address of the PC in the wfb.conf of the recorder) video can be received in QGroundControl, Mission Planner and can be simply displayed in a separate window
without being tied to programs. To do this, you need to install [GStreamer](https://gstreamer.freedesktop.org/download/) and launch it to receive with some parameters, for example:
```
C:\gstreamer\1.0\msvc_x86_64\bin\gst-launch-1.0.exe -v udpsrc port=5600 buffer-size=32768 ! application/x-rtp! rtph265depay! queue max-size-buffers=5 ! avdec_h265 ! videoconvert! videoscale! video/x-raw,width=1280,height=720,format=BGRA ! autovideosink sync=false
```

In this example, the video size is changed to 1280x720. To start the video with the resolution of the original stream, remove `videoscale ! ` and `width=1280,height=720,` from the line.


![preview](https://github.com/OpenIPC/sandbox-fpv/raw/master/notes_files/Screenshot_2.png)

To play a video in the Mission Planner window, right-click on its window with the horizon and select `Video > Set GStreamer source`, enter the parameter line: `udpsrc port=5600 buffer-size=32768 ! application/x-rtp ! rtph265depay ! queue max-size-buffers=5 ! avdec_h265 ! videoconvert ! video/x-raw,format=BGRA ! appsink name=outsink`, click Ok. The line will be saved for future use.