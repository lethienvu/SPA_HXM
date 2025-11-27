// Attendance Management Component - Paradise HR SPA
import { Component } from "../app.js";

export default class AttendanceManagement extends Component {
  constructor(props) {
    super(props);
    this.state = {
      currentDate: new Date().toISOString().split("T")[0],
      viewMode: "calendar", // calendar or list
      attendanceRecords: [
        {
          id: 1,
          employee: "Nguyễn Văn A",
          date: "2024-12-20",
          checkIn: "08:15",
          checkOut: "17:30",
          status: "present",
          workHours: 9.25,
        },
        {
          id: 2,
          employee: "Trần Thị B",
          date: "2024-12-20",
          checkIn: "08:00",
          checkOut: "17:00",
          status: "present",
          workHours: 9,
        },
        {
          id: 3,
          employee: "Lê Quốc C",
          date: "2024-12-20",
          checkIn: null,
          checkOut: null,
          status: "absent",
          workHours: 0,
        },
        {
          id: 4,
          employee: "Phạm Hồng D",
          date: "2024-12-20",
          checkIn: "08:30",
          checkOut: null,
          status: "late",
          workHours: 0,
        },
        {
          id: 5,
          employee: "Nguyễn Văn A",
          date: "2024-12-19",
          checkIn: "08:10",
          checkOut: "17:45",
          status: "present",
          workHours: 9.58,
        },
      ],
      selectedEmployee: null,
    };
  }

