# Sound setup & tweaks

### Setup

Initial setup
```
cli -s .audio.enabled true
cli -s .audio.codec opus
cli -s .audio.srate 48000
cli -s .audio.volume 40
cli -s .audio.outputEnabled true
cli -s .audio.outputVolume 80
cli -s .audio.speakerPin 64
```
### Tweaks

### Usefull things
1. Play file to camera`s speaker remotly (test.pcm - 48k pcm file)
```
curl -u root:1qaz2WSX --data-binary @test.pcm http://192.168.70.232/play_audio
```
2. Play file to camera`s speaker from camera (usefull for debugging purposes, e.g. testing motion detection)

first, copy file to the camera
```
scp ready_48k.pcm root:12345@192.168.1.10:/usr/lib/sounds/ready_48k.pcm
```
then play it
```
curl --data-binary @/usr/lib/sounds/ready_48k.pcm http://localhost/play_audio
```
note: access to web inerface via localhost don`t need an authorization

3. Listen audio from camera`s microphone on PC
```
ffplay -ar 8000 -ac 1 -f s16le http://root:1qaz2WSX@192.168.70.232/audio.pcm
```
