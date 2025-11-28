exec sp_SPA_RegisterComponent 
@ComponentID = 'icons', 
@ComponentName = 'Paradise Icons Inline', 
@RoutePattern = NULL, 
@HTMLTemplate = NULL, 
@CSSTemplate = NULL, 
@JSTemplate = N'
// Paradise HR SPA Main Application

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
];

// 3. Khởi tạo router
const router = new Router(routes);

// 4. Khởi động app
// Đảm bảo ParadiseIconsInline đã load trước khi init
function initializeApp() {
  console.log("🚀 Initializing Paradise HR SPA...");

  // Debug: Kiểm tra các script đã load
  console.log("📦 Available scripts on window:");
  console.log("- ParadiseIconsInline:", !!window.ParadiseIconsInline);
  console.log("- UI:", !!window.UI);
  console.log("- UI.iconInline:", !!(window.UI && window.UI.iconInline));

  // ParadiseIconsInline tự động init trong file của nó, không cần init lại
  if (window.ParadiseIconsInline) {
    console.log("✅ ParadiseIconsInline is available (auto-initialized)");
  } else {
    console.warn("⚠️ ParadiseIconsInline not found");
  }

  // Khởi tạo router
  console.log("🔄 Starting router...");
  router.start();
  console.log("✅ Router started");

  // Cập nhật topnav lần đầu
  const currentRoute = router.getCurrentRoute
    ? router.getCurrentRoute()
    : routes[0];
  if (typeof router.onRouteChange === "function") {
    router.onRouteChange(currentRoute);
  }
}

// Khởi động app sau khi DOM ready
if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", initializeApp);
} else {
  // DOM đã ready, khởi động ngay
  initializeApp();
}

// 5. Make router global if needed
window.router = router;

// Hook vào router để cập nhật topnav
router.onRouteChange = (route) => {
  const title = route.title?.replace(" - Paradise HR", "") || "Dashboard";
  const breadcrumb = getBreadcrumb(route.path);
  const topnavHTML = renderTopNav({ title, breadcrumb });
  const topnavContainer = document.getElementById("topnav-container");
  if (topnavContainer) topnavContainer.innerHTML = topnavHTML;

  // Process lại icons sau khi route thay đổi (vì DOM có thể thay đổi)
  if (window.ParadiseIconsInline) {
    setTimeout(() => {
      window.ParadiseIconsInline.processDataIconElements();
    }, 50);
  }
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
    map[path] || [{ label: "Trang chủ", link: "/", icon: "" }, { label: "404" }]
  );
}

', 
@ComponentType = 'js'