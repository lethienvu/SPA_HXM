// Request Management Component - Paradise HR SPA
import { Component } from "../app.js";

export default class RequestManagement extends Component {
  constructor(props) {
    super(props);
    this.state = {
      requests: [
        {
          id: 1,
          title: "Đơn xin nghỉ phép",
          date: "30/10/2022",
          time: "8:5 giờ",
          status: "approved",
          reason: "Dự định có chuyến du lịch gia đình...",
          type: "leave",
          icon: "🌴",
          color: "cyan",
        },
        {
          id: 2,
          title: "Đơn xin nghỉ phép",
          date: "30/10/2022",
          time: "8:5 giờ",
          status: "approved",
          reason: "A weekly email with your favorite articles about...",
          type: "leave",
          icon: "🌴",
          color: "cyan",
        },
        {
          id: 3,
          title: "Đơn xin nghỉ phép",
          date: "30/10/2022",
          time: "8:5 giờ",
          status: "pending",
          reason: "Interested in digital strategy? Subscribe and get M...",
          type: "leave",
          icon: "🌴",
          color: "orange",
        },
        {
          id: 4,
          title: "Đơn xin nâng lương/Về sâm",
          date: "30/10/2022",
          time: "4 giờ",
          status: "approved",
          reason:
            "Siêu tiết dùng được collecting the best design links of t...",
          type: "salary",
          icon: "💰",
          color: "cyan",
        },
        {
          id: 5,
          title: "Đơn xin nghỉ phép",
          date: "30/10/2022",
          time: "8:5 giờ",
          status: "rejected",
          reason: "We love useful stuff, and we love qualitiy writing...",
          type: "leave",
          icon: "🌴",
          color: "red",
        },
        {
          id: 6,
          title: "Đơn xin nâng lương/Về sâm",
          date: "30/10/2022",
          time: "4 giờ",
          status: "approved",
          reason: "Digital product design tricks, written by, and maint...",
          type: "salary",
          icon: "💰",
          color: "cyan",
        },
      ],
      activeTab: "all", // all, pending, approved, rejected
      searchQuery: "",
      selectedRequest: null,
      showDetailModal: false,
      sortBy: "newest", // newest, oldest
      viewMode: "list", // list, detail
    };
  }

  getStatusDisplay(status) {
    const statuses = {
      approved: { label: "Đã duyệt", color: "cyan", icon: "✓" },
      pending: { label: "Chờ duyệt", color: "orange", icon: "⏳" },
      rejected: { label: "Từ chối", color: "red", icon: "✕" },
    };
    return statuses[status] || statuses.pending;
  }

  getFilteredRequests() {
    let filtered = this.state.requests;

    // Filter by tab
    if (this.state.activeTab !== "all") {
      filtered = filtered.filter((req) => req.status === this.state.activeTab);
    }

    // Filter by search
    if (this.state.searchQuery) {
      filtered = filtered.filter(
        (req) =>
          req.title
            .toLowerCase()
            .includes(this.state.searchQuery.toLowerCase()) ||
          req.reason
            .toLowerCase()
            .includes(this.state.searchQuery.toLowerCase())
      );
    }

    // Sort
    if (this.state.sortBy === "newest") {
      filtered.sort((a, b) => b.id - a.id);
    } else {
      filtered.sort((a, b) => a.id - b.id);
    }

    return filtered;
  }

  getTabStats() {
    return {
      all: this.state.requests.length,
      pending: this.state.requests.filter((r) => r.status === "pending").length,
      approved: this.state.requests.filter((r) => r.status === "approved")
        .length,
      rejected: this.state.requests.filter((r) => r.status === "rejected")
        .length,
    };
  }

