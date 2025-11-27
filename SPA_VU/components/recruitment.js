// Recruitment Management Component - Paradise HR SPA
import { Component } from "../app.js";

export default class RecruitmentManagement extends Component {
  constructor(props) {
    super(props);
    this.state = {
      positions: [
        {
          id: 1,
          title: "Senior Developer",
          department: "IT",
          level: "Senior",
          salary: "15-20 triệu",
          status: "open",
          applications: 12,
          postedDate: "01/11/2025",
          description: "Tìm kiếm developer có kinh nghiệm 5+ năm",
          icon: "💻",
        },
        {
          id: 2,
          title: "Business Analyst",
          department: "Kinh doanh",
          level: "Mid",
          salary: "10-15 triệu",
          status: "open",
          applications: 8,
          postedDate: "15/10/2025",
          description: "Phân tích yêu cầu kinh doanh và đưa ra giải pháp",
          icon: "📊",
        },
        {
          id: 3,
          title: "HR Specialist",
          department: "Nhân sự",
          level: "Mid",
          salary: "8-12 triệu",
          status: "closed",
          applications: 24,
          postedDate: "20/09/2025",
          description: "Chuyên viên Nhân sự toàn diện",
          icon: "👥",
        },
        {
          id: 4,
          title: "UI/UX Designer",
          department: "IT",
          level: "Mid",
          salary: "12-18 triệu",
          status: "open",
          applications: 15,
          postedDate: "05/11/2025",
          description: "Thiết kế giao diện người dùng",
          icon: "🎨",
        },
      ],
      activeFilter: "all",
    };
  }

  getFilteredPositions() {
    if (this.state.activeFilter === "all") return this.state.positions;
    return this.state.positions.filter(
      (p) => p.status === this.state.activeFilter
    );
  }

  render() {
    const filtered = this.getFilteredPositions();
    const positionsHTML = filtered
      .map(
        (pos) => `
      <div class="position-card glass-effect">
        <div class="position-icon">${pos.icon}</div>
        <div class="position-info">
          <h3 class="position-title">${pos.title}</h3>
          <p class="position-meta">${pos.department} • ${pos.level}</p>
          <div class="position-details">
            <span class="detail-item">💰 ${pos.salary}</span>
            <span class="detail-item">📝 ${pos.applications} đơn</span>
          </div>
        </div>
        <div class="position-status ${pos.status}">
          ${pos.status === "open" ? "Đang tuyển" : "Đóng"}
        </div>
      </div>
    `
      )
      .join("");

    return `
      <div class="recruitment-container">
        <div class="recruitment-header">
          <h1>👔 Quản lý Tuyển dụng</h1>
          <button class="btn btn-primary">+ Đăng tin tuyển dụng</button>
        </div>

        <div class="filter-tabs">
          <button class="filter-tab ${
            this.state.activeFilter === "all" ? "active" : ""
          }" data-filter="all">
            Tất cả (${this.state.positions.length})
          </button>
          <button class="filter-tab ${
            this.state.activeFilter === "open" ? "active" : ""
          }" data-filter="open">
            Đang tuyển (${
              this.state.positions.filter((p) => p.status === "open").length
            })
          </button>
          <button class="filter-tab ${
            this.state.activeFilter === "closed" ? "active" : ""
          }" data-filter="closed">
            Đóng (${
              this.state.positions.filter((p) => p.status === "closed").length
            })
          </button>
        </div>

        <div class="positions-grid">
          ${positionsHTML}
        </div>

        <style>
          .recruitment-container {
            padding: var(--space-6);
            background: linear-gradient(135deg, var(--brand-primary-alpha-10) 0%, var(--brand-secondary-alpha-10) 100%);
            min-height: 100vh;
          }

          .recruitment-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: var(--space-6);
            flex-wrap: wrap;
            gap: var(--space-4);
          }

          .recruitment-header h1 {
            font-size: 32px;
            font-weight: 700;
            margin: 0;
            color: var(--text-primary);
          }

          .filter-tabs {
            display: flex;
            gap: var(--space-2);
            margin-bottom: var(--space-5);
            flex-wrap: wrap;
          }

          .filter-tab {
            padding: var(--space-2) var(--space-4);
            background: rgba(255, 255, 255, 0.7);
            border: 1px solid rgba(255, 255, 255, 0.5);
            border-radius: var(--radius-md);
            cursor: pointer;
            font-weight: 600;
            transition: all var(--duration-fast) var(--ease-out);
          }

          .filter-tab:hover,
          .filter-tab.active {
            background: var(--brand-primary);
            color: white;
            border-color: var(--brand-primary);
          }

          .positions-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: var(--space-4);
          }

          .position-card {
            padding: var(--space-4);
            background: rgba(255, 255, 255, 0.7);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.5);
            border-radius: var(--radius-lg);
            cursor: pointer;
            transition: all var(--duration-normal) var(--ease-out);
            display: flex;
            flex-direction: column;
          }

          .position-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
          }

          .position-icon {
            font-size: 48px;
            margin-bottom: var(--space-3);
          }

          .position-info {
            flex: 1;
            margin-bottom: var(--space-3);
          }

          .position-title {
            font-size: 18px;
            font-weight: 700;
            color: var(--text-primary);
            margin: 0 0 var(--space-2) 0;
          }

          .position-meta {
            font-size: 13px;
            color: var(--text-secondary);
            margin: 0 0 var(--space-2) 0;
          }

          .position-details {
            display: flex;
            gap: var(--space-3);
            flex-wrap: wrap;
          }

          .detail-item {
            font-size: 12px;
            color: var(--text-primary);
            font-weight: 500;
          }

          .position-status {
            display: inline-block;
            padding: var(--space-2) var(--space-3);
            border-radius: var(--radius-md);
            font-size: 12px;
            font-weight: 600;
            text-align: center;
            width: fit-content;
          }

          .position-status.open {
            background: var(--system-green-alpha);
            color: var(--system-green-dark);
          }

          .position-status.closed {
            background: var(--neutral-100);
            color: var(--text-secondary);
          }

          @media (max-width: 768px) {
            .recruitment-container {
              padding: var(--space-4);
            }

            .recruitment-header {
              flex-direction: column;
              align-items: flex-start;
            }

            .positions-grid {
              grid-template-columns: 1fr;
            }
          }
        </style>
      </div>
    `;
  }

  onMount() {
    console.log("✅ Recruitment Management component mounted");

    const filterTabs = this.el.querySelectorAll(".filter-tab");
    filterTabs.forEach((tab) => {
      tab.addEventListener("click", (e) => {
        this.state.activeFilter = e.target.dataset.filter;
        this.setHTML(this.render());
        this.onMount();
      });
    });
  }

  onUnmount() {
    console.log("✅ Recruitment Management component unmounted");
  }
}
