# Paradise Icon System

Hệ thống icon SVG sprite tùy chỉnh cho Paradise HR với màu sắc thương hiệu.

## 📁 Cấu trúc

```
assets/
├── icons-sprite.svg        # SVG sprite chứa tất cả icons
└── paradise-icons.css      # CSS styles cho icon system

components/
└── icons.js                # JavaScript helper cho icons
```

## 🎨 Màu Sắc Thương Hiệu

### Gradients

- **Paradise Gradient**: `#73c41d → #71c11d` (Green gradient chính)
- **Paradise Gradient Dark**: `#004c39 → #004b38` (Dark green gradient)

### Solid Colors

- **Primary Green**: `#72c31d`, `#71c11d`, `#73c41d`
- **Dark Green**: `#004c39`, `#004b38`
- **Light**: `#fbfcfc`

## 📦 Icons Có Sẵn (26 icons)

### Navigation & Layout

- `home` - Trang chủ
- `menu` - Menu
- `component` - Component

### Users & Organization

- `users` - Người dùng
- `organization` - Tổ chức

### Documents & Data

- `document` - Tài liệu
- `calendar` - Lịch
- `payroll` - Bảng lương

### Actions

- `plus` - Thêm
- `edit` - Sửa
- `delete` - Xóa
- `check` - Xác nhận
- `close` - Đóng
- `upload` - Upload
- `download` - Download

### Navigation

- `arrow-left` - Mũi tên trái
- `arrow-right` - Mũi tên phải
- `arrow-up` - Mũi tên lên
- `arrow-down` - Mũi tên xuống

### Utilities

- `search` - Tìm kiếm
- `filter` - Lọc
- `settings` - Cài đặt
- `notification` - Thông báo
- `eye` - Hiện
- `eye-off` - Ẩn
- `clock` - Đồng hồ
- `loading` - Loading
- `warning` - Cảnh báo
- `info` - Thông tin

## 🚀 Cách Sử Dụng

### 1. Icon Cơ Bản

```javascript
// Tạo icon HTML string
UI.icon.create("home");

// Với options
UI.icon.create("users", {
  size: "lg", // xs, sm, md, lg, xl, 2xl
  color: "primary", // primary, secondary, dark, light, success, warning, danger, info
  interactive: true, // Hover effects
  animation: "spin", // rotate, spin, pulse
  ariaLabel: "Users", // Accessibility
});
```

### 2. Icon với Container

```javascript
UI.icon.withContainer("notification", {
  containerSize: "md", // sm, md, lg
  containerVariant: "primary", // primary, secondary, glass
  interactive: true,
  size: "md",
  color: "light",
});
```

### 3. Icon với Badge

```javascript
UI.icon.withBadge("notification", 5, {
  size: "lg",
  color: "primary",
});
```

### 4. Tạo DOM Element

```javascript
// Tạo actual DOM node
const icon = UI.icon.createElement("home", { size: "lg" });
document.body.appendChild(icon);
```

### 5. Render Icon Grid

```javascript
// Hiển thị tất cả icons
UI.icon.renderGrid("containerId");
```

### 6. Replace Bootstrap Icons

```javascript
// Tự động thay thế Bootstrap Icons
UI.icon.replaceBootstrapIcons(".bi");
```

## 💅 CSS Classes

### Size Classes

```css
.paradise-icon--xs    /* 16px */
/* 16px */
.paradise-icon--sm    /* 20px */
.paradise-icon--md    /* 24px - default */
.paradise-icon--lg    /* 32px */
.paradise-icon--xl    /* 48px */
.paradise-icon--2xl; /* 64px */
```

### Color Classes

```css
.paradise-icon--primary    /* #72c31d */
/* #72c31d */
.paradise-icon--secondary  /* #71c11d */
.paradise-icon--dark      /* #004c39 */
.paradise-icon--light     /* #fbfcfc */
.paradise-icon--success   /* #73c41d */
.paradise-icon--warning   /* #f59e0b */
.paradise-icon--danger    /* #ef4444 */
.paradise-icon--info; /* #3b82f6 */
```

### Animation Classes

```css
.paradise-icon--rotate     /* Continuous rotation */
/* Continuous rotation */
.paradise-icon--spin       /* Fast spin */
.paradise-icon--pulse      /* Pulse effect */
.paradise-icon--interactive; /* Hover effects */
```

## 🎯 Ví Dụ Thực Tế

### Button với Icon

```html
<button class="btn btn-primary">
  ${UI.icon.create('plus', { size: 'sm' })} Thêm Mới
</button>
```

### Input với Icon

```html
<div class="input-group-icon">
  ${UI.icon.create('search', { size: 'sm' })}
  <input type="text" class="form-control" placeholder="Tìm kiếm..." />
</div>
```

### Navigation Link

```html
<a class="nav-link" href="/users">
  ${UI.icon.create('users', { size: 'sm' })}
  <span>Người Dùng</span>
</a>
```