  render() {
    const today = new Date().toISOString().split("T")[0];
    const todayRecords = this.state.attendanceRecords.filter(
      (r) => r.date === today
    );

    const presentCount = todayRecords.filter(
      (r) => r.status === "present"
    ).length;
    const lateCount = todayRecords.filter((r) => r.status === "late").length;
    const absentCount = todayRecords.filter(
      (r) => r.status === "absent"
    ).length;

    const recordsHTML = todayRecords
      .map(
        (record) => `
      <div class="attendance-item glass-effect">
        <div class="attendance-header">
          <div class="employee-info">
            <div class="employee-avatar">${record.employee.charAt(0)}</div>
            <div class="employee-details">
              <p class="employee-name">${record.employee}</p>
              <p class="work-date">${this.formatDate(record.date)}</p>
            </div>
          </div>
          <span class="status-badge status-${record.status}">
            ${this.getStatusDisplay(record.status)}
          </span>
        </div>

        <div class="attendance-times">
          <div class="time-entry">
            <span class="time-label">Vào làm</span>
            <span class="time-value">${record.checkIn || "--:--"}</span>
          </div>
          <div class="time-entry">
            <span class="time-label">Tan làm</span>
            <span class="time-value">${record.checkOut || "--:--"}</span>
          </div>
          <div class="time-entry">
            <span class="time-label">Giờ làm</span>
            <span class="time-value">${
              record.workHours > 0 ? record.workHours.toFixed(2) : "--"
            }</span>
          </div>
        </div>

        <div class="attendance-actions">
          <button class="btn-small">Chi tiết</button>
        </div>
      </div>
    `
      )
      .join("");

    const attendanceListHTML = this.state.attendanceRecords
      .map(
        (record) => `
      <tr class="record-row">
        <td>${record.employee}</td>
        <td>${this.formatDate(record.date)}</td>
        <td>${record.checkIn || "--:--"}</td>
        <td>${record.checkOut || "--:--"}</td>
        <td class="work-hours-cell">${
          record.workHours > 0 ? record.workHours.toFixed(2) : "--"
        }</td>
        <td><span class="status-badge status-${
          record.status
        }">${this.getStatusDisplay(record.status)}</span></td>
      </tr>
    `
      )
      .join("");

    return `
      <div class="attendance-container">
        <div class="attendance-header">
          <h1>📋 Quản lý Chấm công</h1>
          <div class="header-actions">
            <input type="date" class="date-picker" value="${this.state.currentDate}" />
            <button class="btn btn-primary">Xuất báo cáo</button>
          </div>
        </div>

        <div class="attendance-stats">
          <div class="stat-card glass-effect">
            <span class="stat-label">Có mặt</span>
            <span class="stat-value present">${presentCount}</span>
          </div>
          <div class="stat-card glass-effect">
            <span class="stat-label">Đi muộn</span>
            <span class="stat-value late">${lateCount}</span>
          </div>
          <div class="stat-card glass-effect">
            <span class="stat-label">Vắng mặt</span>
            <span class="stat-value absent">${absentCount}</span>
          </div>
          <div class="stat-card glass-effect">
            <span class="stat-label">Tổng nhân viên</span>
            <span class="stat-value">${todayRecords.length}</span>
          </div>
        </div>

        <div class="view-toggle">
          <button class="toggle-btn active" data-view="calendar">📊 Thẻ</button>
          <button class="toggle-btn" data-view="list">📋 Danh sách</button>
        </div>

        <div class="attendance-view calendar-view active">
          <div class="records-grid">
            ${recordsHTML}
          </div>
        </div>

        <div class="attendance-view list-view">
          <table class="attendance-table">
            <thead>
              <tr>
                <th>Nhân viên</th>
                <th>Ngày</th>
                <th>Vào làm</th>
                <th>Tan làm</th>
                <th>Giờ làm</th>
                <th>Trạng thái</th>
              </tr>
            </thead>
            <tbody>
              ${attendanceListHTML}
            </tbody>
          </table>
        </div>

        <style>
          .attendance-container {
            padding: var(--space-6);
            background: linear-gradient(135deg, var(--brand-primary-alpha-10) 0%, var(--brand-secondary-alpha-10) 100%);
            min-height: 100vh;
          }

          .attendance-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: var(--space-6);
            flex-wrap: wrap;
            gap: var(--space-4);
          }

          .attendance-header h1 {
            font-size: 32px;
            font-weight: 700;
            margin: 0;
            color: var(--text-primary);
          }

          .header-actions {
            display: flex;
            gap: var(--space-3);
            align-items: center;
            flex-wrap: wrap;
          }

          .date-picker {
            padding: var(--space-2) var(--space-3);
            background: white;
            border: 1px solid var(--neutral-200);
            border-radius: var(--radius-md);
            font-size: 14px;
            cursor: pointer;
            transition: all var(--duration-fast) var(--ease-out);
          }

          .date-picker:focus {
            outline: none;
            border-color: var(--brand-primary);
            box-shadow: 0 0 0 3px rgba(115, 196, 29, 0.1);
          }

          .attendance-stats {
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

          .stat-value.present {
            color: var(--semantic-green);
          }

          .stat-value.late {
            color: var(--semantic-orange);
          }

          .stat-value.absent {
            color: var(--semantic-red);
          }

          .view-toggle {
            display: flex;
            gap: var(--space-2);
            margin-bottom: var(--space-6);
          }

          .toggle-btn {
            padding: var(--space-2) var(--space-4);
            background: rgba(255, 255, 255, 0.5);
            border: 1px solid var(--neutral-200);
            border-radius: var(--radius-md);
            cursor: pointer;
            font-weight: 600;
            transition: all var(--duration-fast) var(--ease-out);
          }

          .toggle-btn.active {
            background: var(--brand-primary);
            border-color: var(--brand-primary);
            color: white;
          }

          .records-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: var(--space-4);
          }

          .attendance-item {
            padding: var(--space-4);
            background: rgba(255, 255, 255, 0.7);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.5);
            border-radius: var(--radius-lg);
            transition: all var(--duration-normal) var(--ease-out);
          }

          .attendance-item:hover {
            transform: translateY(-4px);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
          }

          .attendance-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: var(--space-3);
          }

          .employee-info {
            display: flex;
            align-items: center;
            gap: var(--space-3);
            flex: 1;
          }

          .employee-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: var(--brand-primary);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 16px;
          }

          .employee-details {
            flex: 1;
          }

          .employee-name {
            font-weight: 700;
            margin: 0;
            color: var(--text-primary);
            font-size: 14px;
          }

          .work-date {
            font-size: 12px;
            color: var(--text-secondary);
            margin: var(--space-1) 0 0 0;
          }

          .status-badge {
            padding: var(--space-1) var(--space-3);
            border-radius: var(--radius-md);
            font-size: 11px;
            font-weight: 700;
            white-space: nowrap;
          }

          .status-present {
            background: rgba(50, 215, 75, 0.1);
            color: var(--semantic-green);
          }

          .status-late {
            background: rgba(255, 159, 10, 0.1);
            color: var(--semantic-orange);
          }

          .status-absent {
            background: rgba(255, 69, 58, 0.1);
            color: var(--semantic-red);
          }

          .attendance-times {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: var(--space-3);
            padding: var(--space-3);
            background: rgba(115, 196, 29, 0.05);
            border-radius: var(--radius-md);
            margin-bottom: var(--space-3);
          }

          .time-entry {
            display: flex;
            flex-direction: column;
            gap: var(--space-1);
            text-align: center;
          }

          .time-label {
            font-size: 11px;
            font-weight: 600;
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.5px;
          }

          .time-value {
            font-size: 14px;
            font-weight: 700;
            color: var(--text-primary);
          }

          .attendance-actions {
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

          .attendance-view {
            display: none;
          }

          .attendance-view.active {
            display: block;
          }

          .attendance-table {
            width: 100%;
            background: rgba(255, 255, 255, 0.8);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.5);
            border-radius: var(--radius-lg);
            border-collapse: collapse;
            overflow: hidden;
          }

          .attendance-table thead {
            background: rgba(115, 196, 29, 0.1);
          }

          .attendance-table th {
            padding: var(--space-3) var(--space-4);
            text-align: left;
            font-size: 12px;
            font-weight: 700;
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border-bottom: 1px solid var(--neutral-200);
          }

          .record-row {
            border-bottom: 1px solid var(--neutral-100);
            transition: background var(--duration-fast) var(--ease-out);
          }

          .record-row:hover {
            background: rgba(115, 196, 29, 0.05);
          }

          .record-row td {
            padding: var(--space-3) var(--space-4);
            font-size: 13px;
            color: var(--text-primary);
          }

          .work-hours-cell {
            font-weight: 600;
            color: var(--brand-primary);
          }

          @media (max-width: 768px) {
            .attendance-container {
              padding: var(--space-4);
            }

            .attendance-header {
              flex-direction: column;
              align-items: flex-start;
            }

            .records-grid {
              grid-template-columns: 1fr;
            }

            .attendance-times {
              grid-template-columns: repeat(2, 1fr);
            }
          }
        </style>
      </div>
    `;
  }

