// Home Dashboard Component - Paradise HR SPA
import { Component } from "../app.js";

export default class Home extends Component {
  constructor(props) {
    super(props);
    this.state = {
      totalEmployees: 128,
      activeEmployees: 113,
      onLeave: 10,
      newRecruits: 5,
      leaveData: [4, 6, 3, 8, 2, 7, 5, 4, 6, 3, 2, 4],
      genderData: { male: 68, female: 60 },
      recentStaff: [
        {
          name: "Nguyễn Văn An",
          dept: "Kế toán",
          position: "Nhân viên",
          status: "online",
          joinDate: "12/02/2022",
        },
        {
          name: "Lê Thị Bích",
          dept: "IT",
          position: "Quản trị hệ thống",
          status: "on-leave",
          joinDate: "23/08/2021",
        },
        {
          name: "Phạm Quang Định",
          dept: "Kinh doanh",
          position: "Trưởng phòng",
          status: "online",
          joinDate: "05/03/2020",
        },
      ],
      menuItems: [
        {
          title: "Hồ sơ Nhân sự",
          icon: "📋",
          link: "/employees",
          description: "Quản lý hồ sơ chi tiết",
        },
        {
          title: "Đơn yêu cầu",
          icon: "📮",
          link: "/requests",
          description: "Quản lý các đơn xin",
        },
        {
          title: "Danh sách ứng viên",
          icon: "👥",
          link: "/candidates",
          description: "Quản lý ứng viên tuyển dụng",
        },
        {
          title: "Tuyển dụng",
          icon: "🎯",
          link: "/recruitment",
          description: "Quản lý tuyển dụng",
        },
        {
          title: "Quản lý bộ phận",
          icon: "🏢",
          link: "/departments",
          description: "Cấu trúc tổ chức",
        },
        {
          title: "Lương thưởng",
          icon: "💰",
          link: "/payroll",
          description: "Quản lý lương thưởng",
        },
        {
          title: "Chấm công",
          icon: "📅",
          link: "/attendance",
          description: "Ghi nhận chấm công",
        },
        {
          title: "Hợp đồng",
          icon: "📄",
          link: "/contracts",
          description: "Quản lý hợp đồng",
        },
        {
          title: "Đánh giá hiệu suất",
          icon: "⭐",
          link: "/performance",
          description: "Đánh giá nhân viên",
        },
        // {
        //   title: "Thông báo",
        //   icon: "🔔",
        //   link: "/notifications",
        //   description: "Quản lý thông báo hệ thống",
        // },
        // {
        //   title: "Cài đặt",
        //   icon: "⚙️",
        //   link: "/settings",
        //   description: "Tùy chỉnh cài đặt cá nhân",
        // },
      ],
    };
  }

  renderMenuGrid() {
    const menuHTML = this.state.menuItems
      .map(
        (item) => `
      <a href="${item.link}" class="menu-item glass-effect" data-link>
        <div class="menu-icon">${item.icon}</div>
        <h3 class="menu-title">${item.title}</h3>
        <p class="menu-description">${item.description}</p>
      </a>
    `
      )
      .join("");

    return `
      <section class="menu-section">
        <h2 class="menu-section-title">Các tính năng chính</h2>
        <div class="menu-grid">
          ${menuHTML}
        </div>
      </section>
    `;
  }

  renderStatCard(title, value) {
    return `
      <div class="stat-card glass-effect">
        <div class="stat-header">
          <h3 class="stat-title">${title}</h3>
        </div>
        <div class="stat-value">${value}</div>
        <div class="stat-footer">
          <span class="stat-change positive">↑ 2.5%</span>
          <span class="stat-period">so với tháng trước</span>
        </div>
      </div>
    `;
  }

