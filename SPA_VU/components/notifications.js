// Notifications Component - Paradise HR SPA
import { Component } from "../app.js";

export default class Notifications extends Component {
  constructor(props) {
    super(props);
    this.state = {
      notifications: [
        {
          id: 1,
          type: "approval",
          icon: "✅",
          title: "Phê duyệt đơn nghỉ phép",
          message: "Đơn nghỉ phép của Trần Công Đức đã được phê duyệt",
          timestamp: "5 phút trước",
          read: false,
          action: "Xem chi tiết",
        },
        {
          id: 2,
          type: "alert",
          icon: "⚠️",
          title: "Chấm công chưa hoàn thành",
          message: "Bạn chưa chấm công chiều hôm nay. Vui lòng chấm công ngay",
          timestamp: "2 giờ trước",
          read: false,
          action: "Chấm công ngay",
        },
        {
          id: 3,
          type: "info",
          icon: "ℹ️",
          title: "Phát lương tháng 11",
          message: "Lương tháng 11/2025 của bạn đã được phát hành",
          timestamp: "3 giờ trước",
          read: false,
          action: "Xem chi tiết",
        },
        {
          id: 4,
          type: "request",
          icon: "📋",
          title: "Có đơn yêu cầu mới chờ duyệt",
          message: "Nguyễn Thị Hương vừa gửi đơn xin cấp phép",
          timestamp: "1 ngày trước",
          read: true,
          action: "Xem đơn",
        },
        {
          id: 5,
          type: "system",
          icon: "🔧",
          title: "Bảo trì hệ thống",
          message:
            "Hệ thống sẽ bảo trì từ 22:00 - 23:00 hôm nay. Xin lỗi vì bất tiện",
          timestamp: "2 ngày trước",
          read: true,
          action: "Chi tiết",
        },
        {
          id: 6,
          type: "birthday",
          icon: "🎂",
          title: "Sinh nhật nhân viên",
          message: "Hôm nay là sinh nhật của Phạm Minh Tuấn. Hãy gửi lời chúc",
          timestamp: "3 ngày trước",
          read: true,
          action: "Gửi lời chúc",
        },
      ],
      filterType: "all",
      sortBy: "newest",
    };
  }

  getNotificationColor(type) {
    const colors = {
      approval: "green",
      alert: "orange",
      info: "blue",
      request: "blue",
      system: "purple",
      birthday: "pink",
    };
    return colors[type] || "gray";
  }

  getFilteredNotifications() {
    let filtered = this.state.notifications;

    // Filter by type
    if (this.state.filterType !== "all") {
      filtered = filtered.filter((n) => {
        if (this.state.filterType === "unread") {
          return !n.read;
        }
        return n.type === this.state.filterType;
      });
    }

    // Sort
    if (this.state.sortBy === "newest") {
      filtered.sort((a, b) => b.id - a.id);
    }

    return filtered;
  }

  renderNotificationItem(notification) {
    const color = this.getNotificationColor(notification.type);
    const readClass = notification.read ? "read" : "unread";

    return `
      <div class="notification-item notification-${color} ${readClass}" data-notification-id="${
      notification.id
    }">
        <div class="notification-icon">${notification.icon}</div>
        
        <div class="notification-content">
          <div class="notification-header">
            <h3 class="notification-title">${notification.title}</h3>
            <span class="notification-time">${notification.timestamp}</span>
          </div>
          <p class="notification-message">${notification.message}</p>
          <button class="notification-action" data-action="notification-action">${
            notification.action
          }</button>
        </div>

        <div class="notification-actions">
          <button class="action-btn mark-read-btn" data-action="mark-read" title="${
            notification.read ? "Đánh dấu chưa đọc" : "Đánh dấu đã đọc"
          }">
            ${notification.read ? "👁️" : "✓"}
          </button>
          <button class="action-btn delete-btn" data-action="delete-notification" title="Xóa">✕</button>
        </div>
      </div>
    `;
  }

