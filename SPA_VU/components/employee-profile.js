// Personnel File Management Component - Paradise HR SPA
import { Component } from "../app.js";

export default class EmployeeProfile extends Component {
  constructor(props) {
    super(props);
    this.state = {
      employees: [
        {
          id: 1,
          name: "Nguyễn Văn An",
          email: "nguyen.van.an@paradise.com",
          phone: "0912345678",
          position: "Nhân viên Kế toán",
          department: "Kế toán",
          joinDate: "12/02/2022",
          status: "active",
          avatar: "👨‍💼",
          salary: "8,000,000 VND",
        },
        {
          id: 2,
          name: "Lê Thị Bích",
          email: "le.thi.bich@paradise.com",
          phone: "0987654321",
          position: "Quản trị Hệ thống",
          department: "IT",
          joinDate: "23/08/2021",
          status: "active",
          avatar: "👩‍💻",
          salary: "12,000,000 VND",
        },
        {
          id: 3,
          name: "Phạm Quang Định",
          email: "pham.quang.dinh@paradise.com",
          phone: "0901234567",
          position: "Trưởng Phòng Kinh doanh",
          department: "Kinh doanh",
          joinDate: "05/03/2020",
          status: "active",
          avatar: "👨‍💼",
          salary: "15,000,000 VND",
        },
        {
          id: 4,
          name: "Trần Thị Thu Trang",
          email: "tran.thu.trang@paradise.com",
          phone: "0865432198",
          position: "Chuyên viên HR",
          department: "Nhân sự",
          joinDate: "10/01/2023",
          status: "active",
          avatar: "👩‍💼",
          salary: "9,500,000 VND",
        },
        {
          id: 5,
          name: "Đặng Minh Tuấn",
          email: "dang.minh.tuan@paradise.com",
          phone: "0909876543",
          position: "Developer",
          department: "IT",
          joinDate: "15/06/2022",
          status: "active",
          avatar: "👨‍💻",
          salary: "13,000,000 VND",
        },
      ],
      currentPage: 1,
      pageSize: 6,
      selectedEmployee: null,
      searchQuery: "",
      filterDept: "all",
      showDetailModal: false,
      isEditMode: false,
      editFormData: {},
    };
  }

  getFilteredEmployees() {
    return this.state.employees.filter((emp) => {
      const matchSearch =
        emp.name.toLowerCase().includes(this.state.searchQuery.toLowerCase()) ||
        emp.position
          .toLowerCase()
          .includes(this.state.searchQuery.toLowerCase());
      const matchDept =
        this.state.filterDept === "all" ||
        emp.department === this.state.filterDept;
      return matchSearch && matchDept;
    });
  }

  getPaginatedEmployees(filtered) {
    const startIdx = (this.state.currentPage - 1) * this.state.pageSize;
    return filtered.slice(startIdx, startIdx + this.state.pageSize);
  }

  getTotalPages(filtered) {
    return Math.max(1, Math.ceil(filtered.length / this.state.pageSize));
  }

