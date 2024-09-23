# Hướng dẫn Cấu hình PTZ Ingenic

Mô-đun motors được bao gồm trong kho `openingenic` được cài đặt theo mặc định, với tên là mô-đun kernel `motor.ko`.

## Tải mô-đun

Tải mô-đun motor bằng lệnh sau (điều chỉnh GPIO khi cần cho phần cứng của bạn, xem [Cấu hình mô-đun](https://github.com/OpenIPC/wiki/blob/master/en/ingenic-ptz.md#module-configuration)):

```bash
modprobe motor hmaxstep=2540 vmaxstep=720 hst1=52 hst2=53 hst3=57 hst4=51 vst1=59 vst2=61 vst3=62 vst4=63
```

Để tự động hóa quá trình này trong quá trình khởi động, hãy thêm dòng `sample_motor hmaxstep=2540 vmaxstep=720 hst1=52 hst2=53 hst3=57 hst4=51 vst1=59 vst2=61 vst3=62 vst4=63` vào `/etc/modules`.

## Cấu hình mô-đun

- `hstX`: Các chân GPIO pha động cơ ngang.
- `vstX`: Các chân GPIO pha động cơ dọc.
- `hmaxstep` và `vmaxstep`: Chỉ định số bước tối đa mà phần cứng của bạn có thể xử lý.

## Điều khiển động cơ

Sử dụng tiện ích dòng lệnh `ingenic-motor` để điều khiển động cơ.

## Lưu ý về Xử lý GPIO

- Lưu ý rằng tùy thuộc vào GPIO cụ thể mà phần cứng của bạn sử dụng để điều khiển động cơ, bạn có thể gặp phải chuyển động bị hạn chế hoặc không hoạt động do việc xử lý GPIO bị lỗi trên nền tảng Ingenic.
- Vấn đề này có thể được giải quyết trong các bản cập nhật trong tương lai.
```

**Giải thích thuật ngữ:**

* **PTZ (Pan-Tilt-Zoom):** Xoay-Nghiêng-Phóng to, là khả năng điều khiển camera xoay ngang, dọc và phóng to/thu nhỏ.
* **Module:** Mô-đun, là một phần mềm có thể được tải vào kernel Linux.
* **Kernel:** Là phần cốt lõi của hệ điều hành.
* **GPIO (General Purpose Input/Output):** Cổng vào/ra đa năng, là các chân trên vi điều khiển có thể được cấu hình làm đầu vào hoặc đầu ra.
* **modprobe:** Là một lệnh được sử dụng để tải các mô-đun kernel.
* **hmaxstep:** Số bước tối đa theo chiều ngang.
* **vmaxstep:** Số bước tối đa theo chiều dọc.
* **hstX:** Chân GPIO pha động cơ ngang.
* **vstX:** Chân GPIO pha động cơ dọc.
* `/etc/modules`: Là một tệp cấu hình chứa danh sách các mô-đun kernel cần được tải khi khởi động.
* **ingenic-motor:** Là một tiện ích dòng lệnh được sử dụng để điều khiển động cơ trên nền tảng Ingenic.
