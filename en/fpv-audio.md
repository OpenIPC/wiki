## Audio on FPV

### Overview
Everything has been tested using steamdeck (PC x86) and ssc338q-imx415 Anjoy board and choice of decoders and similar may reflect this.
Currently there is ~50-100ms latency, much imprroved from first trials ~200msec. The improvement comes mainy from using "pipewiresink" on client side, but it requires you to have a working pipewire audio backend on your GS. It could also be possible to use jack audio backend for similar or better result.
There was also an update to use a mixed RTP video/audio stream on the output port (standard 5600) which neccesitates a different approach for the gst pipeline (see below). The pipelines need to be disconnected in order to not block each other.
A small warning; if enabling audio and not adapting your pipeline to sort out payload=97 (H265) the RTP payload=98 will cause visual artifacts in your video. rtpjitterbuffer will help to manage out of order packets (will not work without it).
Video using OPUS 16000 OPUS samplerate: https://youtu.be/Z0KxSS24j7o

### Majestic and general settings
Audio settings (majestic.yaml):
```
cli -s .audio.enabled true
cli -s .audio.srate 8000 (8000 pretty crap, 16000 usable and 48000 really good)
```

### Working sound, video & save to file
```
gst-launch-1.0 udpsrc port=5600 ! tee name=videoTee ! queue ! tee name=t t. ! queue ! application/x-rtp,payload=97, clock-rate=90000, encoding-name=H265 ! rtpjitterbuffer latency=20 ! rtph265depay ! mpegtsmux name=ts ! filesink location=/run/media/deck/170a3e7f-325f-4567-8580-0e01dda76973/video/record-$(date +%y%m%d_%H%M%S).tsn sync=false t. ! queue leaky=1 ! tee name=audioTee ! queue ! application/x-rtp, payload=98, encoding-name=OPUS ! rtpjitterbuffer latency=22 do-lost=true drop-on-latency=true ! rtpopusdepay ! ts. audioTee. ! queue leaky=1 ! application/x-rtp, payload=98, encoding-name=OPUS ! rtpjitterbuffer latency=22 ! rtpopusdepay ! opusdec ! audioconvert ! audioresample ! pipewiresink blocksize=128 mode=render processing-deadline=0 sync=false async=false videoTee. ! queue ! application/x-rtp,payload=97, clock-rate=90000, encoding-name=H265 ! rtpjitterbuffer latency=20 ! rtph265depay ! vaapih265dec ! fpsdisplaysink fps-update-interval=200 video-sink=xvimagesink sync=false
```
Nothing more to do, it just works :-)