  renderDetailModal() {
    if (!this.state.showDetailModal || !this.state.selectedEmployee) {
      return "";
    }

    const emp = this.state.selectedEmployee;
    const isEdit = this.state.isEditMode;
    const formData = this.state.editFormData;

    if (isEdit) {
      return `
        <div class="modal-overlay" data-modal="detail">
          <div class="modal-content detail-modal">
            <div class="modal-header">
              <h2 class="modal-title">✏️ Cập nhật thông tin nhân sự</h2>
              <button class="modal-close" data-action="close-modal">✕</button>
            </div>
            
            <form class="edit-form" data-form="employee-edit">
              <div class="form-section">
                <h3 class="section-title">Thông tin cơ bản</h3>
                
                <div class="form-group">
                  <label class="form-label">Họ tên</label>
                  <input type="text" class="form-input" name="name" value="${
                    formData.name || emp.name
                  }" required />
                </div>

                <div class="form-row">
                  <div class="form-group">
                    <label class="form-label">Email</label>
                    <input type="email" class="form-input" name="email" value="${
                      formData.email || emp.email
                    }" required />
                  </div>
                  <div class="form-group">
                    <label class="form-label">Điện thoại</label>
                    <input type="tel" class="form-input" name="phone" value="${
                      formData.phone || emp.phone
                    }" />
                  </div>
                </div>
              </div>

              <div class="form-section">
                <h3 class="section-title">Thông tin công việc</h3>
                
                <div class="form-group">
                  <label class="form-label">Chức vụ</label>
                  <input type="text" class="form-input" name="position" value="${
                    formData.position || emp.position
                  }" required />
                </div>

                <div class="form-row">
                  <div class="form-group">
                    <label class="form-label">Bộ phận</label>
                    <input type="text" class="form-input" name="department" value="${
                      formData.department || emp.department
                    }" required />
                  </div>
                  <div class="form-group">
                    <label class="form-label">Lương</label>
                    <input type="text" class="form-input" name="salary" value="${
                      formData.salary || emp.salary
                    }" />
                  </div>
                </div>

                <div class="form-group">
                  <label class="form-label">Ngày vào làm</label>
                  <input type="date" class="form-input" name="joinDate" value="${this.dateToInput(
                    formData.joinDate || emp.joinDate
                  )}" />
                </div>
              </div>

              <div class="form-actions">
                <button type="button" class="btn btn-secondary" data-action="cancel-edit">Hủy</button>
                <button type="submit" class="btn btn-primary">💾 Lưu thay đổi</button>
              </div>
            </form>
          </div>
        </div>
      `;
    } else {
      return `
        <div class="modal-overlay" data-modal="detail">
          <div class="modal-content detail-modal">
            <div class="modal-header">
              <h2 class="modal-title">👤 Chi tiết hồ sơ nhân sự</h2>
              <button class="modal-close" data-action="close-modal">✕</button>
            </div>
            
            <div class="detail-content">
              <div class="detail-avatar">${emp.avatar}</div>
              
              <div class="detail-section">
                <h3 class="section-title">Thông tin cơ bản</h3>
                <div class="detail-grid">
                  <div class="detail-item">
                    <label class="detail-label">Họ tên:</label>
                    <p class="detail-value">${emp.name}</p>
                  </div>
                  <div class="detail-item">
                    <label class="detail-label">Email:</label>
                    <p class="detail-value"><a href="mailto:${emp.email}">${emp.email}</a></p>
                  </div>
                  <div class="detail-item">
                    <label class="detail-label">Điện thoại:</label>
                    <p class="detail-value"><a href="tel:${emp.phone}">${emp.phone}</a></p>
                  </div>
                </div>
              </div>

              <div class="detail-section">
                <h3 class="section-title">Thông tin công việc</h3>
                <div class="detail-grid">
                  <div class="detail-item">
                    <label class="detail-label">Chức vụ:</label>
                    <p class="detail-value">${emp.position}</p>
                  </div>
                  <div class="detail-item">
                    <label class="detail-label">Bộ phận:</label>
                    <p class="detail-value">${emp.department}</p>
                  </div>
                  <div class="detail-item">
                    <label class="detail-label">Lương:</label>
                    <p class="detail-value salary">${emp.salary}</p>
                  </div>
                  <div class="detail-item">
                    <label class="detail-label">Ngày vào làm:</label>
                    <p class="detail-value">${emp.joinDate}</p>
                  </div>
                  <div class="detail-item">
                    <label class="detail-label">Trạng thái:</label>
                    <p class="detail-value"><span class="status-badge active">● Hoạt động</span></p>
                  </div>
                </div>
              </div>

              <div class="detail-actions">
                <button class="btn btn-primary" data-action="edit-profile">✏️ Chỉnh sửa</button>
                <button class="btn btn-secondary" data-action="download-profile">📥 Tải hồ sơ</button>
                <button class="btn btn-outline" data-action="close-modal">Đóng</button>
              </div>
            </div>
          </div>
        </div>
      `;
    }
  }

  dateToInput(dateStr) {
    // Convert "12/02/2022" to "2022-02-12"
    if (!dateStr) return "";
    const parts = dateStr.split("/");
    if (parts.length === 3) {
      return `${parts[2]}-${parts[1]}-${parts[0]}`;
    }
    return dateStr;
  }

