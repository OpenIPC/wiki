# Wiki OpenIPC
[Mục lục](../README.md)

Ghi chú nghiên cứu và gỡ lỗi SoC Ingenic
----------------------------------------

#### Điều khiển các kênh PWM trên thiết bị Ingenic bằng tiện ích `ingenic-pwm` được bao gồm trong OpenIPC:

```
INGENIC PWM Control Version: Oct 19 2023_18:01:16_latest-2294-g72f266e7
Usage: ingenic-pwm [options]

Options:
  -c, --channel=<0-7>            Chỉ định số kênh PWM
  -q, --query                    Truy vấn trạng thái kênh
  -e, --enable                   Bật kênh
  -d, --disable                  Tắt kênh
  -p, --polarity=<0|1>           Đặt cực tính (0: Đảo ngược, 1: Bình thường)
  -D, --duty=<duty_ns>           Đặt chu kỳ nhiệm vụ tính bằng nano giây
  -P, --period=<period_ns>       Đặt chu kỳ tính bằng nano giây
  -r, --ramp=<value>             Tăng/giảm dần PWM (+value: Tăng dần, -value: Giảm dần)
  -x, --max_duty=<max_duty_ns>   Đặt chu kỳ nhiệm vụ tối đa cho việc tăng dần
  -n, --min_duty=<min_duty_ns>   Đặt chu kỳ nhiệm vụ tối thiểu cho việc tăng dần
  -h, --help                     Hiển thị thông báo trợ giúp này
```

Ví dụ về lệnh:  
Bật đèn LED, Dim ON: Đặt kênh PWM 3 được bật, Chu kỳ thành 1000000, Nhiệm vụ tối thiểu 0, Nhiệm vụ tối đa 1000000, tốc độ tăng dần + để tăng độ sáng, - để giảm độ sáng.

`ingenic-pwm -c 3 -e -p 1 -P 1000000 -n 0 -x 1000000 -r 50000`  
`ingenic-pwm -c 3 -e -p 1 -P 1000000 -n 0 -x 1000000 -r -50000`  

---

#### Bật gỡ lỗi kỹ thuật đầy đủ

Bật: Chạy `switch_debug on` để bật gỡ lỗi  
Tắt: Chạy `switch debug off` hoặc `switch_debug` để tắt đầu ra gỡ lỗi

Bật sẽ bật đầu ra gỡ lỗi kỹ thuật **ĐẦY ĐỦ** trong dmesg. 

---

#### Gỡ lỗi động

Gỡ lỗi động đã được bật trên Linux Kernel cho các nền tảng Ingenic để tắt gỡ lỗi kỹ thuật dư thừa.

https://www.kernel.org/doc/html/v4.14/admin-guide/dynamic-debug-howto.html

Gắn kết debugfs trước:  
`mount -t debugfs none /sys/kernel/debug`

Kiểm tra các mục nhập:  
`cat /sys/kernel/debug/dynamic_debug/control`

Ví dụ đầu ra:  

