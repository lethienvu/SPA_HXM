// Payroll Management Component - Paradise HR SPA
class PayrollManagement extends Component {
  constructor(props) {
    super(props);
    this.state = {
      currentMonth: "12/2024",
      payrollRecords: [
        {
          id: 1,
          employee: "Nguyễn Văn A",
          department: "IT",
          salary: 15000000,
          bonus: 2000000,
          deductions: 1500000,
          netPay: 15500000,
          status: "paid",
          date: "15/12/2024",
        },
        {
          id: 2,
          employee: "Trần Thị B",
          department: "HR",
          salary: 10000000,
          bonus: 1000000,
          deductions: 900000,
          netPay: 10100000,
          status: "paid",
          date: "15/12/2024",
        },
        {
          id: 3,
          employee: "Lê Quốc C",
          department: "Sales",
          salary: 12000000,
          bonus: 3000000,
          deductions: 1200000,
          netPay: 13800000,
          status: "pending",
          date: "25/12/2024",
        },
        {
          id: 4,
          employee: "Phạm Hồng D",
          department: "Finance",
          salary: 11000000,
          bonus: 1500000,
          deductions: 1000000,
          netPay: 11500000,
          status: "paid",
          date: "15/12/2024",
        },
      ],
      searchTerm: "",
      filterDepartment: "all",
    };
  }

