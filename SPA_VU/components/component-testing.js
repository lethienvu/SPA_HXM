/**
 * PARADISE HR - COMPONENT TESTING PAGE
 * Trang test tất cả UI components với mô tả use cases
 */

class ComponentTesting {
  constructor() {
    this.initializeComponents();
  }

  async initializeComponents() {
    // Đảm bảo UI components đã được load
    if (typeof UIComponents !== "undefined" && !window.uiComponents) {
      window.uiComponents = new UIComponents();
      await window.uiComponents.init();
    }
  }

  render() {
    return `
            <div class="page-content">
                <div class="page-header">
                    <div class="page-header-content">
                        <h1 class="page-title">
                            <i class="bi bi-gear-wide-connected me-2"></i>
                            Component Testing Hub
                        </h1>
                        <p class="page-subtitle">
                            Test tất cả UI components với các trường hợp sử dụng thực tế trong Paradise HR
                        </p>
                    </div>
                </div>

                <div class="container-fluid">
                    <!-- Quick Actions -->
                    <div class="row mb-4">
                        <div class="col-12">
                            <div class="card glass-card">
                                <div class="card-body">
                                    <h5 class="card-title">
                                        <i class="bi bi-lightning me-2"></i>
                                        Quick Test Actions
                                    </h5>
                                    <div class="btn-group-custom">
                                        <button class="btn btn-primary" onclick="componentTesting.runFullDemo()">
                                            <i class="bi bi-play-circle me-1"></i>
                                            Run Full Demo
                                        </button>
                                        <button class="btn btn-secondary" onclick="componentTesting.clearAll()">
                                            <i class="bi bi-arrow-clockwise me-1"></i>
                                            Clear All
                                        </button>
                                        <button class="btn btn-info" onclick="componentTesting.openFullDemo()">
                                            <i class="bi bi-box-arrow-up-right me-1"></i>
                                            Open Full Demo Page
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Modal System -->
                    ${this.renderModalSection()}

                    <!-- Toast Notifications -->
                    ${this.renderToastSection()}

                    <!-- Loading System -->
                    ${this.renderLoadingSection()}

                    <!-- Alert System -->
                    ${this.renderAlertSection()}

                    <!-- Integration Examples -->
                    ${this.renderIntegrationSection()}

                    <!-- Status Display -->
                    <div class="row mt-4">
                        <div class="col-12">
                            <div class="card glass-card">
                                <div class="card-body">
                                    <h5 class="card-title">System Status</h5>
                                    <div id="testStatus" class="status-display">
                                        Ready to test components...
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        `;
  }

  renderModalSection() {
    return `
            <div class="row mb-4">
                <div class="col-12">
                    <div class="card glass-card">
                        <div class="card-header">
                            <h5 class="mb-0">
                                <i class="bi bi-window me-2"></i>
                                Modal System
                            </h5>
                            <small class="text-muted">Hộp thoại và popup cho confirmation, forms, và thông báo</small>
                        </div>
                        <div class="card-body">
                            <div class="use-cases mb-3">
                                <h6>Trường hợp sử dụng:</h6>
                                <ul class="small text-muted">
                                    <li><strong>Confirmation:</strong> Xác nhận xóa nhân viên, phê duyệt đơn từ</li>
                                    <li><strong>Forms:</strong> Thêm/sửa thông tin nhân viên, tạo đơn từ</li>
                                    <li><strong>Information:</strong> Hiển thị chi tiết bảng lương, thông báo hệ thống</li>
                                    <li><strong>Alerts:</strong> Cảnh báo lỗi, thông báo thành công</li>
                                </ul>
                            </div>
                            <div class="btn-group-custom">
                                <button class="btn btn-outline-primary" onclick="componentTesting.testBasicModal()">
                                    Basic Modal
                                </button>
                                <button class="btn btn-outline-success" onclick="componentTesting.testSuccessModal()">
                                    Success
                                </button>
                                <button class="btn btn-outline-warning" onclick="componentTesting.testWarningModal()">
                                    Warning
                                </button>
                                <button class="btn btn-outline-danger" onclick="componentTesting.testErrorModal()">
                                    Error
                                </button>
                                <button class="btn btn-outline-info" onclick="componentTesting.testInfoModal()">
                                    Info
                                </button>
                                <button class="btn btn-outline-secondary" onclick="componentTesting.testConfirmModal()">
                                    Confirm Delete
                                </button>
                                <button class="btn btn-outline-primary" onclick="componentTesting.testEmployeeForm()">
                                    Employee Form
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        `;
  }

