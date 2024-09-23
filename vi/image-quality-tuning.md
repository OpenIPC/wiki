## Wiki OpenIPC
[Mục lục](../README.md)

Tổng quan
--------

Mỗi nhà sản xuất SoC có phần mềm riêng để điều chỉnh chất lượng hình ảnh:

* HiSilicon - PQTools
* Novatek - isptool
* Fullhan - Coolview

## Bảng mạch dựa trên HiSilicon

### Dòng EV300

#### Chạy mô-đun máy chủ trên bảng mạch OpenIPC

```console
$ pqtools

.....

dev mounted
libs mounted
pqtools:begin to run
the s32Result is 1
g_bUseSpecAWB is 0
port is : 4321

<HI_PQT_Network_Init>(1486)bind ok!
pqtools:server(port:4321)begin to listen
pqtools:Waiting for connection from client!
```

#### Chạy mô-đun máy chủ trên bảng mạch XM

Để đơn giản, chúng tôi sử dụng máy chủ NFS công cộng:

```console
$ mount -o nolock 95.217.179.189:/srv/ro /utils/
$ cd /utils/ittb_ev300_V1.0.1.2/
$ LD_LIBRARY_PATH=lib ./ittb_control

...
pqtools:Waiting for connection from client!
```

#### Chạy phần mềm máy khách trên Windows

Tải xuống và cài đặt [MATLAB Compiler Runtime][mcr].

Tải xuống [PQTools][pqt] và giải nén kho lưu trữ zip ở đâu đó trên PC của bạn.

Khởi chạy `HiPQTools.exe`, chọn `Hi3516EV200_V1.0.1.2`, nhập địa chỉ IP của camera của bạn và nhấp vào `OK`.

Sử dụng [hướng dẫn này][man] để tham khảo.

[mcr]: https://ssd.mathworks.com/supportfiles/MCR_Runtime/R2012a/MCR_R2012a_win32_installer.exe
[pqt]: https://drive.google.com/file/d/1c4XZRbJKXjMBwfMJaLl5jUPcVqMbO936/view?usp=sharing
[man]: https://drive.google.com/file/d/1mY1lXMZVNz2Ia5CPvTF-K-907eIioSYU/view?usp=sharing


**Giải thích thuật ngữ:**

* **SoC (System on a Chip):** Hệ thống trên một vi mạch, là một mạch tích hợp chứa tất cả các thành phần cần thiết của một hệ thống máy tính.
* **PQTools:** Là một bộ công cụ phần mềm được sử dụng để điều chỉnh chất lượng hình ảnh trên các bảng mạch dựa trên HiSilicon.
* **isptool:** Là một bộ công cụ phần mềm được sử dụng để điều chỉnh chất lượng hình ảnh trên các bảng mạch dựa trên Novatek.
* **Coolview:** Là một bộ công cụ phần mềm được sử dụng để điều chỉnh chất lượng hình ảnh trên các bảng mạch dựa trên Fullhan.
* **EV300:** Là tên của một dòng SoC HiSilicon.
* **OpenIPC:** Là một dự án phần mềm mã nguồn mở cung cấp firmware thay thế cho các camera IP.
* **XM:** Là tên của một nhà sản xuất camera IP.
* **NFS (Network File System):** Hệ thống tệp mạng, là một giao thức cho phép truy cập vào các tệp trên mạng.
* **MATLAB Compiler Runtime:** Là một bộ thư viện cần thiết để chạy các ứng dụng được biên dịch bằng MATLAB Compiler.
* **Client:** Máy khách, là một ứng dụng kết nối đến máy chủ để yêu cầu dịch vụ.
* **Server:** Máy chủ, là một ứng dụng cung cấp dịch vụ cho máy khách.
* **IP address:** Địa chỉ IP, là một địa chỉ định danh duy nhất cho một thiết bị trên mạng.







