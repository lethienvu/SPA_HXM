# Paradise HR - UI Components Documentation

> **Hệ thống UI Components hoàn chỉnh** cho SPA framework với glassmorphism effects và smooth animations

## 🚀 Khởi tạo nhanh

### 1. Thêm vào HTML

```html
<!-- Bootstrap Icons (required) -->
<link
  rel="stylesheet"
  href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css"
/>

<!-- CSS Framework -->
<link rel="stylesheet" href="./styles.css" />

<!-- UI Components -->
<script src="./components/ui-components.js"></script>
```

### 2. Sử dụng cơ bản

```javascript
// Auto-initialized khi DOM ready
// Sử dụng global UI object

UI.toast.success("Đăng nhập thành công!");
UI.modal.confirm({
  title: "Xác nhận xóa",
  content: "Bạn có chắc chắn muốn xóa nhân viên này?",
  onConfirm: () => deleteEmployee(),
});
```

---

## 🎭 1. MODAL SYSTEM

### Các loại Modal

#### Modal cơ bản

```javascript
const modalId = UI.modal.show({
  title: "Thông tin nhân viên",
  content: `
        <div class="form-group">
            <label>Họ tên</label>
            <input type="text" class="form-control" value="Nguyễn Văn A">
        </div>
    `,
  size: "md", // sm, md, lg, xl
  showCloseButton: true,
  onShow: (id) => console.log("Modal opened:", id),
  onHide: (id) => console.log("Modal closed:", id),
});
```

#### Success Modal

```javascript
UI.modal.success({
  title: "Thành công",
  content: "Nhân viên đã được thêm vào hệ thống!",
  confirmText: "OK",
  onConfirm: () => {
    window.location.reload();
  },
});
```

#### Warning Modal

```javascript
UI.modal.warning({
  title: "Cảnh báo",
  content: "Dữ liệu chưa được lưu. Bạn có muốn tiếp tục?",
  confirmText: "Có",
  cancelText: "Không",
  onConfirm: () => console.log("Continue"),
  onCancel: () => console.log("Stay"),
});
```

#### Error Modal

```javascript
UI.modal.error({
  title: "Lỗi hệ thống",
  content: "Không thể kết nối đến server. Vui lòng thử lại sau.",
  confirmText: "Thử lại",
  onConfirm: () => retryAction(),
});
```

#### Confirm Dialog

```javascript
UI.modal.confirm({
  title: "Xác nhận xóa",
  content: "Bạn có chắc chắn muốn xóa 5 nhân viên đã chọn?",
  confirmText: "Xóa",
  cancelText: "Hủy",
  type: "error", // Màu đỏ cho hành động nguy hiểm
  onConfirm: () => {
    // Xóa nhân viên
    return deleteSelectedEmployees();
  },
});
```

#### Custom Modal với nội dung phức tạp

```javascript
const formElement = document.createElement("form");
formElement.innerHTML = `
    <div class="form-group mb-3">
        <label>Họ tên *</label>
        <input type="text" class="form-control" name="fullName" required>
    </div>
    <div class="form-group mb-3">
        <label>Email *</label>
        <input type="email" class="form-control" name="email" required>
    </div>
    <div class="form-group mb-3">
        <label>Phòng ban</label>
        <select class="form-control" name="department">
            <option>Nhân sự</option>
            <option>Kỹ thuật</option>
            <option>Marketing</option>
        </select>
    </div>
`;

UI.modal.show({
  title: "Thêm nhân viên mới",
  content: formElement,
  size: "lg",
  confirmText: "Lưu",
  cancelText: "Hủy",
  onConfirm: (modalId) => {
    const formData = new FormData(formElement);
    // Process form data
    return saveEmployee(formData);
  },
});
```

### Modal Methods

```javascript
// Đóng modal cụ thể
UI.modal.close(modalId);

// Đóng tất cả modals
UI.modal.closeAll();
```

---

## 🍞 2. TOAST NOTIFICATIONS

### Các loại Toast

#### Success Toast

```javascript
UI.toast.success("Nhân viên đã được thêm thành công!");

// Với options
UI.toast.success("Dữ liệu đã được lưu!", {
  duration: 3000,
  showIcon: true,
  showCloseButton: true,
});
```

#### Warning Toast

```javascript
UI.toast.warning("Vui lòng kiểm tra lại thông tin trước khi lưu");
```

#### Error Toast

```javascript
UI.toast.error("Không thể kết nối đến server", {
  duration: 0, // Persistent
  actions: [
    {
      text: "Thử lại",
      type: "primary",
      handler: () => retryConnection(),
    },
  ],
});
```