  renderToastSection() {
    return `
            <div class="row mb-4">
                <div class="col-12">
                    <div class="card glass-card">
                        <div class="card-header">
                            <h5 class="mb-0">
                                <i class="bi bi-bell me-2"></i>
                                Toast Notifications
                            </h5>
                            <small class="text-muted">Thông báo nhanh không làm gián đoạn workflow</small>
                        </div>
                        <div class="card-body">
                            <div class="use-cases mb-3">
                                <h6>Trường hợp sử dụng:</h6>
                                <ul class="small text-muted">
                                    <li><strong>Success:</strong> Lưu thành công, gửi email thành công</li>
                                    <li><strong>Error:</strong> Upload file thất bại, mất kết nối mạng</li>
                                    <li><strong>Warning:</strong> Dung lượng gần hết, phiên làm việc sắp hết hạn</li>
                                    <li><strong>Info:</strong> Có thông báo mới, reminder meeting</li>
                                </ul>
                            </div>
                            <div class="btn-group-custom">
                                <button class="btn btn-outline-success" onclick="componentTesting.testSuccessToast()">
                                    Save Success
                                </button>
                                <button class="btn btn-outline-danger" onclick="componentTesting.testErrorToast()">
                                    Network Error
                                </button>
                                <button class="btn btn-outline-warning" onclick="componentTesting.testWarningToast()">
                                    Session Expiry
                                </button>
                                <button class="btn btn-outline-info" onclick="componentTesting.testInfoToast()">
                                    New Messages
                                </button>
                                <button class="btn btn-outline-primary" onclick="componentTesting.testActionToast()">
                                    With Actions
                                </button>
                                <button class="btn btn-outline-secondary" onclick="componentTesting.testPersistentToast()">
                                    Persistent
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        `;
  }

  renderLoadingSection() {
    return `
            <div class="row mb-4">
                <div class="col-12">
                    <div class="card glass-card">
                        <div class="card-header">
                            <h5 class="mb-0">
                                <i class="bi bi-arrow-repeat me-2"></i>
                                Loading System
                            </h5>
                            <small class="text-muted">Loading states cho tất cả async operations</small>
                        </div>
                        <div class="card-body">
                            <div class="use-cases mb-3">
                                <h6>Trường hợp sử dụng:</h6>
                                <ul class="small text-muted">
                                    <li><strong>Full Screen:</strong> Load trang, import/export data lớn</li>
                                    <li><strong>Button:</strong> Save, Delete, Send email actions</li>
                                    <li><strong>Progress:</strong> Upload files, data processing</li>
                                    <li><strong>Skeleton:</strong> Load danh sách nhân viên, reports</li>
                                </ul>
                            </div>
                            <div class="btn-group-custom">
                                <button class="btn btn-outline-primary" onclick="componentTesting.testFullScreenLoading()">
                                    Full Screen
                                </button>
                                <button class="btn btn-outline-secondary" id="btnLoadingTest" onclick="componentTesting.testButtonLoading(this)">
                                    Button Loading
                                </button>
                                <button class="btn btn-outline-info" onclick="componentTesting.testProgressBar()">
                                    Progress Bar
                                </button>
                                <button class="btn btn-outline-warning" onclick="componentTesting.testSkeletonLoading()">
                                    Skeleton List
                                </button>
                            </div>
                            <div id="loadingDemoContainer" class="mt-3"></div>
                        </div>
                    </div>
                </div>
            </div>
        `;
  }

