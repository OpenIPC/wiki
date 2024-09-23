# XiongMai IPG-53H20AF

Mô-đun tự động lấy nét 2.0M
![device_ipg-53h20af](/images/device-53h20af.jpg)

## Phần cứng

| Hệ thống | Mô tả                          |
|--------|--------------------------------------|
| SoC    | HI3516CV100                          |
| Cảm biến | IMX322                               |
| Flash  | 16Mb (MX25L12835F)                   |

### Mạng
Ethernet chỉ hoạt động với các thông số này
```
    setenv phyaddru 1
    setenv phyaddrd 2
    setenv mdio_intf rmii
    saveenv
```

### GPIO

CẢNH BÁO!!! Trạng thái chân gpio động cơ không chính xác sau khi khởi động, cuộn dây động cơ có thể bị cháy, hãy khởi tạo với [những cái này](#kiểm-tra-động-cơ) càng sớm càng tốt hoặc rút đầu nối động cơ trước khi bật nguồn.

| Nr        | Mô tả   | Màu     |
|-----------|---------------|---------|
| 38        | irCut_1       |         |
| 39        | irCut_2       |         |
| 9         | Động cơ thu phóng A1 | Xanh lá cây |
| 48        | Động cơ thu phóng A2 | Cam    |
| 51        | Động cơ thu phóng B1 | Vàng    |
| 43        | Động cơ thu phóng B2 | Tím    |
| 52        | Động cơ lấy nét A1  | Đen     |
| 55        | Động cơ lấy nét A2  | Xanh lam |
| 53        | Động cơ lấy nét B1  | Trắng   |
| 54        | Động cơ lấy nét B2  | Đỏ      |

### Kiểm tra động cơ

Chuyển động rất chậm do thao tác gpio sysfs

```sh
#!/bin/sh

# kiểm tra động cơ cho ipg-53h20af

gpio_WT_Am=9
gpio_WT_Ap=48
gpio_WT_Bm=51
gpio_WT_Bp=43

gpio_FN_Am=52
gpio_FN_Ap=55
gpio_FN_Bm=53
gpio_FN_Bp=54


sleep_time=100

mux() {
  ipctool gpio mux $gpio_WT_Am
  ipctool gpio mux $gpio_WT_Ap
  ipctool gpio mux $gpio_WT_Bm
  ipctool gpio mux $gpio_WT_Bp
  ipctool gpio mux $gpio_FN_Am
  ipctool gpio mux $gpio_FN_Ap
  ipctool gpio mux $gpio_FN_Bp
  ipctool gpio mux $gpio_FN_Bm
}

unexport() {
  echo "$gpio_WT_Am" >/sys/class/gpio/unexport
  echo "$gpio_WT_Ap" >/sys/class/gpio/unexport
  echo "$gpio_WT_Bm" >/sys/class/gpio/unexport
  echo "$gpio_WT_Bp" >/sys/class/gpio/unexport
  echo "$gpio_FN_Am" >/sys/class/gpio/unexport
  echo "$gpio_FN_Ap" >/sys/class/gpio/unexport
  echo "$gpio_FN_Bp" >/sys/class/gpio/unexport
  echo "$gpio_FN_Bm" >/sys/class/gpio/unexport
}

export_() {
  echo "$gpio_WT_Am" >/sys/class/gpio/export
  echo "$gpio_WT_Ap" >/sys/class/gpio/export
  echo "$gpio_WT_Bm" >/sys/class/gpio/export
  echo "$gpio_WT_Bp" >/sys/class/gpio/export
  echo "$gpio_FN_Am" >/sys/class/gpio/export
  echo "$gpio_FN_Ap" >/sys/class/gpio/export
  echo "$gpio_FN_Bp" >/sys/class/gpio/export
  echo "$gpio_FN_Bm" >/sys/class/gpio/export
}

dir() {
  echo "out" >/sys/class/gpio/gpio$gpio_WT_Am/direction
  echo "out" >/sys/class/gpio/gpio$gpio_WT_Ap/direction
  echo "out" >/sys/class/gpio/gpio$gpio_WT_Bm/direction
  echo "out" >/sys/class/gpio/gpio$gpio_WT_Bp/direction
  echo "out" >/sys/class/gpio/gpio$gpio_FN_Am/direction
  echo "out" >/sys/class/gpio/gpio$gpio_FN_Ap/direction
  echo "out" >/sys/class/gpio/gpio$gpio_FN_Bp/direction
  echo "out" >/sys/class/gpio/gpio$gpio_FN_Bm/direction
}

init() {
  mux
  unexport
  export_
  dir
}

set_zero_FN() {
  echo "0" >/sys/class/gpio/gpio$gpio_FN_Am/value
  echo "0" >/sys/class/gpio/gpio$gpio_FN_Ap/value
  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bp/value
  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bm/value
}
set_zero_WT() {
  echo "0" >/sys/class/gpio/gpio$gpio_WT_Am/value
  echo "0" >/sys/class/gpio/gpio$gpio_WT_Ap/value
  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bm/value
  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bp/value
}
set_zero() {
  set_zero_FN
  set_zero_WT
}

far() {
#  echo "1" >/sys/class/gpio/gpio$gpio_FN_Ap/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Am/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bp/value
  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bm/value
  usleep $sleep_time
  
#  echo "1" >/sys/class/gpio/gpio$gpio_FN_Ap/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Am/value
  echo "1" >/sys/class/gpio/gpio$gpio_FN_Bp/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bm/value
  usleep $sleep_time

  echo "0" >/sys/class/gpio/gpio$gpio_FN_Ap/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Am/value
#  echo "1" >/sys/class/gpio/gpio$gpio_FN_Bp/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bm/value
  usleep $sleep_time

#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Ap/value
  echo "1" >/sys/class/gpio/gpio$gpio_FN_Am/value
#  echo "1" >/sys/class/gpio/gpio$gpio_FN_Bp/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bm/value
  usleep $sleep_time

#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Ap/value
#  echo "1" >/sys/class/gpio/gpio$gpio_FN_Am/value
  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bp/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bm/value
  usleep $sleep_time

#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Ap/value
#  echo "1" >/sys/class/gpio/gpio$gpio_FN_Am/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bp/value
  echo "1" >/sys/class/gpio/gpio$gpio_FN_Bm/value
  usleep $sleep_time

#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Ap/value
  echo "0" >/sys/class/gpio/gpio$gpio_FN_Am/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bp/value
#  echo "1" >/sys/class/gpio/gpio$gpio_FN_Bm/value
  usleep $sleep_time

  echo "1" >/sys/class/gpio/gpio$gpio_FN_Ap/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Am/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bp/value
#  echo "1" >/sys/class/gpio/gpio$gpio_FN_Bm/value
  usleep $sleep_time
}

near() {
#  echo "1" >/sys/class/gpio/gpio$gpio_FN_Ap/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Am/value
  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bp/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bm/value
  usleep $sleep_time
  
#  echo "1" >/sys/class/gpio/gpio$gpio_FN_Ap/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Am/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bp/value
  echo "1" >/sys/class/gpio/gpio$gpio_FN_Bm/value
  usleep $sleep_time

  echo "0" >/sys/class/gpio/gpio$gpio_FN_Ap/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Am/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bp/value
#  echo "1" >/sys/class/gpio/gpio$gpio_FN_Bm/value
  usleep $sleep_time

#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Ap/value
  echo "1" >/sys/class/gpio/gpio$gpio_FN_Am/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bp/value
#  echo "1" >/sys/class/gpio/gpio$gpio_FN_Bm/value
  usleep $sleep_time

#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Ap/value
#  echo "1" >/sys/class/gpio/gpio$gpio_FN_Am/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bp/value
  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bm/value
  usleep $sleep_time

#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Ap/value
#  echo "1" >/sys/class/gpio/gpio$gpio_FN_Am/value
  echo "1" >/sys/class/gpio/gpio$gpio_FN_Bp/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bm/value
  usleep $sleep_time

#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Ap/value
  echo "0" >/sys/class/gpio/gpio$gpio_FN_Am/value
#  echo "1" >/sys/class/gpio/gpio$gpio_FN_Bp/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bm/value
  usleep $sleep_time

  echo "1" >/sys/class/gpio/gpio$gpio_FN_Ap/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Am/value
#  echo "1" >/sys/class/gpio/gpio$gpio_FN_Bp/value
#  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bm/value
  usleep $sleep_time
}

tele() {
#  echo "1" >/sys/class/gpio/gpio$gpio_WT_Ap/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Am/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bp/value
  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bm/value
  usleep $sleep_time
  
#  echo "1" >/sys/class/gpio/gpio$gpio_WT_Ap/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Am/value
  echo "1" >/sys/class/gpio/gpio$gpio_WT_Bp/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bm/value
  usleep $sleep_time

  echo "0" >/sys/class/gpio/gpio$gpio_WT_Ap/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Am/value
#  echo "1" >/sys/class/gpio/gpio$gpio_WT_Bp/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bm/value
  usleep $sleep_time

#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Ap/value
  echo "1" >/sys/class/gpio/gpio$gpio_WT_Am/value
#  echo "1" >/sys/class/gpio/gpio$gpio_WT_Bp/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bm/value
  usleep $sleep_time

#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Ap/value
#  echo "1" >/sys/class/gpio/gpio$gpio_WT_Am/value
  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bp/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bm/value
  usleep $sleep_time

#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Ap/value
#  echo "1" >/sys/class/gpio/gpio$gpio_WT_Am/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bp/value
  echo "1" >/sys/class/gpio/gpio$gpio_WT_Bm/value
  usleep $sleep_time

#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Ap/value
  echo "0" >/sys/class/gpio/gpio$gpio_WT_Am/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bp/value
#  echo "1" >/sys/class/gpio/gpio$gpio_WT_Bm/value
  usleep $sleep_time

  echo "1" >/sys/class/gpio/gpio$gpio_WT_Ap/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Am/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bp/value
#  echo "1" >/sys/class/gpio/gpio$gpio_WT_Bm/value
  usleep $sleep_time

}

wide() {
#  echo "1" >/sys/class/gpio/gpio$gpio_WT_Ap/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Am/value
  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bp/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bm/value
  usleep $sleep_time
  
#  echo "1" >/sys/class/gpio/gpio$gpio_WT_Ap/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Am/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bp/value
  echo "1" >/sys/class/gpio/gpio$gpio_WT_Bm/value
  usleep $sleep_time

  echo "0" >/sys/class/gpio/gpio$gpio_WT_Ap/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Am/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bp/value
#  echo "1" >/sys/class/gpio/gpio$gpio_WT_Bm/value
  usleep $sleep_time

#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Ap/value
  echo "1" >/sys/class/gpio/gpio$gpio_WT_Am/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bp/value
#  echo "1" >/sys/class/gpio/gpio$gpio_WT_Bm/value
  usleep $sleep_time

#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Ap/value
#  echo "1" >/sys/class/gpio/gpio$gpio_WT_Am/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bp/value
  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bm/value
  usleep $sleep_time

#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Ap/value
#  echo "1" >/sys/class/gpio/gpio$gpio_WT_Am/value
  echo "1" >/sys/class/gpio/gpio$gpio_WT_Bp/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bm/value
  usleep $sleep_time

#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Ap/value
  echo "0" >/sys/class/gpio/gpio$gpio_WT_Am/value
#  echo "1" >/sys/class/gpio/gpio$gpio_WT_Bp/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bm/value
  usleep $sleep_time

  echo "1" >/sys/class/gpio/gpio$gpio_WT_Ap/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Am/value
#  echo "1" >/sys/class/gpio/gpio$gpio_WT_Bp/value
#  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bm/value
  usleep $sleep_time
}

if [ $# -lt 1 ]; then
  echo "cách sử dụng: ./motor <hướng> [bước]"
  echo "        -i khởi tạo gpio"
  echo "        -f xa"
  echo "        -n gần"
  echo "        -w rộng"
  echo "        -t tele"
  
  exit
fi

if [ $1 = "-i" ]; then
  init 
  set_zero
  exit
fi

if [ $1 = "-f" ]; then
  direction="far"
  echo "1" >/sys/class/gpio/gpio$gpio_FN_Ap/value
elif [ $1 = "-w" ]; then
  direction="wide"
  echo "1" >/sys/class/gpio/gpio$gpio_WT_Ap/value
elif [ $1 = "-n" ]; then
  direction="near"
  echo "1" >/sys/class/gpio/gpio$gpio_FN_Ap/value
elif [ $1 = "-t" ]; then
  direction="tele"
  echo "1" >/sys/class/gpio/gpio$gpio_WT_Ap/value
fi

if [ $# -eq 2 ]; then
  max=$2
else
  max=10
fi

echo $max

i=0
while [ $i -lt $max ]
do
  $direction >/dev/null
  true $(( i++ ))
done


# chuyển sang bước đầy đủ và vô hiệu hóa động cơ
if [ $1 = "-f" ]; then
  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bm/value
  usleep $sleep_time
  set_zero_FN
elif [ $1 = "-w" ]; then
  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bp/value
  usleep $sleep_time
  set_zero_WT
elif [ $1 = "-n" ]; then
  echo "0" >/sys/class/gpio/gpio$gpio_FN_Bp/value
  usleep $sleep_time
  set_zero_FN
elif [ $1 = "-t" ]; then
  echo "0" >/sys/class/gpio/gpio$gpio_WT_Bm/value
  usleep $sleep_time
  set_zero_WT
fi
```