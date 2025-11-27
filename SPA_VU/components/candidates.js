// Candidates Management Component - Paradise HR SPA
import { Component } from "../app.js";

export default class CandidatesManagement extends Component {
  constructor(props) {
    super(props);
    this.state = {
      candidates: [
        {
          id: 1,
          name: "Trần Công Đức",
          position: "Senior Developer",
          department: "IT",
          email: "tran.cong.duc@email.com",
          phone: "0912345678",
          avatar: "👨‍💼",
          appliedDate: "25/11/2025",
          status: "interview",
          rating: 5,
          experience: "5+ năm",
          skills: ["JavaScript", "React", "Node.js", "SQL"],
        },
        {
          id: 2,
          name: "Nguyễn Thị Hương",
          position: "Business Analyst",
          department: "Kinh doanh",
          email: "nguyen.thi.huong@email.com",
          phone: "0987654321",
          avatar: "👩‍💼",
          appliedDate: "23/11/2025",
          status: "screening",
          rating: 4,
          experience: "3+ năm",
          skills: ["Analysis", "Strategy", "Market Research"],
        },
        {
          id: 3,
          name: "Phạm Minh Tuấn",
          position: "UI/UX Designer",
          department: "IT",
          email: "pham.minh.tuan@email.com",
          phone: "0901234567",
          avatar: "👨‍🎨",
          appliedDate: "20/11/2025",
          status: "approved",
          rating: 5,
          experience: "4+ năm",
          skills: ["Figma", "UI Design", "Prototyping", "Adobe XD"],
        },
        {
          id: 4,
          name: "Lê Thị Hạnh",
          position: "HR Specialist",
          department: "Nhân sự",
          email: "le.thi.hanh@email.com",
          phone: "0865432198",
          avatar: "👩‍💼",
          appliedDate: "18/11/2025",
          status: "rejected",
          rating: 3,
          experience: "2+ năm",
          skills: ["Recruitment", "Employee Relations", "Payroll"],
        },
        {
          id: 5,
          name: "Đặng Quang Huy",
          position: "Senior Developer",
          department: "IT",
          email: "dang.quang.huy@email.com",
          phone: "0909876543",
          avatar: "👨‍💻",
          appliedDate: "22/11/2025",
          status: "interview",
          rating: 4,
          experience: "6+ năm",
          skills: ["Python", "Django", "PostgreSQL", "Docker"],
        },
        {
          id: 6,
          name: "Võ Hồng Nhân",
          position: "QA Engineer",
          department: "IT",
          email: "vo.hong.nhan@email.com",
          phone: "0898765432",
          avatar: "👨‍💻",
          appliedDate: "21/11/2025",
          status: "screening",
          rating: 4,
          experience: "3+ năm",
          skills: ["Test Automation", "Selenium", "Manual Testing"],
        },
      ],
      searchQuery: "",
      filterStatus: "all",
      filterDept: "all",
      sortBy: "newest",
      selectedCandidate: null,
      showDetailModal: false,
    };
  }

  getStatusInfo(status) {
    const statuses = {
      screening: { label: "Đang xem xét", color: "blue", icon: "👁️" },
      interview: { label: "Phỏng vấn", color: "orange", icon: "🎤" },
      approved: { label: "Đạt yêu cầu", color: "green", icon: "✓" },
      rejected: { label: "Bị từ chối", color: "red", icon: "✕" },
    };
    return statuses[status] || statuses.screening;
  }

  getFilteredCandidates() {
    let filtered = this.state.candidates;

    // Search filter
    if (this.state.searchQuery) {
      filtered = filtered.filter(
        (c) =>
          c.name.toLowerCase().includes(this.state.searchQuery.toLowerCase()) ||
          c.position
            .toLowerCase()
            .includes(this.state.searchQuery.toLowerCase()) ||
          c.email.toLowerCase().includes(this.state.searchQuery.toLowerCase())
      );
    }

    // Status filter
    if (this.state.filterStatus !== "all") {
      filtered = filtered.filter((c) => c.status === this.state.filterStatus);
    }

    // Department filter
    if (this.state.filterDept !== "all") {
      filtered = filtered.filter((c) => c.department === this.state.filterDept);
    }

    // Sort
    if (this.state.sortBy === "newest") {
      filtered.sort((a, b) => b.id - a.id);
    } else if (this.state.sortBy === "rating") {
      filtered.sort((a, b) => b.rating - a.rating);
    }

    return filtered;
  }