  renderAlertSection() {
    return `
            <div class="row mb-4">
                <div class="col-12">
                    <div class="card glass-card">
                        <div class="card-header">
                            <h5 class="mb-0">
                                <i class="bi bi-exclamation-triangle me-2"></i>
                                Alert System
                            </h5>
                            <small class="text-muted">Thông báo quan trọng và system alerts</small>
                        </div>
                        <div class="card-body">
                            <div class="use-cases mb-3">
                                <h6>Trường hợp sử dụng:</h6>
                                <ul class="small text-muted">
                                    <li><strong>Success:</strong> Import data thành công, backup completed</li>
                                    <li><strong>Warning:</strong> System maintenance, data validation</li>
                                    <li><strong>Error:</strong> Service down, critical errors</li>
                                    <li><strong>Banner:</strong> Announcements, feature updates</li>
                                </ul>
                            </div>
                            <div class="btn-group-custom">
                                <button class="btn btn-outline-success" onclick="componentTesting.testSuccessAlert()">
                                    Import Success
                                </button>
                                <button class="btn btn-outline-warning" onclick="componentTesting.testWarningAlert()">
                                    Maintenance
                                </button>
                                <button class="btn btn-outline-danger" onclick="componentTesting.testErrorAlert()">
                                    Service Down
                                </button>
                                <button class="btn btn-outline-info" onclick="componentTesting.testInfoAlert()">
                                    New Features
                                </button>
                                <button class="btn btn-outline-primary" onclick="componentTesting.testTopBanner()">
                                    Top Banner
                                </button>
                            </div>
                            <div id="alertContainer" class="mt-3"></div>
                        </div>
                    </div>
                </div>
            </div>
        `;
  }

  renderIntegrationSection() {
    return `
            <div class="row mb-4">
                <div class="col-12">
                    <div class="card glass-card">
                        <div class="card-header">
                            <h5 class="mb-0">
                                <i class="bi bi-puzzle me-2"></i>
                                Real-world Integration
                            </h5>
                            <small class="text-muted">Test components trong context thực tế của Paradise HR</small>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-4">
                                    <h6>Employee Management</h6>
                                    <form id="employeeForm" onsubmit="return componentTesting.handleEmployeeSubmit(event)">
                                        <div class="mb-2">
                                            <input type="text" class="form-control form-control-sm" placeholder="Tên nhân viên" required>
                                        </div>
                                        <div class="mb-2">
                                            <input type="email" class="form-control form-control-sm" placeholder="Email" required>
                                        </div>
                                        <button type="submit" class="btn btn-primary btn-sm">
                                            <i class="bi bi-person-plus me-1"></i>
                                            Add Employee
                                        </button>
                                    </form>
                                </div>
                                <div class="col-md-4">
                                    <h6>Payroll Actions</h6>
                                    <div class="d-grid gap-2">
                                        <button class="btn btn-outline-success btn-sm" onclick="componentTesting.testPayrollProcess()">
                                            <i class="bi bi-calculator me-1"></i>
                                            Process Payroll
                                        </button>
                                        <button class="btn btn-outline-warning btn-sm" onclick="componentTesting.testPayrollReview()">
                                            <i class="bi bi-eye me-1"></i>
                                            Review Payroll
                                        </button>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <h6>System Actions</h6>
                                    <div class="d-grid gap-2">
                                        <button class="btn btn-outline-danger btn-sm" onclick="componentTesting.testDataExport()">
                                            <i class="bi bi-download me-1"></i>
                                            Export Data
                                        </button>
                                        <button class="btn btn-outline-info btn-sm" onclick="componentTesting.testSystemBackup()">
                                            <i class="bi bi-shield-check me-1"></i>
                                            System Backup
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        `;
  }

  // Test Methods
  updateStatus(message) {
    const statusEl = document.getElementById("testStatus");
    if (statusEl) {
      statusEl.textContent = new Date().toLocaleTimeString() + ": " + message;
    }
  }

  testBasicModal() {
    if (!window.UI?.modal) {
      this.updateStatus("UI.modal not available");
      return;
    }

    UI.modal.show({
      title: "Employee Details",
      content: `
                <div class="employee-details">
                    <div class="row">
                        <div class="col-4">
                            <div class="avatar-placeholder"></div>
                        </div>
                        <div class="col-8">
                            <h6>Nguyễn Văn A</h6>
                            <p class="mb-1"><small>Senior Developer</small></p>
                            <p class="mb-1"><small>IT Department</small></p>
                            <p class="mb-0"><small>nguyenvana@company.com</small></p>
                        </div>
                    </div>
                </div>
            `,
      size: "md",
    });
    this.updateStatus("Employee details modal opened");
  }

  testSuccessModal() {
    UI.modal?.success({
      title: "Payroll Processed Successfully",
      content:
        "Monthly payroll for March 2024 has been processed successfully. 245 employees were paid.",
      confirmText: "View Report",
    });
    this.updateStatus("Payroll success modal shown");
  }