  renderRequestItem(request) {
    const statusInfo = this.getStatusDisplay(request.status);
    const monthMap = {
      "01": "T1",
      "02": "T2",
      "03": "T3",
      "04": "T4",
      "05": "T5",
      "06": "T6",
      "07": "T7",
      "08": "T8",
      "09": "T9",
      10: "T10",
      11: "T11",
      12: "T12",
    };
    const [day, month, year] = request.date.split("/");
    const monthLabel = monthMap[month] || month;

    return `
      <div class="request-item glass-effect" data-request-id="${request.id}">
        <div class="request-header">
          <div class="request-date-badge">
            <div class="badge-day">${day}</div>
            <div class="badge-month">${monthLabel}</div>
          </div>
          <div class="request-title-section">
            <h3 class="request-title">${request.title}</h3>
            <p class="request-time">${request.date} • ${request.time}</p>
          </div>
          <span class="status-badge status-${statusInfo.color}">
            ${statusInfo.icon} ${statusInfo.label}
          </span>
        </div>
        <div class="request-reason">${request.reason}</div>
        <div class="request-footer">
          <button class="action-btn view-detail-btn" data-action="view-detail">
            Xem chi tiết →
          </button>
          <button class="action-icon-btn">⋮</button>
        </div>
      </div>
    `;
  }

  renderDetailView() {
    if (!this.state.selectedRequest) return "";

    const req = this.state.selectedRequest;
    const statusInfo = this.getStatusDisplay(req.status);

    return `
      <div class="detail-modal-overlay" data-modal="request-detail">
        <div class="detail-modal-content">
          <div class="detail-modal-header">
            <button class="detail-back-btn" data-action="back-to-list">← Quay lại</button>
            <h2 class="detail-modal-title">Chi tiết đơn yêu cầu</h2>
            <button class="detail-close-btn" data-action="close-detail">✕</button>
          </div>

          <div class="detail-modal-body">
            <div class="detail-header-section">
              <div class="detail-icon">${req.icon}</div>
              <div class="detail-header-info">
                <h3 class="detail-title">${req.title}</h3>
                <p class="detail-date">${req.date} • ${req.time}</p>
              </div>
              <span class="status-badge status-${statusInfo.color} large">
                ${statusInfo.icon} ${statusInfo.label}
              </span>
            </div>

            <div class="detail-section">
              <h4 class="section-title">Nội dung đơn yêu cầu</h4>
              <div class="detail-content">
                <div class="content-item">
                  <label>Loại đơn:</label>
                  <span>${
                    req.type === "leave"
                      ? "Đơn xin nghỉ phép"
                      : "Đơn xin nâng lương"
                  }</span>
                </div>
                <div class="content-item">
                  <label>Lý do:</label>
                  <p>${req.reason}</p>
                </div>
                <div class="content-item">
                  <label>Thời gian:</label>
                  <span>${req.date} (${req.time})</span>
                </div>
              </div>
            </div>

            <div class="detail-section">
              <h4 class="section-title">Lịch sử xử lý</h4>
              <div class="timeline">
                <div class="timeline-item">
                  <div class="timeline-marker"></div>
                  <div class="timeline-content">
                    <p class="timeline-title">Đơn được gửi</p>
                    <p class="timeline-time">${req.date}</p>
                  </div>
                </div>
                ${
                  req.status !== "pending"
                    ? `
                <div class="timeline-item">
                  <div class="timeline-marker completed"></div>
                  <div class="timeline-content">
                    <p class="timeline-title">${statusInfo.label}</p>
                    <p class="timeline-time">Hôm nay</p>
                  </div>
                </div>
                `
                    : ""
                }
              </div>
            </div>

            <div class="detail-actions">
              ${
                req.status === "pending"
                  ? `
                <button class="btn btn-success" data-action="approve">✓ Phê duyệt</button>
                <button class="btn btn-danger" data-action="reject">✕ Từ chối</button>
              `
                  : `
                <button class="btn btn-secondary" data-action="print">🖨️ In đơn</button>
                <button class="btn btn-secondary" data-action="download">📥 Tải xuống</button>
              `
              }
            </div>
          </div>
        </div>
      </div>
    `;
  }

