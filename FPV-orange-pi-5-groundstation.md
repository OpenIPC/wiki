Download Ubuntu Server ISO and flash to device  -- https://github.com/Joshua-Riek/ubuntu-rockchip

	sudo apt update
	sudo apt upgrade	

Go ahead and pull some packages we will need, too.

	sudo apt install dkms python3-all-dev fakeroot network-manager


-------------------------------------------------------------------------------------------

Gsteamer setup with MPP


Download and install gstreamer

	sudo apt-get install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5



Download and install rockchip mpp, rga, and gstreamer plugin from an included custom PPA, for hardware accelerated decoding.

	sudo apt install gstreamer1.0-rockchip1 librga-dev librga2 librockchip-mpp-dev librockchip-mpp1 librockchip-vpu0 libv4l-rkmpp rockchip-multimedia-config libgl4es libgl4es-dev libdri2to3



test with:

	gst-inspect-1.0 | grep 265

	gst-inspect-1.0 | grep mpp




-----------------------------------------------------------------------

rtl8812au drivers installation


enter the following line-by-line

	sudo bash -c "cat > /etc/modprobe.d/wfb.conf <<EOF
	# blacklist stock module
	blacklist 88XXau
	blacklist 8812au
	blacklist rtl8812au
	blacklist rtl88x2bs
	EOF"


	git clone -b v5.2.20 https://github.com/svpcom/rtl8812au.git
	cd rtl8812au/
	sudo ./dkms-install.sh


---------------------------------------------------------------------


reboot device 

TODO: or figure out how to load the driver without a full reboot. Try "modprobe rtl8812au"


----------------------------------------------------------------------

WFB-ng installation


find wifi device name using iwconfig and substitute it for $WLAN in the script install

	git clone -b stable https://github.com/svpcom/wfb-ng.git
	cd wfb-ng
	sudo ./scripts/install_gs.sh $WLAN

after install:

	sudo systemctl enable wifibroadcast


then

	sudo nano /etc/wifibroadcast.cfg

change the channel to match the vtx

change the region from 'BO' to '00' 




Copy drone.key from the wfb-ng directory to the vtx's /etc directory

example using scp, replace x.x.x.x with the camera's ip address

	scp drone.key root@x.x.x.x:/etc



Make sure gs.key was automatically put in /etc on the VRX side

	ls /etc/gs.key



---------------------------------------------------------------------


reboot device again


----------------------------------------------------------------------

test the connection:

on the groundstation run

 	sudo systemctl enable wifibroadcast@gs
	sudo systemctl start wifibroadcast@gs
	wfb-cli gs


Plug in the camera and watch the packets come in, xlost should stay near zero while xrecv should go up


-----------------------------------------------------------------


graphical environment for gstreamer playback


	sudo apt install xorg
	sudo apt install --no-install-recommends lightdm-gtk-greeter
	sudo apt install --no-install-recommends lightdm
	sudo apt install --no-install-recommends openbox
	

	sudo nano /etc/lightdm/lightdm.conf


insert:

		[Seat:*]
		autologin-user=ubuntu
		xserver-command = X -nocursor



------------------------------------------------------------------------------------------------------------------------------------

TODO:
At this point, reboot and you will have to login with a keyboard at least once, but after it will auto login the ubuntu user to an openbox session with no cursor


-----------------------------------------------------------------------------------------------------------------------------------



let's set the desktop wallpaper and write some startup scripts

	
	sudo apt install libimlib2-dev libx11-dev libxinerama-dev pkg-config make
	git clone https://github.com/himdel/hsetroot.git
	cd hsetroot
	make
	sudo make install



 Save your desired background image to /home/ubuntu/desktop.png


a script to set the display resolution to 1280x720


	sudo nano /home/ubuntu/setdisplay.sh


 insert:

	#/bin/bash
 	export DISPLAY=:0

 	if [[ $(xrandr | awk '/HDMI-1/ {print $2}') == "connected" ]]; then
        xrandr --output HDMI-1 --mode 1280x720
	fi
	if [[ $(xrandr | awk '/HDMI-2/ {print $2}') == "connected" ]]; then
        xrandr --output HDMI-2 --mode 1280x720
	fi
 
 	exit 0





a script to start/stop the video stream and save DVR to the ~/Videos directory

note: This script relies on a push button connected between pin 5 and GND. You will have to install one for this to work.


	sudo nano /home/ubuntu/dvr.sh


 insert:

	#!/bin/bash

	export DISPLAY=:0

	xset s off -dpms

	GPIO_PIN=5
	RUNNING=0
	gpio mode $GPIO_PIN up

	cd /home/ubuntu/Videos

	while true; do
        if [ $(gpio read $GPIO_PIN) -eq 0 ]; then
        if [ $RUNNING -eq 0 ]; then
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
        else
                kill $RUNNING
                RUNNING=0
        fi
        sleep 0.2
        fi
        sleep 0.1
	done



Finally:

	sudo nano /etc/xdg/openbox/autostart
 
add:	

	bash /home/ubuntu/setdisplay.sh

	hsetroot -cover /home/ubuntu/desktop.png &

	sudo /home/ubuntu/dvr.sh &