```
../ingenic-opensdk/kernel/avpu/t31/avpu_main.c:314 [avpu]write_reg =_ "Ghi thanh ghi ngoài phạm vi: 0x%.4X\012"
../ingenic-opensdk/kernel/avpu/t31/avpu_main.c:304 [avpu]write_reg =_ "Ghi thanh ghi: 0x%.4X: 0x%.8x\012"
../ingenic-opensdk/kernel/avpu/t31/avpu_main.c:302 [avpu]write_reg =_ "Ghi thanh ghi: 0x%.4X: 0x%.8x\012"
../ingenic-opensdk/kernel/avpu/t31/avpu_main.c:290 [avpu]read_reg =_ "Đọc thanh ghi: 0x%.4X: 0x%.8x\012"
../ingenic-opensdk/kernel/avpu/t31/avpu_main.c:234 [avpu]wait_irq =_ "Bỏ chặn kênh\012"
../ingenic-opensdk/kernel/avpu/t31/avpu_ip.c:128 [avpu]avpu_hardirq_handler =_ "ENOMEM: Bỏ lỡ ngắt\012"
../ingenic-opensdk/kernel/avpu/t31/avpu_ip.c:117 [avpu]avpu_hardirq_handler =_ "trường bit là 0\012"
/mnt/mips/external_utilities/OpenIPC/openingenic/kernel/sensors/t31/gc2053/gc2053.c:1860 [sensor_gc2053_t31]gc2053_probe =p "dò tìm ok ------->gc2053\012"
/mnt/mips/external_utilities/OpenIPC/openingenic/kernel/sensors/t31/gc2053/gc2053.c:1422 [sensor_gc2053_t31]gc2053_s_stream =p "luồng gc2053 tắt\012"
/mnt/mips/external_utilities/OpenIPC/openingenic/kernel/sensors/t31/gc2053/gc2053.c:1415 [sensor_gc2053_t31]gc2053_s_stream =p "luồng gc2053 bật\012"
/mnt/mips/external_utilities/OpenIPC/openingenic/kernel/sensors/t31/gc2053/gc2053.c:1288 [sensor_gc2053_t31]gc2053_detect =p "-----%s: %d ret = %d, v = 0x%02x\012"
/mnt/mips/external_utilities/OpenIPC/openingenic/kernel/sensors/t31/gc2053/gc2053.c:1282 [sensor_gc2053_t31]gc2053_detect =p "-----%s: %d ret = %d, v = 0x%02x\012"
```

`=_` nghĩa là đầu ra gỡ lỗi bị `tắt`, trong khi `=P` sẽ cho biết rằng đầu ra gỡ lỗi được `bật`.  

Kiểm tra `dmesg` để biết đầu ra

Lưu ý: Một số mô-đun kernel cũ có thể phàn nàn về các ký hiệu bị thiếu liên quan đến gỡ lỗi động:
```
[    4.357160] sample_core: Ký hiệu không xác định __dynamic_dev_dbg (lỗi 1)
[    4.361299] sample_hal: Ký hiệu không xác định __dynamic_dev_dbg (lỗi 1)
```
Để giải quyết vấn đề này, hãy đảm bảo bạn cập nhật toàn bộ cài đặt OpenIPC lên phiên bản mới nhất sau ngày 20/10/2023 hoặc thử cập nhật các mô-đun kernel riêng lẻ gặp sự cố. Là phương sách cuối cùng, bạn cũng có thể tắt `CONFIG_DYNAMIC_DEBUG` trong cấu hình kernel của mình, nhưng thử nghiệm rộng rãi đã cho thấy đây không phải là vấn đề.

---

#### Thay đổi tốc độ xung nhịp cảm biến động

`echo "30000000" > /proc/jz/clock/cgu_cim/rate`  
Điều này có thể được sử dụng để thay đổi cài đặt tốc độ xung nhịp MCLK cho các cảm biến hình ảnh. Bạn có thể sử dụng điều này để có được băng thông lớn hơn cho độ phân giải cao hơn cho tốc độ FPS.

---

#### Chèn hoặc xóa thiết bị SDIO động

Sử dụng các lệnh này để bật hoặc tắt thiết bị SDIO sau khi hệ thống đã khởi động.  

`echo "INSERT" > /sys/devices/platform/jzmmc_v1.2.X/present`  
`echo "REMOVE" > /sys/devices/platform/jzmmc_v1.2.X/present` 

Trong đó X = thiết bị MMC bạn muốn điều khiển  MSC0=0 MSC1=1

---

### IMP-Control

IMP-Control là một công cụ linh hoạt được thiết kế để điều khiển và cấu hình nhiều tham số trong thư viện IMP Ingenic, trong trình phát trực tuyến Majestic. Công cụ này cho phép tinh chỉnh cả cài đặt âm thanh và video để đạt được hiệu suất tối ưu trong các môi trường khác nhau.

