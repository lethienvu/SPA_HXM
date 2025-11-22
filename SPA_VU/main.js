// Kiểm tra file này và sửa theo mẫu dưới đây

import { Component, Router } from "./app.js";

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

class OrganizationPage extends Component {
  render() {
    return `
      <div class="container-fluid p-4">
        <h1>Organization Chart</h1>
        <p>Organization structure page</p>
      </div>
    `;
  }
}

class ComponentTestingPage extends Component {
  constructor(props) {
    super(props);
    this.componentTesting = null;
  }

  async render() {
    // Load component testing script if not already loaded
    if (typeof ComponentTesting === "undefined") {
      try {
        await this.loadScript("./components/component-testing.js");
      } catch (error) {
        console.error("Failed to load component testing script:", error);
        return `
          <div class="container-fluid p-4">
            <div class="alert alert-danger">
              <h4>Error Loading Component Testing</h4>
              <p>Failed to load the component testing module. Please refresh the page.</p>
            </div>
          </div>
        `;
      }
    }

    // Create instance
    this.componentTesting = new ComponentTesting();

    // Make it globally available for onclick handlers
    window.componentTesting = this.componentTesting;

    return this.componentTesting.render();
  }

  loadScript(src) {
    return new Promise((resolve, reject) => {
      if (document.querySelector(`script[src="${src}"]`)) {
        resolve();
        return;
      }

      const script = document.createElement("script");
      script.src = src;
      script.onload = resolve;
      script.onerror = reject;
      document.head.appendChild(script);
    });
  }

  onMount() {
    if (this.componentTesting && this.componentTesting.mount) {
      this.componentTesting.mount();
    }
  }

  onUnmount() {
    // Clean up global reference
    if (window.componentTesting === this.componentTesting) {
      window.componentTesting = null;
    }
  }
}

class IconShowcasePage extends Component {
  constructor(props) {
    super(props);
    this.iconShowcase = null;
  }

  async render() {
    // Load icon showcase script if not already loaded
    if (typeof window.IconShowcasePage === "undefined") {
      try {
        await this.loadScript("./components/icon-showcase.js");
      } catch (error) {
        console.error("Failed to load icon showcase script:", error);
        return `
          <div class="container-fluid p-4">
            <div class="alert alert-danger">
              <h4>Error Loading Icon Showcase</h4>
              <p>Failed to load the icon showcase module. Please refresh the page.</p>
            </div>
          </div>
        `;
      }
    }

    // Create instance using the exported class
    this.iconShowcase = new window.IconShowcasePage();
    return await this.iconShowcase.render();
  }

  loadScript(src) {
    return new Promise((resolve, reject) => {
      if (document.querySelector(`script[src="${src}"]`)) {
        resolve();
        return;
      }

      const script = document.createElement("script");
      script.src = src;
      script.onload = resolve;
      script.onerror = reject;
      document.head.appendChild(script);
    });
  }

  async onMount() {
    if (this.iconShowcase && this.iconShowcase.afterRender) {
      await this.iconShowcase.afterRender();
    }
  }

  onUnmount() {
    this.iconShowcase = null;
  }
}

class NotFoundPage extends Component {
  render() {
    return `
      <div class="container-fluid p-4">
        <h1>404 - Page Not Found</h1>
        <p>The page you're looking for doesn't exist.</p>
        <a href="/" data-link class="btn btn-primary">Go Home</a>
      </div>
    `;
  }
}

// 2. Định nghĩa routes - ĐẢM BẢO SỬ DỤNG CLASS TRỰC TIẾP
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
  {
    path: "/organization",
    component: OrganizationPage,
    title: "Organization - Paradise HR",
  },
  {
    path: "/component-testing",
    component: ComponentTestingPage,
    title: "Component Testing - Paradise HR",
  },
  {
    path: "/icon-showcase",
    component: IconShowcasePage,
    title: "Icon Showcase - Paradise HR",
  },
  { path: "*", component: NotFoundPage, title: "Page Not Found - Paradise HR" },
];

// 3. Khởi tạo router
const router = new Router(routes);

// 4. Khởi động app
document.addEventListener("DOMContentLoaded", () => {
  router.start();
});

// 5. Export để có thể sử dụng ở nơi khác
export { router };
