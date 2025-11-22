# SPA Migration Tool

Công cụ Python để tự động migrate source code từ SPA_VU vào SQL Server tables theo kiến trúc hybrid component.

## 🚀 Cài đặt

### 1. Setup môi trường

```bash
# Clone repo hoặc cd vào thư mục
cd /path/to/SPA_HXM

# Chạy setup script (macOS/Linux)
chmod +x setup.sh
./setup.sh

# Hoặc setup thủ công:
pip3 install -r requirements.txt
```

### 2. Cấu hình database

```bash
# Copy và chỉnh sửa file config
cp .env.example .env

# Cập nhật thông tin database trong .env
DB_SERVER=localhost
DB_NAME=Paradise_HPSF
DB_USER=your_username  # Optional for Windows Auth
DB_PASSWORD=your_password
```

### 3. Cài đặt ODBC Driver (nếu chưa có)

**macOS:**

```bash
brew install msodbcsql17
```

**Ubuntu/Debian:**

```bash
curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
apt-get update
ACCEPT_EULA=Y apt-get install msodbcsql17
```

## 📖 Sử dụng

### 1. Migrate tất cả components

```bash
python3 spa_migrator.py \
    --action migrate-all \
    --source-dir ./SPA_VU \
    --db-server localhost \
    --db-name Paradise_HPSF
```

### 2. Migrate component cụ thể

```bash
python3 spa_migrator.py \
    --action migrate \
    --component dashboard \
    --source-dir ./SPA_VU \
    --db-server localhost \
    --db-name Paradise_HPSF
```

### 3. Đăng ký component mới (thủ công)

```bash
python3 spa_migrator.py \
    --action register \
    --component leave-list \
    --route "/leave" \
    --menu "MnuWPT200" \
    --title "Danh sách nghỉ phép" \
    --db-server localhost \
    --db-name Paradise_HPSF
```

### 4. Liệt kê tất cả components

```bash
python3 spa_migrator.py \
    --action list \
    --db-server localhost \
    --db-name Paradise_HPSF
```

## 🏗️ Cấu trúc Component Mapping

Tool sử dụng mapping mặc định:

| File Name       | Component ID | Route         | Menu ID    | Title              |
| --------------- | ------------ | ------------- | ---------- | ------------------ |
| home.js         | dashboard    | /             | MnuHRS2000 | Dashboard          |
| employees.js    | employees    | /employees    | MnuHRS100  | Employees          |
| requests.js     | requests     | /requests     | MnuWPT100  | Create Request     |
| attendance.js   | attendance   | /attendance   | MnuWPT206  | Attendance         |
| payroll.js      | payroll      | /payroll      | MnuHRS200  | Payroll            |
| organization.js | organization | /organization | MnuHRS300  | Organization Chart |

## 🔧 Options

### Required Parameters

- `--action`: Action to perform (`migrate`, `migrate-all`, `register`, `list`)
- `--db-server`: Database server hostname/IP
- `--db-name`: Database name

### Optional Parameters

- `--component`: Component name (required for `migrate` and `register`)
- `--source-dir`: Source directory path (default: `./SPA_VU`)
- `--db-user`: Database username (optional for Windows Auth)
- `--db-password`: Database password
- `--route`: Route pattern (required for `register`)
- `--menu`: Menu ID (for `register`)
- `--title`: Component title (for `register`)
- `--type`: Component type (default: `page`)

## 📁 Cấu trúc files được migrate

### JavaScript Components

Tool sẽ parse:

- Class name và extends Component
- HTML template từ render() method
- Các methods khác (onMount, onUnmount, etc.)
- Convert sang format phù hợp với SQL architecture

### CSS Files

- Parse toàn bộ styles.css
- Chỉ inject CSS cho main component để tránh duplicate

### Generated SQL Structure

```sql
-- Component registry
INSERT INTO tblSPA_Components (ComponentID, ComponentName, RoutePattern, MenuID, ...)

-- HTML Template
INSERT INTO tblSPA_Templates (ComponentID, TemplateType, TemplateContent)
VALUES ('dashboard', 'html', '<div>...</div>')

-- CSS Template
INSERT INTO tblSPA_Templates (ComponentID, TemplateType, TemplateContent)
VALUES ('dashboard', 'css', '.dashboard { ... }')

-- JavaScript Template
INSERT INTO tblSPA_Templates (ComponentID, TemplateType, TemplateContent)
VALUES ('dashboard', 'js', 'class DashboardComponent extends Component { ... }')
```

## 🎯 Workflow Examples

### Migrate từ source code hiện tại

```bash
# 1. Migrate tất cả components
python3 spa_migrator.py --action migrate-all --db-server localhost --db-name Paradise_HPSF

# 2. Kiểm tra kết quả
python3 spa_migrator.py --action list --db-server localhost --db-name Paradise_HPSF

# 3. Test specific component
python3 spa_migrator.py --action migrate --component dashboard --db-server localhost --db-name Paradise_HPSF
```

### Thêm component mới

```bash
# 1. Tạo component file trong SPA_VU/components/
# 2. Migrate component
python3 spa_migrator.py --action migrate --component new-component --db-server localhost --db-name Paradise_HPSF

# Hoặc đăng ký thủ công
python3 spa_migrator.py \
    --action register \
    --component new-component \
    --route "/new-route" \
    --menu "MnuXXX" \
    --title "New Component" \
    --db-server localhost \
    --db-name Paradise_HPSF
```

## 🐛 Troubleshooting

### Connection Issues

```bash
# Test ODBC drivers
odbcinst -q -d

# Test connection string
python3 -c "import pyodbc; print(pyodbc.drivers())"
```

### Permission Issues

- Đảm bảo database user có quyền INSERT/UPDATE trên tables:
  - `tblSPA_Components`
  - `tblSPA_Templates`
  - `tblSPA_Config`

### Component Parsing Issues

- Kiểm tra syntax JavaScript trong components
- Đảm bảo class extends Component
- Kiểm tra render() method return template string

## 📋 Log và Debug

Tool sẽ log chi tiết:

- ✅ Success operations
- ❌ Failed operations
- ⚠️ Warnings
- 🔍 Debug info

Log format:

```
2025-11-22 10:30:15 - INFO - Connected to database: Paradise_HPSF
2025-11-22 10:30:16 - INFO - Migrating component: dashboard
2025-11-22 10:30:16 - INFO - ✅ Inserted component: dashboard
```

## 🚀 Next Steps

Sau khi migrate thành công:

1. **Test SQL procedures:**

   ```sql
   EXEC sp_SPA_LoadFramework @LoginID = 3, @LanguageID = 'VN'
   ```

2. **Test component loading:**

   ```sql
   EXEC sp_SPA_LoadComponent @ComponentID = 'dashboard', @LoginID = 3
   ```

3. **Update application to call new procedures**

4. **Implement client-side API endpoints**