#### Info Toast

```javascript
UI.toast.info("Có 3 thông báo mới chưa đọc", {
  onClick: () => openNotifications(),
});
```

#### Custom Toast

```javascript
UI.toast.show("Tin nhắn tùy chỉnh", {
  type: "info",
  title: "Cập nhật hệ thống",
  duration: 5000,
  showIcon: true,
  showCloseButton: true,
  customClass: "my-custom-toast",
  actions: [
    {
      text: "Xem chi tiết",
      type: "primary",
      handler: (toastId) => {
        console.log("View details clicked");
        // Toast sẽ tự đóng trừ khi return false
      },
    },
    {
      text: "Bỏ qua",
      type: "ghost",
      handler: (toastId) => {
        console.log("Dismissed");
      },
    },
  ],
  onClose: (toastId) => {
    console.log("Toast closed:", toastId);
  },
});
```

### Toast Methods

```javascript
// Xóa tất cả toasts
UI.toast.clear();

// Xóa toast cụ thể
const toastId = UI.toast.info("Message");
setTimeout(() => UI.toast.hide(toastId), 2000);
```

---

## ⏳ 3. LOADING SYSTEM

### Full Screen Loading

#### Basic Loading

```javascript
const loadingId = UI.loading.show({
  message: "Đang tải dữ liệu...",
  spinner: "border", // border, dots, pulse
  size: "lg",
});

// Hide loading
setTimeout(() => {
  UI.loading.hide(loadingId);
}, 3000);
```

#### Loading với Promise

```javascript
// Tự động show/hide loading
UI.loading
  .withLoading(
    fetch("/api/employees").then((r) => r.json()),
    "Đang tải danh sách nhân viên..."
  )
  .then((data) => {
    console.log("Data loaded:", data);
  })
  .catch((error) => {
    UI.toast.error("Lỗi tải dữ liệu");
  });
```

### Button Loading

#### Manual Button Loading

```javascript
const submitBtn = document.getElementById("submitBtn");

const buttonLoading = UI.loading.button(submitBtn, "Đang lưu...");

// Simulate async operation
setTimeout(() => {
  buttonLoading.hide();
}, 2000);
```

#### Auto Form Loading

```html
<!-- Tự động show loading khi submit -->
<form data-loading data-loading-text="Đang xử lý...">
  <input type="text" name="name" required />
  <button type="submit" class="btn btn-primary">Lưu</button>
</form>
```

### Progress Bar

#### Basic Progress

```javascript
const progress = UI.loading.progress({
  value: 0,
  max: 100,
  showLabel: true,
  label: "Đang upload file...",
  animated: true,
});

// Update progress
let value = 0;
const interval = setInterval(() => {
  value += 10;
  progress.update(value);

  if (value >= 100) {
    clearInterval(interval);
    setTimeout(() => progress.destroy(), 1000);
  }
}, 200);
```

#### File Upload Progress

```javascript
function uploadFile(file) {
  const progress = UI.loading.progress({
    value: 0,
    max: 100,
    showLabel: true,
    label: `Đang upload ${file.name}...`,
    animated: true,
  });

  const formData = new FormData();
  formData.append("file", file);

  const xhr = new XMLHttpRequest();

  xhr.upload.addEventListener("progress", (e) => {
    if (e.lengthComputable) {
      const percentComplete = (e.loaded / e.total) * 100;
      progress.update(percentComplete);
    }
  });

  xhr.addEventListener("load", () => {
    progress.update(100);
    UI.toast.success("File đã được upload thành công!");
    setTimeout(() => progress.destroy(), 1000);
  });

  xhr.open("POST", "/api/upload");
  xhr.send(formData);
}
```

### Skeleton Loading

#### List Skeleton

```javascript
const listContainer = document.getElementById("employeeList");

// Show skeleton
const skeletonId = UI.loading.createSkeletonList(listContainer, 5, "list");

// Load data và remove skeleton
fetch("/api/employees")
  .then((r) => r.json())
  .then((data) => {
    UI.loading.removeSkeleton(listContainer);
    renderEmployeeList(data);
  });
```

#### Individual Skeletons

```javascript
// Text skeleton
const textSkeleton = UI.loading.createSkeleton("text", { width: "60%" });

// Avatar skeleton
const avatarSkeleton = UI.loading.createSkeleton("avatar", { size: "48px" });

// Button skeleton
const buttonSkeleton = UI.loading.createSkeleton("button", {
  width: "120px",
  height: "40px",
});

// Card skeleton
const cardSkeleton = UI.loading.createSkeleton("card", {
  height: "200px",
});
```

