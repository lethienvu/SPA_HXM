// Paradise HR SPA Main Application

import { Component, Router } from "./app.js";
import "./components/paradise-icons-inline.js";
import NotFound from "./components/404.js";

// 1. Tạo các component classes
class HomePage extends Component {
  render() {
    return `
      <div class="container-fluid p-4">
        <h1>Dashboard</h1>
        <p>Welcome to Paradise HR Dashboard</p>
      </div>
    `;
  }
}

class EmployeesPage extends Component {
  render() {
    return `
      <div class="container-fluid p-4">
        <h1>Employees</h1>
        <p>Employee management page</p>
      </div>
    `;
  }
}

class RequestsPage extends Component {
  render() {
    return `
      <div class="container-fluid p-4">
        <h1>Create a Request</h1>
        <p>Request creation page</p>
      </div>
    `;
  }
}

class AttendancePage extends Component {
  render() {
    return `
      <div class="container-fluid p-4">
        <h1>Attendance</h1>
        <p>Attendance tracking page</p>
      </div>
    `;
  }
}

class PayrollPage extends Component {
  render() {
    return `
      <div class="container-fluid p-4">
        <h1>Payroll</h1>
        <p>Payroll management page</p>
      </div>
    `;
  }
}

// 2. Định nghĩa routes
const routes = [
  { path: "/", component: HomePage, title: "Dashboard - Paradise HR" },
  {
    path: "/employees",
    component: EmployeesPage,
    title: "Employees - Paradise HR",
  },
  {
    path: "/requests",
    component: RequestsPage,
    title: "Requests - Paradise HR",
  },
  {
    path: "/attendance",
    component: AttendancePage,
    title: "Attendance - Paradise HR",
  },
  { path: "/payroll", component: PayrollPage, title: "Payroll - Paradise HR" },
  { path: "*", component: NotFound, title: "Page Not Found - Paradise HR" },
];

// 3. Khởi tạo router
const router = new Router(routes);

// 4. Khởi động app
document.addEventListener("DOMContentLoaded", async () => {
  // Initialize Paradise Icons Inline first
  if (window.ParadiseIconsInline) {
    console.log("🚀 Initializing Paradise Icons Inline from main.js...");
    window.ParadiseIconsInline.init();
  }

  router.start();
});

// 5. Export để có thể sử dụng ở nơi khác
export { router };
