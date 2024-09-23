# OpenIPC Wiki
[Mục lục](../README.md)

Cách build OpenIPC với trình điều khiển RTL8812EU
--------------------------------

Thêm chi tiết về rtl8812eu có thể được tìm thấy ở đây https://github.com/OpenIPC/wiki/blob/master/en/fpv-bl-m8812eu2-wifi-adaptors.md

- Khởi động vào Ubuntu
- Mở Terminal

```
sudo apt-get install -y automake autotools-dev bc build-essential curl fzf git libtool rsync unzip
```

```
rm -r -f yourOpenipc #xóa bất kỳ thư mục build firmware cũ nào (tùy chọn)
git clone --depth=1 https://github.com/OpenIPC/firmware.git yourOpenipc
cd yourOpenipc
make clean
cd br-ext-chip-sigmastar
cd configs
ls
sudo nano yourSelectconfig
```

```
	Sau đó, trong phần Không dây, thêm dòng
BR2_PACKAGE_RTL88X2EU_OPENIPC=y
	Lưu tệp

cd ..
cd ..
make
```

- Chọn bảng của bạn và nhập ví dụ: ssc338q fpv và build firmware
- Điều hướng đến /home/YourUser/yourOpenipc/output/images
- Tìm kho lưu trữ .tgz đầu ra thích hợp của bạn, tức là openipc.ssc338q-nor-fpv.tgz và giải nén các tệp rootfs và uboot
- Sao chép 2 tệp đó vào /tmp của camera OpenIPC
    - ssh vào camera
`cd /tmp`

`sysupgrade --kernel=uImage.ssc338q --rootfs=rootfs.squashfs.ssc338q`
hoặc
`sysupgrade --kernel=uImage.ssc30kq --rootfs=rootfs.squashfs.ssc30kq`

