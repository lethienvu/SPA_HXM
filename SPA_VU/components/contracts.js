// Contracts Management Component - Paradise HR SPA

class ContractManagement extends Component {
  constructor(props) {
    super(props);
    this.state = {
      contracts: [
        {
          id: 1,
          employee: "Nguyễn Văn A",
          type: "Hợp đồng xác định thời hạn",
          startDate: "2022-01-15",
          endDate: "2025-01-14",
          status: "active",
          daysLeft: 25,
          value: "500 triệu VND",
        },
        {
          id: 2,
          employee: "Trần Thị B",
          type: "Hợp đồng không xác định thời hạn",
          startDate: "2021-06-01",
          endDate: null,
          status: "active",
          daysLeft: null,
          value: "300 triệu VND",
        },
        {
          id: 3,
          employee: "Lê Quốc C",
          type: "Hợp đồng xác định thời hạn",
          startDate: "2023-03-20",
          endDate: "2024-03-19",
          status: "expired",
          daysLeft: -266,
          value: "350 triệu VND",
        },
        {
          id: 4,
          employee: "Phạm Hồng D",
          type: "Hợp đồng xác định thời hạn",
          startDate: "2024-01-10",
          endDate: "2025-07-09",
          status: "active",
          daysLeft: 200,
          value: "450 triệu VND",
        },
      ],
      filterStatus: "all",
      searchTerm: "",
    };
  }

  render() {
    const filtered = this.getFilteredContracts();

    const contractsHTML = filtered
      .map(
        (contract) => `
      <div class="contract-card glass-effect">
        <div class="contract-header">
          <div class="contract-employee">
            <div class="emp-avatar">${contract.employee.charAt(0)}</div>
            <div class="emp-info">
              <h3 class="emp-name">${contract.employee}</h3>
              <p class="contract-type">${contract.type}</p>
            </div>
          </div>
          <span class="contract-badge badge-${contract.status}">
            ${this.getStatusDisplay(contract.status)}
          </span>
        </div>

        <div class="contract-details">
          <div class="detail-item">
            <span class="detail-label">Ngày bắt đầu</span>
            <span class="detail-value">${this.formatDate(
              contract.startDate
            )}</span>
          </div>
          <div class="detail-item">
            <span class="detail-label">Ngày kết thúc</span>
            <span class="detail-value">${
              contract.endDate
                ? this.formatDate(contract.endDate)
                : "Không xác định"
            }</span>
          </div>
          <div class="detail-item">
            <span class="detail-label">Giá trị</span>
            <span class="detail-value">${contract.value}</span>
          </div>
          ${
            contract.daysLeft !== null
              ? `
            <div class="detail-item">
              <span class="detail-label">Còn lại</span>
              <span class="detail-value ${
                contract.daysLeft < 30 ? "warning" : ""
              }">${contract.daysLeft} ngày</span>
            </div>
          `
              : ""
          }
        </div>

        <div class="contract-actions">
          <button class="btn-action">Xem</button>
          <button class="btn-action">Gia hạn</button>
          <button class="btn-action">Xuất PDF</button>
        </div>
      </div>
    `
      )
      .join("");

    const activeCount = filtered.filter((c) => c.status === "active").length;
    const expiredCount = filtered.filter((c) => c.status === "expired").length;
    const pendingRenewal = filtered.filter(
      (c) => c.daysLeft !== null && c.daysLeft <= 30
    ).length;

