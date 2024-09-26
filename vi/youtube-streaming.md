# OpenIPC Wiki
[Mục lục](../README.md)

Yêu cầu cấu hình
--------------------------

Để ngăn việc luồng phát trực tiếp bị chấm dứt do kết nối bị gián đoạn tạm thời,
hãy lên lịch phát trực tiếp với ngày bắt đầu trong tương lai xa (ví dụ: ngày 31 tháng 12
của năm hiện tại). Nó sẽ hoạt động trơn tru khi bạn phát trực tiếp, ngắt kết nối
camera và sau đó tiếp tục phát trực tiếp.

### HLS + H.265

Theo dõi [Cung cấp Nội dung qua HLS](https://developers.google.com/youtube/v3/live/guides/hls-ingestion)
để biết thêm thông tin.

### Tạo luồng mới

- Điều hướng đến trang <https://developers.google.com/youtube/v3/live/code_samples>.
- Chọn 'liveStreams' làm Tài nguyên và 'insert' làm Phương thức.
- Trong bảng bên dưới, nhấp vào trường hợp sử dụng 'insert'.
- Ở phía bên phải của trang:
  - trong đối tượng 'cdn', thay đổi "frameRate" từ "60fps" thành "variable";
  - chuyển "resolution" từ "1080p" thành "variable";
  - chuyển "ingestionType" từ "rtmp" thành "hls":

```json
"cdn": {
  "ingestionType": "hls",
  "frameRate": "variable",
  "resolution": "variable"
}
```

- trong phần Thông tin đăng nhập, hãy đảm bảo rằng bạn đã chọn 'Google OAuth 2.0' và
  phạm vi 'https://www.googleapis.com/auth/youtube' (sử dụng 'Hiển thị phạm vi') và
  bỏ chọn tùy chọn 'Khóa API', sau đó nhấn nút 'Thực thi' bên dưới.
- Ủy quyền cho chính bạn bằng tài khoản được kết nối với YouTube của bạn.
- Đảm bảo rằng bạn nhận được phản hồi 200, nếu không hãy kiểm tra lỗi và lặp lại.
  Lỗi phổ biến là khi [phát trực tiếp](https://support.google.com/youtube/answer/2474026?hl=en)
  chưa được bật trước đó trong tài khoản của bạn.
- Lưu "channelId" từ phản hồi (nó trông giống như "UCPJRjbxYlq6h2cCqy8RCRjg").


### Tạo chương trình phát sóng mới:

- Điều hướng đến trang <https://developers.google.com/youtube/v3/live/code_samples>.
- Chọn 'liveBroadcast' làm Tài nguyên và 'insert' làm Phương thức.
- Trong bảng bên dưới, nhấp vào trường hợp sử dụng 'insert'.
- Ở phía bên phải của trang:
  - trường 'title' cho chương trình phát sóng của bạn như 'My Hometown Camera'
  - 'scheduledStartTime' như '2020-04-21T00:00:00.000Z' (đảm bảo thời gian này trong tương lai),
  - 'scheduledEndTime' như '2020-04-21T01:00:00.000Z' (thời gian kết thúc theo lịch trình phải sau thời gian bắt đầu theo lịch trình)
  - cũng nhấn nút cộng màu xanh lam bên trong khối "snippet" và thêm "channelId" với giá trị được cung cấp từ bước luồng

```json
"snippet": {`
  `"title": "My Hometown Camera",`
  `"scheduledStartTime": "2021-04-12T00:00:00.000Z",`
  `"scheduledEndTime": "2021-04-13T00:00:00.000Z",`
  `"channelId": "MCpZqkqqEZw806aGGHUdepIl"`
`},
```

- trong phần Thông tin đăng nhập, hãy đảm bảo rằng bạn đã chọn 'Google OAuth 2.0' và
  phạm vi 'https://www.googleapis.com/auth/youtube' (sử dụng 'Hiển thị phạm vi') và
  bỏ chọn tùy chọn 'Khóa API', sau đó nhấn nút 'Thực thi' bên dưới.
- Ủy quyền cho chính bạn bằng tài khoản được kết nối với YouTube của bạn.
- Đảm bảo rằng bạn nhận được phản hồi 200, nếu không hãy kiểm tra lỗi và lặp lại.


### Liên kết chương trình phát sóng với luồng:

- Điều hướng đến trang <https://developers.google.com/youtube/v3/live/code_samples>.
- Chọn 'liveBroadcast' làm Tài nguyên và 'bind' làm Phương thức.
- Trong bảng bên dưới, nhấp vào trường hợp sử dụng 'Liên kết chương trình phát sóng với luồng'.
- Ở phía bên phải của trang:
  - 'id' - ID của chương trình phát sóng (có thể được tìm thấy trong phản hồi của máy chủ trong bước 'Tạo chương trình phát sóng mới', trường 'id')
  - 'streamId' - ID của luồng (có thể được tìm thấy trong phản hồi của máy chủ trong bước 'Tạo luồng mới', trường 'id')
  - trong phần Thông tin đăng nhập, hãy đảm bảo rằng bạn đã chọn 'Google OAuth 2.0' và phạm vi 'https://www.googleapis.com/auth/youtube' (sử dụng 'Hiển thị phạm vi') và bỏ chọn tùy chọn 'Khóa API', sau đó nhấn nút 'Thực thi' bên dưới
- Ủy quyền cho chính bạn bằng tài khoản được kết nối với YouTube của bạn.
- Đảm bảo rằng bạn nhận được phản hồi 200, nếu không hãy kiểm tra lỗi và lặp lại.


### Phát trực tiếp!

Điều hướng đến <https://studio.youtube.com/>.

Ở phía bên phải, nhấp vào nút 'TẠO' và sau đó 'Phát trực tiếp'.


(c) Victor, Nguồn: https://github.com/OpenIPC/camerasrnd/blob/master/streaming/youtube.md




