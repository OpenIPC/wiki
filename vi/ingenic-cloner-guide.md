### Tiện ích Sao chép Ingenic

Ứng dụng Sao chép Ingenic là một tiện ích bên máy tính giao tiếp với chế độ "USB-Boot" được tích hợp trong các SoC Ingenic. Bằng cách đặt SoC vào chế độ "USB-Boot", bạn có thể sử dụng ứng dụng Sao chép Ingenic để flash trực tiếp chip firmware mà không cần phải tháo rời vật lý hoặc giao tiếp với chip flash.

Hướng dẫn này là một công việc đang tiến hành.


#### Chập các chân trên chip flash

Điều đầu tiên cần làm là xác định vị trí chip bộ nhớ flash trên bảng mạch camera. Thông thường đây là một chip vuông có 8 chân được dán nhãn 25Q64 hoặc 25Q128, hiếm khi là 25L64 hoặc 25L128. Nếu bạn gặp sự cố khi xác định vị trí chip, hãy thử chụp một số ảnh bảng của bạn từ cả hai phía. Sau đó, hãy yêu cầu trợ giúp [trong kênh Telegram của chúng tôi](https://t.me/openipc).
**Không cố gắng chập mạch bất kỳ chip ngẫu nhiên nào! Nó rất có thể sẽ làm cháy mạch camera của bạn.**

Chập mạch các chân 5 và 6 của chip flash bằng một vật kim loại nhỏ, tua vít hoặc nhíp, ngay sau khi bootloader khởi động nhưng trước khi nó gọi kernel Linux.

Các chân 5 và 6 của chip SOIC8 nằm ở góc đối diện với chân 1, được biểu thị bằng dấu chấm nổi hoặc vẽ bên cạnh nó.

![](../images/flash-pins.webp)
![](../images/flash-pins-2.webp)


![hình ảnh](https://github.com/OpenIPC/wiki/assets/12115272/632e5cb9-0b5d-406b-a268-7c4b65781828)
![hình ảnh](https://github.com/OpenIPC/wiki/assets/12115272/5b9fed70-031e-42ea-89b6-292cc2f34458)
![hình ảnh](https://github.com/OpenIPC/wiki/assets/12115272/27f0d101-059d-41a1-a444-43bd137cf1b9)
![hình ảnh](https://github.com/OpenIPC/wiki/assets/12115272/69c6f79d-1c88-45d9-b6a7-003345d72e56)

---

# Tải xuống Cloner: [Tiện ích OpenIPC](https://openipc.org/utilities)

---

**Hướng dẫn ứng dụng OpenIPC Cloner**

1. **Truy cập Cloner**: 
   - Điều hướng đến thư mục "cloner-2.5.xx-ubuntu_alpha", với "xx" cho biết phiên bản Cloner bạn đã tải xuống.

2. **Chuẩn bị cho Firmware**: 
   - Tạo một thư mục mới có tên `0_OpenIPC_Firmware` trong thư mục này.

3. **Khởi chạy Cloner**: 
   - Mở ứng dụng `cloner`. Đảm bảo bạn đang sử dụng phiên bản 2.5.43 trở lên để tương thích.

4. **Thiết lập ban đầu**: 
   - Nhấp vào "Load Image" và chọn tệp "openipc_cloner_bundle_xxx.zip".
   - Nếu mức khóa là "2", hãy thay đổi thành "0". Nhập '!@#' (dấu chấm than, ký hiệu @, dấu thăng, không có dấu ngoặc kép) làm mật khẩu. Nút 'Config' sẽ xuất hiện lại.

5. **Cài đặt cấu hình**: 
   - Nhấp vào nút 'Config' ở góc trên cùng bên phải.

6. **Điều hướng cấu hình**: 
   - Trong cửa sổ Config, trong tab "Info", hãy truy cập các menu cấu hình khác nhau.

7. **Cài đặt dành riêng cho thiết bị**: 
   - Chọn 'Platform T'.
   - Chọn phiên bản SoC phù hợp cho thiết bị của bạn bên cạnh Platform 'T'.
   - Trong 'Board', chọn thao tác liên quan:
     - `txxx_sfc_nor_reader_8MB.cfg` cho thiết bị có chip flash 8MB.
     - `txxx_sfc_nor_reader_16MB.cfg` cho thiết bị có chip flash 16MB.
     - `txxx_sfc_nor_writer.cfg` để ghi các phân vùng riêng lẻ.
     - `txxx_sfc_nor_writer_full.cfg` để flash toàn bộ chip.
   - Nhấp vào "Save" để quay lại màn hình chính.

8. **Bắt đầu chương trình**: 
   - Với cấu hình mong muốn đã được tải, hãy nhấp vào "Start" trên màn hình chính.

9. **Quy trình nhận dạng thiết bị**:
   - Cắm cáp USB vào thiết bị, để đầu kia không được cắm.
   - Chập các chân 5-6 TRÊN CHIP FLASH, không phải SoC hoặc bất kỳ chip nào khác, hãy sử dụng ảnh làm tài liệu tham khảo, như đã mô tả trước đó trong tài liệu này.
   - Trong khi duy trì chập, hãy kết nối cáp USB với máy tính. Chờ 2 giây, sau đó thả chập.
   - Có thể mất tối đa 30 giây để Cloner nhận dạng thiết bị. Thanh tiến trình trên màn hình chính sẽ cho biết các thao tác đang diễn ra.

10. **Hoàn thành**: 
   - Sau khi tất cả các thanh tiến trình chuyển sang màu xanh lục, các thao tác đã hoàn tất.

---

Hãy cẩn thận làm theo các bước này để đảm bảo ứng dụng Cloner được thiết lập chính xác và hoạt động như mong đợi.

