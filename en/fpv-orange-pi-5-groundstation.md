Download Ubuntu Server ISO and flash to device  -- https://github.com/Joshua-Riek/ubuntu-rockchip

`sudo apt update`

`sudo apt upgrade`

Go ahead and pull some packages we will need, too.

`sudo apt install dkms python3-all-dev fakeroot network-manager cmake meson`

Set system local timezone - replace region and city with your usecase

`ln -sf /usr/share/zoneinfo/<region>/<city> /etc/localtime`

set hostname

`sudo nano /etc/hostname`


***

Gsteamer setup with MPP


Download and install gstreamer

`sudo apt-get install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5`



Download and install rockchip mpp, rga, and gstreamer plugin from an included custom PPA, for hardware accelerated decoding.

`sudo apt install gstreamer1.0-rockchip1 librga-dev librga2 librockchip-mpp-dev librockchip-mpp1 librockchip-vpu0 libv4l-rkmpp rockchip-multimedia-config libgl4es libgl4es-dev libdri2to3`



test with:

`gst-inspect-1.0 | grep 265`

`gst-inspect-1.0 | grep mpp`



***

rtl8812au drivers installation


enter the following line-by-line

	sudo bash -c "cat > /etc/modprobe.d/wfb.conf <<EOF
	# blacklist stock module
	blacklist 88XXau
	blacklist 8812au
	blacklist rtl8812au
	blacklist rtl88x2bs
	EOF"



`git clone -b v5.2.20 https://github.com/svpcom/rtl8812au.git`

``cd rtl8812au/``

`sudo ./dkms-install.sh`


***


reboot device 

TODO: or figure out how to load the driver without a full reboot. Try "modprobe 88xxau"


***

WFB-ng installation


find wifi device name using iwconfig and substitute it for $WLAN in the script install

`git clone -b stable https://github.com/svpcom/wfb-ng.git`

`cd wfb-ng`

`sudo ./scripts/install_gs.sh $WLAN`


after install:


`sudo systemctl enable wifibroadcast`


then


`sudo nano /etc/wifibroadcast.cfg`


change the channel to match the vtx

change the region from 'BO' to '00' 




Copy drone.key from the wfb-ng directory to the vtx's /etc directory

example using scp, replace x.x.x.x with the camera's ip address

`scp drone.key root@x.x.x.x:/etc`


Make sure gs.key was automatically put in /etc on the VRX side

`ls /etc/gs.key`



***


reboot device again


***

test the connection:

on the groundstation run

 `sudo systemctl enable wifibroadcast@gs`
 
`sudo systemctl start wifibroadcast@gs`

`wfb-cli gs`


Plug in the camera and watch the packets come in, xlost should stay near zero while xrecv should go up


***


graphical environment for gstreamer playback


`sudo apt install xorg`

`sudo apt install --no-install-recommends lightdm-gtk-greeter lightdm openbox`

Then edit	

`sudo nano /etc/lightdm/lightdm.conf`


insert:

	[Seat:*]
	autologin-user=ubuntu
	xserver-command = X -nocursor



***

TODO:
At this point, reboot and you will have to login with a keyboard at least once, but after it will auto login the ubuntu user to an openbox session with no cursor


***



let's set the desktop wallpaper and write some startup scripts

	
`sudo apt install libimlib2-dev libx11-dev libxinerama-dev pkg-config make`

`git clone https://github.com/himdel/hsetroot.git`

`cd hsetroot`

`make`

`sudo make install`



Save your desired background image to /home/ubuntu/desktop.png


a script to set the display resolution to 1280x720


`sudo nano /home/ubuntu/setdisplay.sh`


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

Make Videos directory

`sudo mkdir /home/ubuntu/Videos`

Make the script

`sudo nano /home/ubuntu/dvr.sh`

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


Make the scripts executable with chmod +x.

Finally:

`sudo nano /etc/xdg/openbox/autostart`
 
add:	

	bash /home/ubuntu/setdisplay.sh

	hsetroot -cover /home/ubuntu/desktop.png &

	sudo /home/ubuntu/dvr.sh &

To display the video stream to the screen borderless we do the following.

`sudo nano /etc/xdg/openbox/rc.xml`

locate the line `<keepBorder>yes</keepBorder>` and replace it with `<keepBorder>no</keepBorder>`

then at the end of the file add:

	<applications>
	     <application class="*">
	         <decor>no</decor>
	    </application>
	</applications>


***

Pulling the DVR over IP -- a basic media server using nginx


`sudo apt install nginx-light`


give permissions up the file tree to our video directory


`sudo chmod o+x /home /home/ubuntu /home/ubuntu/Videos`



backup the default loading page and replace it with our own

`sudo mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.old`

`sudo nano /etc/nginx/sites-available/default`

Add the following, but replace x.x.x.x with your system's network IP address:
	

	server {
		listen 8080;
		listen [::]:8080;

		server_name x.x.x.x;

		root /home/ubuntu/Videos;
  		autoindex on;
	}


restart nginx to initate the changes

`sudo systemctl restart nginx`

Your DVR is now available for download at x.x.x.x:8080 in a browser

***

Automatic transcoding of the mkv DVR to hevc mp4

If you wish to make an apple pie from scratch, you must first invent the universe -- Our gstreamer packages don't handle muxing of mp4 h265 video, and our apt-get ffmpeg package does not include rkmpp hardware acceleration.... so we're going to build ffmpeg with mpp support with the help of https://github.com/nyanmisaka/ffmpeg-rockchip

We can do this with 3 simple installation scripts.

First we build MPP from sources, as our current MPP package is older.

Second we build RGA from sources for the same reason.

Third we build ffmpeg with rkmpp and rkrga support.

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


Make the scripts executable 

`sudo chmod +x buildMPP.sh buildRGA.sh buildFFMPEG.sh`

And run them one at a time:

`./buildMPP.sh`

`./buildRGA.sh`

`./buildFFMPEG.sh`

Now we can use ffmpeg to hardware transcode the mkv video files to hevc mp4. We can have this automatically happen at the end of each recording by augmenting the dvr.sh script. Open the dvr.sh script in your /home/ubuntu directory, find the line `kill $RUNNING` and add the following two lines below it.

	sleep 0.2
 	ffmpeg -hwaccel rkmpp -i record_${current_date}.mkv -c:v hevc_rkmpp record_${current_date}.mp4

The full script should look like this:

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
		sleep 0.2
		ffmpeg -hwaccel rkmpp -i record_${current_date}.mkv -c:v hevc_rkmpp record_${current_date}.mp4
	fi
	sleep 0.2
	fi
	sleep 0.1
	done

 ***
