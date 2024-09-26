## OpenIPC Wiki
[Mục lục](../README.md)

Chế độ ban đêm tự động trên các thiết bị không có cảm biến ánh sáng
==============================

Không phải tất cả các thiết bị đều có cảm biến ánh sáng tích hợp để xác định xem có nên kích hoạt chế độ ban đêm hay không. 
Đối với những thiết bị này, chúng ta có thể sử dụng giá trị độ lợi analog của cảm biến hình ảnh để chuyển đổi. Trong điều kiện ánh sáng yếu, giá trị này sẽ cao, cho biết cảm biến hình ảnh đang áp dụng độ lợi để tăng độ sáng. Trong điều kiện ánh sáng tốt, giá trị này sẽ thấp.

#### Bước 1: Xác định xem bộ lọc cắt IR đã được thiết lập đúng chưa
Bài viết này giả định rằng bạn đã tìm thấy và nhập đúng chân GPIO cho bộ lọc cắt IR của mình và bạn có thể bật tắt bộ lọc bằng cách sử dụng nút `Bộ lọc cắt IR` trong chế độ xem trước. Trong điều kiện ban ngày, trong chế độ xem trước, hình ảnh không nên có màu hồng.
Nếu nó có màu hồng, rất có thể các chân của bạn bị đảo ngược thứ tự và chúng cần được hoán đổi trong `Majestic > Chế độ ban đêm`.

#### Bước 2: Cài đặt tập lệnh chế độ ban đêm
Chúng ta cần 2 tập lệnh: tập lệnh chế độ ban đêm thực tế và tập lệnh khởi động cho phép tập lệnh chế độ ban đêm khi khởi động.

[autonight.sh](https://raw.githubusercontent.com/OpenIPC/device-mjsxj02hl/master/flash/autoconfig/usr/sbin/autonight.sh)

Sao chép `autonight.sh` vào `/usr/sbin`

[S96autonight](https://raw.githubusercontent.com/OpenIPC/device-mjsxj02hl/master/flash/autoconfig/etc/init.d/S96autonight)

Sao chép `S96autonight` vào `/etc/init.d/` và làm cho nó có thể thực thi được với `chmod +x /etc/init.d/S96autonight`

#### Bước 3: Tinh chỉnh giá trị độ lợi analog của cảm biến
Trong `autonight.sh` bạn sẽ tìm thấy 3 cài đặt:
```
again_high_target=14000
again_low_target=2000
pollingInterval=5
```

`again_high_target` là giá trị độ lợi mà chế độ ban đêm sẽ được bật. Tương tự, `again_low_target` là giá trị mà chế độ ban đêm bị tắt. Bạn có thể thay đổi các số này để tối ưu hóa cho thiết lập cụ thể của mình.
`pollingInterval` cho biết tần suất tập lệnh kiểm tra giá trị độ lợi analog của cảm biến. Giá trị thấp hơn sẽ dẫn đến phản hồi nhanh hơn, nhưng có thể dẫn đến hành vi chuyển đổi "hồi hộp" hơn để đáp ứng với các tia sáng ngắn, v.v.

**Lưu ý:** Để khởi động lại tập lệnh `autonight.sh`, ví dụ: nếu bạn đã thay đổi cài đặt, hãy sử dụng `/etc/init.d/S96autonight restart`. Để dừng tập lệnh, ví dụ: nếu bạn muốn quan sát các giá trị độ lợi analog mà không cần chuyển đổi bộ lọc IR,
hãy sử dụng `/etc/init.d/S96autonight stop`. 
Sau khi dừng tập lệnh, bạn có thể chạy `/usr/sbin/autonight.sh` theo cách thủ công trong terminal để nhận đầu ra nhật ký.

#### Bổ sung: Xem giá trị độ lợi analog của cảm biến và trạng thái chế độ ban đêm hiện tại
Các số liệu được hiển thị tại điểm cuối `/metrics` trong giao diện web.

_Giá trị độ lợi analog hiện tại được hiển thị trong `isp_again`:_
```
# HELP isp_again Analog Gain
# TYPE isp_again gauge
isp_again 2880
```

_Cài đặt chế độ ban đêm hiện tại được hiển thị trong `night_enabled`:_
```
# HELP night_enabled Is night mode enabled
# TYPE night_enabled gauge
night_enabled 0
```