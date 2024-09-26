## OpenIPC Wiki
[Mục lục](../README.md)

Ghi chú về việc cài đặt OpenIPC bằng Burn
--------------------------------------

### Hướng dẫn flash GK7205V210 với bootloader bị khóa

#### Lời mở đầu

```
Quan điểm của tôi là - hướng dẫn dành cho người mới bắt đầu nên được viết bởi người mới bắt đầu.
Ngay khi một người hoàn thành việc flash 2-3 board, kỹ năng của anh ta sẽ tăng lên cấp độ 50 
và anh ta không muốn nhớ những điều nhỏ nhặt quan trọng đối với người mới bắt đầu.
```

Trước khi bắt đầu làm việc, hãy xem video trên kênh [YouTube](https://www.youtube.com/@openipc/playlists) của chúng tôi

- Tải xuống [Burn](https://github.com/OpenIPC/burn)
- Cài đặt máy chủ [PUTTY](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html) và [TFTP](https://pjo2.github.io/tftpd64/)
- Tắt nguồn camera, Kết nối USB com FTDI với camera của bạn, chỉ rõ cổng COM nào trên PC của bạn
- Nhập thư mục burn và chạy lệnh cmd sau (Chỉ tập trung vào cổng serial, trong trường hợp của tôi là COM4, các tham số khác không quan trọng, nó hoạt động với GK7205V210 của tôi):
- **Chỉ** sử dụng bộ nạp khởi động U-Boot từ kho lưu trữ Burn!
```
python burn --chip hi3516ev200 --file=u-boot/gk7205v200.bin -p COM4 --break && putty.exe -serial COM4 -sercfg 115200,8,n,1,N
```
- Bật nguồn camera bằng bộ nguồn và đợi putty hiển thị console
- Nhấn enter, sau đó bạn sẽ thấy "goke" trong console
- Chạy máy chủ TFTP, chỉ định đường dẫn của tệp bin
- Bây giờ hãy làm theo hướng dẫn được tạo từ trang web OpenIPC:

```
# Nhập các dòng lệnh từng dòng một! Không sao chép và dán nhiều dòng cùng một lúc!
setenv ipaddr 192.168.0.10; setenv serverip 192.168.0.40
mw.b 0x42000000 0xff 0x800000
tftpboot 0x42000000 openipc-FULL-FIRMWARE-IMAGE.bin
sf probe 0; sf lock 0;
sf erase 0x0 0x800000; sf write 0x42000000 0x0 0x800000
reset
Ctrl + c nhanh chóng trong quá trình khởi động
# Nhập các dòng lệnh từng dòng một! Không sao chép và dán nhiều dòng cùng một lúc!run setnor8m
```