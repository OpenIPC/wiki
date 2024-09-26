# OpenIPC Wiki
[Mục lục](../README.md)

Cách build OpenIPC với trình điều khiển RTL8812EU
--------------------------------

Xem thêm chi tiết về rtl8812eu tại đây https://github.com/OpenIPC/wiki/blob/master/en/fpv-bl-m8812eu2-wifi-adaptors.md

- Khởi động vào Ubuntu
- Mở Terminal

```
sudo apt-get install -y automake autotools-dev bc build-essential curl fzf git libtool rsync unzip
```

```
rm -r -f yourOpenipc #xóa mọi thư mục build firmware cũ (tùy chọn)
git clone --depth=1 https://github.com/OpenIPC/firmware.git yourOpenipc
cd yourOpenipc
make clean
cd br-ext-chip-sigmastar
cd configs
ls
sudo nano yourSelectconfig
```

```
	Sau đó, trong Wireless, thêm dòng
BR2_PACKAGE_RTL88X2EU_OPENIPC=y
	Lưu tệp

cd ..
cd ..
make
```

- Chọn board của bạn và nhập ví dụ: ssc338q fpv và build firmware
- Điều hướng đến /home/YourUser/yourOpenipc/output/images
- Tìm kho lưu trữ .tgz đầu ra phù hợp của bạn, ví dụ: openipc.ssc338q-nor-fpv.tgz và giải nén các tệp rootfs và uboot
- Sao chép hai tệp đó vào thư mục /tmp của camera OpenIPC
    - ssh vào camera
`cd /tmp`

`sysupgrade --kernel=uImage.ssc338q --rootfs=rootfs.squashfs.ssc338q`
hoặc
`sysupgrade --kernel=uImage.ssc30kq --rootfs=rootfs.squashfs.ssc30kq`

Changes:
- "bảng của bạn"  -> "board của bạn"
- "tệp rootfs và uboot" -> "các tệp rootfs và uboot"
- "/tmp của camera OpenIPC" -> "thư mục /tmp của camera OpenIPC"




