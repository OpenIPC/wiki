## Wiki OpenIPC
[Mục lục](../README.md)

Bảng mạch HiSilicon
----------------

### Vô hiệu hóa các hệ thống con bạn không sử dụng

Các mô-đun kernel của nhà cung cấp chiếm khoảng 5 megabyte RAM (mã có bộ nhớ động cho bộ đệm) và một số trong số chúng khá vô dụng nếu bạn cần chức năng cụ thể như OSD, phát hiện chuyển động, hỗ trợ âm thanh hoặc codec H264/265/JPEG.

| Tính năng                                 | Mô-đun                                                                                                  | Kích thước |
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


**Giải thích thuật ngữ:**

* **HiSilicon:** Là một công ty con của Huawei, chuyên sản xuất chip xử lý.
* **Kernel module:** Mô-đun kernel, là một phần mềm có thể được tải vào kernel Linux.
* **RAM (Random Access Memory):** Bộ nhớ truy cập ngẫu nhiên, là một loại bộ nhớ máy tính mà dữ liệu có thể được truy cập trực tiếp ở bất kỳ vị trí nào.
* **OSD (On-Screen Display):** Hiển thị trên màn hình, là một tính năng cho phép hiển thị thông tin trên hình ảnh video.
* **Motion detection:** Phát hiện chuyển động, là một tính năng cho phép camera phát hiện chuyển động trong trường nhìn của nó.
* **Codec:** Bộ mã hóa/giải mã, là một thuật toán được sử dụng để nén và giải nén dữ liệu âm thanh hoặc video.
* **H.264, H.265, JPEG:** Là các codec được sử dụng để nén video và hình ảnh.
* **I2C, SPI:** Là các giao thức truyền thông được sử dụng để giao tiếp với các cảm biến và thiết bị ngoại vi khác.
* **PWM (Pulse Width Modulation):** Điều chế độ rộng xung, là một kỹ thuật được sử dụng để điều khiển công suất được truyền đến một tải bằng cách thay đổi độ rộng của xung.