---

## 🚨 4. ALERT SYSTEM

### Static Alerts

#### Basic Alerts

```javascript
UI.alert.success("Thao tác đã được thực hiện thành công!");
UI.alert.warning("Vui lòng kiểm tra lại thông tin");
UI.alert.error("Có lỗi xảy ra trong quá trình xử lý");
UI.alert.info("Thông tin được cập nhật định kỳ mỗi 5 phút");
```

#### Alert với Actions

```javascript
UI.alert.warning("Phiên làm việc sắp hết hạn", {
  dismissible: true,
  actions: [
    {
      text: "Gia hạn",
      type: "primary",
      handler: () => extendSession(),
    },
    {
      text: "Đăng xuất",
      type: "secondary",
      handler: () => logout(),
    },
  ],
});
```

#### Glass Alert

```javascript
UI.alert.info("Hệ thống sẽ bảo trì từ 2:00 - 4:00 sáng mai", {
  glass: true,
  showIcon: true,
  duration: 10000,
});
```

#### Compact Alert

```javascript
UI.alert.success("Saved!", {
  compact: true,
  duration: 2000,
});
```

### System Banners

#### Top Banner

```javascript
UI.alert.banner("🎉 Chào mừng phiên bản Paradise HR v2.0!", {
  type: "success",
  position: "top",
  dismissible: true,
});
```

#### Maintenance Banner

```javascript
UI.alert.maintenance("Hệ thống sẽ bảo trì từ 23:00 hôm nay đến 1:00 ngày mai", {
  dismissible: false,
});
```

#### Bottom Banner

```javascript
UI.alert.banner("Vui lòng cập nhật trình duyệt để có trải nghiệm tốt nhất", {
  type: "warning",
  position: "bottom",
  actions: [
    {
      text: "Cập nhật ngay",
      type: "primary",
      handler: () => window.open("https://www.google.com/chrome/"),
    },
  ],
});
```

### Alert Methods

```javascript
// Dismiss alert cụ thể
UI.alert.dismiss(alertId);

// Dismiss tất cả alerts
UI.alert.dismissAll();

// Dismiss theo type
UI.alert.dismissByType("warning");
```

---

## 🎯 5. TÍCH HỢP VỚI SPA FRAMEWORK

### Auto-Integration Features

#### 1. Form Loading

```html
<!-- Tự động show loading khi submit form -->
<form data-loading data-loading-text="Đang xử lý...">
  <input type="text" name="name" required />
  <button type="submit">Lưu</button>
</form>
```

#### 2. Confirm Actions

```html
<!-- Tự động hiện confirm dialog -->
<button
  data-confirm="Bạn có chắc chắn muốn xóa?"
  data-confirm-title="Xác nhận xóa"
  onclick="deleteItem()"
>
  Xóa
</button>

<a href="/delete/123" data-confirm="Xóa nhân viên này khỏi hệ thống?">
  Xóa nhân viên
</a>
```

#### 3. AJAX Loading

```javascript
// Fetch tự động show loading và handle errors
fetch("/api/employees")
  .then((response) => response.json())
  .then((data) => {
    // Loading tự động hide
    console.log("Data:", data);
  })
  .catch((error) => {
    // Error toast tự động hiện
    console.error("Error:", error);
  });
```

#### 4. Navigation Loading

```javascript
// Router tự động show loading khi chuyển trang
router.navigate("/employees"); // Auto show/hide loading
```

### Component Integration trong các trang

#### Home Component

```javascript
// components/home.js
export default class Home extends Component {
  async render() {
    // Show skeleton while loading
    const container = document.createElement("div");
    container.innerHTML = '<div id="stats-container"></div>';

    const skeletonId = UI.loading.createSkeletonList(
      container.querySelector("#stats-container"),
      4,
      "card"
    );

    // Load data
    try {
      const stats = await this.loadStats();
      UI.loading.removeSkeleton(container.querySelector("#stats-container"));
      this.renderStats(stats, container.querySelector("#stats-container"));
    } catch (error) {
      UI.toast.error("Không thể tải thống kê");
    }

    return container;
  }

  async loadStats() {
    // This will auto-show loading overlay
    const response = await fetch("/api/stats");
    if (!response.ok) throw new Error("Failed to load stats");
    return response.json();
  }

  renderStats(stats, container) {
    container.innerHTML = `
            <div class="stats-grid">
                ${stats
                  .map(
                    (stat) => `
                    <div class="stat-card hover-lift">
                        <h3>${stat.value}</h3>
                        <p>${stat.label}</p>
                    </div>
                `
                  )
                  .join("")}
            </div>
        `;
  }
}
```

