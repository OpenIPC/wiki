## OpenIPC Wiki
[Mục lục](../README.md)

Ví dụ về FFMPEG, RTSP và SRT
-----------------------------

```bash
# Sao chép từ tệp này sang tệp khác
./ffmpeg -re -i z_input.mp4 -c copy z_output.mp4

# Ghi từ RTSP vào tệp
./ffmpeg -re -i 'rtsp://172.19.32.179:554/stream=0' -c copy z_output.mp4

# Ghi từ SRT vào tệp
./ffmpeg -re -i 'srt://172.19.32.189:12345?pkt_size=1316' -c copy z_output.mp4

# Ghi từ RTSP sang MP4
./ffmpeg -re -i 'rtsp://172.19.32.179:554/stream=0' -c copy -listen 1 -seekable 1 -multiple_requests 1 -f mp4 http://localhost:8090


# Phát trực tiếp với quay phim màn hình
./ffmpeg -video_size 1920x1080 -framerate 25 -f x11grab -i :0.0 -f mpegts 'srt://172.17.32.18:12345'

# Phát trực tiếp từ tệp sang SRT
./ffmpeg -re -i input.mp4 -c copy -f mpegts 'srt://172.17.32.18:12345'

# Phát trực tiếp từ tệp sang RTSP với lặp lại
./ffmpeg -re -stream_loop -1 -i input.mp4 -f rtsp -rtsp_transport tcp 'rtsp://localhost:554/stream=0'

# Phát trực tiếp từ tệp sang SRT với mã hóa lại
./ffmpeg -re -i input.mp4 -c:v libx264 -b:v 4000k -maxrate 4000k -bufsize 8000k -g 50 -f mpegts 'srt://172.17.32.18:12345'

# Phát trực tiếp sang SRT và sao chép codec từ ipcam với Majestic
./ffmpeg -re -i 'rtsp://172.19.32.179:554/stream=0' -c copy -f mpegts 'srt://172.17.32.18:12345'

# Phát trực tiếp độ trễ thấp từ ipcam với Majestic
./ffmpeg -re -fflags nobuffer -i 'rtsp://172.19.32.179:554/stream=0' -c copy -f mpegts 'srt://172.17.32.18:12345?mode=caller&transtype=live&latency=100'  


# Bộ nhận, chưa được kiểm tra
ffplay 'srt://172.17.32.18:12345'
```

