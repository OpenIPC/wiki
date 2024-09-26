# ZeroTier One
Gói [ZeroTier One](https://www.zerotier.com) cho các bản dựng ultimate.

### Bắt đầu
- Để bắt đầu dịch vụ, hãy thực thi lệnh này:
```
/usr/sbin/zerotier-one -d &
```

### Thiết lập
1. Đăng ký tại [my.zerotier.com](https://my.zerotier.com).
2. Nhận ID mạng, cấu hình mạng là riêng tư.
3. Từ bảng điều khiển ssh (hoặc bảng điều khiển web) hãy chạy như sau:
```
zerotier-cli join [ID mạng]
```

4. Truy cập giao diện web tại [my.zerotier.com](https://my.zerotier.com) và ủy quyền cho camera mới được kết nối, ủy quyền diễn ra bằng cách chọn hộp bên cạnh peer tương ứng.

### Cài đặt
- Cấu hình được lưu trữ trong `/var/lib/zerotier-one`
- Bạn có thể rời khỏi mạng bằng cách chạy lệnh sau:
```
zerotier-cli leave [ID mạng]
```
