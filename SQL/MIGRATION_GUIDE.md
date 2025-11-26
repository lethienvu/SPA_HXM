# 📋 HƯỚNG DẪN MIGRATION SPA_VU

## 📁 File đã tạo
- `SQL/SAFE_MIGRATION_SPA_VU.sql` - Script migration an toàn với backup & rollback

---

## 🚀 CÁCH CHẠY MIGRATION

### Bước 1: Mở SQL Server Management Studio (SSMS)
1. Kết nối đến SQL Server của bạn
2. Mở file `SQL/SAFE_MIGRATION_SPA_VU.sql`

### Bước 2: Cấu hình Database
Ở dòng đầu tiên của script, thay đổi tên database nếu cần:
```sql
USE [Paradise_HPSF]; -- ⬅️ THAY ĐỔI NẾU DATABASE KHÁC
```

### Bước 3: Chạy Script
- Nhấn **F5** hoặc click **Execute**
- Script sẽ tự động:
  1. ✅ Tạo backup table với timestamp
  2. ✅ Bắt đầu transaction
  3. ✅ Xóa dữ liệu cũ của component `ess-dashboard`
  4. ✅ Insert HTML, CSS, JS templates mới
  5. ✅ Commit nếu thành công, Rollback nếu lỗi

### Bước 4: Kiểm tra kết quả
Sau khi chạy xong, bạn sẽ thấy:
```
✅ MIGRATION HOÀN TẤT THÀNH CÔNG!
Backup table: tblSPA_Templates_backup_20251126_143052
```

---

## 🔄 ROLLBACK (Hoàn tác nếu cần)

Nếu có vấn đề, mở file `SAFE_MIGRATION_SPA_VU.sql`, cuộn xuống phần **ROLLBACK SCRIPT** và:

1. Uncomment các lệnh rollback
2. Thay `tblSPA_Templates_backup_YYYYMMDD_HHMMSS` bằng tên backup table thực
3. Chạy phần rollback

Ví dụ:
```sql
-- Xóa dữ liệu mới
DELETE FROM tblSPA_Templates WHERE ComponentID = 'ess-dashboard';

-- Khôi phục từ backup
INSERT INTO tblSPA_Templates 
SELECT * FROM tblSPA_Templates_backup_20251126_143052;
```

---

## 🧹 CLEANUP (Sau khi xác nhận OK)

Sau vài ngày khi đã xác nhận migration hoạt động tốt:

1. Mở phần **CLEANUP SCRIPT** ở cuối file
2. Uncomment và chạy để xóa backup tables cũ hơn 7 ngày

---

## ⚠️ LƯU Ý QUAN TRỌNG

1. **LUÔN BACKUP** trước khi chạy bất kỳ migration nào
2. **KIỂM TRA TÊN DATABASE** trước khi chạy
3. **KHÔNG ĐÓNG SSMS** khi script đang chạy
4. **GHI LẠI TÊN BACKUP TABLE** để rollback nếu cần

---

## 📊 CẤU TRÚC DỮ LIỆU

Script sẽ cập nhật bảng `tblSPA_Templates` với 3 records:

| ComponentID | TemplateType | Description |
|-------------|--------------|-------------|
| ess-dashboard | html | Base HTML framework |
| ess-dashboard | css | Base CSS styles |
| ess-dashboard | js | JavaScript framework |

---

## 🛠️ ALTERNATIVE: Sử dụng Python Script

Nếu muốn migrate nhiều components hoặc tự động hóa:

```bash
# Cài đặt dependencies
cd Auto-Update
pip install -r requirements.txt

# Chạy quick migrator (interactive)
python quick_migrate.py

# Hoặc chạy non-interactive
python spa_migrator.py --action migrate-all \
  --source-dir ../SPA_VU \
  --db-server localhost \
  --db-name Paradise_HPSF \
  --db-user sa \
  --db-password 'YourPassword'
```

---

## 📞 HỖ TRỢ

Nếu gặp lỗi:
1. Kiểm tra error message trong SSMS
2. Xác nhận database name chính xác
3. Kiểm tra quyền INSERT/DELETE trên bảng `tblSPA_Templates`
4. Đảm bảo bảng `tblSPA_Templates` đã tồn tại

---

*Tạo bởi: Migration Tool - 2025-11-26*
