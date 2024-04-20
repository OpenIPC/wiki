# Audio on FPV (Experimental)

## Overview
Everything has been tested using steamdeck (PC x86) and ssc338q-imx415 Anjoy board and choice of decoders and similar may reflect this.
Cúrrently there is ~200msec delay on audio stream, encoding settings may improve this (smaller packets, opus supports 20msec intervals), changing OS settings, changing to PCM/PCMA/PCMU.
Most interesting observation is that the audio/video is perfectly synced in recorded TS file. It indicates delay comes from the decoder chain in GSTreamer. If using mpegtsmux like I did, there is no need for decoding and parsing when using OPUS.

## Majestic and general settings
Audio settings (majestic.yaml):
cli -s .audio.enabled true
cli -s .audio.srate 8000 (goes up to 48000 but consumes more bandwidth)
Port can be set (default 5700) with:
cli -s .outgoing.audioPort 6200 (does it really work?)

## Quick wfb_ng setup
Example wfb_ng setup:
Drone:
wfb_tx -p -u 5700 -K /etc/drone.key -k 8 -n 12 -i 7669207 -f data wlan0
GS:
wfb_rx -p 0 -c 127.0.0.1 -u 5700 -K /etc/gs.key -i 7669207 wlan1

## Client side audio & video commands
GST command for opus 8000hz (sound only):
gst-launch-1.0 udpsrc port=5700 ! application/x-rtp, payload=98, encoding-name=OPUS ! rtpopusdepay ! opusdec ! audioconvert ! autoaudiosink sync=false

#Working sound, video & save!!!!
gst-launch-1.0 udpsrc port=5600 caps='application/x-rtp, media=(string)video, clock-rate=(int)90000, encoding-name=(string)H265' ! rtpjitterbuffer ! rtph265depay ! tee name=videoTee ! queue ! ts. udpsrc port=5700 ! application/x-rtp, payload=98, encoding-name=OPUS ! rtpjitterbuffer ! rtpopusdepay ! tee name=audioTee ! queue ! ts. mpegtsmux name=ts ! filesink location=/run/media/deck/170a3e7f-325f-4567-8580-0e01dda76973/video/record-$(date +%y%m%d_%H%M%S).tsn sync=true -e videoTee. ! vaapih265dec ! fpsdisplaysink fps-update-interval=250 video-sink=autovideosink text-overlay=true sync=false audioTee. ! opusdec ! audioconvert ! pulsesink sync=false

#Video & sound play
gst-launch-1.0 udpsrc port=5600 caps='application/x-rtp, media=(string)video, clock-rate=(int)90000, encoding-name=(string)H265' ! rtph265depay ! vaapih265dec ! autovideosink sync=false udpsrc port=5700 ! application/x-rtp, payload=98, encoding-name=OPUS ! rtpopusdepay ! opusdec ! audioconvert ! autoaudiosink sync=false

#Video & sound record
gst-launch-1.0 udpsrc port=5600 caps='application/x-rtp, media=(string)video, clock-rate=(int)90000, encoding-name=(string)H265' ! rtpjitterbuffer ! rtph265depay ! queue ! ts. udpsrc port=5700 ! application/x-rtp, payload=98, encoding-name=OPUS ! rtpjitterbuffer ! rtpopusdepay ! queue ! ts. mpegtsmux name=ts ! filesink location=/run/media/deck/170a3e7f-325f-4567-8580-0e01dda76973/video/record-$(date +%y%m%d_%H%M%S).tsn sync=true -e

FFPLAY command for opusn 8000hz (sound only):
ffplay.exe -fflags nobuffer -vn -flags low_delay -strict experimental -deadline realtime -framedrop -protocol_whitelist file,crypto,rtp,tcp,udp opus_audio.txt
opus_audio.txt (sdp)
v=0
o=StreamingServer 38990265062388 38990265062388 IN IP4 0.0.0.0
s=RTSP Session
c=IN IP4 0.0.0.0
t=0 0
a=range:npt=0-
m=video 5600 RTP/AVP 97
a=control:video
a=rtpmap:97 H265/90000
a=fmtp:97 profile-level-id=016000; packetization-mode=1; 
a=framerate:90
m=audio 5700 RTP/AVP 98
a=control:audio
a=rtpmap:98 opus/8000/1

# TODO & suggestions:
Optimize and adapt GST commands to different gs platforms.

### /etc/wfb.conf 
add audio specific parameters like port, fec, ...

### /usr/bin/wifibroadcast
add "if audio_enabled=true in datalink.conf then start wfb_tx ....."