  inputToDate(dateStr) {
    // Convert "2022-02-12" to "12/02/2022"
    if (!dateStr) return "";
    const parts = dateStr.split("-");
    if (parts.length === 3) {
      return `${parts[2]}/${parts[1]}/${parts[0]}`;
    }
    return dateStr;
  }

  renderEmployeeCard(employee) {
    return `
      <div class="employee-card glass-effect" data-employee-id="${employee.id}">
        <div class="employee-avatar">${employee.avatar}</div>
        <div class="employee-info">
          <h3 class="employee-name">${employee.name}</h3>
          <p class="employee-position">${employee.position}</p>
          <p class="employee-dept">${employee.department}</p>
          <div class="employee-meta">
            <span class="meta-label">Vào làm:</span>
            <span class="meta-value">${employee.joinDate}</span>
          </div>
        </div>
        <div class="employee-actions">
          <button class="action-btn view-btn" title="Xem chi tiết">👁️</button>
          <button class="action-btn edit-btn" title="Chỉnh sửa">✏️</button>
          <button class="action-btn download-btn" title="Tải hồ sơ">📥</button>
        </div>
      </div>
    `;
  }

  getDepartments() {
    const depts = new Set(this.state.employees.map((emp) => emp.department));
    return Array.from(depts);
  }

