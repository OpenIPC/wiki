## HiSilicon boards

### Disable subsystems you don't use

Vendor kernel memory modules take around 5 megabytes of RAM (code with dynamic memory for buffers) and some of them are useless if you don't need specific functions like (OSD, motion detection, audio, H264/265/JPEG codecs)

| Feature                               | Modules                                                                                            | Size |
|---------------------------------------|----------------------------------------------------------------------------------------------------|------|
| Audio output                          | hi3516ev200_ao hi3516ev200_adec                                                                    |      |
| Audio input                           | hi3516ev200_ai hi3516ev200_aenc                                                                    |      |
| Audio support (both input and output) | hi3516ev200_acodec hi3516ev200_adec hi3516ev200_aenc hi3516ev200_ao hi3516ev200_ai hi3516ev200_aio |      |
| I2C sensor support                    | hi_sensor_i2c                                                                                      |      |
| SPI sensor support                    | hi_sensor_spi                                                                                      |      |
| PWM support                           | hi_pwm                                                                                             |      |
| Motion detection                      | hi3516ev200_ive                                                                                    |      |
| JPEG snapshots                        | hi3516ev200_jpege                                                                                  |      |
| H.264 codec support                   | hi3516ev200_h264e                                                                                  |      |
| H.265 codec support                   | hi3516ev200_h265e                                                                                  |      |
| OSD support                           | hi3516ev200_rgn  