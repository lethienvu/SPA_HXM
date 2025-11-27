// Settings Component - Paradise HR SPA
import { Component } from "../app.js";
import {
  renderSidebarPreferencesSetting,
  setupSidebarPreferences,
} from "./sidebar-preferences.js";

export default class Settings extends Component {
  constructor(props) {
    super(props);
    this.state = {
      activeTab: "general",
      profile: {
        fullName: "Võ Thế Thiên Vũ",
        email: "thienvu@paradise.vn",
        phone: "0912345678",
        department: "IT",
        position: "System Administrator",
        avatar: "👨‍💼",
      },
      settings: {
        general: {
          language: "vi",
          theme: "light",
          timezone: "Asia/Ho_Chi_Minh",
          dateFormat: "DD/MM/YYYY",
        },
        notifications: {
          emailNotifications: true,
          pushNotifications: true,
          leaveReminder: true,
          attendanceAlert: true,
          payrollNotification: true,
          systemUpdates: false,
        },
        security: {
          twoFactor: false,
          loginAlerts: true,
          sessionTimeout: 30,
          passwordExpiry: 90,
        },
        privacy: {
          profileVisibility: "team",
          showEmail: true,
          showPhone: false,
          dataCollection: true,
        },
      },
      showChangePassword: false,
      passwordData: {
        current: "",
        new: "",
        confirm: "",
      },
      saveMessage: "",
      changesSaved: false,
    };
  }

  renderGeneralSettings() {
    const s = this.state.settings.general;
    return `
      <div class="settings-panel">
        <h3 class="panel-title">🌍 Cài đặt chung</h3>
        
        <div class="setting-item">
          <label class="setting-label">Ngôn ngữ</label>
          <select class="setting-input lang-select">
            <option value="vi" ${
              s.language === "vi" ? "selected" : ""
            }>Tiếng Việt</option>
            <option value="en" ${
              s.language === "en" ? "selected" : ""
            }>English</option>
            <option value="zh" ${
              s.language === "zh" ? "selected" : ""
            }>中文</option>
          </select>
        </div>

        <div class="setting-item">
          <label class="setting-label">Chủ đề</label>
          <div class="radio-group">
            <label class="radio-option">
              <input type="radio" name="theme" value="light" ${
                s.theme === "light" ? "checked" : ""
              } />
              <span>☀️ Sáng</span>
            </label>
            <label class="radio-option">
              <input type="radio" name="theme" value="dark" ${
                s.theme === "dark" ? "checked" : ""
              } />
              <span>🌙 Tối</span>
            </label>
          </div>
        </div>

        <div class="setting-item">
          <label class="setting-label">Múi giờ</label>
          <select class="setting-input timezone-select">
            <option value="Asia/Ho_Chi_Minh" ${
              s.timezone === "Asia/Ho_Chi_Minh" ? "selected" : ""
            }>GMT+7 (Hà Nội)</option>
            <option value="Asia/Bangkok" ${
              s.timezone === "Asia/Bangkok" ? "selected" : ""
            }>GMT+7 (Bangkok)</option>
            <option value="Asia/Shanghai" ${
              s.timezone === "Asia/Shanghai" ? "selected" : ""
            }>GMT+8 (Shanghai)</option>
          </select>
        </div>

        <div class="setting-item">
          <label class="setting-label">Định dạng ngày</label>
          <select class="setting-input date-format-select">
            <option value="DD/MM/YYYY" ${
              s.dateFormat === "DD/MM/YYYY" ? "selected" : ""
            }>DD/MM/YYYY</option>
            <option value="MM/DD/YYYY" ${
              s.dateFormat === "MM/DD/YYYY" ? "selected" : ""
            }>MM/DD/YYYY</option>
            <option value="YYYY-MM-DD" ${
              s.dateFormat === "YYYY-MM-DD" ? "selected" : ""
            }>YYYY-MM-DD</option>
          </select>
        </div>

        <div class="separator"></div>

        ${renderSidebarPreferencesSetting()}

        <button class="btn btn-primary save-settings-btn">💾 Lưu cài đặt</button>
      </div>
    `;
  }

