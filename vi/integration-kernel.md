## Wiki OpenIPC
[Mục lục](../README.md)

Các yêu cầu bổ sung cho cấu hình kernel
------------------------------------------------

```
CONFIG_BLK_DEV=y
CONFIG_BLK_DEV_LOOP=y

CONFIG_IP_MULTICAST=y

CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y

CONFIG_ROOT_NFS=y
```

## Yêu cầu đối với tệp vá

- Tên tệp vá phải tuân theo định dạng `<số>-<mô tả>.patch`.

- Tên tệp vá không được chứa bất kỳ tham chiếu nào đến phiên bản gói.

- Phần `<số>` trong tên tệp của bản vá đề cập đến thứ tự áp dụng, bắt đầu từ 1. Nên thêm số 0 vào bên trái cho đến khi tổng số chữ số là bốn, giống như `git-format-patch`. Ví dụ: _0001-foobar-the-buz.patch_

- Tệp vá nên chứa phần chú thích trong tiêu đề, giải thích bản vá này thực hiện điều gì và tại sao cần nó.

- Thêm câu lệnh _Signed-off-by_ trong tiêu đề của mỗi tệp vá để giúp theo dõi các thay đổi và chứng nhận rằng bản vá được phát hành theo cùng giấy phép với phần mềm mà nó sửa đổi.


