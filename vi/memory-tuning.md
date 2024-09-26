# Wiki OpenIPC
[Mục lục](../README.md)

Bo mạch HiSilicon
----------------

### Vô hiệu hóa các hệ thống con bạn không sử dụng

Các mô-đun kernel của nhà cung cấp chiếm khoảng 5 megabyte RAM (mã có bộ nhớ động dành cho bộ đệm) và một số trong số chúng khá vô dụng nếu bạn cần chức năng cụ thể như OSD, phát hiện chuyển động, hỗ trợ âm thanh hoặc codec H.264/H.265/JPEG.

| Tính năng                             | Mô-đun                                                                                                  | Kích thước |
|------------------------------------------|----------------------------------------------------------------------------------------------------------|-----------|
| Đầu ra âm thanh                          | hi3516ev200_ao, hi3516ev200_adec                                                                        |           |
| Đầu vào âm thanh                          | hi3516ev200_ai, hi3516ev200_aenc                                                                        |           |
| Hỗ trợ âm thanh (cả đầu vào và đầu ra) | hi3516ev200_acodec, hi3516ev200_adec, hi3516ev200_aenc, hi3516ev200_ao, hi3516ev200_ai, hi3516ev200_aio |           |
| Hỗ trợ cảm biến I2C                       | hi_sensor_i2c                                                                                           |           |
| Hỗ trợ cảm biến SPI                       | hi_sensor_spi                                                                                           |           |
| Hỗ trợ PWM                                | hi_pwm                                                                                                  |           |
| Phát hiện chuyển động                     | hi3516ev200_ive                                                                                         |           |
| Ảnh chụp nhanh JPEG                       | hi3516ev200_jpege                                                                                       |           |
| Hỗ trợ codec H.264                        | hi3516ev200_h264e                                                                                       |           |
| Hỗ trợ codec H.265                        | hi3516ev200_h265e                                                                                       |           |
| Hỗ trợ OSD                                | hi3516ev200_rgn                                                                                         |           |