#### Users Component

```javascript
// components/users.js
export default class Users extends Component {
  async render() {
    const container = document.createElement("div");
    container.innerHTML = `
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2>Quản lý nhân viên</h2>
                <button class="btn btn-primary" id="addEmployeeBtn">
                    <i class="bi bi-plus"></i> Thêm nhân viên
                </button>
            </div>
            <div id="employeeList"></div>
        `;

    // Setup events
    container.querySelector("#addEmployeeBtn").addEventListener("click", () => {
      this.showAddEmployeeModal();
    });

    // Load employees
    await this.loadEmployees(container.querySelector("#employeeList"));

    return container;
  }

  async loadEmployees(listContainer) {
    // Show skeleton
    const skeletonId = UI.loading.createSkeletonList(listContainer, 5, "list");

    try {
      const employees = await fetch("/api/employees").then((r) => r.json());
      UI.loading.removeSkeleton(listContainer);
      this.renderEmployeeList(employees, listContainer);
    } catch (error) {
      UI.alert.error("Không thể tải danh sách nhân viên");
    }
  }

  showAddEmployeeModal() {
    const form = this.createEmployeeForm();

    UI.modal.show({
      title: "Thêm nhân viên mới",
      content: form,
      size: "lg",
      confirmText: "Lưu",
      cancelText: "Hủy",
      onConfirm: async (modalId) => {
        const formData = new FormData(form);

        try {
          await this.saveEmployee(formData);
          UI.toast.success("Nhân viên đã được thêm thành công!");
          this.loadEmployees(document.querySelector("#employeeList"));
          return true; // Close modal
        } catch (error) {
          UI.toast.error("Lỗi khi lưu nhân viên");
          return false; // Keep modal open
        }
      },
    });
  }

  createEmployeeForm() {
    const form = document.createElement("form");
    form.innerHTML = `
            <div class="row">
                <div class="col-md-6">
                    <div class="form-group mb-3">
                        <label>Họ tên *</label>
                        <input type="text" class="form-control" name="fullName" required>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="form-group mb-3">
                        <label>Email *</label>
                        <input type="email" class="form-control" name="email" required>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="form-group mb-3">
                        <label>Phòng ban</label>
                        <select class="form-control" name="department">
                            <option>Nhân sự</option>
                            <option>Kỹ thuật</option>
                            <option>Marketing</option>
                        </select>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="form-group mb-3">
                        <label>Chức vụ</label>
                        <input type="text" class="form-control" name="position">
                    </div>
                </div>
            </div>
        `;
    return form;
  }

  async saveEmployee(formData) {
    const response = await fetch("/api/employees", {
      method: "POST",
      body: formData,
    });

    if (!response.ok) {
      throw new Error("Failed to save employee");
    }

    return response.json();
  }

  renderEmployeeList(employees, container) {
    container.innerHTML = employees
      .map(
        (emp) => `
            <div class="card-glass hover-lift mb-3">
                <div class="card-body">
                    <div class="d-flex align-items-center">
                        <div class="avatar me-3">
                            ${
                              emp.avatar
                                ? `<img src="${emp.avatar}" alt="${emp.name}">`
                                : `<div class="avatar-placeholder">${emp.name.charAt(
                                    0
                                  )}</div>`
                            }
                        </div>
                        <div class="flex-grow-1">
                            <h5 class="mb-1">${emp.name}</h5>
                            <p class="text-muted mb-0">${emp.department} - ${
          emp.position
        }</p>
                        </div>
                        <div class="actions">
                            <button class="btn btn-ghost btn-sm" onclick="editEmployee(${
                              emp.id
                            })">
                                <i class="bi bi-pencil"></i>
                            </button>
                            <button class="btn btn-ghost btn-sm text-danger" 
                                    data-confirm="Xóa nhân viên ${emp.name}?"
                                    onclick="deleteEmployee(${emp.id})">
                                <i class="bi bi-trash"></i>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        `
      )
      .join("");
  }
}
```

---

## 🛠️ 6. ADVANCED USAGE

### Custom Styling

#### CSS Variables Customization

```css
:root {
  /* Override component colors */
  --toast-success-bg: #10b981;
  --toast-error-bg: #ef4444;
  --modal-backdrop-blur: blur(30px);
  --loading-spinner-color: #71c11d;
}
```

#### Custom Component Classes