  renderLeaveChart() {
    const data = this.state.leaveData;
    const months = [
      "T1",
      "T2",
      "T3",
      "T4",
      "T5",
      "T6",
      "T7",
      "T8",
      "T9",
      "T10",
      "T11",
      "T12",
    ];
    const maxBar = Math.max(...data);

    let barsHTML = "";
    data.forEach((val, i) => {
      const heightPercent = (val / maxBar) * 100;
      barsHTML += `
        <div class="chart-bar-wrapper">
          <div class="chart-bar-container">
            <div class="chart-bar" style="height: ${heightPercent}%; background: linear-gradient(180deg, var(--system-blue) 0%, var(--system-blue-light) 100%);">
              <span class="chart-bar-value">${val}</span>
            </div>
          </div>
          <span class="chart-bar-label">${months[i]}</span>
        </div>
      `;
    });

    return `
      <div class="chart-card glass-effect">
        <div class="chart-header">
          <h2 class="chart-title">Thống kê nghỉ phép theo tháng</h2>
          <button class="chart-btn-menu">⋮</button>
        </div>
        <div class="chart-bars-container">
          ${barsHTML}
        </div>
      </div>
    `;
  }

  renderGenderChart() {
    const { male, female } = this.state.genderData;
    const total = male + female;
    const malePercent = (male / total) * 100;
    const femalePercent = (female / total) * 100;

    return `
      <div class="chart-card glass-effect">
        <div class="chart-header">
          <h2 class="chart-title">Tỉ lệ giới tính nhân sự</h2>
          <button class="chart-btn-menu">⋮</button>
        </div>
        <div class="gender-chart-container">
          <div class="donut-chart">
            <svg viewBox="0 0 180 180" class="donut-svg">
              <circle cx="90" cy="90" r="60" class="donut-background"></circle>
              <circle cx="90" cy="90" r="60" class="donut-segment male" 
                style="stroke-dasharray: ${
                  (malePercent / 100) * 376.99
                } 376.99;"></circle>
              <circle cx="90" cy="90" r="60" class="donut-segment female" 
                style="transform: rotate(${
                  (malePercent / 100) * 360
                }deg); transform-origin: 90px 90px;
                stroke-dasharray: ${
                  (femalePercent / 100) * 376.99
                } 376.99;"></circle>
            </svg>
            <div class="donut-center">
              <div class="donut-total">${total}</div>
              <div class="donut-label">Nhân sự</div>
            </div>
          </div>
          <div class="gender-legend">
            <div class="legend-item">
              <div class="legend-color male"></div>
              <span class="legend-text">Nam: ${male}</span>
            </div>
            <div class="legend-item">
              <div class="legend-color female"></div>
              <span class="legend-text">Nữ: ${female}</span>
            </div>
          </div>
        </div>
      </div>
    `;
  }

  renderStaffTable() {
    const staffRows = this.state.recentStaff
      .map(
        (staff) => `
      <tr class="staff-table-row">
        <td class="staff-name">${staff.name}</td>
        <td class="staff-dept">${staff.dept}</td>
        <td class="staff-position">${staff.position}</td>
        <td class="staff-status">
          <span class="status-badge ${staff.status}">
            ${staff.status === "online" ? "● Đang làm việc" : "● Nghỉ phép"}
          </span>
        </td>
        <td class="staff-date">${staff.joinDate}</td>
      </tr>
    `
      )
      .join("");

    return `
      <section class="table-section glass-effect">
        <div class="table-header">
          <h2 class="table-title">Danh sách nhân sự nổi bật</h2>
          <a href="/employees" class="table-link" data-link>Xem tất cả →</a>
        </div>
        <div class="table-wrapper">
          <table class="staff-table">
            <thead>
              <tr class="staff-table-header">
                <th class="staff-header-cell">Họ tên</th>
                <th class="staff-header-cell">Bộ phận</th>
                <th class="staff-header-cell">Chức vụ</th>
                <th class="staff-header-cell">Trạng thái</th>
                <th class="staff-header-cell">Ngày vào làm</th>
              </tr>
            </thead>
            <tbody>
              ${staffRows}
            </tbody>
          </table>
        </div>
      </section>
    `;
  }