  getDepartments() {
    return [...new Set(this.state.candidates.map((c) => c.department))];
  }

  renderStars(rating) {
    let stars = "";
    for (let i = 0; i < 5; i++) {
      stars += i < rating ? "⭐" : "☆";
    }
    return stars;
  }

  renderCandidateRow(candidate) {
    const statusInfo = this.getStatusInfo(candidate.status);

    return `
      <tr class="candidate-row" data-candidate-id="${candidate.id}">
        <td class="candidate-name-cell">
          <div class="candidate-info-row">
            <span class="candidate-avatar">${candidate.avatar}</span>
            <div class="candidate-name-info">
              <p class="candidate-name">${candidate.name}</p>
              <p class="candidate-email">${candidate.email}</p>
            </div>
          </div>
        </td>
        <td class="candidate-position-cell">
          <p class="position-text">${candidate.position}</p>
          <p class="dept-text">${candidate.department}</p>
        </td>
        <td class="candidate-date-cell">${candidate.appliedDate}</td>
        <td class="candidate-status-cell">
          <span class="status-badge status-${statusInfo.color}">
            ${statusInfo.label}
          </span>
        </td>
        <td class="candidate-rating-cell">
          <div class="stars">${this.renderStars(candidate.rating)}</div>
        </td>
        <td class="candidate-actions-cell">
          <button class="action-btn view-btn" data-action="view-detail" title="Xem chi tiết">👁️</button>
          <button class="action-btn contact-btn" data-action="contact" title="Liên hệ">📧</button>
          <button class="action-btn menu-btn" title="Menu">⋮</button>
        </td>
      </tr>
    `;
  }

  renderDetailModal() {
    if (!this.state.showDetailModal || !this.state.selectedCandidate) {
      return "";
    }

    const c = this.state.selectedCandidate;
    const statusInfo = this.getStatusInfo(c.status);

    return `
      <div class="modal-overlay" data-modal="candidate-detail">
        <div class="modal-content candidate-detail-modal">
          <div class="modal-header">
            <h2 class="modal-title">👤 Hồ sơ ứng viên</h2>
            <button class="modal-close" data-action="close-modal">✕</button>
          </div>

          <div class="modal-body">
            <div class="detail-header">
              <div class="detail-avatar">${c.avatar}</div>
              <div class="detail-info">
                <h3 class="detail-name">${c.name}</h3>
                <p class="detail-position">${c.position}</p>
                <p class="detail-email"><a href="mailto:${c.email}">${
      c.email
    }</a></p>
                <p class="detail-phone"><a href="tel:${c.phone}">${
      c.phone
    }</a></p>
              </div>
              <span class="status-badge status-${statusInfo.color} large">
                ${statusInfo.label}
              </span>
            </div>

            <div class="detail-section">
              <h4 class="section-title">Thông tin cơ bản</h4>
              <div class="info-grid">
                <div class="info-item">
                  <label>Vị trí ứng tuyển:</label>
                  <span>${c.position}</span>
                </div>
                <div class="info-item">
                  <label>Bộ phận:</label>
                  <span>${c.department}</span>
                </div>
                <div class="info-item">
                  <label>Kinh nghiệm:</label>
                  <span>${c.experience}</span>
                </div>
                <div class="info-item">
                  <label>Ngày ứng tuyển:</label>
                  <span>${c.appliedDate}</span>
                </div>
                <div class="info-item">
                  <label>Đánh giá:</label>
                  <span class="stars">${this.renderStars(c.rating)}</span>
                </div>
              </div>
            </div>

            <div class="detail-section">
              <h4 class="section-title">Kỹ năng</h4>
              <div class="skills-list">
                ${c.skills
                  .map((skill) => `<span class="skill-tag">${skill}</span>`)
                  .join("")}
              </div>
            </div>

            <div class="detail-actions">
              <button class="btn btn-primary" data-action="approve-candidate">✓ Phê duyệt</button>
              <button class="btn btn-danger" data-action="reject-candidate">✕ Từ chối</button>
              <button class="btn btn-secondary" data-action="close-modal">Đóng</button>
            </div>
          </div>
        </div>
      </div>
    `;
  }

