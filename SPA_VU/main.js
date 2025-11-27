// Paradise HR SPA Main Application

import { Component, Router } from "./app.js";
import "./components/paradise-icons-inline.js";
import NotFound from "./components/404.js";
import Home from "./components/home.js";
import EmployeeProfile from "./components/employee-profile.js";
import RequestManagement from "./components/request-management.js";
import CandidatesManagement from "./components/candidates.js";
import RecruitmentManagement from "./components/recruitment.js";
import DepartmentManagement from "./components/department.js";
import PayrollManagement from "./components/payroll.js";
import AttendanceManagement from "./components/attendance.js";
import ContractManagement from "./components/contracts.js";
import PerformanceManagement from "./components/performance.js";
import Settings from "./components/settings.js";
import Notifications from "./components/notifications.js";
import renderTopNav from "./components/top-nav.js";

// 2. Định nghĩa routes
const routes = [
  { path: "/", component: Home, title: "Dashboard - Paradise HR" },
  {
    path: "/employees",
    component: EmployeeProfile,
    title: "Hồ sơ Nhân sự - Paradise HR",
  },
  {
    path: "/requests",
    component: RequestManagement,
    title: "Đơn yêu cầu - Paradise HR",
  },
  {
    path: "/recruitment",
    component: RecruitmentManagement,
    title: "Tuyển dụng - Paradise HR",
  },
  {
    path: "/candidates",
    component: CandidatesManagement,
    title: "Danh sách ứng viên - Paradise HR",
  },
  {
    path: "/departments",
    component: DepartmentManagement,
    title: "Quản lý Bộ phận - Paradise HR",
  },
  {
    path: "/payroll",
    component: PayrollManagement,
    title: "Quản lý Lương - Paradise HR",
  },
  {
    path: "/attendance",
    component: AttendanceManagement,
    title: "Quản lý Chấm công - Paradise HR",
  },
  {
    path: "/contracts",
    component: ContractManagement,
    title: "Quản lý Hợp đồng - Paradise HR",
  },
  {
    path: "/performance",
    component: PerformanceManagement,
    title: "Đánh giá hiệu suất - Paradise HR",
  },
  {
    path: "/settings",
    component: Settings,
    title: "Cài đặt - Paradise HR",
  },
  {
    path: "/notifications",
    component: Notifications,
    title: "Thông báo - Paradise HR",
  },
  { path: "*", component: NotFound, title: "Page Not Found - Paradise HR" },
];

// 3. Khởi tạo router
const router = new Router(routes);

// 4. Khởi động app
// Khởi động app trực tiếp, không dùng DOMContentLoaded
if (window.ParadiseIconsInline) {
  window.ParadiseIconsInline.init();
}
router.start();

// Cập nhật topnav lần đầu
const currentRoute = router.getCurrentRoute
  ? router.getCurrentRoute()
  : routes[0];
if (typeof router.onRouteChange === "function") {
  router.onRouteChange(currentRoute);
}

// 5. Export để có thể sử dụng ở nơi khác
export { router };

// Hook vào router để cập nhật topnav
router.onRouteChange = (route) => {
  const title = route.title?.replace(" - Paradise HR", "") || "Dashboard";
  const breadcrumb = getBreadcrumb(route.path);
  const topnavHTML = renderTopNav({ title, breadcrumb });
  const topnavContainer = document.getElementById("topnav-container");
  if (topnavContainer) topnavContainer.innerHTML = topnavHTML;
};

function getBreadcrumb(path) {
  const map = {
    "/": [
      {
        label: "Trang chủ",
        link: "/",
        icon: ``,
      },
    ],
    "/employees": [
      { label: "Trang chủ", link: "/", icon: "" },
      { label: "Hồ sơ Nhân sự" },
    ],
    "/requests": [
      { label: "Trang chủ", link: "/", icon: "" },
      { label: "Đơn yêu cầu" },
    ],
    "/recruitment": [
      { label: "Trang chủ", link: "/", icon: "" },
      { label: "Tuyển dụng" },
    ],
    "/candidates": [
      { label: "Trang chủ", link: "/", icon: "" },
      { label: "Danh sách ứng viên" },
    ],
    "/departments": [
      { label: "Trang chủ", link: "/", icon: "" },
      { label: "Quản lý Bộ phận" },
    ],
    "/payroll": [
      { label: "Trang chủ", link: "/", icon: "" },
      { label: "Quản lý Lương" },
    ],
    "/attendance": [
      { label: "Trang chủ", link: "/", icon: "" },
      { label: "Quản lý Chấm công" },
    ],
    "/contracts": [
      { label: "Trang chủ", link: "/", icon: "" },
      { label: "Quản lý Hợp đồng" },
    ],
    "/performance": [
      { label: "Trang chủ", link: "/", icon: "" },
      { label: "Đánh giá hiệu suất" },
    ],
    "/settings": [
      { label: "Trang chủ", link: "/", icon: "" },
      { label: "Cài đặt" },
    ],
    "/notifications": [
      { label: "Trang chủ", link: "/", icon: "" },
      { label: "Thông báo" },
    ],
  };
  return (
    map[path] || [
      { label: "Trang chủ", link: "/", icon: "" },
      { label: "404" },
    ]
  );
}