  getStatusDisplay(status) {
    const statusMap = {
      present: "✓ Có mặt",
      late: "⏳ Đi muộn",
      absent: "✗ Vắng mặt",
    };
    return statusMap[status] || status;
  }

  formatDate(dateStr) {
    const date = new Date(dateStr + "T00:00:00");
    return date.toLocaleDateString("vi-VN");
  }

  onMount() {
    const toggleBtns = this.el.querySelectorAll(".toggle-btn");
    const views = this.el.querySelectorAll(".attendance-view");
    const datePicker = this.el.querySelector(".date-picker");

    if (toggleBtns) {
      toggleBtns.forEach((btn) => {
        btn.addEventListener("click", (e) => {
          const viewType = e.target.dataset.view;
          toggleBtns.forEach((b) => b.classList.remove("active"));
          views.forEach((v) => v.classList.remove("active"));
          e.target.classList.add("active");
          this.el.querySelector(`.${viewType}-view`)?.classList.add("active");
        });
      });
    }

    if (datePicker) {
      datePicker.addEventListener("change", (e) => {
        this.state.currentDate = e.target.value;
        // Filter records by selected date
      });
    }

    console.log("✅ Attendance Management component mounted");
  }

  onUnmount() {
    console.log("✅ Attendance Management component unmounted");
  }
}