  render() {
    const filtered = this.getFilteredCandidates();
    const depts = this.getDepartments();
    const deptOptions = depts
      .map(
        (dept) =>
          `<option value="${dept}" ${
            this.state.filterDept === dept ? "selected" : ""
          }>${dept}</option>`
      )
      .join("");

    const rowsHTML = filtered
      .map((candidate) => this.renderCandidateRow(candidate))
      .join("");

    return `
      <div class="candidates-container">
        <!-- Header -->
        <div class="candidates-header">
          <div class="header-content">
            <h1 class="page-title">👥 Danh sách ứng viên tuyển dụng</h1>
            <p class="page-subtitle">Quản lý hồ sơ và tiến độ tuyển dụng</p>
          </div>
          <button class="btn btn-primary">+ Thêm ứng viên</button>
        </div>

        <!-- Filters -->
        <div class="filters-section glass-effect">
          <div class="filter-group">
            <input
              type="text"
              class="filter-input search-input"
              placeholder="Tìm kiếm theo tên, vị trí, email..."
              value="${this.state.searchQuery}"
            />
          </div>
          <div class="filter-group">
            <select class="filter-input status-filter">
              <option value="all">Tất cả trạng thái</option>
              <option value="screening" ${
                this.state.filterStatus === "screening" ? "selected" : ""
              }>Đang xem xét</option>
              <option value="interview" ${
                this.state.filterStatus === "interview" ? "selected" : ""
              }>Phỏng vấn</option>
              <option value="approved" ${
                this.state.filterStatus === "approved" ? "selected" : ""
              }>Đạt yêu cầu</option>
              <option value="rejected" ${
                this.state.filterStatus === "rejected" ? "selected" : ""
              }>Bị từ chối</option>
            </select>
          </div>
          <div class="filter-group">
            <select class="filter-input dept-filter">
              <option value="all">Tất cả bộ phận</option>
              ${deptOptions}
            </select>
          </div>
          <div class="filter-group">
            <select class="filter-input sort-filter">
              <option value="newest" ${
                this.state.sortBy === "newest" ? "selected" : ""
              }>Mới nhất</option>
              <option value="rating" ${
                this.state.sortBy === "rating" ? "selected" : ""
              }>Đánh giá cao</option>
            </select>
          </div>
        </div>

        <!-- Table -->
        <div class="table-section glass-effect">
          <table class="candidates-table">
            <thead>
              <tr>
                <th>Ứng viên</th>
                <th>Vị trí</th>
                <th>Ngày ứng tuyển</th>
                <th>Trạng thái</th>
                <th>Đánh giá</th>
                <th>Hành động</th>
              </tr>
            </thead>
            <tbody>
              ${
                filtered.length > 0
                  ? rowsHTML
                  : `
                <tr>
                  <td colspan="6" style="text-align: center; padding: 40px; color: #888;">
                    <div style="font-size: 48px; margin-bottom: 16px;">🔍</div>
                    <p>Không tìm thấy ứng viên</p>
                  </td>
                </tr>
              `
              }
            </tbody>
          </table>
        </div>

        <!-- Detail Modal -->
        ${this.renderDetailModal()}

        <style>
          .candidates-container {
            width: 100%;
            min-height: 100vh;
            background: linear-gradient(135deg, var(--brand-primary-alpha-10) 0%, var(--brand-secondary-alpha-10) 100%);
            padding: var(--space-6);
          }

          .candidates-header {
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
            margin: 0;
            line-height: 1.2;
          }

          .page-subtitle {
            font-size: 14px;
            color: var(--text-secondary);
            margin: var(--space-2) 0 0 0;
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

          .table-section {
            background: rgba(255, 255, 255, 0.7);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.5);
            border-radius: var(--radius-lg);
            overflow: hidden;
          }

          .candidates-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 14px;
          }

          .candidates-table thead {
            background: var(--neutral-50);
            border-bottom: 1px solid var(--neutral-200);
          }

          .candidates-table th {
            padding: var(--space-3) var(--space-4);
            text-align: left;
            font-weight: 600;
            color: var(--text-secondary);
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
          }

          .candidates-table tbody tr {
            border-bottom: 1px solid var(--neutral-100);
            transition: all var(--duration-fast) var(--ease-out);
          }

          .candidates-table tbody tr:hover {
            background: var(--neutral-50);
          }

          .candidates-table td {
            padding: var(--space-3) var(--space-4);
          }

          .candidate-info-row {
            display: flex;
            align-items: center;
            gap: var(--space-3);
          }

          .candidate-avatar {
            font-size: 40px;
            line-height: 1;
            flex-shrink: 0;
          }

          .candidate-name-info {
            min-width: 0;
          }

          .candidate-name {
            font-weight: 600;
            color: var(--text-primary);
            margin: 0;
            line-height: 1.3;
          }

          .candidate-email {
            font-size: 12px;
            color: var(--text-secondary);
            margin: var(--space-1) 0 0 0;
            word-break: break-all;
          }

          .position-text {
            font-weight: 600;
            color: var(--text-primary);
            margin: 0;
          }

          .dept-text {
            font-size: 12px;
            color: var(--text-secondary);
            margin: var(--space-1) 0 0 0;
          }

          .status-badge {
            display: inline-block;
            padding: var(--space-2) var(--space-3);
            border-radius: var(--radius-md);
            font-size: 12px;
            font-weight: 600;
            width: fit-content;
          }

          .status-badge.status-blue {
            background: rgba(10, 132, 255, 0.12);
            color: #0066cc;
          }

          .status-badge.status-orange {
            background: rgba(255, 159, 10, 0.12);
            color: #ff9f0a;
          }

          .status-badge.status-green {
            background: rgba(50, 215, 75, 0.12);
            color: #00b34c;
          }

          .status-badge.status-red {
            background: rgba(255, 59, 48, 0.12);
            color: #ff3b30;
          }

          .status-badge.large {
            padding: var(--space-3) var(--space-4);
            font-size: 14px;
          }

          .stars {
            font-size: 14px;
            letter-spacing: 2px;
          }

          .candidate-actions-cell {
            display: flex;
            gap: var(--space-2);
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
            background: var(--brand-primary-alpha-10);
            border-color: var(--brand-primary);
          }

          .view-btn:hover {
            background: rgba(10, 132, 255, 0.12);
            border-color: #0a84ff;
          }

          .contact-btn:hover {
            background: rgba(52, 168, 219, 0.12);
            border-color: #34a8db;
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
            from { opacity: 0; }
            to { opacity: 1; }
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

          .candidate-detail-modal {
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

          .modal-body {
            padding: var(--space-5);
          }

          .detail-header {
            display: flex;
            align-items: center;
            gap: var(--space-4);
            margin-bottom: var(--space-5);
            padding-bottom: var(--space-4);
            border-bottom: 1px solid var(--neutral-100);
          }

          .detail-avatar {
            font-size: 80px;
            line-height: 1;
            flex-shrink: 0;
          }

          .detail-info {
            flex: 1;
          }

          .detail-name {
            font-size: 20px;
            font-weight: 700;
            color: var(--text-primary);
            margin: 0 0 var(--space-1) 0;
            line-height: 1.3;
          }

          .detail-position {
            font-size: 14px;
            color: var(--brand-primary);
            margin: 0 0 var(--space-2) 0;
            font-weight: 600;
          }

          .detail-email,
          .detail-phone {
            font-size: 13px;
            color: var(--text-secondary);
            margin: 0;
          }

          .detail-email a,
          .detail-phone a {
            color: var(--brand-primary);
            text-decoration: none;
          }

          .detail-email a:hover,
          .detail-phone a:hover {
            text-decoration: underline;
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

          .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: var(--space-3);
          }

          .info-item {
            display: flex;
            flex-direction: column;
            gap: var(--space-1);
          }

          .info-item label {
            font-size: 12px;
            font-weight: 600;
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.5px;
          }

          .info-item span {
            font-size: 14px;
            color: var(--text-primary);
            font-weight: 500;
          }

          .skills-list {
            display: flex;
            flex-wrap: wrap;
            gap: var(--space-2);
          }

          .skill-tag {
            padding: var(--space-2) var(--space-3);
            background: var(--brand-primary-alpha-10);
            color: var(--brand-primary);
            border-radius: var(--radius-md);
            font-size: 12px;
            font-weight: 600;
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

          .btn-danger {
            background: var(--system-red);
            color: white;
            border: none;
          }

          .btn-danger:hover {
            background: var(--system-red-dark);
          }

          @media (max-width: 768px) {
            .candidates-container {
              padding: var(--space-4);
            }

            .candidates-header {
              flex-direction: column;
            }

            .filters-section {
              flex-direction: column;
              gap: var(--space-2);
            }

            .filter-group {
              min-width: unset;
            }

            .candidates-table {
              font-size: 12px;
            }

            .candidates-table th,
            .candidates-table td {
              padding: var(--space-2) var(--space-2);
            }

            .candidate-avatar {
              font-size: 32px;
            }

            .candidate-actions-cell {
              gap: var(--space-1);
            }

            .action-btn {
              width: 28px;
              height: 28px;
              font-size: 14px;
            }

            .modal-content {
              max-width: unset;
            }

            .detail-header {
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
    console.log("✅ Candidates Management component mounted");

    // Search
    const searchInput = this.el.querySelector(".search-input");
    if (searchInput) {
      searchInput.addEventListener("input", (e) => {
        this.state.searchQuery = e.target.value;
        this.setHTML(this.render());
        this.onMount();
      });
    }

    // Status filter
    const statusFilter = this.el.querySelector(".status-filter");
    if (statusFilter) {
      statusFilter.addEventListener("change", (e) => {
        this.state.filterStatus = e.target.value;
        this.setHTML(this.render());
        this.onMount();
      });
    }

    // Department filter
    const deptFilter = this.el.querySelector(".dept-filter");
    if (deptFilter) {
      deptFilter.addEventListener("change", (e) => {
        this.state.filterDept = e.target.value;
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

    // View detail
    const viewBtns = this.el.querySelectorAll(".view-btn");
    viewBtns.forEach((btn) => {
      btn.addEventListener("click", (e) => {
        e.stopPropagation();
        const row = e.target.closest(".candidate-row");
        const candId = parseInt(row.dataset.candidateId);
        const candidate = this.state.candidates.find((c) => c.id === candId);
        if (candidate) {
          this.state.selectedCandidate = candidate;
          this.state.showDetailModal = true;
          this.setHTML(this.render());
          this.onMount();
        }
      });
    });

    // Contact button
    const contactBtns = this.el.querySelectorAll(".contact-btn");
    contactBtns.forEach((btn) => {
      btn.addEventListener("click", (e) => {
        e.stopPropagation();
        const row = e.target.closest(".candidate-row");
        const candId = parseInt(row.dataset.candidateId);
        const candidate = this.state.candidates.find((c) => c.id === candId);
        if (candidate) {
          alert(`📧 Gửi email cho ${candidate.name}: ${candidate.email}`);
        }
      });
    });

    // Modal close
    const closeBtn = this.el.querySelector(".modal-close");
    if (closeBtn) {
      closeBtn.addEventListener("click", () => {
        this.state.showDetailModal = false;
        this.state.selectedCandidate = null;
        this.setHTML(this.render());
        this.onMount();
      });
    }

    // Modal overlay close
    const overlay = this.el.querySelector(".modal-overlay");
    if (overlay) {
      overlay.addEventListener("click", (e) => {
        if (e.target === overlay) {
          this.state.showDetailModal = false;
          this.state.selectedCandidate = null;
          this.setHTML(this.render());
          this.onMount();
        }
      });
    }

    // Modal action buttons
    const modalBtns = this.el.querySelectorAll("[data-action]");
    modalBtns.forEach((btn) => {
      btn.addEventListener("click", (e) => {
        const action = e.target.dataset.action;
        if (action === "close-modal") {
          this.state.showDetailModal = false;
          this.state.selectedCandidate = null;
          this.setHTML(this.render());
          this.onMount();
        } else if (action === "approve-candidate") {
          if (this.state.selectedCandidate) {
            const idx = this.state.candidates.findIndex(
              (c) => c.id === this.state.selectedCandidate.id
            );
            if (idx !== -1) {
              this.state.candidates[idx].status = "approved";
              this.setHTML(this.render());
              this.onMount();
              alert(`✅ ${this.state.candidates[idx].name} đã được phê duyệt`);
            }
          }
        } else if (action === "reject-candidate") {
          if (this.state.selectedCandidate) {
            const idx = this.state.candidates.findIndex(
              (c) => c.id === this.state.selectedCandidate.id
            );
            if (idx !== -1) {
              this.state.candidates[idx].status = "rejected";
              this.setHTML(this.render());
              this.onMount();
              alert(`✕ ${this.state.candidates[idx].name} đã bị từ chối`);
            }
          }
        }
      });
    });
  }

  onUnmount() {
    console.log("✅ Candidates Management component unmounted");
  }
}