### Card Header

```html
<div class="card-header">
  ${UI.icon.withContainer('document', { containerVariant: 'primary', size: 'md'
  })}
  <h3>Tài Liệu</h3>
</div>
```

### Notification Badge

```html
<a href="/notifications">
  ${UI.icon.withBadge('notification', 5, { size: 'lg', color: 'primary' })}
</a>
```

## 🔧 API Reference

### UI.icon.create(name, options)

Tạo icon HTML string.

**Parameters:**

- `name` (string): Tên icon
- `options` (object): Configuration options
  - `size`: xs|sm|md|lg|xl|2xl
  - `color`: primary|secondary|dark|light|success|warning|danger|info
  - `className`: Custom CSS classes
  - `interactive`: Enable hover effects
  - `animation`: rotate|spin|pulse
  - `ariaLabel`: Accessibility label

**Returns:** HTML string

### UI.icon.createElement(name, options)

Tạo icon DOM element.

**Returns:** SVGElement

### UI.icon.withContainer(name, options)

Tạo icon với container background.

**Additional Options:**

- `containerSize`: sm|md|lg
- `containerVariant`: primary|secondary|glass

**Returns:** HTML string

### UI.icon.withBadge(name, badge, options)

Tạo icon với notification badge.

**Parameters:**

- `badge` (number|string): Badge content

**Returns:** HTML string

### UI.icon.list()

Lấy danh sách tất cả icons.

**Returns:** Array of icon names

### UI.icon.renderGrid(containerId)

Render icon grid showcase.

**Parameters:**

- `containerId` (string): Container element ID

### UI.icon.replaceBootstrapIcons(selector)

Replace Bootstrap Icons với Paradise Icons.

**Parameters:**

- `selector` (string): CSS selector (default: '.bi')

## 📱 Demo Page

Truy cập `/icon-showcase` để xem:

- Tất cả icons có sẵn
- Biến thể kích thước
- Biến thể màu sắc
- Container styles
- Badge examples
- Animations
- Interactive demos
- Usage examples
- Integration examples

## 🎨 Customization

### Thay đổi màu sắc trong sprite

Edit `assets/icons-sprite.svg`:

```xml
<defs>
    <linearGradient id="paradiseGradient">
        <stop offset="0%" style="stop-color:#73c41d"/>
        <stop offset="100%" style="stop-color:#71c11d"/>
    </linearGradient>
</defs>
```

### Thêm icon mới

1. Tạo symbol mới trong `icons-sprite.svg`
2. Cập nhật `getAvailableIcons()` trong `icons.js`
3. Thêm mapping trong `replaceBootstrapIcons()` nếu cần

### Custom CSS

Override trong `styles.css`:

```css
.paradise-icon--custom {
  color: #your-color;
  width: 28px;
  height: 28px;
}
```

## ✨ Features

- ✅ Single SVG sprite file (tối ưu performance)
- ✅ Màu sắc thương hiệu Paradise HR
- ✅ 26 icons đa dụng
- ✅ Multiple sizes (6 kích thước)
- ✅ 8 color variants
- ✅ Container styles với glassmorphism
- ✅ Badge support
- ✅ Animations (rotate, spin, pulse)
- ✅ Interactive hover effects
- ✅ Accessibility support (ARIA labels)
- ✅ Easy API (UI.icon.\*)
- ✅ Bootstrap Icons replacement
- ✅ Responsive design
- ✅ Dark mode ready

## 🔄 Migration từ Bootstrap Icons

Icon system tự động replace Bootstrap Icons khi page load:

```javascript
// Auto-replacement khi load sprite
ParadiseIcon.replaceBootstrapIcons(".bi");
```

**Icon Mapping:**

- `bi-house` → `home`
- `bi-people` → `users`
- `bi-file-earmark` → `document`
- `bi-calendar` → `calendar`
- `bi-gear` → `settings`
- Và nhiều hơn nữa...

## 📝 Notes

- Icons sử dụng `currentColor` nên inherit màu từ text color
- Sprite được load vào DOM khi page load
- Tất cả icons có `viewBox="0 0 24 24"` để đảm bảo consistent sizing
- CSS variables được sử dụng với fallback values

## 🆘 Troubleshooting

**Icons không hiển thị?**

1. Kiểm tra sprite đã load: `document.querySelector('svg#icons-sprite')`
2. Check console errors
3. Verify đường dẫn: `/SPA_VU/assets/icons-sprite.svg`

**Icons sai màu?**

1. Check `currentColor` inheritance
2. Use explicit `color` option
3. Verify CSS variable values

**Icons quá lớn/nhỏ?**

1. Set explicit `size` option
2. Override với custom CSS class
3. Check parent container sizing

---

**Version:** 1.0.0  
**Author:** Paradise HR Team  
**License:** Proprietary