  render() {
    return `
      <div class="dashboard-container">
          <!-- Statistics Section -->
          <section class="stats-section">
            <div class="stats-grid">
              ${this.renderStatCard("Tổng nhân sự", this.state.totalEmployees)}
              ${this.renderStatCard(
                "Đang làm việc",
                this.state.activeEmployees
              )}
              ${this.renderStatCard("Đang nghỉ phép", this.state.onLeave)}
              ${this.renderStatCard("Tuyển dụng mới", this.state.newRecruits)}
            </div>
          </section>

          <!-- Charts Section -->
          <section class="charts-section">
            <div class="charts-grid">
              ${this.renderLeaveChart()}
              ${this.renderGenderChart()}
            </div>
          </section>

          <!-- Staff Table Section -->
          ${this.renderStaffTable()}
        </main>
      </div>

      <style>
        .dashboard-container {
          width: 100%;
          min-height: 100vh;
          background: transparent;
        }

        .dashboard-header {
          margin-bottom: var(--space-8);
          display: flex;
          justify-content: space-between;
          align-items: flex-start;
          gap: var(--space-4);
          flex-wrap: wrap;
        }

        .dashboard-header-content {
          flex: 1;
        }

        .dashboard-title {
          font-size: 32px;
          font-weight: 700;
          color: var(--text-primary);
          margin: 0;
          line-height: 1.2;
        }

        .dashboard-subtitle {
          font-size: 14px;
          color: var(--text-secondary);
          margin: var(--space-2) 0 0 0;
        }

        .dashboard-actions {
          display: flex;
          gap: var(--space-3);
          flex-wrap: wrap;
        }

        .menu-section {
          margin-bottom: var(--space-8);
        }

        .menu-section-title {
          font-size: 20px;
          font-weight: 600;
          color: var(--text-primary);
          margin: 0 0 var(--space-5) 0;
        }

        .menu-grid {
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
          gap: var(--space-4);
        }

        .menu-item {
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          gap: var(--space-3);
          padding: var(--space-5);
          background: rgba(255, 255, 255, 0.7);
          backdrop-filter: blur(20px);
          border: 1px solid rgba(255, 255, 255, 0.5);
          border-radius: var(--radius-lg);
          text-decoration: none;
          cursor: pointer;
          transition: all var(--duration-normal) var(--ease-out);
          text-align: center;
          min-height: 180px;
        }

        .menu-item:hover {
          transform: translateY(-6px);
          box-shadow: 0 24px 48px rgba(0, 0, 0, 0.12);
          background: rgba(255, 255, 255, 0.9);
          border-color: rgba(115, 196, 29, 0.3);
        }

        .menu-icon {
          font-size: 48px;
          line-height: 1;
        }

        .menu-title {
          font-size: 16px;
          font-weight: 600;
          color: var(--text-primary);
          margin: 0;
          line-height: 1.2;
        }

        .menu-description {
          font-size: 12px;
          color: var(--text-secondary);
          margin: 0;
          line-height: 1.4;
        }

        .stats-section {
          margin-bottom: var(--space-8);
        }

        .stats-grid {
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
          gap: var(--space-5);
        }

        .stat-card {
          padding: var(--space-5);
          background: rgba(255, 255, 255, 0.7);
          backdrop-filter: blur(20px);
          border: 1px solid rgba(255, 255, 255, 0.5);
          border-radius: var(--radius-lg);
          transition: all var(--duration-normal) var(--ease-out);
        }

        .stat-card:hover {
          transform: translateY(-4px);
          box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
          background: rgba(255, 255, 255, 0.85);
        }

        .stat-header {
          margin-bottom: var(--space-3);
        }

        .stat-title {
          font-size: 13px;
          font-weight: 600;
          color: var(--text-secondary);
          text-transform: uppercase;
          letter-spacing: 0.5px;
          margin: 0;
        }

        .stat-value {
          font-size: 36px;
          font-weight: 700;
          color: var(--brand-primary);
          margin: var(--space-2) 0;
          line-height: 1;
        }

        .stat-footer {
          display: flex;
          align-items: center;
          gap: var(--space-2);
          font-size: 12px;
          color: var(--text-secondary);
        }

        .stat-change {
          color: var(--system-green);
          font-weight: 600;
        }

        .charts-section {
          margin-bottom: var(--space-8);
        }

        .charts-grid {
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
          gap: var(--space-5);
        }

        .chart-card {
          padding: var(--space-5);
          background: rgba(255, 255, 255, 0.7);
          backdrop-filter: blur(20px);
          border: 1px solid rgba(255, 255, 255, 0.5);
          border-radius: var(--radius-lg);
        }

        .chart-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          margin-bottom: var(--space-4);
        }

        .chart-title {
          font-size: 18px;
          font-weight: 600;
          color: var(--text-primary);
          margin: 0;
        }

        .chart-btn-menu {
          background: none;
          border: none;
          color: var(--text-secondary);
          cursor: pointer;
          font-size: 18px;
          padding: var(--space-1);
          border-radius: var(--radius-md);
          transition: all var(--duration-fast) var(--ease-out);
        }

        .chart-btn-menu:hover {
          background: rgba(0, 0, 0, 0.05);
          color: var(--text-primary);
        }

        .chart-bars-container {
          display: flex;
          align-items: flex-end;
          justify-content: space-around;
          height: 200px;
          gap: var(--space-2);
          padding: var(--space-3) 0;
        }

        .chart-bar-wrapper {
          display: flex;
          flex-direction: column;
          align-items: center;
          flex: 1;
          gap: var(--space-2);
          height: 100%;
        }

        .chart-bar-container {
          width: 100%;
          height: 100%;
          display: flex;
          align-items: flex-end;
          justify-content: center;
        }

        .chart-bar {
          width: 80%;
          border-radius: var(--radius-md) var(--radius-md) 0 0;
          display: flex;
          align-items: flex-start;
          justify-content: center;
          padding-top: var(--space-2);
          transition: all var(--duration-normal) var(--ease-out);
          position: relative;
        }

        .chart-bar:hover {
          box-shadow: 0 8px 20px rgba(0, 0, 0, 0.15);
        }

        .chart-bar-value {
          font-size: 11px;
          font-weight: 600;
          color: white;
          opacity: 0;
          transition: opacity var(--duration-normal) var(--ease-out);
        }

        .chart-bar:hover .chart-bar-value {
          opacity: 1;
        }

        .chart-bar-label {
          font-size: 12px;
          color: var(--text-secondary);
          font-weight: 500;
        }

        .gender-chart-container {
          display: flex;
          align-items: center;
          justify-content: center;
          gap: var(--space-8);
          min-height: 220px;
        }

        .donut-chart {
          position: relative;
          width: 160px;
          height: 160px;
        }

        .donut-svg {
          width: 100%;
          height: 100%;
          transform: rotate(-90deg);
        }

        .donut-background {
          fill: none;
          stroke: var(--neutral-100);
          stroke-width: 12;
        }

        .donut-segment {
          fill: none;
          stroke-width: 12;
          stroke-linecap: round;
          transition: all var(--duration-normal) var(--ease-out);
        }

        .donut-segment.male {
          stroke: var(--system-blue);
        }

        .donut-segment.female {
          stroke: var(--system-pink);
        }

        .donut-center {
          position: absolute;
          top: 50%;
          left: 50%;
          transform: translate(-50%, -50%);
          text-align: center;
        }

        .donut-total {
          font-size: 24px;
          font-weight: 700;
          color: var(--text-primary);
        }

        .donut-label {
          font-size: 12px;
          color: var(--text-secondary);
          font-weight: 500;
        }

        .gender-legend {
          display: flex;
          flex-direction: column;
          gap: var(--space-3);
        }

        .legend-item {
          display: flex;
          align-items: center;
          gap: var(--space-2);
        }

        .legend-color {
          width: 12px;
          height: 12px;
          border-radius: 50%;
        }

        .legend-color.male {
          background: var(--system-blue);
        }

        .legend-color.female {
          background: var(--system-pink);
        }

        .legend-text {
          font-size: 13px;
          color: var(--text-primary);
          font-weight: 500;
        }

        .table-section {
          padding: var(--space-5);
          background: rgba(255, 255, 255, 0.7);
          backdrop-filter: blur(20px);
          border: 1px solid rgba(255, 255, 255, 0.5);
          border-radius: var(--radius-lg);
        }

        .table-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          margin-bottom: var(--space-4);
        }

        .table-title {
          font-size: 18px;
          font-weight: 600;
          color: var(--text-primary);
          margin: 0;
        }

        .table-link {
          color: var(--brand-primary);
          text-decoration: none;
          font-weight: 500;
          font-size: 14px;
          transition: all var(--duration-fast) var(--ease-out);
        }

        .table-link:hover {
          color: var(--brand-primary-dark);
        }

        .table-wrapper {
          overflow-x: auto;
        }

        .staff-table {
          width: 100%;
          border-collapse: collapse;
        }

        .staff-table-header {
          background: var(--neutral-50);
        }

        .staff-header-cell {
          padding: var(--space-3) var(--space-4);
          text-align: left;
          font-size: 13px;
          font-weight: 600;
          color: var(--text-secondary);
          text-transform: uppercase;
          letter-spacing: 0.5px;
          border-bottom: 1px solid var(--neutral-200);
        }

        .staff-table-row {
          transition: all var(--duration-fast) var(--ease-out);
          border-bottom: 1px solid var(--neutral-100);
        }

        .staff-table-row:hover {
          background: var(--neutral-50);
        }

        .staff-table-row:last-child {
          border-bottom: none;
        }

        .staff-name,
        .staff-dept,
        .staff-position,
        .staff-status,
        .staff-date {
          padding: var(--space-3) var(--space-4);
          font-size: 14px;
          color: var(--text-primary);
        }

        .staff-name {
          font-weight: 600;
        }

        .staff-dept,
        .staff-position {
          color: var(--text-secondary);
        }

        .staff-date {
          color: var(--text-secondary);
          font-size: 13px;
        }

        .status-badge {
          display: inline-flex;
          align-items: center;
          gap: var(--space-1);
          padding: var(--space-2) var(--space-3);
          border-radius: var(--radius-md);
          font-size: 12px;
          font-weight: 600;
        }

        .status-badge.online {
          background: var(--system-green-alpha);
          color: var(--system-green-dark);
        }

        .status-badge.on-leave {
          background: var(--system-orange-alpha);
          color: var(--system-orange-dark);
        }

        @media (max-width: 1024px) {
          .menu-grid {
            grid-template-columns: repeat(3, 1fr);
          }
        }

        @media (max-width: 768px) {
          .dashboard-container {
            padding: var(--space-4);
          }

          .dashboard-header {
            flex-direction: column;
          }

          .dashboard-title {
            font-size: 24px;
          }

          .menu-grid {
            grid-template-columns: repeat(2, 1fr);
          }

          .menu-item {
            min-height: 140px;
            padding: var(--space-4);
          }

          .menu-icon {
            font-size: 40px;
          }

          .menu-title {
            font-size: 14px;
          }

          .menu-description {
            font-size: 11px;
          }

          .stats-grid {
            grid-template-columns: 1fr;
          }

          .charts-grid {
            grid-template-columns: 1fr;
          }

          .gender-chart-container {
            flex-direction: column;
            gap: var(--space-4);
          }

          .chart-bars-container {
            height: 150px;
          }
        }

        @media (max-width: 480px) {
          .menu-grid {
            grid-template-columns: 1fr;
          }

          .menu-item {
            min-height: 120px;
          }

          .menu-icon {
            font-size: 36px;
          }
        }
      </style>
    `;
  }

  onMount() {
    console.log("✅ Home Dashboard component mounted");
  }

  onUnmount() {
    console.log("✅ Home Dashboard component unmounted");
  }
}