  renderEmployeeGrid() {
    const filtered = this.getFilteredEmployees();
    const depts = this.getDepartments();
    const deptOptions = depts
      .map(
        (dept) =>
          `<option value="${dept}" ${
            this.state.filterDept === dept ? "selected" : ""
          }>${dept}</option>`
      )
      .join("");

    const paginated = this.getPaginatedEmployees(filtered);
    const totalPages = this.getTotalPages(filtered);
    const cardsHTML = paginated
      .map((emp) => this.renderEmployeeCard(emp))
      .join("");

    // Pagination controls
    const paginationHTML =
      totalPages > 1
        ? `<div class="pagination">
          <button class="page-btn" data-page="prev" ${
            this.state.currentPage === 1 ? "disabled" : ""
          }>&laquo;</button>
          ${Array.from({ length: totalPages }, (_, i) => {
            const pageNum = i + 1;
            return `<button class="page-btn${
              this.state.currentPage === pageNum ? " active" : ""
            }" data-page="${pageNum}">${pageNum}</button>`;
          }).join("")}
          <button class="page-btn" data-page="next" ${
            this.state.currentPage === totalPages ? "disabled" : ""
          }>&raquo;</button>
        </div>`
        : "";

    return `
      <div class="profile-container">

        <!-- Filters Section -->
        <div class="filters-section glass-effect">
          <div class="filter-item">
            <label class="filter-label">Tìm kiếm:</label>
            <input
              type="text"
              class="filter-input search-input"
              placeholder="Tìm theo tên hoặc chức vụ..."
              value="${this.state.searchQuery}"
            />
          </div>
          <div class="filter-item">
            <label class="filter-label">Bộ phận:</label>
            <select class="filter-input dept-filter">
              <option value="all">Tất cả bộ phận</option>
              ${deptOptions}
            </select>
          </div>
          <div class="filter-stats">
            <span class="stat-badge">Tổng: ${filtered.length}/${
      this.state.employees.length
    }</span>
          </div>
        </div>

        <!-- Employees Grid -->
        <div class="employees-grid">
          ${cardsHTML}
        </div>

        <!-- Pagination -->
        ${paginationHTML}

        <!-- Empty State -->
        ${
          filtered.length === 0
            ? `
          <div class="empty-state">
            <div class="empty-icon">🔍</div>
            <h3 class="empty-title">Không tìm thấy nhân sự</h3>
            <p class="empty-message">Vui lòng điều chỉnh bộ lọc tìm kiếm</p>
          </div>
        `
            : ""
        }

        <!-- Detail Modal -->
        ${this.renderDetailModal()}
      </div>

      <style>
        .profile-container {
          width: 100%;
          min-height: 100vh;
          padding: var(--space-2);
        }

        .profile-header {
          display: flex;
          justify-content: space-between;
          align-items: flex-start;
          gap: var(--space-4);
          margin-bottom: var(--space-6);
          flex-wrap: wrap;
        }

        .profile-header-content {
          flex: 1;
        }

        .profile-title {
          font-size: 32px;
          font-weight: 700;
          color: var(--text-primary);
          margin: 0;
          line-height: 1.2;
        }

        .profile-subtitle {
          font-size: 14px;
          color: var(--text-secondary);
          margin: var(--space-2) 0 0 0;
        }

        .filters-section {
          display: flex;
          gap: var(--space-4);
          align-items: flex-end;
          padding: var(--space-4);
          background: rgba(255, 255, 255, 0.7);
          backdrop-filter: blur(20px);
          border: 1px solid rgba(255, 255, 255, 0.5);
          border-radius: var(--radius-lg);
          margin-bottom: var(--space-6);
          flex-wrap: wrap;
        }

        .filter-item {
          flex: 1;
          min-width: 200px;
          display: flex;
          flex-direction: column;
          gap: var(--space-2);
        }

        .filter-label {
          font-size: 13px;
          font-weight: 600;
          color: var(--text-secondary);
          text-transform: uppercase;
          letter-spacing: 0.5px;
        }

        .filter-input {
          padding: var(--space-2) var(--space-3);
          border: 1px solid var(--neutral-200);
          border-radius: var(--radius-md);
          font-size: 14px;
          font-family: inherit;
          transition: all var(--duration-fast) var(--ease-out);
          background: rgba(255, 255, 255, 0.9);
        }

        .filter-input:focus {
          outline: none;
          border-color: var(--brand-primary);
          background: white;
          box-shadow: 0 0 0 3px rgba(115, 196, 29, 0.1);
        }

        .search-input {
          min-width: 250px;
        }

        .filter-stats {
          display: flex;
          gap: var(--space-2);
          align-items: center;
        }

        .stat-badge {
          padding: var(--space-2) var(--space-3);
          background: var(--brand-primary-alpha-20);
          color: var(--brand-primary-dark);
          border-radius: var(--radius-md);
          font-size: 12px;
          font-weight: 600;
        }

        .employees-grid {
          display: grid;
          grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
          gap: var(--space-5);
        }

        .employee-card {
          display: flex;
          flex-direction: column;
          padding: var(--space-4);
          background: rgba(255, 255, 255, 0.7);
          backdrop-filter: blur(20px);
          border: 1px solid rgba(255, 255, 255, 0.5);
          border-radius: var(--radius-lg);
          transition: all var(--duration-normal) var(--ease-out);
          cursor: pointer;
        }

        .employee-card:hover {
          transform: translateY(-6px);
          box-shadow: 0 24px 48px rgba(0, 0, 0, 0.12);
          background: rgba(255, 255, 255, 0.9);
          border-color: rgba(115, 196, 29, 0.3);
        }

        .employee-avatar {
          font-size: 56px;
          text-align: center;
          margin-bottom: var(--space-3);
          line-height: 1;
        }

        .employee-info {
          flex: 1;
          margin-bottom: var(--space-3);
        }

        .employee-name {
          font-size: 16px;
          font-weight: 700;
          color: var(--text-primary);
          margin: 0 0 var(--space-1) 0;
          line-height: 1.3;
        }

        .employee-position {
          font-size: 14px;
          font-weight: 600;
          color: var(--brand-primary);
          margin: 0 0 var(--space-1) 0;
        }

        .employee-dept {
          font-size: 13px;
          color: var(--text-secondary);
          margin: 0 0 var(--space-2) 0;
        }

        .employee-meta {
          display: flex;
          gap: var(--space-2);
          font-size: 12px;
        }

        .meta-label {
          color: var(--text-secondary);
          font-weight: 500;
        }

        .meta-value {
          color: var(--text-primary);
          font-weight: 600;
        }

        .employee-actions {
          display: flex;
          gap: var(--space-2);
          justify-content: space-evenly;
          padding-top: var(--space-3);
          border-top: 1px solid rgba(0, 0, 0, 0.05);
        }

        .action-btn {
          flex: 1;
          padding: var(--space-2);
          background: var(--neutral-50);
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
          background: var(--brand-primary-alpha-10);
          border-color: var(--brand-primary);
          color: var(--brand-primary);
          transform: scale(1.05);
        }

        .view-btn:hover {
          background: var(--system-blue-alpha);
          border-color: var(--system-blue);
        }

        .edit-btn:hover {
          background: var(--system-orange-alpha);
          border-color: var(--system-orange);
        }

        .download-btn:hover {
          background: var(--system-green-alpha);
          border-color: var(--system-green);
        }

        /* Modal Styles */
        .modal-overlay {
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
          from {
            opacity: 0;
          }
          to {
            opacity: 1;
          }
        }

        .modal-content {
          background: white;
          border-radius: var(--radius-lg);
          box-shadow: 0 30px 90px rgba(0, 0, 0, 0.2);
          max-height: 90vh;
          overflow-y: auto;
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

        .detail-modal {
          max-width: 700px;
          width: 100%;
        }

        .modal-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          padding: var(--space-5);
          border-bottom: 1px solid var(--neutral-100);
          position: sticky;
          top: 0;
          background: white;
          z-index: 10;
        }

        .modal-title {
          font-size: 20px;
          font-weight: 700;
          color: var(--text-primary);
          margin: 0;
        }

        .modal-close {
          background: none;
          border: none;
          font-size: 24px;
          cursor: pointer;
          color: var(--text-secondary);
          padding: var(--space-1);
          border-radius: var(--radius-md);
          transition: all var(--duration-fast) var(--ease-out);
        }

        .modal-close:hover {
          background: var(--neutral-100);
          color: var(--text-primary);
        }

        .detail-content {
          padding: var(--space-5);
        }

        .detail-avatar {
          font-size: 80px;
          text-align: center;
          margin-bottom: var(--space-5);
          line-height: 1;
        }

        .detail-section {
          margin-bottom: var(--space-5);
        }

        .section-title {
          font-size: 16px;
          font-weight: 700;
          color: var(--text-primary);
          margin: 0 0 var(--space-3) 0;
          padding-bottom: var(--space-2);
          border-bottom: 2px solid var(--neutral-100);
        }

        .detail-grid {
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
          gap: var(--space-4);
        }

        .detail-item {
          display: flex;
          flex-direction: column;
          gap: var(--space-1);
        }

        .detail-label {
          font-size: 12px;
          font-weight: 600;
          color: var(--text-secondary);
          text-transform: uppercase;
          letter-spacing: 0.5px;
        }

        .detail-value {
          font-size: 14px;
          color: var(--text-primary);
          margin: 0;
          font-weight: 500;
        }

        .detail-value a {
          color: var(--brand-primary);
          text-decoration: none;
        }

        .detail-value a:hover {
          text-decoration: underline;
        }

        .detail-value.salary {
          font-size: 16px;
          font-weight: 700;
          color: var(--system-green);
        }

        .status-badge {
          display: inline-block;
          padding: var(--space-2) var(--space-3);
          border-radius: var(--radius-md);
          font-size: 12px;
          font-weight: 600;
          width: fit-content;
        }

        .status-badge.active {
          background: var(--system-green-alpha);
          color: var(--system-green-dark);
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

        /* Edit Form Styles */
        .edit-form {
          display: flex;
          flex-direction: column;
          gap: var(--space-4);
        }

        .form-section {
          display: flex;
          flex-direction: column;
          gap: var(--space-3);
        }

        .form-group {
          display: flex;
          flex-direction: column;
          gap: var(--space-2);
        }

        .form-label {
          font-size: 13px;
          font-weight: 600;
          color: var(--text-secondary);
          text-transform: uppercase;
          letter-spacing: 0.5px;
        }

        .form-input {
          padding: var(--space-3);
          border: 1px solid var(--neutral-200);
          border-radius: var(--radius-md);
          font-size: 14px;
          font-family: inherit;
          transition: all var(--duration-fast) var(--ease-out);
          background: white;
        }

        .form-input:focus {
          outline: none;
          border-color: var(--brand-primary);
          background: white;
          box-shadow: 0 0 0 3px rgba(115, 196, 29, 0.1);
        }

        .form-row {
          display: grid;
          grid-template-columns: repeat(2, 1fr);
          gap: var(--space-3);
        }

        .form-actions {
          display: flex;
          gap: var(--space-3);
          margin-top: var(--space-4);
          padding-top: var(--space-4);
          border-top: 1px solid var(--neutral-100);
        }

        .form-actions .btn {
          flex: 1;
        }

        .btn-outline {
          background: white;
          border: 1px solid var(--neutral-300);
          color: var(--text-primary);
        }

        .btn-outline:hover {
          background: var(--neutral-50);
          border-color: var(--neutral-400);
        }

        .empty-state {
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          gap: var(--space-3);
          padding: var(--space-8);
          background: rgba(255, 255, 255, 0.7);
          backdrop-filter: blur(20px);
          border: 1px solid rgba(255, 255, 255, 0.5);
          border-radius: var(--radius-lg);
          text-align: center;
        }

        .empty-icon {
          font-size: 64px;
          opacity: 0.5;
        }

        .empty-title {
          font-size: 18px;
          font-weight: 600;
          color: var(--text-primary);
          margin: 0;
        }

        .empty-message {
          font-size: 14px;
          color: var(--text-secondary);
          margin: 0;
        }

        .pagination {
          display: flex;
          gap: 8px;
          justify-content: center;
          align-items: center;
          margin: 32px 0 0 0;
        }
        .page-btn {
          min-width: 36px;
          height: 36px;
          border-radius: 8px;
          border: 1px solid var(--neutral-200);
          background: white;
          color: var(--text-primary);
          font-size: 15px;
          font-weight: 600;
          cursor: pointer;
          transition: all 0.2s;
        }
        .page-btn.active {
          background: var(--brand-primary);
          color: white;
          border-color: var(--brand-primary);
          box-shadow: 0 2px 8px rgba(115,196,29,0.08);
        }
        .page-btn:disabled {
          opacity: 0.5;
          cursor: not-allowed;
        }
        .page-btn:not(:disabled):hover {
          background: var(--brand-primary-alpha-10);
          color: var(--brand-primary);
        }
        @media (max-width: 768px) {
          .profile-container {
            padding: var(--space-4);
          }

          .profile-header {
            flex-direction: column;
          }

          .profile-title {
            font-size: 24px;
          }

          .filters-section {
            flex-direction: column;
            gap: var(--space-3);
          }

          .filter-item {
            width: 100%;
            min-width: unset;
          }

          .search-input {
            min-width: unset;
            width: 100%;
          }

          .employees-grid {
            grid-template-columns: 1fr;
          }

          .employee-card {
            flex-direction: row;
            align-items: center;
            gap: var(--space-3);
          }

          .employee-avatar {
            font-size: 48px;
            margin-bottom: 0;
            min-width: 60px;
          }

          .employee-info {
            flex: 1;
            margin-bottom: 0;
          }

          .employee-actions {
            flex-direction: column;
            gap: var(--space-1);
            padding: 0;
            border: none;
          }

          .action-btn {
            padding: var(--space-1) var(--space-2);
            font-size: 14px;
          }
        }
      </style>
    `;
  }

  render() {
    return this.renderEmployeeGrid();
  }

  onMount() {
    console.log("✅ Employee Profile component mounted");

    // Event listeners for filters
    const searchInput = this.el.querySelector(".search-input");
    const deptFilter = this.el.querySelector(".dept-filter");

    if (searchInput) {
      searchInput.addEventListener("input", (e) => {
        this.state.searchQuery = e.target.value;
        this.state.currentPage = 1;
        this.setHTML(this.render());
        this.onMount(); // Re-attach listeners
      });
    }

    if (deptFilter) {
      deptFilter.addEventListener("change", (e) => {
        this.state.filterDept = e.target.value;
        this.state.currentPage = 1;
        this.setHTML(this.render());
        this.onMount(); // Re-attach listeners
      });
    }

    // Pagination listeners
    const pageBtns = this.el.querySelectorAll(".page-btn");
    pageBtns.forEach((btn) => {
      btn.addEventListener("click", (e) => {
        const page = btn.dataset.page;
        const filtered = this.getFilteredEmployees();
        const totalPages = this.getTotalPages(filtered);
        if (page === "prev" && this.state.currentPage > 1) {
          this.state.currentPage--;
        } else if (page === "next" && this.state.currentPage < totalPages) {
          this.state.currentPage++;
        } else if (!isNaN(parseInt(page))) {
          this.state.currentPage = parseInt(page);
        }
        this.setHTML(this.render());
        this.onMount();
      });
    });

    // Action buttons listeners
    const actionBtns = this.el.querySelectorAll(".action-btn");
    actionBtns.forEach((btn) => {
      btn.addEventListener("click", (e) => {
        const card = e.target.closest(".employee-card");
        const empId = parseInt(card.dataset.employeeId);
        const employee = this.state.employees.find((e) => e.id === empId);

        if (e.target.closest(".view-btn")) {
          this.openDetailModal(employee);
        } else if (e.target.closest(".edit-btn")) {
          this.openDetailModal(employee);
          setTimeout(() => this.enterEditMode(), 100);
        } else if (e.target.closest(".download-btn")) {
          console.log("Download:", employee);
          alert(`📥 Tải hồ sơ: ${employee.name}`);
        }
      });
    });

    // Modal actions
    const modalButtons = this.el.querySelectorAll("[data-action]");
    modalButtons.forEach((btn) => {
      btn.addEventListener("click", (e) => {
        e.preventDefault();
        const action = e.target.dataset.action;

        if (action === "close-modal") {
          this.closeModal();
        } else if (action === "edit-profile") {
          this.enterEditMode();
        } else if (action === "download-profile") {
          alert(`📥 Tải hồ sơ: ${this.state.selectedEmployee.name}`);
        } else if (action === "cancel-edit") {
          this.exitEditMode();
        }
      });
    });

    // Form submission
    const editForm = this.el.querySelector(".edit-form");
    if (editForm) {
      editForm.addEventListener("submit", (e) => {
        e.preventDefault();
        this.saveEmployeeChanges();
      });
    }

    // Close modal on overlay click
    const overlay = this.el.querySelector(".modal-overlay");
    if (overlay) {
      overlay.addEventListener("click", (e) => {
        if (e.target === overlay) {
          this.closeModal();
        }
      });
    }
  }

  openDetailModal(employee) {
    this.state.selectedEmployee = employee;
    this.state.showDetailModal = true;
    this.state.isEditMode = false;
    this.state.editFormData = { ...employee };
    this.setHTML(this.render());
    this.onMount();
  }

  closeModal() {
    this.state.showDetailModal = false;
    this.state.selectedEmployee = null;
    this.state.isEditMode = false;
    this.setHTML(this.render());
    this.onMount();
  }

  enterEditMode() {
    this.state.isEditMode = true;
    this.setHTML(this.render());
    this.onMount();
  }

  exitEditMode() {
    this.state.isEditMode = false;
    this.state.editFormData = { ...this.state.selectedEmployee };
    this.setHTML(this.render());
    this.onMount();
  }

  saveEmployeeChanges() {
    const form = this.el.querySelector(".edit-form");
    const formData = new FormData(form);

    // Update form data
    for (let [key, value] of formData.entries()) {
      this.state.editFormData[key] = value;
    }

    // Find and update employee in the list
    const empIndex = this.state.employees.findIndex(
      (e) => e.id === this.state.selectedEmployee.id
    );

    if (empIndex !== -1) {
      // Convert date back to display format
      if (this.state.editFormData.joinDate) {
        this.state.editFormData.joinDate = this.inputToDate(
          this.state.editFormData.joinDate
        );
      }

      this.state.employees[empIndex] = {
        ...this.state.employees[empIndex],
        ...this.state.editFormData,
      };

      this.state.selectedEmployee = this.state.employees[empIndex];
      this.state.isEditMode = false;

      this.setHTML(this.render());
      this.onMount();

      alert(
        `✅ Cập nhật thông tin ${this.state.selectedEmployee.name} thành công!`
      );
    }
  }

  onUnmount() {
    console.log("✅ Employee Profile component unmounted");
  }
}
