// Department Management Component - Paradise HR SPA
import { Component } from "../app.js";

export default class DepartmentManagement extends Component {
  constructor(props) {
    super(props);
    this.state = {
      departments: [
        {
          id: 1,
          name: "IT",
          icon: "💻",
          manager: "Lê Thị Bích",
          employees: 12,
          budget: "500 triệu VND",
          status: "active",
        },
        {
          id: 2,
          name: "Nhân sự",
          icon: "👥",
          manager: "Trần Thị Thu Trang",
          employees: 5,
          budget: "100 triệu VND",
          status: "active",
        },
        {
          id: 3,
          name: "Kinh doanh",
          icon: "📊",
          manager: "Phạm Quang Định",
          employees: 8,
          budget: "300 triệu VND",
          status: "active",
        },
        {
          id: 4,
          name: "Kế toán",
          icon: "💰",
          manager: "Nguyễn Văn An",
          employees: 6,
          budget: "150 triệu VND",
          status: "active",
        },
      ],
    };
  }

  render() {
    const deptHTML = this.state.departments
      .map(
        (dept) => `
      <div class="dept-card glass-effect">
        <div class="dept-header">
          <div class="dept-icon">${dept.icon}</div>
          <div class="dept-title-info">
            <h3 class="dept-name">${dept.name}</h3>
            <p class="dept-manager">👤 ${dept.manager}</p>
          </div>
        </div>
        <div class="dept-stats">
          <div class="stat">
            <span class="stat-label">Nhân viên</span>
            <span class="stat-value">${dept.employees}</span>
          </div>
          <div class="stat">
            <span class="stat-label">Ngân sách</span>
            <span class="stat-value">${dept.budget}</span>
          </div>
        </div>
        <div class="dept-actions">
          <button class="btn-small">Xem chi tiết</button>
          <button class="btn-small">Chỉnh sửa</button>
        </div>
      </div>
    `
      )
      .join("");

    return `
      <div class="department-container">
        <div class="department-header">
          <h1>🏢 Quản lý Bộ phận</h1>
          <button class="btn btn-primary">+ Thêm bộ phận</button>
        </div>

        <div class="dept-grid">
          ${deptHTML}
        </div>

        <style>
          .department-container {
            padding: var(--space-6);
            background: linear-gradient(135deg, var(--brand-primary-alpha-10) 0%, var(--brand-secondary-alpha-10) 100%);
            min-height: 100vh;
          }

          .department-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: var(--space-6);
            flex-wrap: wrap;
            gap: var(--space-4);
          }

          .department-header h1 {
            font-size: 32px;
            font-weight: 700;
            margin: 0;
            color: var(--text-primary);
          }

          .dept-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: var(--space-5);
          }

          .dept-card {
            padding: var(--space-5);
            background: rgba(255, 255, 255, 0.7);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.5);
            border-radius: var(--radius-lg);
            transition: all var(--duration-normal) var(--ease-out);
          }

          .dept-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
          }

          .dept-header {
            display: flex;
            align-items: center;
            gap: var(--space-3);
            margin-bottom: var(--space-4);
          }

          .dept-icon {
            font-size: 48px;
            line-height: 1;
          }

          .dept-title-info {
            flex: 1;
          }

          .dept-name {
            font-size: 20px;
            font-weight: 700;
            color: var(--text-primary);
            margin: 0;
          }

          .dept-manager {
            font-size: 13px;
            color: var(--text-secondary);
            margin: var(--space-1) 0 0 0;
          }

          .dept-stats {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: var(--space-3);
            padding: var(--space-3);
            background: rgba(115, 196, 29, 0.05);
            border-radius: var(--radius-md);
            margin-bottom: var(--space-4);
          }

          .stat {
            display: flex;
            flex-direction: column;
            gap: var(--space-1);
          }

          .stat-label {
            font-size: 11px;
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            font-weight: 600;
          }

          .stat-value {
            font-size: 16px;
            font-weight: 700;
            color: var(--brand-primary);
          }

          .dept-actions {
            display: flex;
            gap: var(--space-2);
          }

          .btn-small {
            flex: 1;
            padding: var(--space-2) var(--space-3);
            background: var(--neutral-50);
            border: 1px solid var(--neutral-200);
            border-radius: var(--radius-md);
            cursor: pointer;
            font-size: 12px;
            font-weight: 600;
            color: var(--text-primary);
            transition: all var(--duration-fast) var(--ease-out);
          }

          .btn-small:hover {
            background: var(--brand-primary-alpha-10);
            border-color: var(--brand-primary);
            color: var(--brand-primary);
          }

          @media (max-width: 768px) {
            .department-container {
              padding: var(--space-4);
            }

            .department-header {
              flex-direction: column;
              align-items: flex-start;
            }

            .dept-grid {
              grid-template-columns: 1fr;
            }
          }
        </style>
      </div>
    `;
  }

  onMount() {
    console.log("✅ Department Management component mounted");
  }

  onUnmount() {
    console.log("✅ Department Management component unmounted");
  }
}