  render() {
    const filtered = this.getFilteredRequests();
    const stats = this.getTabStats();
    const requestsHTML = filtered
      .map((req) => this.renderRequestItem(req))
      .join("");

    return `
      <div class="request-container">
        <div class="request-header-section">
          <div class="header-content">
            <h1 class="request-page-title">📋 Đơn yêu cầu</h1>
            <p class="request-page-subtitle">Quản lý các đơn xin phép, nâng lương và các yêu cầu khác</p>
          </div>
          <button class="btn btn-primary">+ Tạo đơn mới</button>
        </div>

        <!-- Search & Filters -->
        <div class="request-controls glass-effect">
          <div class="search-box">
            <input
              type="text"
              class="search-input request-search"
              placeholder="Tìm kiếm..."
              value="${this.state.searchQuery}"
            />
            <span class="search-icon">🔍</span>
          </div>
          <div class="filter-controls">
            <select class="sort-filter" data-filter="sort">
              <option value="newest" ${
                this.state.sortBy === "newest" ? "selected" : ""
              }>Mới nhất</option>
              <option value="oldest" ${
                this.state.sortBy === "oldest" ? "selected" : ""
              }>Cũ nhất</option>
            </select>
          </div>
        </div>

        <!-- Tabs -->
        <div class="request-tabs">
          <button class="tab-btn ${
            this.state.activeTab === "all" ? "active" : ""
          }" data-tab="all">
            Tất cả (${stats.all})
          </button>
          <button class="tab-btn ${
            this.state.activeTab === "pending" ? "active" : ""
          }" data-tab="pending">
            Chờ duyệt (${stats.pending})
          </button>
          <button class="tab-btn ${
            this.state.activeTab === "approved" ? "active" : ""
          }" data-tab="approved">
            Đã duyệt (${stats.approved})
          </button>
          <button class="tab-btn ${
            this.state.activeTab === "rejected" ? "active" : ""
          }" data-tab="rejected">
            Từ chối (${stats.rejected})
          </button>
        </div>

        <!-- Request List -->
        <div class="request-list">
          ${
            filtered.length > 0
              ? requestsHTML
              : `
            <div class="empty-state">
              <div class="empty-icon">📭</div>
              <h3>Không có đơn yêu cầu</h3>
              <p>Tạo một đơn mới hoặc thay đổi bộ lọc</p>
            </div>
          `
          }
        </div>

        <!-- Detail Modal -->
        ${this.renderDetailView()}

        <style>
          .request-container {
            width: 100%;
            min-height: 100vh;
            background: linear-gradient(135deg, var(--brand-primary-alpha-10) 0%, var(--brand-secondary-alpha-10) 100%);
            padding: var(--space-6);
          }

          .request-header-section {
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

          .request-page-title {
            font-size: 32px;
            font-weight: 700;
            color: var(--text-primary);
            margin: 0;
            line-height: 1.2;
          }

          .request-page-subtitle {
            font-size: 14px;
            color: var(--text-secondary);
            margin: var(--space-2) 0 0 0;
          }

          .request-controls {
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

          .search-box {
            flex: 1;
            min-width: 250px;
            position: relative;
            display: flex;
            align-items: center;
          }

          .search-input {
            width: 100%;
            padding: var(--space-2) var(--space-3) var(--space-2) var(--space-3);
            border: 1px solid var(--neutral-200);
            border-radius: var(--radius-md);
            font-size: 14px;
            font-family: inherit;
            padding-right: var(--space-4);
          }

          .search-input:focus {
            outline: none;
            border-color: var(--brand-primary);
            box-shadow: 0 0 0 3px rgba(115, 196, 29, 0.1);
          }

          .search-icon {
            position: absolute;
            right: var(--space-3);
            pointer-events: none;
            color: var(--text-secondary);
          }

          .filter-controls {
            display: flex;
            gap: var(--space-2);
          }

          .sort-filter {
            padding: var(--space-2) var(--space-3);
            border: 1px solid var(--neutral-200);
            border-radius: var(--radius-md);
            font-size: 13px;
            font-family: inherit;
            background: white;
            cursor: pointer;
          }

          .sort-filter:hover {
            border-color: var(--neutral-300);
          }

          .request-tabs {
            display: flex;
            gap: var(--space-2);
            margin-bottom: var(--space-5);
            overflow-x: auto;
            padding-bottom: var(--space-2);
          }

          .tab-btn {
            padding: var(--space-2) var(--space-3);
            background: rgba(255, 255, 255, 0.7);
            border: 1px solid rgba(255, 255, 255, 0.5);
            border-radius: var(--radius-md);
            font-size: 13px;
            font-weight: 600;
            color: var(--text-secondary);
            cursor: pointer;
            white-space: nowrap;
            transition: all var(--duration-fast) var(--ease-out);
            backdrop-filter: blur(20px);
          }

          .tab-btn:hover {
            background: rgba(255, 255, 255, 0.9);
            border-color: rgba(115, 196, 29, 0.3);
          }

          .tab-btn.active {
            background: var(--brand-primary);
            color: white;
            border-color: var(--brand-primary);
          }

          .request-list {
            display: flex;
            flex-direction: column;
            gap: var(--space-3);
          }

          .request-item {
            padding: var(--space-4);
            background: rgba(255, 255, 255, 0.7);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.5);
            border-radius: var(--radius-lg);
            transition: all var(--duration-normal) var(--ease-out);
            cursor: pointer;
          }

          .request-item:hover {
            transform: translateX(4px);
            box-shadow: 0 12px 32px rgba(0, 0, 0, 0.1);
            background: rgba(255, 255, 255, 0.9);
          }

          .request-header {
            display: flex;
            align-items: flex-start;
            gap: var(--space-3);
            margin-bottom: var(--space-3);
          }

          .request-date-badge {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            width: 50px;
            height: 50px;
            background: linear-gradient(135deg, var(--system-blue-alpha) 0%, var(--system-blue-light) 100%);
            border-radius: var(--radius-md);
            flex-shrink: 0;
          }

          .badge-day {
            font-size: 18px;
            font-weight: 700;
            color: var(--system-blue);
            line-height: 1;
          }

          .badge-month {
            font-size: 11px;
            font-weight: 600;
            color: var(--system-blue-dark);
            margin-top: 2px;
          }

          .request-title-section {
            flex: 1;
          }

          .request-title {
            font-size: 15px;
            font-weight: 700;
            color: var(--text-primary);
            margin: 0;
            line-height: 1.3;
          }

          .request-time {
            font-size: 12px;
            color: var(--text-secondary);
            margin: var(--space-1) 0 0 0;
          }

          .status-badge {
            display: inline-flex;
            align-items: center;
            gap: var(--space-1);
            padding: var(--space-2) var(--space-3);
            border-radius: var(--radius-md);
            font-size: 12px;
            font-weight: 600;
            white-space: nowrap;
            flex-shrink: 0;
          }

          .status-badge.status-cyan {
            background: var(--system-blue-alpha);
            color: var(--system-blue-dark);
          }

          .status-badge.status-orange {
            background: var(--system-orange-alpha);
            color: var(--system-orange-dark);
          }

          .status-badge.status-red {
            background: var(--system-red-alpha);
            color: var(--system-red-dark);
          }

          .status-badge.large {
            padding: var(--space-3) var(--space-4);
            font-size: 14px;
          }

          .request-reason {
            font-size: 13px;
            color: var(--text-secondary);
            line-height: 1.5;
            margin-bottom: var(--space-3);
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
          }

          .request-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: var(--space-2);
          }

          .action-btn {
            flex: 1;
            padding: var(--space-2) var(--space-3);
            background: var(--neutral-50);
            border: 1px solid var(--neutral-200);
            border-radius: var(--radius-md);
            font-size: 12px;
            font-weight: 600;
            color: var(--brand-primary);
            cursor: pointer;
            transition: all var(--duration-fast) var(--ease-out);
          }

          .action-btn:hover {
            background: var(--brand-primary-alpha-10);
            border-color: var(--brand-primary);
          }

          .action-icon-btn {
            width: 32px;
            height: 32px;
            padding: 0;
            background: var(--neutral-50);
            border: 1px solid var(--neutral-200);
            border-radius: var(--radius-md);
            cursor: pointer;
            font-size: 16px;
            transition: all var(--duration-fast) var(--ease-out);
          }

          .action-icon-btn:hover {
            background: var(--neutral-100);
            border-color: var(--neutral-300);
          }

          .empty-state {
            text-align: center;
            padding: var(--space-8);
            background: rgba(255, 255, 255, 0.7);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.5);
            border-radius: var(--radius-lg);
          }

          .empty-icon {
            font-size: 64px;
            margin-bottom: var(--space-3);
          }

          .empty-state h3 {
            font-size: 18px;
            font-weight: 700;
            color: var(--text-primary);
            margin: 0 0 var(--space-1) 0;
          }

          .empty-state p {
            font-size: 13px;
            color: var(--text-secondary);
            margin: 0;
          }

          /* Detail Modal */
          .detail-modal-overlay {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.5);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 1000;
            padding: var(--space-4);
            animation: fadeIn 0.3s ease-out;
          }

          @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
          }

          .detail-modal-content {
            background: white;
            border-radius: var(--radius-lg);
            box-shadow: 0 30px 90px rgba(0, 0, 0, 0.2);
            max-height: 90vh;
            overflow-y: auto;
            max-width: 600px;
            width: 100%;
            animation: slideUp 0.3s ease-out;
          }

          @keyframes slideUp {
            from {
              transform: translateY(20px);
              opacity: 0;
            }
            to {
              transform: translateY(0);
              opacity: 1;
            }
          }

          .detail-modal-header {
            display: flex;
            align-items: center;
            gap: var(--space-3);
            padding: var(--space-4);
            border-bottom: 1px solid var(--neutral-100);
            position: sticky;
            top: 0;
            background: white;
          }

          .detail-back-btn {
            background: none;
            border: none;
            color: var(--brand-primary);
            font-weight: 600;
            cursor: pointer;
            padding: 0;
            font-size: 14px;
          }

          .detail-back-btn:hover {
            text-decoration: underline;
          }

          .detail-modal-title {
            flex: 1;
            font-size: 18px;
            font-weight: 700;
            color: var(--text-primary);
            margin: 0;
          }

          .detail-close-btn {
            background: none;
            border: none;
            font-size: 20px;
            cursor: pointer;
            color: var(--text-secondary);
          }

          .detail-close-btn:hover {
            color: var(--text-primary);
          }

          .detail-modal-body {
            padding: var(--space-5);
          }

          .detail-header-section {
            display: flex;
            align-items: center;
            gap: var(--space-4);
            margin-bottom: var(--space-5);
            padding-bottom: var(--space-4);
            border-bottom: 1px solid var(--neutral-100);
          }

          .detail-icon {
            font-size: 56px;
            line-height: 1;
          }

          .detail-header-info {
            flex: 1;
          }

          .detail-title {
            font-size: 18px;
            font-weight: 700;
            color: var(--text-primary);
            margin: 0;
            line-height: 1.3;
          }

          .detail-date {
            font-size: 12px;
            color: var(--text-secondary);
            margin: var(--space-1) 0 0 0;
          }

          .detail-section {
            margin-bottom: var(--space-5);
          }

          .section-title {
            font-size: 14px;
            font-weight: 700;
            color: var(--text-primary);
            margin: 0 0 var(--space-3) 0;
            text-transform: uppercase;
            letter-spacing: 0.5px;
          }

          .detail-content {
            display: flex;
            flex-direction: column;
            gap: var(--space-3);
          }

          .content-item {
            display: flex;
            flex-direction: column;
            gap: var(--space-1);
          }

          .content-item label {
            font-size: 12px;
            font-weight: 600;
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.5px;
          }

          .content-item span,
          .content-item p {
            font-size: 14px;
            color: var(--text-primary);
            margin: 0;
            line-height: 1.5;
          }

          .timeline {
            display: flex;
            flex-direction: column;
            gap: var(--space-3);
            position: relative;
            padding-left: var(--space-4);
          }

          .timeline::before {
            content: "";
            position: absolute;
            left: 10px;
            top: 0;
            bottom: 0;
            width: 2px;
            background: var(--neutral-200);
          }

          .timeline-item {
            display: flex;
            gap: var(--space-3);
            position: relative;
          }

          .timeline-marker {
            width: 20px;
            height: 20px;
            border-radius: 50%;
            background: var(--neutral-200);
            position: absolute;
            left: -14px;
            top: 2px;
            border: 3px solid white;
          }

          .timeline-marker.completed {
            background: var(--system-green);
          }

          .timeline-content {
            flex: 1;
          }

          .timeline-title {
            font-size: 13px;
            font-weight: 600;
            color: var(--text-primary);
            margin: 0;
          }

          .timeline-time {
            font-size: 12px;
            color: var(--text-secondary);
            margin: var(--space-1) 0 0 0;
          }

          .detail-actions {
            display: flex;
            gap: var(--space-3);
            margin-top: var(--space-5);
            padding-top: var(--space-4);
            border-top: 1px solid var(--neutral-100);
          }

          .detail-actions .btn {
            flex: 1;
          }

          .btn-success {
            background: var(--system-green);
            color: white;
            border: none;
          }

          .btn-success:hover {
            background: var(--system-green-dark);
          }

          .btn-danger {
            background: var(--system-red);
            color: white;
            border: none;
          }

          .btn-danger:hover {
            background: var(--system-red-dark);
          }

          @media (max-width: 768px) {
            .request-container {
              padding: var(--space-4);
            }

            .request-header-section {
              flex-direction: column;
            }

            .request-controls {
              flex-direction: column;
            }

            .search-box {
              min-width: unset;
            }

            .detail-modal-content {
              max-width: unset;
            }

            .request-header {
              flex-wrap: wrap;
            }

            .detail-header-section {
              flex-direction: column;
              text-align: center;
            }

            .status-badge {
              width: 100%;
              justify-content: center;
            }
          }
        </style>
      </div>
    `;
  }

