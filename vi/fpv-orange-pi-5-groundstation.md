# OpenIPC Wiki
[Mục lục](../README.md)

Hướng dẫn từng bước để chạy Trạm Mặt đất trên Ubuntu 22.04
---------------------------------------------------------

<p align="center">
  <img src="https://github.com/OpenIPC/wiki/blob/master/images/fpv-logo.jpg?raw=true" alt="Logo"/>
</p>

Phiên bản video: - [OpenIPC - Chuẩn bị Trạm Mặt đất: Ubuntu + QGroundControl](https://www.youtube.com/watch?v=JMtRAsOm0Dc)

### Chuẩn bị
```
sudo apt update
```
```
sudo apt install dkms git python3-all-dev net-tools virtualenv fakeroot debhelper python3-twisted
 libpcap-dev python3-pyroute2 python3-future python3-configparser python3-all libsodium-dev
```

### Libsodium
```
git clone https://github.com/jedisct1/libsodium --branch stable
cd libsodium
./configure
make && make check
sudo make install
```

### Trình điều khiển card Wifi
```
git clone -b v5.2.20 https://github.com/svpcom/rtl8812au.git
cd rtl8812au/
sudo ./dkms-install.sh
```

### WFB-NG
```
git clone -b stable https://github.com/svpcom/wfb-ng.git
cd wfb-ng
sudo ./scripts/install_gs.sh wlan0
```

### Cấu hình kênh
```
vi /etc/wifibroadcast.cfg
```

### Khởi động WFB CLI
```
wfb-cli gs
```
###TRẠM MẶT ĐẤT ĐÃ SẴN SÀNG SỬ DỤNG###

### Khởi động, dừng, khởi động lại dịch vụ
```
systemctl status wifibroadcast@gs
systemctl stop wifibroadcast@gs
systemctl start wifibroadcast@gs
```

### Hướng dẫn Qground control

- https://docs.qgroundcontrol.com/master/en/getting_started/download_and_install.html

### Lấy nhật ký cuối cùng từ dịch vụ
```
journalctl -xu wifibroadcast@gs -n 100
```

### Các lệnh hữu ích
```
nmcli
ifconfig
iwconfig

```

<h3>* Hình ảnh được cài đặt sẵn hiện có sẵn ở đây -- https://github.com/JohnDGodwin/OpenIPC_Groundstations/releases/tag/OrangePi5Plus</h3>

***

Tải xuống Ubuntu Server ISO và flash vào thiết bị -- `https://github.com/Joshua-Riek/ubuntu-rockchip`

`sudo apt update`

`sudo apt nâng cấp`

Hãy tiếp tục và kéo một số gói chúng ta sẽ cần nữa.

`sudo apt install dkms python3-all-dev fakeroot cmake meson`

Đặt múi giờ cục bộ của hệ thống - thay thế vùng và thành phố bằng trường hợp sử dụng của bạn

`ln -sf /usr/share/zoneinfo/<vùng>/<thành phố> /etc/localtime`

đặt tên máy chủ

`sudo nano /etc/hostname`


***

Thiết lập Gsteamer với MPP


Tải xuống và cài đặt gstreamer

`sudo apt --no-install-recommends install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-gl`



Tải xuống và cài đặt plugin rockchip mpp, rga và gstreamer từ PPA tùy chỉnh đi kèm, để giải mã được tăng tốc phần cứng.

`sudo apt install gstreamer1.0-rockchip1 librga-dev librga2 librockchip-mpp-dev librockchip-mpp1 librockchip-vpu0 libv4l-rkmpp rockchip-multimedia-config libgl4es libgl4es-dev libdri2to3`



kiểm tra với:

`gst-inspect-1.0 | grep 265`

`gst-inspect-1.0 | grep mpp`



***

cài đặt trình điều khiển rtl8812au


nhập theo từng dòng sau

	sudo bash -c "cat > /etc/modprobe.d/wfb.conf <<EOF
	# danh sách đen mô-đun chứng khoán
	danh sách đen 88XXau
	danh sách đen 8812au
	danh sách đen rtl8812au
	danh sách đen rtl88x2bs
	EOF"



`git clone -b v5.2.20 https://github.com/svpcom/rtl8812au.git`

``cd rtl8812au/``

`sudo ./dkms-install.sh`


***


khởi động lại thiết bị

TODO: hoặc tìm ra cách tải trình điều khiển mà không cần khởi động lại hoàn toàn. Hãy thử "modprobe 88xxau"


***

cài đặt WFB-ng


tìm tên thiết bị wifi bằng iwconfig và thay thế nó cho $WLAN trong tập lệnh cài đặt

`git clone -b stable https://github.com/svpcom/wfb-ng.git`

`cd wfb-ng`

`sudo ./scripts/install_gs.sh $WLAN`


sau khi cài đặt:


`sudo systemctl enable wifibroadcast`


sau đó


`sudo nano /etc/wifibroadcast.cfg`


thay đổi kênh để phù hợp với vtx

thay đổi vùng từ 'BO' thành '00'




Sao chép drone.key từ thư mục wfb-ng vào thư mục /etc của vtx

ví dụ sử dụng scp, thay thế x.x.x.x bằng địa chỉ ip của camera

`scp drone.key root@x.x.x.x:/etc`


Đảm bảo gs.key đã được tự động đặt trong /etc ở phía VRX

`ls /etc/gs.key`



***


khởi động lại thiết bị một lần nữa


***

kiểm tra kết nối:

trên trạm mặt đất chạy

 `sudo systemctl enable wifibroadcast@gs`
 
`sudo systemctl start wifibroadcast@gs`

`wfb-cli gs`


Cắm camera vào và xem các gói dữ liệu đến, xlost nên ở gần 0 trong khi xrecv nên tăng lên


***


môi trường đồ họa để phát lại gstreamer


`sudo apt install --no-install-recommends xorg lightdm-gtk-greeter lightdm openbox`

Sau đó chỉnh sửa	

`sudo nano /etc/lightdm/lightdm.conf`


chèn:

	[Seat:*]
	autologin-user=ubuntu
	xserver-command = X -nocursor



***

TODO:
Tại thời điểm này, khởi động lại và bạn sẽ phải đăng nhập bằng bàn phím ít nhất một lần, nhưng sau đó nó sẽ tự động đăng nhập người dùng ubuntu vào phiên openbox mà không có con trỏ


***



hãy đặt hình nền máy tính để bàn và viết một số tập lệnh khởi động

	
`sudo apt install --no-install-recommends libimlib2-dev libx11-dev libxinerama-dev pkg-config make`

`git clone https://github.com/himdel/hsetroot.git`

`cd hsetroot`

`make`

`sudo make install`



Lưu hình nền mong muốn của bạn vào /home/ubuntu/desktop.png

Tạo một thư mục tập lệnh:

`mkdir /home/ubuntu/scripts`

một tập lệnh để đặt độ phân giải màn hình thành 1280x720


`sudo nano /home/ubuntu/scripts/setdisplay.sh`


 chèn:


	#/bin/bash
	xuất DISPLAY=:0

	#đặt độ phân giải màn hình mong muốn của bạn ở đây
	MODE=1280x720


	nếu [[ $(xrandr | awk '/HDMI-1/ {print $2}') == "đã kết nối" ]]; sau đó
	        xrandr --output HDMI-1 --mode $MODE
	fi
	nếu [[ $(xrandr | awk '/HDMI-2/ {print $2}') == "đã kết nối" ]]; sau đó
	        xrandr --output HDMI-2 --mode $MODE
	fi
	thoát 0




một tập lệnh để bắt đầu/dừng luồng video và lưu DVR vào thư mục ~/Video

lưu ý: Tập lệnh này dựa vào nút nhấn được kết nối giữa chân 5 và GND. Bạn sẽ phải cài đặt một cái để cái này hoạt động.

Tạo thư mục Video

`sudo mkdir /home/ubuntu/Videos`

Tạo tập lệnh

`sudo nano /home/ubuntu/scripts/dvr.sh`

 chèn:

	#!/bin/bash

	xuất DISPLAY=:0

	xset s tắt -dpms

	GPIO_PIN=5
	ĐANG CHẠY=0
	gpio mode $GPIO_PIN up

	cd /home/ubuntu/Videos

	trong khi đúng; làm
        nếu [ $(gpio read $GPIO_PIN) -eq 0 ]; sau đó
        nếu [ $RUNNING -eq 0 ]; sau đó
                current_date=$(date +'%m-%d-%Y_%H-%M-%S')
		
		gst-launch-1.0 -e \
                udpsrc port=5600 caps='application/x-rtp, media=(string)video, clock-rate=(int)90000, encoding-name=(string)H265' ! \
                rtph265depay ! \
                h265parse ! \
                tee name=t ! \
                queue ! \
                mppvideodec ! \
                videoconvert ! \
                autovideosink sync=false t. ! \
                queue ! \
                matroskamux ! \
                filesink location=record_${current_date}.mkv &
		
                RUNNING=$!
        khác
                kill $RUNNING
                RUNNING=0
        fi
        ngủ 0.2
        fi
        ngủ 0.1
	xong


Làm cho các tập lệnh có thể thực thi được với chmod +x.

`sudo chmod +x /home/ubuntu/scripts/dvr.sh /home/ubuntu/scripts/setdisplay.sh`


Cuối cùng:

`sudo nano /etc/xdg/openbox/autostart`
 
thêm vào:	

	bash /home/ubuntu/scripts/setdisplay.sh

	hsetroot -cover /home/ubuntu/desktop.png &

	sudo /home/ubuntu/scripts/dvr.sh &

Để hiển thị luồng video lên màn hình không viền, chúng ta thực hiện như sau.

`sudo nano /etc/xdg/openbox/rc.xml`

xác định vị trí dòng `<keepBorder>yes</keepBorder>` và thay thế bằng `<keepBorder>no</keepBorder>`

sau đó ở cuối tệp, thêm:

	<ứng dụng>
	     <ứng dụng class="*">
	         <trang trí>không</trang trí>
	    </ứng dụng>
	</ứng dụng>


***

Kéo DVR qua IP -- máy chủ phương tiện cơ bản sử dụng nginx


`sudo apt install nginx-light`


cấp quyền cho cây tệp lên thư mục video của chúng tôi


`sudo chmod o+x /home /home/ubuntu /home/ubuntu/Videos`



sao lưu trang tải mặc định và thay thế nó bằng trang của riêng chúng tôi

`sudo mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.old`

`sudo nano /etc/nginx/sites-available/default`

Thêm như sau, nhưng thay thế x.x.x.x bằng địa chỉ IP mạng của hệ thống của bạn:
	

	máy chủ {
		nghe 8080;
		nghe [::]:8080;

		server_name x.x.x.x;

		root /home/ubuntu/Videos;
  		autoindex trên;
	}


khởi động lại nginx để bắt đầu các thay đổi

`sudo systemctl restart nginx`

DVR của bạn hiện có sẵn để tải xuống tại x.x.x.x:8080 trong trình duyệt

***

Tự động chuyển mã DVR mkv sang hevc mp4

Nếu bạn muốn làm một chiếc bánh táo từ đầu, trước tiên bạn phải tạo ra vũ trụ -- Các gói gstreamer của chúng tôi không xử lý việc ghép mp4 h265 video và gói apt-get ffmpeg của chúng tôi không bao gồm tăng tốc phần cứng rkmpp.... vì vậy chúng tôi sẽ build ffmpeg với hỗ trợ mpp với sự trợ giúp của https://github.com/nyanmisaka/ffmpeg-rockchip

Chúng ta có thể làm điều này với 3 tập lệnh cài đặt đơn giản.

Đầu tiên, chúng tôi build MPP từ các nguồn, vì gói MPP hiện tại của chúng tôi cũ hơn.

Thứ hai, chúng tôi build RGA từ các nguồn vì lý do tương tự.

Thứ ba, chúng tôi build ffmpeg với hỗ trợ rkmpp và rkrga.

`sudo nano buildMPP.sh`

	mkdir -p ~/MPP && cd ~/MPP
	git clone -b jellyfin-mpp --depth=1 https://github.com/nyanmisaka/mpp.git rkmpp
	pushd rkmpp
	mkdir rkmpp_build
	pushd rkmpp_build
	cmake \
	    -DCMAKE_INSTALL_PREFIX=/usr \
	    -DCMAKE_BUILD_TYPE=Release \
	    -DBUILD_SHARED_LIBS=ON \
	    -DBUILD_TEST=OFF \
	    ..
	make -j $(nproc)
	sudo make install
 

`sudo nano buildRGA.sh`

	mkdir -p ~/RGA && cd ~/RGA
	git clone -b jellyfin-rga --depth=1 https://github.com/nyanmisaka/rk-mirrors.git rkrga
	meson setup rkrga rkrga_build \
	    --prefix=/usr \
	    --libdir=lib \
	    --buildtype=release \
	    --default-library=shared \
 	   -Dcpp_args=-fpermissive \
 	   -Dlibdrm=false \
 	   -Dlibrga_demo=false
	meson configure rkrga_build
	sudo ninja -C rkrga_build install

`sudo nano buildFFMPEG.sh`

	mkdir -p ~/ffmpeg && cd ~/ffmpeg
	git clone --depth=1 https://github.com/nyanmisaka/ffmpeg-rockchip.git ffmpeg
	cd ffmpeg
	./configure --prefix=/usr --enable-gpl --enable-version3 --enable-libdrm --enable-rkmpp --enable-rkrga
	make -j $(nproc)

	./ffmpeg -decoders | grep rkmpp
	./ffmpeg -encoders | grep rkmpp
	./ffmpeg -filters | grep rkrga

	sudo make install


Làm cho các tập lệnh có thể thực thi được 

`sudo chmod +x buildMPP.sh buildRGA.sh buildFFMPEG.sh`

Và chạy chúng từng cái một:

`./buildMPP.sh`

`./buildRGA.sh`

`./buildFFMPEG.sh`

Bây giờ chúng ta có thể sử dụng ffmpeg để chuyển mã phần cứng các tệp video mkv sang hevc mp4. Chúng ta có thể làm cho điều này tự động xảy ra vào cuối mỗi lần ghi bằng cách tăng cường tập lệnh dvr.sh. Mở tập lệnh dvr.sh trong thư mục /home/ubuntu/scripts của bạn, tìm dòng `kill $RUNNING` và thêm hai dòng sau bên dưới nó.

	sleep 0.2
 	ffmpeg -hwaccel rkmpp -i record_${current_date}.mkv -c:v hevc_rkmpp record_${current_date}.mp4

Toàn bộ tập lệnh sẽ trông như thế này:

	#!/bin/bash

	xuất DISPLAY=:0

	xset s tắt -dpms

	GPIO_PIN=5
	ĐANG CHẠY=0
	gpio mode $GPIO_PIN up

	cd /home/ubuntu/Videos

	trong khi đúng; làm
	nếu [ $(gpio read $GPIO_PIN) -eq 0 ]; sau đó
	nếu [ $RUNNING -eq 0 ]; sau đó
		current_date=$(date +'%m-%d-%Y_%H-%M-%S')
		
		gst-launch-1.0 -e \
		udpsrc port=5600 caps='application/x-rtp, media=(string)video, clock-rate=(int)90000, encoding-name=(string)H265' ! \
		rtph265depay ! \
		h265parse ! \
		tee name=t ! \
		queue ! \
		mppvideodec ! \
		videoconvert ! \
		autovideosink sync=false t. ! \
		queue ! \
		matroskamux ! \
		filesink location=record_${current_date}.mkv &
	
 		RUNNING=$!
	khác
		kill $RUNNING
		RUNNING=0
		sleep 0.2
		ffmpeg -hwaccel rkmpp -i record_${current_date}.mkv -c:v hevc_rkmpp record_${current_date}.mp4
	fi
	sleep 0.2
	fi
	sleep 0.1
	xong

 ***