  render() {
    const filtered = this.getFilteredRecords();

    const recordsHTML = filtered
      .map(
        (record) => `
      <tr class="payroll-row">
        <td class="col-employee">${record.employee}</td>
        <td class="col-dept">${record.department}</td>
        <td class="col-salary">${this.formatCurrency(record.salary)}</td>
        <td class="col-deductions">${this.formatCurrency(
          record.deductions
        )}</td>
        <td class="col-net">${this.formatCurrency(record.netPay)}</td>
        <td class="col-date">${record.date}</td>
        <td class="col-status">
          <span class="status-badge status-${record.status}">
            ${record.status === "paid" ? "✓ Đã trả" : "⏳ Chưa trả"}
          </span>
        </td>
        <td class="col-actions">
          <button class="btn-action" data-id="${record.id}">Chi tiết</button>
        </td>
      </tr>
    `
      )
      .join("");

    const totalSalary = filtered.reduce((sum, r) => sum + r.salary, 0);
    const totalDeductions = filtered.reduce((sum, r) => sum + r.deductions, 0);
    const totalNetPay = filtered.reduce((sum, r) => sum + r.netPay, 0);

    return `
      <div class="payroll-container">
        <div class="payroll-header">
          <h1>💰 Quản lý Lương</h1>
          <button class="btn btn-primary">+ Tính toán lương</button>
        </div>

        <div class="payroll-controls">
          <div class="control-group">
            <label>Tháng</label>
            <select class="select-month">
              <option selected>${this.state.currentMonth}</option>
              <option>11/2024</option>
              <option>10/2024</option>
            </select>
          </div>

          <div class="control-group flex-1">
            <label>Tìm kiếm</label>
            <input
              type="text"
              placeholder="Tên nhân viên..."
              class="search-input"
              value="${this.state.searchTerm}"
            />
          </div>

          <div class="control-group">
            <label>Bộ phận</label>
            <select class="select-department">
              <option value="all">Tất cả</option>
              <option value="IT">IT</option>
              <option value="HR">HR</option>
              <option value="Sales">Sales</option>
              <option value="Finance">Finance</option>
            </select>
          </div>
        </div>

        <div class="payroll-summary">
          <div class="summary-card glass-effect">
            <span class="summary-label">Tổng lương</span>
            <span class="summary-value">${this.formatCurrency(
              totalSalary
            )}</span>
          </div>
          <div class="summary-card glass-effect">
            <span class="summary-label">Tổng khấu trừ</span>
            <span class="summary-value deductions">${this.formatCurrency(
              totalDeductions
            )}</span>
          </div>
          <div class="summary-card glass-effect">
            <span class="summary-label">Tổng lương ròng</span>
            <span class="summary-value net">${this.formatCurrency(
              totalNetPay
            )}</span>
          </div>
        </div>

        <div class="payroll-table-wrapper">
          <table class="payroll-table">
            <thead>
              <tr>
                <th>Nhân viên</th>
                <th>Bộ phận</th>
                <th>Lương cơ bản</th>
                <th>Khấu trừ</th>
                <th>Lương ròng</th>
                <th>Ngày trả</th>
                <th>Trạng thái</th>
                <th>Hành động</th>
              </tr>
            </thead>
            <tbody>
              ${recordsHTML}
            </tbody>
          </table>
        </div>

        <style>
          .payroll-container {
            padding: var(--space-6);
            background: linear-gradient(135deg, var(--brand-primary-alpha-10) 0%, var(--brand-secondary-alpha-10) 100%);
            min-height: 100vh;
          }

          .payroll-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: var(--space-6);
            flex-wrap: wrap;
            gap: var(--space-4);
          }

          .payroll-header h1 {
            font-size: 32px;
            font-weight: 700;
            margin: 0;
            color: var(--text-primary);
          }

          .payroll-controls {
            display: flex;
            gap: var(--space-4);
            margin-bottom: var(--space-6);
            flex-wrap: wrap;
            align-items: flex-end;
          }

          .control-group {
            display: flex;
            flex-direction: column;
            gap: var(--space-2);
            flex: 0 1 auto;
          }

          .control-group.flex-1 {
            flex: 1;
            min-width: 200px;
          }

          .control-group label {
            font-size: 12px;
            font-weight: 600;
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.5px;
          }

          .search-input,
          .select-month,
          .select-department {
            padding: var(--space-2) var(--space-3);
            background: rgba(255, 255, 255, 0.9);
            border: 1px solid var(--neutral-200);
            border-radius: var(--radius-md);
            font-size: 14px;
            color: var(--text-primary);
            transition: all var(--duration-fast) var(--ease-out);
          }

          .search-input:focus,
          .select-month:focus,
          .select-department:focus {
            outline: none;
            border-color: var(--brand-primary);
            background: white;
            box-shadow: 0 0 0 3px rgba(115, 196, 29, 0.1);
          }

          .payroll-summary {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: var(--space-4);
            margin-bottom: var(--space-6);
          }

          .summary-card {
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

          .summary-label {
            font-size: 12px;
            font-weight: 600;
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.5px;
          }

          .summary-value {
            font-size: 24px;
            font-weight: 700;
            color: var(--brand-primary);
          }

          .summary-value.deductions {
            color: var(--semantic-red);
          }

          .summary-value.net {
            color: var(--semantic-green);
          }

          .payroll-table-wrapper {
            background: rgba(255, 255, 255, 0.8);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.5);
            border-radius: var(--radius-lg);
            overflow: hidden;
          }

          .payroll-table {
            width: 100%;
            border-collapse: collapse;
          }

          .payroll-table thead {
            background: rgba(115, 196, 29, 0.1);
          }

          .payroll-table th {
            padding: var(--space-3) var(--space-4);
            text-align: left;
            font-size: 12px;
            font-weight: 700;
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border-bottom: 1px solid var(--neutral-200);
          }

          .payroll-row {
            border-bottom: 1px solid var(--neutral-100);
            transition: background var(--duration-fast) var(--ease-out);
          }

          .payroll-row:hover {
            background: rgba(115, 196, 29, 0.05);
          }

          .payroll-row td {
            padding: var(--space-3) var(--space-4);
            font-size: 13px;
            color: var(--text-primary);
          }

          .col-employee {
            font-weight: 600;
            color: var(--brand-primary);
          }

          .col-salary,
          .col-deductions,
          .col-net {
            font-weight: 600;
            text-align: right;
          }

          .col-status {
            text-align: center;
          }

          .status-badge {
            display: inline-block;
            padding: var(--space-1) var(--space-3);
            border-radius: var(--radius-md);
            font-size: 11px;
            font-weight: 700;
            letter-spacing: 0.5px;
          }

          .status-paid {
            background: rgba(50, 215, 75, 0.1);
            color: var(--semantic-green);
          }

          .status-pending {
            background: rgba(255, 159, 10, 0.1);
            color: var(--semantic-orange);
          }

          .col-actions {
            text-align: center;
          }

          .btn-action {
            padding: var(--space-2) var(--space-3);
            background: var(--brand-primary-alpha-10);
            border: 1px solid var(--brand-primary);
            border-radius: var(--radius-md);
            color: var(--brand-primary);
            font-size: 12px;
            font-weight: 600;
            cursor: pointer;
            transition: all var(--duration-fast) var(--ease-out);
          }

          .btn-action:hover {
            background: var(--brand-primary);
            color: white;
          }

          @media (max-width: 768px) {
            .payroll-container {
              padding: var(--space-4);
            }

            .payroll-controls {
              flex-direction: column;
              gap: var(--space-3);
            }

            .control-group.flex-1 {
              width: 100%;
            }

            .payroll-table {
              font-size: 12px;
            }

            .payroll-table th,
            .payroll-row td {
              padding: var(--space-2) var(--space-2);
            }

            .col-salary,
            .col-deductions,
            .col-net {
              display: none;
            }
          }
        </style>
      </div>
    `;
  }

  getFilteredRecords() {
    return this.state.payrollRecords.filter((record) => {
      const matchesSearch =
        record.employee
          .toLowerCase()
          .includes(this.state.searchTerm.toLowerCase()) ||
        record.department
          .toLowerCase()
          .includes(this.state.searchTerm.toLowerCase());
      const matchesDept =
        this.state.filterDepartment === "all" ||
        record.department === this.state.filterDepartment;
      return matchesSearch && matchesDept;
    });
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("vi-VN", {
      style: "currency",
      currency: "VND",
      minimumFractionDigits: 0,
    }).format(value);
  }

  onMount() {
    const searchInput = this.el.querySelector(".search-input");
    const selectDept = this.el.querySelector(".select-department");

    if (searchInput) {
      searchInput.addEventListener("input", (e) => {
        this.state.searchTerm = e.target.value;
        this.render();
      });
    }

    if (selectDept) {
      selectDept.addEventListener("change", (e) => {
        this.state.filterDepartment = e.target.value;
        this.render();
      });
    }

    console.log("✅ Payroll Management component mounted");
  }

  onUnmount() {
    console.log("✅ Payroll Management component unmounted");
  }
}