  render() {
    const filtered = this.getFilteredNotifications();
    const unreadCount = this.state.notifications.filter((n) => !n.read).length;
    const approvalCount = this.state.notifications.filter(
      (n) => n.type === "approval"
    ).length;
    const alertCount = this.state.notifications.filter(
      (n) => n.type === "alert"
    ).length;

    return `
      <div class="notifications-container">
        <!-- Header -->
        <div class="notifications-header">
          <div class="header-content">
            <h1 class="page-title">🔔 Thông báo</h1>
            <p class="page-subtitle">Quản lý thông báo hệ thống</p>
          </div>
          <div class="header-stats">
            <div class="stat-badge">
              <span class="stat-label">Chưa đọc</span>
              <span class="stat-value">${unreadCount}</span>
            </div>
            <div class="stat-badge">
              <span class="stat-label">Phê duyệt</span>
              <span class="stat-value">${approvalCount}</span>
            </div>
          </div>
        </div>

        <!-- Filters -->
        <div class="filters-section glass-effect">
          <div class="filter-group">
            <select class="filter-input type-filter">
              <option value="all">Tất cả thông báo</option>
              <option value="unread">Chưa đọc</option>
              <option value="approval">Phê duyệt</option>
              <option value="alert">Cảnh báo</option>
              <option value="request">Yêu cầu</option>
              <option value="info">Thông tin</option>
              <option value="system">Hệ thống</option>
              <option value="birthday">Sinh nhật</option>
            </select>
          </div>
          <div class="filter-group">
            <select class="filter-input sort-filter">
              <option value="newest">Mới nhất</option>
              <option value="oldest">Cũ nhất</option>
            </select>
          </div>
          <div class="filter-actions">
            <button class="btn btn-secondary mark-all-read-btn">✓ Đánh dấu tất cả đã đọc</button>
            <button class="btn btn-danger clear-all-btn">🗑️ Xóa tất cả</button>
          </div>
        </div>

        <!-- Notifications List -->
        <div class="notifications-list">
          ${
            filtered.length > 0
              ? filtered.map((n) => this.renderNotificationItem(n)).join("")
              : `
            <div class="empty-state">
              <div class="empty-icon">🎉</div>
              <h3 class="empty-title">Không có thông báo</h3>
              <p class="empty-message">Bạn đã xem hết thông báo. Tất cả mọi thứ đều cập nhật!</p>
            </div>
          `
          }
        </div>

        <style>
          .notifications-container {
            width: 100%;
            min-height: 100vh;
            background: linear-gradient(135deg, var(--brand-primary-alpha-10) 0%, var(--brand-secondary-alpha-10) 100%);
            padding: var(--space-6);
          }

          .notifications-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: var(--space-4);
            margin-bottom: var(--space-6);
            flex-wrap: wrap;
          }

          .header-content {
            flex: 1;
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

          .header-stats {
            display: flex;
            gap: var(--space-3);
            flex-wrap: wrap;
          }

          .stat-badge {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: var(--space-1);
            padding: var(--space-3) var(--space-4);
            background: rgba(255, 255, 255, 0.7);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.5);
            border-radius: var(--radius-md);
            text-align: center;
          }

          .stat-label {
            font-size: 12px;
            color: var(--text-secondary);
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
          }

          .stat-value {
            font-size: 24px;
            font-weight: 700;
            color: var(--brand-primary);
          }

          .filters-section {
            display: flex;
            gap: var(--space-3);
            align-items: center;
            padding: var(--space-4);
            background: rgba(255, 255, 255, 0.7);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.5);
            border-radius: var(--radius-lg);
            margin-bottom: var(--space-5);
            flex-wrap: wrap;
          }

          .filter-group {
            flex: 1;
            min-width: 200px;
          }

          .filter-input {
            width: 100%;
            padding: var(--space-2) var(--space-3);
            border: 1px solid var(--neutral-200);
            border-radius: var(--radius-md);
            font-size: 13px;
            font-family: inherit;
            background: white;
            transition: all var(--duration-fast) var(--ease-out);
          }

          .filter-input:focus {
            outline: none;
            border-color: var(--brand-primary);
            box-shadow: 0 0 0 3px rgba(115, 196, 29, 0.1);
          }

          .filter-actions {
            display: flex;
            gap: var(--space-2);
          }

          .notifications-list {
            display: flex;
            flex-direction: column;
            gap: var(--space-3);
          }

          .notification-item {
            display: flex;
            gap: var(--space-4);
            align-items: flex-start;
            padding: var(--space-4);
            background: rgba(255, 255, 255, 0.7);
            backdrop-filter: blur(20px);
            border-left: 4px solid;
            border-radius: var(--radius-md);
            transition: all var(--duration-fast) var(--ease-out);
            position: relative;
          }

          .notification-item:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
          }

          .notification-item.unread {
            background: rgba(255, 255, 255, 0.9);
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
          }

          .notification-item.read {
            opacity: 0.85;
          }

          .notification-green {
            border-left-color: var(--system-green);
          }

          .notification-orange {
            border-left-color: var(--system-orange);
          }

          .notification-blue {
            border-left-color: var(--system-blue);
          }

          .notification-purple {
            border-left-color: var(--system-purple);
          }

          .notification-pink {
            border-left-color: #ec4899;
          }

          .notification-gray {
            border-left-color: var(--neutral-300);
          }

          .notification-icon {
            font-size: 32px;
            line-height: 1;
            flex-shrink: 0;
            margin-top: var(--space-1);
          }

          .notification-content {
            flex: 1;
            min-width: 0;
          }

          .notification-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: var(--space-2);
            margin-bottom: var(--space-2);
          }

          .notification-title {
            font-size: 15px;
            font-weight: 700;
            color: var(--text-primary);
            margin: 0;
            line-height: 1.3;
          }

          .notification-time {
            font-size: 12px;
            color: var(--text-secondary);
            white-space: nowrap;
            flex-shrink: 0;
          }

          .notification-message {
            font-size: 13px;
            color: var(--text-secondary);
            margin: 0 0 var(--space-2) 0;
            line-height: 1.5;
          }

          .notification-action {
            padding: var(--space-1) var(--space-3);
            background: var(--brand-primary-alpha-10);
            color: var(--brand-primary);
            border: 1px solid var(--brand-primary-alpha-20);
            border-radius: var(--radius-md);
            font-size: 12px;
            font-weight: 600;
            cursor: pointer;
            transition: all var(--duration-fast) var(--ease-out);
          }

          .notification-action:hover {
            background: var(--brand-primary);
            color: white;
            border-color: var(--brand-primary);
          }

          .notification-actions {
            display: flex;
            gap: var(--space-2);
            flex-shrink: 0;
            align-items: center;
          }

          .action-btn {
            width: 32px;
            height: 32px;
            padding: 0;
            background: var(--neutral-100);
            border: 1px solid var(--neutral-200);
            border-radius: var(--radius-md);
            cursor: pointer;
            font-size: 16px;
            transition: all var(--duration-fast) var(--ease-out);
            display: flex;
            align-items: center;
            justify-content: center;
          }

          .action-btn:hover {
            background: var(--neutral-200);
            border-color: var(--neutral-300);
          }

          .delete-btn:hover {
            background: var(--system-red-alpha-10);
            border-color: var(--system-red);
            color: var(--system-red);
          }

          .empty-state {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: var(--space-8);
            text-align: center;
            background: rgba(255, 255, 255, 0.7);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.5);
            border-radius: var(--radius-lg);
          }

          .empty-icon {
            font-size: 80px;
            margin-bottom: var(--space-4);
            line-height: 1;
          }

          .empty-title {
            font-size: 20px;
            font-weight: 700;
            color: var(--text-primary);
            margin: 0 0 var(--space-2) 0;
          }

          .empty-message {
            font-size: 14px;
            color: var(--text-secondary);
            margin: 0;
          }

          @media (max-width: 768px) {
            .notifications-container {
              padding: var(--space-4);
            }

            .notifications-header {
              flex-direction: column;
            }

            .header-stats {
              width: 100%;
            }

            .filters-section {
              flex-direction: column;
            }

            .filter-group {
              min-width: unset;
            }

            .filter-actions {
              width: 100%;
              flex-direction: column;
            }

            .filter-actions .btn {
              width: 100%;
            }

            .notification-item {
              flex-direction: column;
            }

            .notification-actions {
              align-self: flex-start;
              margin-top: var(--space-2);
            }
          }
        </style>
      </div>
    `;
  }

