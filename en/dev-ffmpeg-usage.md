# OpenIPC Wiki
[Table of Content](index.md)

FFMPEG, RTSP and SRT examples
-----------------------------

```
# Copy from file to file
./ffmpeg -re -i z_input.mp4 -c copy z_output.mp4

# Grab from RTSP to file
./ffmpeg -re -i 'rtsp://172.19.32.179:554/stream=0' -c copy z_output.mp4

# Grab from SRT to file
./ffmpeg -re -i 'srt://172.19.32.189:12345?pkt_size=1316' -c copy z_output.mp4

# Grab from RTSP to MP4
./ffmpeg -re -i 'rtsp://172.19.32.179:554/stream=0' -c copy -listen 1 -seekable 1 -multiple_requests 1 -f mp4 http://localhost:8090


# Stream with capture desktop
./ffmpeg -video_size 1920x1080 -framerate 25 -f x11grab -i :0.0 -f mpegts 'srt://172.17.32.18:12345'

# Stream from file to SRT
./ffmpeg -re -i input.mp4 -c copy -f mpegts 'srt://172.17.32.18:12345'

# Stream from file to RTSP with loop
./ffmpeg -re -stream_loop -1 -i input.mp4 -f rtsp -rtsp_transport tcp 'rtsp://localhost:554/stream=0'

# Stream from file to SRT with re-encode
./ffmpeg -re -i input.mp4 -c:v libx264 -b:v 4000k -maxrate 4000k -bufsize 8000k -g 50 -f mpegts 'srt://172.17.32.18:12345'

# Stream to SRT and copy codec from ipcam with Majestic
./ffmpeg -re -i 'rtsp://172.19.32.179:554/stream=0' -c copy -f mpegts 'srt://172.17.32.18:12345'

# Stream low latency from ipcam with Majestic
./ffmpeg -re -fflags nobuffer -i 'rtsp://172.19.32.179:554/stream=0' -c copy -f mpegts 'srt://172.17.32.18:12345?mode=caller&transtype=live&latency=100'  


# Receiver, untested
ffplay 'srt://172.17.32.18:12345'
```
