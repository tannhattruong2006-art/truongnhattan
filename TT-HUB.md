# TT HUB 3.1 — giao diện theo video

Đã dựng lại đủ **16 danh mục theo đúng thứ tự video**, nền xanh đen, ô bật/tắt vuông, hàng nút Click, tiêu đề nhóm có đường kẻ, tìm kiếm và logo TT màu tím. Điện thoại cuộn ngang thanh danh mục; máy tính cuộn dọc bên trái.

**Đây là bản làm phần giao diện theo video. Raid, Race, boss, cửa hàng và các tùy chọn riêng của Blox Fruits chưa có xử lý; chúng hiện màu xám và ghi “Chưa kết nối”.** Các mục đó không tự bật hoặc hiển thị kết quả giả. Ba mục video không mở chi tiết cũng ghi rõ chưa có thông tin.

Menu vẫn có tám tính năng đã viết trước đó, dành cho experience của boss man trong Roblox Studio:

| Danh mục | Tính năng có xử lý |
| --- | --- |
| LocalPlayer → GRAPHICS | Giảm hiệu ứng, tăng ánh sáng |
| Farming → Setting Farm | Start Farm và chọn NPC |
| Farming Other → AUTO LOOT | Auto Loot và chọn loại vật phẩm |
| PVP → MISC PVP | Tốc độ đi, lực/độ cao nhảy, xuyên vật cản |
| ESP → ESP PLAYERS | Hiện người chơi và lọc đội đối thủ |

Auto Farm/Auto Loot cần đúng NPC, tag và cơ chế combat/loot của experience. Gói này tạo LocalScript trong map của boss man; không cài menu vào Blox Fruits của người khác.

## Cài bằng một dòng

1. Mở map trong **Roblox Studio**, bấm **Stop**.
2. Mở **Command Bar** bằng **Ctrl+9**, dán lệnh sau rồi Enter:

```luau
assert(loadstring(game:GetService("HttpService"):GetAsync("https://raw.githubusercontent.com/tannhattruong2006-art/truongnhattan/main/TTHubInstaller.luau")))()
```

3. Bộ cài tạo **StarterPlayer → StarterPlayerScripts → TTHub**. Bấm **Play** để dùng menu.

Nếu Studio báo HTTP chưa bật, vào **File → Experience Settings → Security → Allow HTTP Requests**, rồi chạy lại. Tên menu thiết lập có thể được bản Studio cũ gọi là Game Settings. [Hướng dẫn HTTP của Roblox](https://create.roblox.com/docs/cloud-services/http-service).

Lệnh `loadstring` ở đây dùng để cài trong Command Bar khi đang Stop. Mã chạy lúc Play là LocalScript thông thường.

Nếu đã cài TT HUB 3.0, bộ cài chuyển sang 3.1 và giữ mã cũ trong **TTHub_Backup_v3_0** (thêm số nếu trùng tên). Bản dự phòng được tắt. Chạy lại khi đã có 3.1 sẽ giữ nguyên mã boss man đã sửa. Các thiết lập riêng trong bản 3.0 được giữ trong bản dự phòng, cần chép lại phần CONFIG muốn dùng sang 3.1.

## Cài bằng file, không tải từ GitHub

1. Bấm **Stop**. Trong Explorer, chuột phải **Workspace → Insert → Import Roblox Model**.
2. Chọn **TTHubInstaller.rbxmx** trong thư mục này. Nếu đã có StringValue tên TTHubInstaller từ bản trước, xóa StringValue cũ trước khi nhập bản mới; đây chỉ là gói cài, không phải LocalScript đang dùng.
3. Kiểm tra **TTHubInstaller** nằm trực tiếp trong Workspace. Mở **Command Bar**, chạy:

```luau
assert(loadstring(workspace.TTHubInstaller.Value))()
```

4. Bấm **Play**.

Nếu muốn dán trực tiếp, tạo **LocalScript** trong **StarterPlayerScripts**, đặt tên **TTHub**, dán toàn bộ **TTHub.client.luau**. Tắt bản menu cũ trước khi Play để tránh hai bản điều khiển cùng lúc. Cách dán tay không gắn dấu quản lý của bộ cài.

## Chỉnh script

Bấm **Stop**, mở **StarterPlayer → StarterPlayerScripts → TTHub**. Sửa xong bấm **Ctrl+S → Play**.

- Tìm `local CONFIG = {` gần đầu file: sửa `UI.Labels.Title` để đổi tên, `UI.Labels.Subtitle` để đổi dòng chữ nhỏ.
- `UI.Accent = Color3.fromRGB(157, 105, 255)` đổi màu nhấn và logo.
- `WalkSpeed.Default`, `JumpPower.Default`, `JumpHeight.Default` đổi giá trị ban đầu. Giữ giá trị trong khoảng Min–Max.
- Tìm `local VIDEO_CATEGORIES = {` để đổi tên danh mục và các hàng giao diện. `label` là chữ hiển thị; `key` và `id` là mã liên kết, nên giữ nguyên. Đổi nhãn không tạo thêm xử lý cho mục chưa kết nối.
- Logo TT được dựng bằng Frame trong hàm `monogram`, không cần tải ảnh lên Roblox.
- `Combat.ToolNames` cần đúng tên Tool chiến đấu; mặc định rỗng nên không tự kích hoạt Tool. NPC dùng tag **FarmableEnemy** hoặc nằm trong **Workspace.Enemies**; loot dùng tag **LootChest** hoặc **DevilFruit**. Các hook `attackTarget(target)` và `collectLoot(item)` nằm trong cùng file để nối hệ thống của experience.

Nút **×** đóng menu và tắt các tính năng. Logo TT nổi hoặc **RightShift** mở lại. Nút **−** thu gọn. Ô tìm kiếm tìm cả danh mục và tính năng, hỗ trợ tiếng Việt không dấu.

Muốn hoàn tác nâng cấp: Stop, tắt **TTHub** mới, bật bản **TTHub_Backup_v3_0** rồi Play. Giữ một bản menu được bật.

## Xem trước và kiểm tra

Các ảnh **Xem-truoc-Shop.png**, **Xem-truoc-Volcano.png**, **Xem-truoc-PVP.png** được dựng từ cây giao diện của mã Luau để xem bố cục. Chúng không phải ảnh chụp Roblox Studio.

Mã Luau, UI, bộ cài và nội dung XML được kiểm tra bằng trình biên dịch và mô phỏng. Chưa chạy trực tiếp trong Roblox Studio. Chi tiết lần kiểm tra cuối nằm trong **Kiem-tra.md**.
