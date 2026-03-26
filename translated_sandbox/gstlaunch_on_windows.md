## Прием и отображение видео на windows

В "классическом режиме" (на камере стримит majestic, а NVR пересылает видеопоток на ПК, не забываем указать IP адрес ПК в wfb.conf регистратора) видео можно принимать в QGroundControl, Mission Planner и можно просто вывести в отдельном окне
без привязки к программам. Для этого нужно установить [GStreamer](https://gstreamer.freedesktop.org/download/) и запускать его на прием с некими параметрами, например:
```
C:\gstreamer\1.0\msvc_x86_64\bin\gst-launch-1.0.exe -v udpsrc port=5600 buffer-size=32768 ! application/x-rtp ! rtph265depay ! queue max-size-buffers=5 ! avdec_h265 ! videoconvert ! videoscale ! video/x-raw,width=1280,height=720,format=BGRA ! autovideosink sync=false
```

В данном примере размер видео изменяется до 1280x720. Для запуска видео с разрешением оригинального потока убираем из строки `videoscale ! ` и `width=1280,height=720,`.


![preview](https://github.com/OpenIPC/sandbox-fpv/raw/master/notes_files/Screenshot_2.png)

Для воспроизведения видео в окне Mission Planner нужно кликнуть правой кнопкой мыши  по его окну с горизонтом и выбрать `Video > Set GStreamer source`, внести строку параметров: `udpsrc port=5600 buffer-size=32768 ! application/x-rtp ! rtph265depay ! queue max-size-buffers=5 ! avdec_h265 ! videoconvert ! video/x-raw,format=BGRA ! appsink name=outsink`, нажать Ok. Строка сохранится для будущий применений.
