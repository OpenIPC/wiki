# Wiki OpenIPC
[Mục lục](../README.md)

Tổng quan
--------

Mỗi nhà sản xuất SoC có phần mềm riêng để điều chỉnh chất lượng hình ảnh:

* HiSilicon - PQTools
* Novatek - isptool
* Fullhan - Coolview

## Bo mạch dựa trên HiSilicon

### Họ EV300

#### Chạy mô-đun máy chủ trên bo mạch OpenIPC

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

#### Chạy mô-đun máy chủ trên bo mạch XM

Để đơn giản, chúng tôi sẽ sử dụng máy chủ NFS công cộng:

```console
$ mount -o nolock 95.217.179.189:/srv/ro /utils/
$ cd /utils/ittb_ev300_V1.0.1.2/
$ LD_LIBRARY_PATH=lib ./ittb_control

...
pqtools:Waiting for connection from client!
```

#### Chạy phần mềm máy khách trên Windows

Tải xuống và cài đặt [MATLAB Compiler Runtime][mcr].

Tải xuống [PQTools][pqt] và giải nén tập tin zip ở đâu đó trên PC của bạn.

Khởi chạy `HiPQTools.exe`, chọn `Hi3516EV200_V1.0.1.2`, nhập địa chỉ IP của camera và nhấp vào `OK`.

Sử dụng [hướng dẫn này][man] để tham khảo.

[mcr]: https://ssd.mathworks.com/supportfiles/MCR_Runtime/R2012a/MCR_R2012a_win32_installer.exe
[pqt]: https://drive.google.com/file/d/1c4XZRbJKXjMBwfMJaLl5jUPcVqMbO936/view?usp=sharing
[man]: https://drive.google.com/file/d/1mY1lXMZVNz2Ia5CPvTF-K-907eIioSYU/view?usp=sharing