#### Các tính năng và chức năng chính
1. **Điều chỉnh âm thanh:**
   - `aihpf`: Bật/tắt bộ lọc thông cao.
   - `aiagc`: Điều khiển khuếch đại tự động với các mức khuếch đại và bù có thể điều chỉnh.
   - `ains`: Khử nhiễu với các mức cường độ.
   - `aiaec`: Bật/tắt khử tiếng vọng.
   - `aivol` và `aovol`: Điều chỉnh âm lượng đầu vào và đầu ra âm thanh tương ứng.
   - `aigain` và `aogain`: Đặt mức khuếch đại đầu vào và đầu ra âm thanh.
   - `aialc`: Cài đặt mức khuếch đại Điều khiển mức tự động đầu vào âm thanh.

2. **Nâng cao video:**
   - `flip`: Thao tác định hướng hình ảnh.
   - `contrast`, `brightness`, `saturation`, `sharpness`: Điều chỉnh chất lượng hình ảnh cơ bản.
   - `sinter`, `temper`: Nâng cao hình ảnh bằng cách điều chỉnh cường độ sinter và temper.
   - `aecomp`: Bù phơi sáng tự động.
   - `dpc`, `drc`: Điều khiển cường độ DPC và DRC.
   - `hilight`: Điều chỉnh cường độ điểm sáng.
   - `again`, `dgain`: Đặt mức khuếch đại tương tự và kỹ thuật số.
   - `hue`: Sửa đổi sắc độ màu.
   - `ispmode`: Chuyển đổi giữa chế độ ngày và đêm.
   - `flicker`: Cài đặt chống nhấp nháy.

3. **Điều khiển nâng cao:**
   - `whitebalance`: Điều chỉnh cân bằng trắng với các chế độ, mức khuếch đại màu đỏ và xanh lam.
   - `sensorfps`: Cấu hình khung hình trên giây của cảm biến.
   - `backlightcomp`: Cường độ bù sáng ngược.
   - `defogstrength`: Điều khiển cường độ khử sương mù cho hình ảnh rõ nét hơn.
   - `framerate`, `gopattr`: Quản lý tốc độ khung hình và các thuộc tính Nhóm hình ảnh (GOP).
   - `setbitrate`, `setgoplength`, `setqp`, `setqpbounds`, `setqpipdelta`: Cài đặt bộ mã hóa chi tiết.
   - `rcmode`: Đặt hoặc nhận Chế độ điều khiển tốc độ.
   - `aemin`: Đặt tham số tối thiểu Phơi sáng tự động.
   - `autozoom`, `frontcrop`: Điều chỉnh cài đặt thu phóng và cắt.
   - `mask`: Đặt tham số che cho quyền riêng tư hoặc nhấn mạnh.

4. **OSD và phân tích:**
   - `getosdattr`, `getosdgrpattr`: Truy xuất các thuộc tính Hiển thị trên màn hình (OSD).
   - `getgamma`, `getevattr`, `getaeluma`, `getawbct`, `getafmetrics`, `gettotalgain`, `getaeattr`: Tìm nạp các chỉ số xử lý hình ảnh khác nhau.

5. **Thông tin hệ thống:**
   - `getimpversion`: Lấy phiên bản IMP.
   - `getcpuinfo`: Truy xuất thông tin CPU.

6. **Trình diễn và thử nghiệm:**
   - `full_demo`: Chạy bản trình diễn toàn diện về các chức năng khác nhau.

#### Cách sử dụng
Cú pháp sử dụng chung là:
```
imp-control [lệnh] [tham số]
```
Các tham số khác nhau tùy thuộc vào lệnh và trong một số trường hợp, chúng là tùy chọn để truy xuất các giá trị hiện tại.

Để nhận trợ giúp và xem danh sách các lệnh khả dụng, hãy sử dụng:
```
imp-control help
```
---
