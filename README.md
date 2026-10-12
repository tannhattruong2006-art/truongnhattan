# MrDon Utility v2

Bộ cài menu Roblox dành cho experience của bạn. Lệnh loadstring chạy một lần trong Command Bar của Roblox Studio ở chế độ chỉnh sửa, tạo LocalScript **MrDonUtility** trong **StarterPlayer → StarterPlayerScripts**. Bấm Play sau khi cài để chạy menu.

## Cài bằng một dòng

1. Mở map trong Roblox Studio và bấm **Stop**.
2. Mở **Command Bar** bằng **Ctrl+9**, dán và chạy:

```luau
assert(loadstring(game:GetService("HttpService"):GetAsync("https://raw.githubusercontent.com/tannhattruong2006-art/truongnhattan/main/UtilityInstaller.luau")))()
```

3. Nếu Output báo HTTP bị tắt, bật **Allow HTTP Requests** trong phần **Security** của thiết lập experience rồi chạy lại.
4. Bấm **Play**. Phím **RightShift** ẩn/hiện menu theo cấu hình mặc định.

Lệnh trên là bước cài đặt trong Command Bar, không phải mã đặt vào LocalScript. Menu được tạo dùng API Roblox thông thường; không cần thêm ServerScript hay ModuleScript. [Command Bar](https://create.roblox.com/docs/studio/ui-overview), [HttpService](https://create.roblox.com/docs/reference/engine/classes/HttpService).

## Chỉnh menu đã cài

1. Bấm **Stop**.
2. Mở **Explorer → StarterPlayer → StarterPlayerScripts → MrDonUtility**.
3. Tìm `local CONFIG = {` gần đầu script, sửa giá trị rồi **Ctrl+S → Play**.

Ví dụ lựa chọn tốc độ ban đầu là 35:

```luau
WalkSpeed = { Min = 8, Max = 80, Default = 35, Step = 1 },
```

Farm nhận NPC Model có Humanoid và root part, ưu tiên tag **FarmableEnemy**, sau đó thư mục **Workspace.Enemies**. Điền đúng tên Tool trong **Combat.ToolNames** và trang bị Tool trước khi bật Farm. Loot dùng tag **LootChest** hoặc **DevilFruit**. Các kết nối chiến đấu và nhặt vật phẩm cần khớp với hệ thống của experience; menu không tự tạo sát thương hoặc phần thưởng.

Chạy lại lệnh cài sẽ giữ nguyên MrDonUtility đã có, bao gồm các thay đổi và trạng thái Enabled. Bộ cài nhận diện các bản menu v2 đã giao trước đó, tắt chúng để tránh chạy trùng và giữ mã cũ làm dự phòng.

## Chỉnh bộ cài trên GitHub

Mở **UtilityInstaller.luau → Edit**, tìm `local CONFIG = {` bên trong chuỗi **CLIENT_SOURCE**, sửa và lưu commit lên **main**. Giữ nguyên dấu mở/đóng chuỗi dài bao quanh CLIENT_SOURCE.

Thay đổi trên GitHub áp dụng cho lần cài mới. Để cài bản mới vào map đã có menu, bấm Stop, đổi tên bản **MrDonUtility** cũ để giữ dự phòng, tắt Enabled của nó rồi chạy lại lệnh. Để sửa menu của riêng map hiện tại, dùng phần chỉnh trong Studio ở trên.

## Kiểm tra

Mã bộ cài và lệnh một dòng đã qua trình biên dịch Luau; bộ cài đã qua 18 tình huống mô phỏng với 55 khẳng định. Nội dung tải từ URL Raw đã được đối chiếu với bản đã kiểm tra. Chưa chạy trực tiếp lệnh cài trong Roblox Studio.