```css
/* Custom toast styling */
.my-custom-toast {
  border-left: 4px solid var(--brand-primary);
  background: linear-gradient(
    135deg,
    rgba(113, 193, 29, 0.1),
    rgba(113, 193, 29, 0.05)
  );
}

/* Custom modal styling */
.large-modal {
  max-width: 90vw !important;
  width: 90vw !important;
}
```

### Component Lifecycle Hooks

#### Modal Lifecycle

```javascript
UI.modal.show({
  title: "Lifecycle Demo",
  content: "Modal with lifecycle hooks",
  onShow: (modalId) => {
    console.log("Modal shown:", modalId);
    // Initialize form validation, focus first input, etc.
  },
  onHide: (modalId) => {
    console.log("Modal hidden:", modalId);
    // Cleanup, save draft, etc.
  },
});
```

#### Toast Lifecycle

```javascript
UI.toast.success("Success message", {
  onClose: (toastId) => {
    console.log("Toast closed:", toastId);
    // Analytics tracking, cleanup, etc.
  },
});
```

### Bulk Operations

#### Bulk Actions with Progress

```javascript
async function bulkDeleteEmployees(employeeIds) {
  const progress = UI.loading.progress({
    value: 0,
    max: employeeIds.length,
    showLabel: true,
    label: "Đang xóa nhân viên...",
    animated: true,
  });

  let processed = 0;
  const results = [];

  for (const id of employeeIds) {
    try {
      await deleteEmployee(id);
      results.push({ id, success: true });
      processed++;
      progress.update(processed);
    } catch (error) {
      results.push({ id, success: false, error });
      processed++;
      progress.update(processed);
    }
  }

  progress.destroy();

  const successCount = results.filter((r) => r.success).length;
  const failCount = results.length - successCount;

  if (failCount === 0) {
    UI.toast.success(`Đã xóa thành công ${successCount} nhân viên`);
  } else {
    UI.toast.warning(
      `Xóa thành công ${successCount}, thất bại ${failCount} nhân viên`
    );
  }
}
```

---

## 📱 7. MOBILE OPTIMIZATION

### Responsive Behavior

- **Toasts**: Tự động chuyển về bottom position trên mobile
- **Modals**: Tự động full-width trên mobile
- **Loading**: Optimized spinner sizes cho touch devices
- **Alerts**: Responsive padding và font sizes

### Touch Interactions

```javascript
// Mobile-optimized touch events
UI.toast.success("Message", {
  // Longer duration on mobile
  duration: window.innerWidth <= 768 ? 5000 : 3000,
});
```

---

## 🔧 8. DEBUGGING & TROUBLESHOOTING

### Debug Mode

```javascript
// Enable debug logging
window.uiComponents.debug = true;

// Check component status
console.log("Components ready:", window.uiComponents.isReady());
console.log("Modal instance:", window.uiComponents.getComponent("modal"));
```

### Common Issues

#### Components not working

```javascript
// Check if components are loaded
if (!window.uiComponents.isReady()) {
  console.log("Components not ready yet");

  // Wait for initialization
  setTimeout(() => {
    UI.toast.info("Components ready!");
  }, 1000);
}
```

#### Cleanup on navigation

```javascript
// In SPA router
router.beforeNavigate(() => {
  // Cleanup all components
  window.uiComponents.cleanup();
});
```

---

## 📊 9. PERFORMANCE TIPS

### Lazy Loading

```javascript
// Components auto-load only when needed
// No performance impact if not used
```

### Memory Management

```javascript
// Auto-cleanup prevents memory leaks
// Manual cleanup for large operations
UI.toast.clear();
UI.modal.closeAll();
UI.alert.dismissAll();
```

### Optimization

```javascript
// Reduce animations on low-end devices
if (navigator.hardwareConcurrency < 4) {
  document.documentElement.style.setProperty("--duration-normal", "150ms");
}
```

---

## 🎨 10. THEMING & CUSTOMIZATION

### Dark Mode Support

```css
@media (prefers-color-scheme: dark) {
  :root {
    --glass-primary: rgba(0, 0, 0, 0.25);
    --glass-border-light: rgba(255, 255, 255, 0.1);
  }
}
```

### Brand Customization

```css
:root {
  --brand-primary: #your-brand-color;
  --brand-secondary: #your-secondary-color;
}
```

---

_Paradise HR UI Components - Modern, accessible, và responsive UI library cho enterprise applications_

**Version**: 1.0.0  
**Documentation**: Lê Thiên Vũ  
**Last Updated**: Tháng 11, 2025
