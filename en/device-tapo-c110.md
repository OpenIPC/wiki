# OpenIPC Wiki
[Table of Content](../README.md)

TP-Link Tapo C110
---

### GPIO
IRLed | WhiteLed | RedLed | GreenLed | Speaker | Reset | IRCut
-|-|-|-|-|-|-
GPIO14 | GPIO15 | GPIO46 | GPIO47 | GPIO61 | GPIO66 | GPIO78

```
curl http://localhost/api/v1/config --data-binary @- <<'EOF'
{
  "nightMode": {
    "irCutPin1": 78,
    "backlightPin": 14
  },
  "audio": {
    "speakerPin": 61
  }
}
EOF
```

---

### Wireless
```
fw_setenv wlandev ssw101b-ssc333-tapo-c110
fw_setenv wlanssid Router
fw_setenv wlanpass 12345678
```