  renderNotificationSettings() {
    const n = this.state.settings.notifications;
    return `
      <div class="settings-panel">
        <h3 class="panel-title">🔔 Thông báo</h3>
        
        <div class="toggle-item">
          <div class="toggle-info">
            <label class="toggle-label">Thông báo qua email</label>
            <p class="toggle-description">Nhận thông báo qua email</p>
          </div>
          <label class="toggle-switch">
            <input type="checkbox" class="email-notify-toggle" ${
              n.emailNotifications ? "checked" : ""
            } />
            <span class="toggle-slider"></span>
          </label>
        </div>

        <div class="toggle-item">
          <div class="toggle-info">
            <label class="toggle-label">Thông báo đẩy (Push)</label>
            <p class="toggle-description">Thông báo thời gian thực trên trình duyệt</p>
          </div>
          <label class="toggle-switch">
            <input type="checkbox" class="push-notify-toggle" ${
              n.pushNotifications ? "checked" : ""
            } />
            <span class="toggle-slider"></span>
          </label>
        </div>

        <div class="toggle-item">
          <div class="toggle-info">
            <label class="toggle-label">Nhắc nhở nghỉ phép</label>
            <p class="toggle-description">Thông báo khi có đơn nghỉ phép cần phê duyệt</p>
          </div>
          <label class="toggle-switch">
            <input type="checkbox" class="leave-reminder-toggle" ${
              n.leaveReminder ? "checked" : ""
            } />
            <span class="toggle-slider"></span>
          </label>
        </div>

        <div class="toggle-item">
          <div class="toggle-info">
            <label class="toggle-label">Cảnh báo chấm công</label>
            <p class="toggle-description">Thông báo khi quên chấm công</p>
          </div>
          <label class="toggle-switch">
            <input type="checkbox" class="attendance-alert-toggle" ${
              n.attendanceAlert ? "checked" : ""
            } />
            <span class="toggle-slider"></span>
          </label>
        </div>

        <div class="toggle-item">
          <div class="toggle-info">
            <label class="toggle-label">Thông báo lương</label>
            <p class="toggle-description">Thông báo khi lương được phát hành</p>
          </div>
          <label class="toggle-switch">
            <input type="checkbox" class="payroll-notify-toggle" ${
              n.payrollNotification ? "checked" : ""
            } />
            <span class="toggle-slider"></span>
          </label>
        </div>

        <div class="toggle-item">
          <div class="toggle-info">
            <label class="toggle-label">Cập nhật hệ thống</label>
            <p class="toggle-description">Thông báo về cập nhật và bảo trì hệ thống</p>
          </div>
          <label class="toggle-switch">
            <input type="checkbox" class="system-updates-toggle" ${
              n.systemUpdates ? "checked" : ""
            } />
            <span class="toggle-slider"></span>
          </label>
        </div>

        <button class="btn btn-primary save-settings-btn">💾 Lưu cài đặt</button>
      </div>
    `;
  }

