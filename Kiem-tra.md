# Kiểm tra TT HUB 3.1.0

- LocalScript cuối: **3.149 dòng, 147.353 byte UTF-8**, trình biên dịch Luau thành công.
- UI thực tế kết hợp catalog video: **828 khẳng định mô phỏng đạt**. Kiểm tra 16 danh mục đúng thứ tự, cuộn ngang trên điện thoại/cuộn dọc trên máy tính, tìm kiếm, nhập số, chế độ nhảy, đóng/mở, kéo thanh chỉnh, dropdown và dọn kết nối.
- Các hàng chưa có xử lý là Frame không tương tác, ghi “Chưa kết nối”, không đổi trạng thái tính năng khi bấm.
- Cấu hình: **26 trường hợp không hợp lệ bị từ chối đúng**, khôi phục cấu hình hợp lệ thành công.
- Bộ cài cuối: **36 tình huống, 124 khẳng định đạt**, gồm nâng cấp 3.0 lên 3.1, giữ mã cũ trong bản dự phòng, tránh trùng tên, giữ sửa đổi khi cài lại và khôi phục khi cài lỗi.
- Bộ cài **152.575 byte UTF-8**, trong giới hạn gói StringValue. File XML được đọc lại và so khớp toàn bộ nội dung; lệnh cài cục bộ và bộ cài được biên dịch thành công.
- Đã đọc lại file Raw GitHub sau khi đăng và xác nhận trùng toàn bộ nội dung bộ cài đã kiểm tra. Commit bộ cài: `e5bcfee21c950a6b0eec128f93dc506aae5fa5c5`.
- Ảnh xem trước được dựng từ cây UI của mã Luau với mô phỏng bố cục, phục vụ kiểm tra hình thức. Không phải ảnh chụp Roblox Studio.

**Chưa chạy trực tiếp trong Roblox Studio.** Các phép kiểm tra mô phỏng không xác nhận combat/loot của một experience cụ thể. Tùy chọn riêng cho Blox Fruits như Raid, Race, boss và mua vật phẩm vẫn chưa có xử lý.