  onMount() {
    console.log("✅ Notifications component mounted");

    // Type filter
    const typeFilter = this.el.querySelector(".type-filter");
    if (typeFilter) {
      typeFilter.addEventListener("change", (e) => {
        this.state.filterType = e.target.value;
        this.setHTML(this.render());
        this.onMount();
      });
    }

    // Sort filter
    const sortFilter = this.el.querySelector(".sort-filter");
    if (sortFilter) {
      sortFilter.addEventListener("change", (e) => {
        this.state.sortBy = e.target.value;
        this.setHTML(this.render());
        this.onMount();
      });
    }

    // Mark read buttons
    const markReadBtns = this.el.querySelectorAll(".mark-read-btn");
    markReadBtns.forEach((btn) => {
      btn.addEventListener("click", (e) => {
        e.stopPropagation();
        const item = e.target.closest(".notification-item");
        const notifId = parseInt(item.dataset.notificationId);
        const notif = this.state.notifications.find((n) => n.id === notifId);
        if (notif) {
          notif.read = !notif.read;
          this.setHTML(this.render());
          this.onMount();
        }
      });
    });

    // Delete buttons
    const deleteBtns = this.el.querySelectorAll(".delete-btn");
    deleteBtns.forEach((btn) => {
      btn.addEventListener("click", (e) => {
        e.stopPropagation();
        const item = e.target.closest(".notification-item");
        const notifId = parseInt(item.dataset.notificationId);
        this.state.notifications = this.state.notifications.filter(
          (n) => n.id !== notifId
        );
        this.setHTML(this.render());
        this.onMount();
      });
    });

    // Mark all read
    const markAllReadBtn = this.el.querySelector(".mark-all-read-btn");
    if (markAllReadBtn) {
      markAllReadBtn.addEventListener("click", () => {
        this.state.notifications.forEach((n) => {
          n.read = true;
        });
        this.setHTML(this.render());
        this.onMount();
      });
    }

    // Clear all
    const clearAllBtn = this.el.querySelector(".clear-all-btn");
    if (clearAllBtn) {
      clearAllBtn.addEventListener("click", () => {
        if (
          confirm(
            "Bạn có chắc chắn muốn xóa tất cả thông báo? Hành động này không thể hoàn tác."
          )
        ) {
          this.state.notifications = [];
          this.setHTML(this.render());
          this.onMount();
        }
      });
    }

    // Action buttons
    const actionBtns = this.el.querySelectorAll(".notification-action");
    actionBtns.forEach((btn) => {
      btn.addEventListener("click", (e) => {
        e.stopPropagation();
        const item = e.target.closest(".notification-item");
        const notifId = parseInt(item.dataset.notificationId);
        const notif = this.state.notifications.find((n) => n.id === notifId);
        if (notif) {
          alert(`${notif.action} cho: ${notif.title}`);
          notif.read = true;
          this.setHTML(this.render());
          this.onMount();
        }
      });
    });
  }

  onUnmount() {
    console.log("✅ Notifications component unmounted");
  }
}