  renderSecuritySettings() {
    const sec = this.state.settings.security;
    return `
      <div class="settings-panel">
        <h3 class="panel-title">🔐 Bảo mật</h3>
        
        <div class="toggle-item">
          <div class="toggle-info">
            <label class="toggle-label">Xác thực hai yếu tố (2FA)</label>
            <p class="toggle-description">Bảo vệ tài khoản bằng xác thực hai yếu tố</p>
          </div>
          <label class="toggle-switch">
            <input type="checkbox" class="two-factor-toggle" ${
              sec.twoFactor ? "checked" : ""
            } />
            <span class="toggle-slider"></span>
          </label>
        </div>

        <div class="toggle-item">
          <div class="toggle-info">
            <label class="toggle-label">Cảnh báo đăng nhập</label>
            <p class="toggle-description">Thông báo khi có hoạt động đăng nhập mới</p>
          </div>
          <label class="toggle-switch">
            <input type="checkbox" class="login-alerts-toggle" ${
              sec.loginAlerts ? "checked" : ""
            } />
            <span class="toggle-slider"></span>
          </label>
        </div>

        <div class="setting-item">
          <label class="setting-label">Thời gian hết phiên (phút)</label>
          <input type="number" class="setting-input session-timeout" value="${
            sec.sessionTimeout
          }" min="10" max="480" />
        </div>

        <div class="setting-item">
          <label class="setting-label">Hết hạn mật khẩu (ngày)</label>
          <input type="number" class="setting-input password-expiry" value="${
            sec.passwordExpiry
          }" min="30" max="365" />
        </div>

        <div class="separator"></div>

        <h4 class="panel-subtitle">🔑 Đổi mật khẩu</h4>
        
        <div class="setting-item">
          <label class="setting-label">Mật khẩu hiện tại</label>
          <input type="password" class="setting-input current-password" placeholder="Nhập mật khẩu hiện tại" />
        </div>

        <div class="setting-item">
          <label class="setting-label">Mật khẩu mới</label>
          <input type="password" class="setting-input new-password" placeholder="Nhập mật khẩu mới" />
        </div>

        <div class="setting-item">
          <label class="setting-label">Xác nhận mật khẩu</label>
          <input type="password" class="setting-input confirm-password" placeholder="Xác nhận mật khẩu mới" />
        </div>

        <button class="btn btn-primary save-settings-btn">💾 Lưu cài đặt</button>
      </div>
    `;
  }

  renderPrivacySettings() {
    const priv = this.state.settings.privacy;
    return `
      <div class="settings-panel">
        <h3 class="panel-title">👁️ Riêng tư</h3>
        
        <div class="setting-item">
          <label class="setting-label">Độ hiển thị hồ sơ</label>
          <select class="setting-input profile-visibility">
            <option value="private" ${
              priv.profileVisibility === "private" ? "selected" : ""
            }>🔒 Riêng tư</option>
            <option value="team" ${
              priv.profileVisibility === "team" ? "selected" : ""
            }>👥 Chỉ đội của tôi</option>
            <option value="public" ${
              priv.profileVisibility === "public" ? "selected" : ""
            }>🌐 Công khai</option>
          </select>
        </div>

        <div class="toggle-item">
          <div class="toggle-info">
            <label class="toggle-label">Hiển thị email</label>
            <p class="toggle-description">Cho phép người khác xem email của bạn</p>
          </div>
          <label class="toggle-switch">
            <input type="checkbox" class="show-email-toggle" ${
              priv.showEmail ? "checked" : ""
            } />
            <span class="toggle-slider"></span>
          </label>
        </div>

        <div class="toggle-item">
          <div class="toggle-info">
            <label class="toggle-label">Hiển thị số điện thoại</label>
            <p class="toggle-description">Cho phép người khác xem số điện thoại của bạn</p>
          </div>
          <label class="toggle-switch">
            <input type="checkbox" class="show-phone-toggle" ${
              priv.showPhone ? "checked" : ""
            } />
            <span class="toggle-slider"></span>
          </label>
        </div>

        <div class="toggle-item">
          <div class="toggle-info">
            <label class="toggle-label">Thu thập dữ liệu</label>
            <p class="toggle-description">Cho phép hệ thống thu thập dữ liệu để cải thiện trải nghiệm</p>
          </div>
          <label class="toggle-switch">
            <input type="checkbox" class="data-collection-toggle" ${
              priv.dataCollection ? "checked" : ""
            } />
            <span class="toggle-slider"></span>
          </label>
        </div>

        <button class="btn btn-primary save-settings-btn">💾 Lưu cài đặt</button>
      </div>
    `;
  }