  testErrorModal() {
    UI.modal?.error({
      title: "Email Service Unavailable",
      content:
        "Unable to send payroll notifications. The email service is currently down. Please try again later.",
      confirmText: "Retry",
      cancelText: "Cancel",
    });
    this.updateStatus("Email error modal shown");
  }

  testConfirmModal() {
    UI.modal?.confirm({
      title: "Delete Employee Record",
      content:
        "Are you sure you want to delete Nguyễn Văn A's employee record? This action cannot be undone.",
      confirmText: "Delete",
      cancelText: "Cancel",
      type: "error",
      onConfirm: () => {
        this.updateStatus("Employee deletion confirmed");
        UI.toast?.success("Employee record deleted successfully");
      },
    });
    this.updateStatus("Delete confirmation modal shown");
  }

  testSuccessToast() {
    UI.toast?.success("Employee data saved successfully!", {
      duration: 3000,
    });
    this.updateStatus("Success toast shown");
  }

  testErrorToast() {
    UI.toast?.error("Failed to connect to HR database", {
      duration: 5000,
      actions: [
        {
          text: "Retry",
          type: "primary",
          handler: () => this.updateStatus("Retry clicked"),
        },
      ],
    });
    this.updateStatus("Error toast with action shown");
  }

  testFullScreenLoading() {
    const loadingId = UI.loading?.show({
      message: "Processing payroll data...",
      spinner: "border",
    });

    setTimeout(() => {
      UI.loading?.hide(loadingId);
      UI.toast?.success("Payroll processing completed!");
      this.updateStatus("Full screen loading test completed");
    }, 3000);
  }

  testButtonLoading(button) {
    const loading = UI.loading?.button(button, "Saving...");

    setTimeout(() => {
      loading?.hide();
      UI.toast?.success("Employee data saved!");
      this.updateStatus("Button loading test completed");
    }, 2000);
  }

  async runFullDemo() {
    this.updateStatus("Starting full component demo...");

    // Sequence demo
    await this.sleep(500);
    UI.toast?.info("Demo started - Testing all components...");

    await this.sleep(1000);
    this.testSuccessToast();

    await this.sleep(2000);
    UI.alert?.warning("This is a demo warning alert", {
      container: document.getElementById("alertContainer"),
      duration: 4000,
    });

    await this.sleep(3000);
    const loadingId = UI.loading?.show({ message: "Demo loading..." });

    await this.sleep(2000);
    UI.loading?.hide(loadingId);

    await this.sleep(500);
    UI.modal?.success({
      title: "Demo Complete!",
      content: "All Paradise HR components are working perfectly!",
      confirmText: "Excellent!",
    });

    this.updateStatus("Full demo completed successfully");
  }

  clearAll() {
    UI.modal?.closeAll();
    UI.toast?.clear();
    UI.loading?.clearAll();
    UI.alert?.dismissAll();

    const containers = ["alertContainer", "loadingDemoContainer"];
    containers.forEach((id) => {
      const el = document.getElementById(id);
      if (el) el.innerHTML = "";
    });

    this.updateStatus("All components cleared");
  }

  openFullDemo() {
    window.open("components-demo.html", "_blank");
    this.updateStatus("Full demo page opened in new tab");
  }

  sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }

  // Event handlers for integration tests
  handleEmployeeSubmit(event) {
    event.preventDefault();

    const formData = new FormData(event.target);
    const name = formData.get("name") || "New Employee";

    const loadingId = UI.loading?.show({ message: "Adding employee..." });

    setTimeout(() => {
      UI.loading?.hide(loadingId);
      UI.toast?.success(`Employee "${name}" added successfully!`);
      event.target.reset();
      this.updateStatus("Employee added via form");
    }, 1500);

    return false;
  }

  testPayrollProcess() {
    UI.modal?.confirm({
      title: "Process Monthly Payroll",
      content:
        "This will process payroll for all 245 active employees. This action cannot be undone.",
      confirmText: "Process Payroll",
      cancelText: "Cancel",
      type: "warning",
      onConfirm: () => {
        const loadingId = UI.loading?.show({
          message: "Processing payroll...",
        });
        setTimeout(() => {
          UI.loading?.hide(loadingId);
          UI.toast?.success("Payroll processed for 245 employees");
          this.updateStatus("Payroll processing completed");
        }, 3000);
      },
    });
  }

  mount() {
    // Initialize when component is mounted
    this.initializeComponents();
  }
}

// Export for SPA framework
window.ComponentTesting = ComponentTesting;
