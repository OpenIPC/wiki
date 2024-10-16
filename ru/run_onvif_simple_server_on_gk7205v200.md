

После нескольких попыток запуска onvif_simple_server на камере с процессором gk7205v200 и получением ошибки 401 Unauthorized был придуман следующий костыль:

#### Запускаю дополнительный httpd сервер
```
httpd -p 8080 -h /var/www -c /etc/httpdonvif.conf
```

#### Содержимое httpdonvif.conf примерно такое:
```
A:*
/cgi-bin:*:*
```


#### В /etc/onvif.config прописываю следующее (пример):
```
# General
model=OpenIPC ShowMe
manufacturer=OpenIPC
firmware_ver=2.3.7.x
hardware_id=openipc-gk7205v200
serial_num=OPENIPC.ORG
ifs=lo
port=85
scope=onvif://www.onvif.org/Profile/Streaming
user=viewer
password=123456

#Advanced options
#adv_fault_if_unknown=1
#adv_synology_nvr=0

#Profile 0
name=Profile_0
width=1920
height=1080
url=rtsp://127.0.0.1/stream=0
snapurl=http://127.0.0.1/image.jpg
type=H264

#Profile 1
name=Profile_1
width=640
height=480
url=rtsp://127.0.0.1/stream=0
snapurl=http://127.0.0.1/image.jpg?width=640&height=480
type=H264

#PTZ
ptz=1
move_left=motor gk7205v200 1 0
move_right=motor gk7205v200 -1 0
move_up=motor gk7205v200 0 1
move_down=motor gk7205v200 0 -1
#move_stop=motor -d s
#move_preset=xm-kmotor -d t
```

#### Onvif работает.