  render() {
    const profileColor = this.state.profile.avatar;
    const generalBtn = this.state.activeTab === "general" ? "active" : "";
    const notifBtn = this.state.activeTab === "notifications" ? "active" : "";
    const securityBtn = this.state.activeTab === "security" ? "active" : "";
    const privacyBtn = this.state.activeTab === "privacy" ? "active" : "";

    let panelContent = this.renderGeneralSettings();
    if (this.state.activeTab === "notifications") {
      panelContent = this.renderNotificationSettings();
    } else if (this.state.activeTab === "security") {
      panelContent = this.renderSecuritySettings();
    } else if (this.state.activeTab === "privacy") {
      panelContent = this.renderPrivacySettings();
    }

    return `
      <div class="settings-container">
        <!-- Header -->
        <div class="settings-header">
          <h1 class="page-title">⚙️ Cài đặt</h1>
          <p class="page-subtitle">Quản lý tài khoản và cài đặt hệ thống</p>
        </div>

        <!-- Profile Card -->
        <div class="profile-card glass-effect">
          <div class="profile-content">
            <div class="profile-avatar">${this.state.profile.avatar}</div>
            <div class="profile-info">
              <h3 class="profile-name">${this.state.profile.fullName}</h3>
              <p class="profile-position">${this.state.profile.position}</p>
              <p class="profile-dept">${this.state.profile.department}</p>
            </div>
          </div>
          <button class="btn btn-secondary">✏️ Chỉnh sửa hồ sơ</button>
        </div>

        <!-- Main Settings -->
        <div class="settings-main">
          <!-- Sidebar -->
          <div class="settings-sidebar">
            <button class="tab-btn ${generalBtn}" data-tab="general">
              🌍 Chung
            </button>
            <button class="tab-btn ${notifBtn}" data-tab="notifications">
              🔔 Thông báo
            </button>
            <button class="tab-btn ${securityBtn}" data-tab="security">
              🔐 Bảo mật
            </button>
            <button class="tab-btn ${privacyBtn}" data-tab="privacy">
              👁️ Riêng tư
            </button>
          </div>

          <!-- Settings Panel -->
          <div class="settings-content glass-effect">
            ${panelContent}
          </div>
        </div>

        ${
          this.state.changesSaved
            ? `
          <div class="success-message">
            ✅ Đã lưu thay đổi thành công!
          </div>
        `
            : ""
        }

        <style>
          .settings-container {
            width: 100%;
            min-height: 100vh;
            background: linear-gradient(135deg, var(--brand-primary-alpha-10) 0%, var(--brand-secondary-alpha-10) 100%);
            padding: var(--space-6);
          }

          .settings-header {
            margin-bottom: var(--space-6);
          }

          .page-title {
            font-size: 32px;
            font-weight: 700;
            color: var(--text-primary);
            margin: 0 0 var(--space-2) 0;
          }

          .page-subtitle {
            font-size: 14px;
            color: var(--text-secondary);
            margin: 0;
          }

          .profile-card {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: var(--space-5);
            background: rgba(255, 255, 255, 0.7);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.5);
            border-radius: var(--radius-lg);
            margin-bottom: var(--space-6);
            gap: var(--space-4);
            flex-wrap: wrap;
          }

          .profile-content {
            display: flex;
            align-items: center;
            gap: var(--space-4);
            flex: 1;
            min-width: 250px;
          }

          .profile-avatar {
            font-size: 60px;
            line-height: 1;
            flex-shrink: 0;
          }

          .profile-info {
            min-width: 0;
          }

          .profile-name {
            font-size: 18px;
            font-weight: 700;
            color: var(--text-primary);
            margin: 0;
            line-height: 1.3;
          }

          .profile-position {
            font-size: 14px;
            color: var(--brand-primary);
            margin: var(--space-1) 0 0 0;
            font-weight: 600;
          }

          .profile-dept {
            font-size: 12px;
            color: var(--text-secondary);
            margin: var(--space-1) 0 0 0;
          }

          .settings-main {
            display: grid;
            grid-template-columns: 200px 1fr;
            gap: var(--space-4);
          }

          .settings-sidebar {
            display: flex;
            flex-direction: column;
            gap: var(--space-2);
          }

          .tab-btn {
            padding: var(--space-3) var(--space-4);
            background: rgba(255, 255, 255, 0.7);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.5);
            border-radius: var(--radius-md);
            color: var(--text-primary);
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all var(--duration-fast) var(--ease-out);
            text-align: left;
          }

          .tab-btn:hover {
            background: var(--brand-primary-alpha-10);
            border-color: var(--brand-primary);
          }

          .tab-btn.active {
            background: var(--brand-primary);
            color: white;
            border-color: var(--brand-primary);
          }

          .settings-content {
            background: rgba(255, 255, 255, 0.7);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.5);
            border-radius: var(--radius-lg);
            padding: var(--space-5);
          }

          .settings-panel {
            display: flex;
            flex-direction: column;
            gap: var(--space-4);
          }

          .panel-title {
            font-size: 18px;
            font-weight: 700;
            color: var(--text-primary);
            margin: 0;
            padding-bottom: var(--space-3);
            border-bottom: 2px solid var(--neutral-100);
          }

          .panel-subtitle {
            font-size: 14px;
            font-weight: 700;
            color: var(--text-primary);
            margin: 0;
            text-transform: uppercase;
            letter-spacing: 0.5px;
          }

          .setting-item {
            display: flex;
            flex-direction: column;
            gap: var(--space-2);
          }

          .setting-label {
            font-size: 13px;
            font-weight: 600;
            color: var(--text-primary);
            text-transform: uppercase;
            letter-spacing: 0.5px;
          }

          .setting-input {
            padding: var(--space-2) var(--space-3);
            border: 1px solid var(--neutral-200);
            border-radius: var(--radius-md);
            font-size: 14px;
            font-family: inherit;
            background: white;
            color: var(--text-primary);
            transition: all var(--duration-fast) var(--ease-out);
          }

          .setting-input:focus {
            outline: none;
            border-color: var(--brand-primary);
            box-shadow: 0 0 0 3px rgba(115, 196, 29, 0.1);
          }

          .radio-group {
            display: flex;
            gap: var(--space-3);
            flex-wrap: wrap;
          }

          .radio-option {
            display: flex;
            align-items: center;
            gap: var(--space-2);
            cursor: pointer;
            font-size: 14px;
            color: var(--text-primary);
          }

          .radio-option input[type="radio"] {
            cursor: pointer;
            width: 18px;
            height: 18px;
          }

          .toggle-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: var(--space-3);
            background: var(--neutral-50);
            border-radius: var(--radius-md);
            gap: var(--space-4);
          }

          .toggle-info {
            flex: 1;
          }

          .toggle-label {
            display: block;
            font-size: 14px;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: var(--space-1);
          }

          .toggle-description {
            font-size: 12px;
            color: var(--text-secondary);
            margin: 0;
          }

          .toggle-switch {
            position: relative;
            display: inline-block;
            width: 50px;
            height: 28px;
            flex-shrink: 0;
          }

          .toggle-switch input {
            opacity: 0;
            width: 0;
            height: 0;
          }

          .toggle-slider {
            position: absolute;
            cursor: pointer;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: #ccc;
            transition: 0.3s;
            border-radius: 28px;
          }

          .toggle-slider:before {
            position: absolute;
            content: "";
            height: 22px;
            width: 22px;
            left: 3px;
            bottom: 3px;
            background-color: white;
            transition: 0.3s;
            border-radius: 50%;
          }

          input:checked + .toggle-slider {
            background-color: var(--brand-primary);
          }

          input:checked + .toggle-slider:before {
            transform: translateX(22px);
          }

          .separator {
            height: 1px;
            background: var(--neutral-100);
            margin: var(--space-2) 0;
          }

          .save-settings-btn {
            align-self: flex-start;
          }

          .success-message {
            position: fixed;
            top: var(--space-4);
            right: var(--space-4);
            padding: var(--space-3) var(--space-4);
            background: var(--system-green);
            color: white;
            border-radius: var(--radius-md);
            font-weight: 600;
            animation: slideInRight 0.3s ease-out;
            z-index: 999;
          }

          @keyframes slideInRight {
            from {
              transform: translateX(400px);
              opacity: 0;
            }
            to {
              transform: translateX(0);
              opacity: 1;
            }
          }

          @media (max-width: 768px) {
            .settings-container {
              padding: var(--space-4);
            }

            .settings-main {
              grid-template-columns: 1fr;
            }

            .settings-sidebar {
              flex-direction: row;
              overflow-x: auto;
              margin-bottom: var(--space-4);
            }

            .tab-btn {
              flex-shrink: 0;
            }

            .profile-card {
              flex-direction: column;
              text-align: center;
            }

            .profile-content {
              flex-direction: column;
            }
          }
        </style>
      </div>
    `;
  }