    return `
      <div class="contracts-container">
        <div class="contracts-header">
          <h1>📄 Quản lý Hợp đồng</h1>
          <button class="btn btn-primary">+ Thêm hợp đồng</button>
        </div>

        <div class="contracts-stats">
          <div class="stat-card glass-effect">
            <span class="stat-label">Đang hiệu lực</span>
            <span class="stat-value active">${activeCount}</span>
          </div>
          <div class="stat-card glass-effect">
            <span class="stat-label">Hết hiệu lực</span>
            <span class="stat-value expired">${expiredCount}</span>
          </div>
          <div class="stat-card glass-effect">
            <span class="stat-label">Cần gia hạn</span>
            <span class="stat-value warning">${pendingRenewal}</span>
          </div>
          <div class="stat-card glass-effect">
            <span class="stat-label">Tổng cộng</span>
            <span class="stat-value">${filtered.length}</span>
          </div>
        </div>

        <div class="contracts-controls">
          <input
            type="text"
            placeholder="Tìm kiếm nhân viên..."
            class="search-input"
            value="${this.state.searchTerm}"
          />
          <select class="filter-status">
            <option value="all">Tất cả trạng thái</option>
            <option value="active">Đang hiệu lực</option>
            <option value="expired">Hết hiệu lực</option>
          </select>
        </div>

        <div class="contracts-grid">
          ${contractsHTML}
        </div>

        <style>
          .contracts-container {
            padding: var(--space-6);
            background: linear-gradient(135deg, var(--brand-primary-alpha-10) 0%, var(--brand-secondary-alpha-10) 100%);
            min-height: 100vh;
          }

          .contracts-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: var(--space-6);
            flex-wrap: wrap;
            gap: var(--space-4);
          }

          .contracts-header h1 {
            font-size: 32px;
            font-weight: 700;
            margin: 0;
            color: var(--text-primary);
          }

          .contracts-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: var(--space-4);
            margin-bottom: var(--space-6);
          }

          .stat-card {
            padding: var(--space-4);
            background: rgba(255, 255, 255, 0.7);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.5);
            border-radius: var(--radius-lg);
            display: flex;
            flex-direction: column;
            gap: var(--space-2);
            text-align: center;
          }

          .stat-label {
            font-size: 12px;
            font-weight: 600;
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.5px;
          }

          .stat-value {
            font-size: 28px;
            font-weight: 700;
            color: var(--brand-primary);
          }

          .stat-value.active {
            color: var(--semantic-green);
          }

          .stat-value.expired {
            color: var(--semantic-red);
          }

          .stat-value.warning {
            color: var(--semantic-orange);
          }

          .contracts-controls {
            display: flex;
            gap: var(--space-4);
            margin-bottom: var(--space-6);
            flex-wrap: wrap;
          }

          .search-input,
          .filter-status {
            padding: var(--space-2) var(--space-3);
            background: white;
            border: 1px solid var(--neutral-200);
            border-radius: var(--radius-md);
            font-size: 14px;
            color: var(--text-primary);
            transition: all var(--duration-fast) var(--ease-out);
            flex: 0 1 auto;
            min-width: 200px;
          }

          .search-input {
            flex: 1;
            min-width: 250px;
          }

          .search-input:focus,
          .filter-status:focus {
            outline: none;
            border-color: var(--brand-primary);
            box-shadow: 0 0 0 3px rgba(115, 196, 29, 0.1);
          }

          .contracts-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: var(--space-5);
          }

          .contract-card {
            padding: var(--space-5);
            background: rgba(255, 255, 255, 0.7);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.5);
            border-radius: var(--radius-lg);
            transition: all var(--duration-normal) var(--ease-out);
            display: flex;
            flex-direction: column;
            gap: var(--space-4);
          }

          .contract-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
          }

          .contract-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: var(--space-3);
          }

          .contract-employee {
            display: flex;
            align-items: center;
            gap: var(--space-3);
            flex: 1;
          }

          .emp-avatar {
            width: 44px;
            height: 44px;
            border-radius: 50%;
            background: var(--brand-primary);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 18px;
            flex-shrink: 0;
          }

          .emp-info {
            flex: 1;
            min-width: 0;
          }

          .emp-name {
            font-size: 15px;
            font-weight: 700;
            color: var(--text-primary);
            margin: 0;
            word-break: break-word;
          }

          .contract-type {
            font-size: 12px;
            color: var(--text-secondary);
            margin: var(--space-1) 0 0 0;
          }

          .contract-badge {
            padding: var(--space-1) var(--space-3);
            border-radius: var(--radius-md);
            font-size: 11px;
            font-weight: 700;
            white-space: nowrap;
          }

          .badge-active {
            background: rgba(50, 215, 75, 0.1);
            color: var(--semantic-green);
          }

          .badge-expired {
            background: rgba(255, 69, 58, 0.1);
            color: var(--semantic-red);
          }

          .contract-details {
            display: flex;
            flex-direction: column;
            gap: var(--space-3);
            padding: var(--space-3);
            background: rgba(115, 196, 29, 0.05);
            border-radius: var(--radius-md);
          }

          .detail-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: var(--space-3);
          }

          .detail-label {
            font-size: 11px;
            font-weight: 600;
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            flex: 0 0 auto;
          }

          .detail-value {
            font-size: 13px;
            font-weight: 600;
            color: var(--text-primary);
            text-align: right;
          }

          .detail-value.warning {
            color: var(--semantic-orange);
          }

          .contract-actions {
            display: flex;
            gap: var(--space-2);
            padding-top: var(--space-3);
            border-top: 1px solid rgba(0, 0, 0, 0.05);
          }

          .btn-action {
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

          .btn-action:hover {
            background: var(--brand-primary-alpha-10);
            border-color: var(--brand-primary);
            color: var(--brand-primary);
          }

          @media (max-width: 768px) {
            .contracts-container {
              padding: var(--space-4);
            }

            .contracts-header {
              flex-direction: column;
              align-items: flex-start;
            }

            .contracts-controls {
              flex-direction: column;
            }

            .search-input,
            .filter-status {
              width: 100%;
              min-width: unset;
            }

            .contracts-grid {
              grid-template-columns: 1fr;
            }

            .contract-header {
              flex-direction: column;
            }
          }
        </style>
      </div>
    `;
  }

  getFilteredContracts() {
    return this.state.contracts.filter((contract) => {
      const matchesSearch = contract.employee
        .toLowerCase()
        .includes(this.state.searchTerm.toLowerCase());
      const matchesStatus =
        this.state.filterStatus === "all" ||
        contract.status === this.state.filterStatus;
      return matchesSearch && matchesStatus;
    });
  }

  getStatusDisplay(status) {
    const statusMap = {
      active: "✓ Đang hiệu lực",
      expired: "✗ Hết hiệu lực",
    };
    return statusMap[status] || status;
  }

  formatDate(dateStr) {
    const date = new Date(dateStr + "T00:00:00");
    return date.toLocaleDateString("vi-VN");
  }

  onMount() {
    const searchInput = this.el.querySelector(".search-input");
    const filterStatus = this.el.querySelector(".filter-status");

    if (searchInput) {
      searchInput.addEventListener("input", (e) => {
        this.state.searchTerm = e.target.value;
        this.render();
      });
    }

    if (filterStatus) {
      filterStatus.addEventListener("change", (e) => {
        this.state.filterStatus = e.target.value;
        this.render();
      });
    }

    console.log("✅ Contract Management component mounted");
  }

  onUnmount() {
    console.log("✅ Contract Management component unmounted");
  }
}
