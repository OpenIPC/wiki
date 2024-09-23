# OpenIPC Wiki
[Mục lục](../README.md)

Hướng dẫn Sử dụng Mô-đun Wi-Fi BL-M8812EU2 (hoặc dựa trên RTL8812EU khác) trong Firmware FPV
---
[Mô-đun BL-M8812EU2 của LB-LINK](https://www.lb-link.com/product_36_183.html)  
Một lựa chọn bộ chuyển đổi Wi-Fi FPV khác với công suất TX cao (>29dBm) và chi phí thấp.   
![image](https://github.com/libc0607/openipc-wiki/assets/8705034/8aed1797-8f58-4e8f-95d7-b8d055c3519a)


### Phần cứng
#### Mua ở đâu
Vì chip RTL8812EU còn khá mới nên hiện tại chưa có người bán nào trên Aliexpress.   
Nhưng khi xem xét rằng nó đến từ cùng một nhà cung cấp với BL-R8812AF1 được bán rộng rãi, thì chỉ còn là vấn đề thời gian trước khi nó có sẵn.   
Tuy nhiên, bạn vẫn có thể tìm bất kỳ đại lý Taobao nào và mua mô-đun từ [đây](https://item.taobao.com/item.htm?id=764510955987).

#### Lắp dây
![image](https://github.com/libc0607/openipc-wiki/assets/8705034/0511de9a-bd3a-42c1-8f35-0f5ec72a1121)  

Kết nối ```USB2.0+DP```, ```USB2.0-DM``` bằng một cặp dây xoắn với USB của IPC. Kết nối GND với IPC cũng được yêu cầu.   
Kết nối ```GND``` và ```VDD5.0``` với bộ nguồn 5V/>3A để cấp nguồn cho mô-đun.   
Kết nối hai ăng-ten 5GHz với đầu nối IPEX J0 và J1 trước khi truyền.   
Chân 9~18 là GND và có thể để nổi.  

Tham khảo: https://oshwhub.com/libc0607/bl-m8812eu2-demoboard-v1p0  

### Thêm Trình điều khiển vào Firmware OpenIPC
Do không gian flash rất hạn chế nên trình điều khiển bị vô hiệu hóa theo mặc định.  
Bạn cần biên dịch firmware từ mã nguồn để bật nó.  

#### Bước 1. Chuẩn bị
Làm theo hướng dẫn trong [source-code.md](https://github.com/libc0607/openipc-wiki/blob/master/en/source-code.md) cho đến khi bạn build thành công firmware của mình.

#### Bước 2. Thêm BR2_PACKAGE vào Cấu hình Bảng  
Tìm cấu hình bảng mục tiêu của bạn trong ```br-ext-chip-*/config```, sau đó thêm  ```BR2_PACKAGE_RTL88X2EU_OPENIPC=y``` vào đó.
Nếu IPC của bạn có Flash NOR 8M/16M, bạn có thể cần phải tắt các trình điều khiển khác (ví dụ: RTL8812AU) để tiết kiệm dung lượng.

#### Bước 3. Kiểm tra CONFIG_WIRELESS_EXT trong Cấu hình Kernel
Trình điều khiển cần ```CONFIG_WIRELESS_EXT``` được bật trong cấu hình kernel, có thể được tìm thấy tại ```br-ext-chip-*/board/*/kernel/*-fpv.config```.
Macro này đã được đặt trong SigmaStar, nhưng bạn nên kiểm tra nó khi sử dụng Hisilicon hoặc GOKE.

#### Bước 4. Build firmware
```
make
```
Sau đó, bạn có thể sử dụng ```output/images/rootfs.squashfs.*``` và ```output/images/uImage.*``` với ```sysupgrade```.

### Cách sử dụng
Nó gần giống với các bộ chuyển đổi RTL8812AU.

#### Đặt Công suất TX  
Có hai cách để đặt công suất TX.   
- ```driver_txpower_override``` trong ```/etc/wfb.conf```. Phạm vi là ```0~63```
- ```iw dev <wlan0> set txpower fixed <mBm>```. Phạm vi là ```0~3150``` và có thể được đặt động khi truyền.

Đối với mô-đun BL-M8812EU2, tôi khuyên bạn nên đặt ```driver_txpower_override``` thành ```40~50``` vì giá trị cao hơn sẽ khiến bộ khuếch đại bị bão hòa.  
Mức tiêu thụ điện năng của mô-đun BL-M8812EU2 có thể đạt 5V/2.xA khi ```driver_txpower_override > ~40```.  
Sử dụng bộ nguồn 5V phù hợp và TẢN NHIỆT CÓ QUẠT.