  onMount() {
    console.log("✅ Request Management component mounted");

    // Tab switching
    const tabBtns = this.el.querySelectorAll(".tab-btn");
    tabBtns.forEach((btn) => {
      btn.addEventListener("click", (e) => {
        this.state.activeTab = e.target.dataset.tab;
        this.setHTML(this.render());
        this.onMount();
      });
    });

    // Search
    const searchInput = this.el.querySelector(".request-search");
    if (searchInput) {
      searchInput.addEventListener("input", (e) => {
        this.state.searchQuery = e.target.value;
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

    // View detail buttons
    const viewBtns = this.el.querySelectorAll(".view-detail-btn");
    viewBtns.forEach((btn) => {
      btn.addEventListener("click", (e) => {
        e.stopPropagation();
        const item = e.target.closest(".request-item");
        const reqId = parseInt(item.dataset.requestId);
        const request = this.state.requests.find((r) => r.id === reqId);
        if (request) {
          this.state.selectedRequest = request;
          this.state.showDetailModal = true;
          this.setHTML(this.render());
          this.onMount();
        }
      });
    });

    // Request item click
    const requestItems = this.el.querySelectorAll(".request-item");
    requestItems.forEach((item) => {
      item.addEventListener("click", (e) => {
        if (!e.target.closest("button")) {
          const reqId = parseInt(item.dataset.requestId);
          const request = this.state.requests.find((r) => r.id === reqId);
          if (request) {
            this.state.selectedRequest = request;
            this.state.showDetailModal = true;
            this.setHTML(this.render());
            this.onMount();
          }
        }
      });
    });

    // Modal actions
    const modalBtns = this.el.querySelectorAll("[data-action]");
    modalBtns.forEach((btn) => {
      btn.addEventListener("click", (e) => {
        const action = e.target.dataset.action;
        if (action === "back-to-list" || action === "close-detail") {
          this.state.showDetailModal = false;
          this.state.selectedRequest = null;
          this.setHTML(this.render());
          this.onMount();
        } else if (action === "approve") {
          if (this.state.selectedRequest) {
            const idx = this.state.requests.findIndex(
              (r) => r.id === this.state.selectedRequest.id
            );
            if (idx !== -1) {
              this.state.requests[idx].status = "approved";
              this.state.selectedRequest.status = "approved";
              this.setHTML(this.render());
              this.onMount();
              alert("✅ Đơn yêu cầu đã được phê duyệt");
            }
          }
        } else if (action === "reject") {
          if (this.state.selectedRequest) {
            const idx = this.state.requests.findIndex(
              (r) => r.id === this.state.selectedRequest.id
            );
            if (idx !== -1) {
              this.state.requests[idx].status = "rejected";
              this.state.selectedRequest.status = "rejected";
              this.setHTML(this.render());
              this.onMount();
              alert("✕ Đơn yêu cầu đã bị từ chối");
            }
          }
        } else if (action === "print" || action === "download") {
          alert(
            `${action === "print" ? "🖨️ In" : "📥 Tải"}: ${
              this.state.selectedRequest.title
            }`
          );
        }
      });
    });

    // Close modal on overlay click
    const overlay = this.el.querySelector(".detail-modal-overlay");
    if (overlay) {
      overlay.addEventListener("click", (e) => {
        if (e.target === overlay) {
          this.state.showDetailModal = false;
          this.state.selectedRequest = null;
          this.setHTML(this.render());
          this.onMount();
        }
      });
    }
  }

  onUnmount() {
    console.log("✅ Request Management component unmounted");
  }
}