  onMount() {
    console.log("✅ Settings component mounted");

    // Tab switching
    const tabBtns = this.el.querySelectorAll(".tab-btn");
    tabBtns.forEach((btn) => {
      btn.addEventListener("click", (e) => {
        this.state.activeTab = e.target.dataset.tab;
        this.setHTML(this.render());
        this.onMount();
      });
    });

    // Save button
    const saveBtns = this.el.querySelectorAll(".save-settings-btn");
    saveBtns.forEach((btn) => {
      btn.addEventListener("click", () => {
        // Update general settings
        const langSelect = this.el.querySelector(".lang-select");
        if (langSelect) {
          this.state.settings.general.language = langSelect.value;
        }

        // Update toggles
        const emailToggle = this.el.querySelector(".email-notify-toggle");
        if (emailToggle) {
          this.state.settings.notifications.emailNotifications =
            emailToggle.checked;
        }

        const pushToggle = this.el.querySelector(".push-notify-toggle");
        if (pushToggle) {
          this.state.settings.notifications.pushNotifications =
            pushToggle.checked;
        }

        const leaveToggle = this.el.querySelector(".leave-reminder-toggle");
        if (leaveToggle) {
          this.state.settings.notifications.leaveReminder = leaveToggle.checked;
        }

        const attendanceToggle = this.el.querySelector(
          ".attendance-alert-toggle"
        );
        if (attendanceToggle) {
          this.state.settings.notifications.attendanceAlert =
            attendanceToggle.checked;
        }

        const payrollToggle = this.el.querySelector(".payroll-notify-toggle");
        if (payrollToggle) {
          this.state.settings.notifications.payrollNotification =
            payrollToggle.checked;
        }

        const systemToggle = this.el.querySelector(".system-updates-toggle");
        if (systemToggle) {
          this.state.settings.notifications.systemUpdates =
            systemToggle.checked;
        }

        const twoFactorToggle = this.el.querySelector(".two-factor-toggle");
        if (twoFactorToggle) {
          this.state.settings.security.twoFactor = twoFactorToggle.checked;
        }

        const loginAlertsToggle = this.el.querySelector(".login-alerts-toggle");
        if (loginAlertsToggle) {
          this.state.settings.security.loginAlerts = loginAlertsToggle.checked;
        }

        const sessionTimeout = this.el.querySelector(".session-timeout");
        if (sessionTimeout) {
          this.state.settings.security.sessionTimeout = parseInt(
            sessionTimeout.value
          );
        }

        const passwordExpiry = this.el.querySelector(".password-expiry");
        if (passwordExpiry) {
          this.state.settings.security.passwordExpiry = parseInt(
            passwordExpiry.value
          );
        }

        const showEmailToggle = this.el.querySelector(".show-email-toggle");
        if (showEmailToggle) {
          this.state.settings.privacy.showEmail = showEmailToggle.checked;
        }

        const showPhoneToggle = this.el.querySelector(".show-phone-toggle");
        if (showPhoneToggle) {
          this.state.settings.privacy.showPhone = showPhoneToggle.checked;
        }

        const dataCollectionToggle = this.el.querySelector(
          ".data-collection-toggle"
        );
        if (dataCollectionToggle) {
          this.state.settings.privacy.dataCollection =
            dataCollectionToggle.checked;
        }

        // Show success message
        this.state.changesSaved = true;
        this.setHTML(this.render());
        this.onMount();

        // Hide message after 3 seconds
        setTimeout(() => {
          this.state.changesSaved = false;
          this.setHTML(this.render());
          this.onMount();
        }, 3000);
      });
    });

    // Setup sidebar preferences
    setupSidebarPreferences();
  }

  onUnmount() {
    console.log("✅ Settings component unmounted");
  }
}
