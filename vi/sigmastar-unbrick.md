# OpenIPC Wiki
[Mục lục](../README.md)

Phục hồi Sigmastar
---

**Xác định vị trí đầu ra UART của Sigmastar và kết nối nó với CH341A I2C:**
- $\color{dimgray}{\texttt{GND -> GND (Chân 1-4)}}$
- $\color{deepskyblue}{\texttt{TX -> SDA I2C (Chân 5)}}$
- $\color{orange}{\texttt{RX -> SCL I2C (Chân 6)}}$

<img src="../images/sigmastar-ch341a.webp">
<img src="../images/sigmastar-uart.webp">
<img src="../images/sigmastar-example.webp">

---

**Tải xuống snander-mstar:**
- https://github.com/openipc/snander-mstar/releases

<details>
<summary>Cài đặt trình điều khiển Windows</summary>
<img src="../images/sigmastar-driver.webp">
</details>

---

**Kiểm tra bộ nhớ flash của thiết bị bằng snander:**
- Thiết bị phải được cấp nguồn khi kết nối với bộ lập trình.
- Tắt và bật nguồn có thể giúp ích nếu không thể phát hiện thiết bị.
```
snander -i -q
```

<img src="../images/sigmastar-check.webp">

**Xóa phân vùng khởi động:**
```
snander -l 0x200000 -e
```

<img src="../images/sigmastar-erase.webp">

**Ghi tệp uboot mới:**
- https://github.com/openipc/firmware/releases/tag/latest
- thả tệp vào cùng thư mục với chương trình
```
snander -w u-boot-ssc338q-nand.bin
```

<img src="../images/sigmastar-write.webp">

---

**Thiết bị I2C:**
- 0x49 -> MStar ISP
- 0x59 -> MStar Debug

---

- [Phương pháp Raspberry thay thế bởi MarioFPV](https://youtu.be/88C8UvyKQlQ)



