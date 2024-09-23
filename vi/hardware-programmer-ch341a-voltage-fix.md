## Wiki OpenIPC
[Mục lục](../README.md)

Bộ lập trình CH341A
-----------------

### Khắc phục lỗi điện áp cao

Các phiên bản đầu tiên, trước phiên bản 1.7, của Bộ lập trình Mini CH341A phổ biến và giá rẻ có một lỗi khó chịu là mức điện áp trên các đường dữ liệu vẫn ở mức 5V mặc dù bộ lập trình được đặt thành 3.3V bằng jumper.

@ddemos1963 đã đưa ra một giải pháp hack thú vị để khắc phục sự cố một cách hiệu quả và khéo léo.

![](../images/hardware-ch341a-hack-1.webp)
![](../images/hardware-ch341a-hack-2.webp)

Đây là những gì bạn cần làm.

![](../images/hardware-ch341a-hack-6.png)

Ngắt kết nối giữa đường dây nguồn 5V và chip CH341A. Dùng dao tiện ích sắc bén, cắt đường mạch ở mặt sau của bảng mạch lập trình.

![](../images/hardware-ch341a-hack-3.webp)

Kết nối chân đầu ra 3.3v của bộ điều chỉnh điện áp với chân 9 của IC CH341A, bắc cầu nó với đường mạch tương ứng tại một tụ điện gần đó.

![](../images/hardware-ch341a-hack-4.webp)

Khôi phục nguồn điện cho chip bằng cách định tuyến lại điện áp 3.3V từ chân 3v3 đến chân 28 của IC CH341A thông qua đầu nối chân 5V trên đầu nối.

![](../images/hardware-ch341a-hack-5.webp)

### Khắc phục sự cố

```console
libusb: error [get_usbfs_fd] libusb couldn't open USB device /dev/bus/usb/001/003, errno=13
libusb: error [get_usbfs_fd] libusb requires write access to USB device nodes
```

Nếu bạn nhận được thông báo lỗi như thế này khi chạy phần mềm lập trình, bạn cần điều chỉnh quyền trên cổng USB cho thiết bị đó.

Tạo một tệp quy tắc udev

```bash
sudo vi /etc/udev/rules.d/99-ch341a-prog.rules
```

thêm nội dung sau vào tệp:

```bash
# udev rule that sets permissions for CH341A programmer in Linux.
# Put this file in /etc/udev/rules.d and reload udev rules or reboot to install
SUBSYSTEM=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="5512", MODE="0666"
```

lưu tệp, tải lại udev

```bash
sudo udevadm control --reload-rules
sudo udevadm trigger
```

sau đó rút bộ lập trình và cắm lại vào cổng USB.

### Phần mềm

- [SNANDer](https://github.com/McMCCRU/SNANDer) hoặc [bản fork này](https://github.com/Droid-MAX/SNANDer)
- [microsnander](https://github.com/OpenIPC/microsnander) từ OpenIPC
- [ch341prog](https://github.com/setarcos/ch341prog/)
- [flashrom](https://www.flashrom.org/Flashrom)
- [Diễn đàn DIY BCQ CH341A](http://www.diybcq.com/thread-144131-1-1.html) (Tiếng Trung, sử dụng tính năng dịch tự động của Chrome)
- [Bộ lập trình CH341A](https://4pda.to/forum/index.php?showtopic=884713) (Tiếng Nga, sử dụng tính năng dịch tự động của Chrome)


**Giải thích thuật ngữ:**

* **Jumper:** Cầu nối, là một miếng nhựa nhỏ có thể được sử dụng để kết nối hoặc ngắt kết nối các mạch điện trên bảng mạch.
* **Trace:** Đường mạch, là một đường dẫn dẫn điện trên bảng mạch.
* **IC (Integrated Circuit):** Mạch tích hợp, là một mạch điện tử được chế tạo trên một miếng silicon nhỏ.
* **Header:** Đầu nối, là một bộ phận được sử dụng để kết nối các dây hoặc cáp với bảng mạch.
* **Udev:** Là một trình quản lý thiết bị cho nhân Linux, nó quản lý các tệp thiết bị trong `/dev`.
* **Fork:** Bản sao chép của một dự án phần mềm, được tạo ra để phát triển độc lập với dự án gốc.


