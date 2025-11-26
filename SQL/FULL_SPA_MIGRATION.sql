-- =============================================================================
-- 🚀 FULL SPA_VU MIGRATION SCRIPT
-- =============================================================================
-- Author: Le Thien Vu
-- Date: 2025-11-26
-- Description: Migrate tất cả source files từ SPA_VU vào database
-- =============================================================================

USE [Paradise_HPSF]; -- ⬅️ THAY ĐỔI TÊN DATABASE NẾU CẦN
GO

SET NOCOUNT ON;
PRINT '========================================';
PRINT '🚀 FULL SPA_VU MIGRATION';
PRINT '========================================';
PRINT 'Thời gian bắt đầu: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '';

-- =============================================================================
-- BƯỚC 1: BACKUP DỮ LIỆU HIỆN TẠI
-- =============================================================================
PRINT '📦 BƯỚC 1: Tạo backup...';

DECLARE @BackupTime VARCHAR(20) = FORMAT(GETDATE(), 'yyyyMMdd_HHmmss');
DECLARE @SQL NVARCHAR(MAX);

-- Backup tblSPA_Components
SET @SQL = N'SELECT * INTO tblSPA_Components_backup_' + @BackupTime + N' FROM tblSPA_Components';
BEGIN TRY
    EXEC sp_executesql @SQL;
    PRINT '   ✅ Backup tblSPA_Components';
END TRY
BEGIN CATCH
    PRINT '   ⚠️ tblSPA_Components: ' + ERROR_MESSAGE();
END CATCH

-- Backup tblSPA_Templates
SET @SQL = N'SELECT * INTO tblSPA_Templates_backup_' + @BackupTime + N' FROM tblSPA_Templates';
BEGIN TRY
    EXEC sp_executesql @SQL;
    PRINT '   ✅ Backup tblSPA_Templates';
END TRY
BEGIN CATCH
    PRINT '   ⚠️ tblSPA_Templates: ' + ERROR_MESSAGE();
END CATCH

PRINT '';

-- =============================================================================
-- BƯỚC 2: BẮT ĐẦU TRANSACTION
-- =============================================================================
PRINT '🔄 BƯỚC 2: Bắt đầu transaction...';

BEGIN TRANSACTION FullMigration;

BEGIN TRY

    -- =============================================================================
    -- BƯỚC 3: XÓA DỮ LIỆU CŨ
    -- =============================================================================
    PRINT '🗑️ BƯỚC 3: Xóa dữ liệu cũ...';
    
    DELETE FROM tblSPA_Templates;
    PRINT '   → Đã xóa ' + CAST(@@ROWCOUNT AS VARCHAR) + ' templates';
    
    DELETE FROM tblSPA_Components;
    PRINT '   → Đã xóa ' + CAST(@@ROWCOUNT AS VARCHAR) + ' components';
    PRINT '';

    -- =============================================================================
    -- BƯỚC 4: ĐĂNG KÝ COMPONENTS
    -- =============================================================================
    PRINT '📋 BƯỚC 4: Đăng ký components...';

    -- 4.1 SPA Framework Core (layout chung)
    INSERT INTO tblSPA_Components (ComponentID, ComponentName, ComponentType, RoutePattern, PreloadJS, RequireAuth, Priority)
    VALUES ('spa-framework', N'SPA Framework Core', 'layout', '*', 1, 0, 1);
    PRINT '   ✅ spa-framework';

    -- 4.2 Dashboard / Home
    INSERT INTO tblSPA_Components (ComponentID, ComponentName, ComponentType, RoutePattern, MenuID, PreloadJS, RequireAuth, Priority)
    VALUES ('dashboard', N'Dashboard', 'page', '/', 'MnuHRS2000', 1, 1, 10);
    PRINT '   ✅ dashboard';

    -- 4.3 Employees
    INSERT INTO tblSPA_Components (ComponentID, ComponentName, ComponentType, RoutePattern, MenuID, RequireAuth, Priority)
    VALUES ('employees', N'Employees', 'page', '/employees', 'MnuHRS100', 1, 20);
    PRINT '   ✅ employees';

    -- 4.4 Employee Detail (nested route)
    INSERT INTO tblSPA_Components (ComponentID, ComponentName, ComponentType, RoutePattern, ParentComponentID, RequireAuth, Priority)
    VALUES ('employee-detail', N'Employee Detail', 'page', '/employees/:id', 'employees', 1, 21);
    PRINT '   ✅ employee-detail';

    -- 4.5 Requests
    INSERT INTO tblSPA_Components (ComponentID, ComponentName, ComponentType, RoutePattern, MenuID, RequireAuth, Priority)
    VALUES ('requests', N'Create Request', 'page', '/requests', 'MnuWPT100', 1, 30);
    PRINT '   ✅ requests';

    -- 4.6 Attendance
    INSERT INTO tblSPA_Components (ComponentID, ComponentName, ComponentType, RoutePattern, MenuID, RequireAuth, Priority)
    VALUES ('attendance', N'Attendance', 'page', '/attendance', 'MnuWPT206', 1, 40);
    PRINT '   ✅ attendance';

    -- 4.7 Payroll
    INSERT INTO tblSPA_Components (ComponentID, ComponentName, ComponentType, RoutePattern, MenuID, RequireAuth, Priority)
    VALUES ('payroll', N'Payroll', 'page', '/payroll', 'MnuHRS200', 1, 50);
    PRINT '   ✅ payroll';

    -- 4.8 About
    INSERT INTO tblSPA_Components (ComponentID, ComponentName, ComponentType, RoutePattern, RequireAuth, Priority)
    VALUES ('about', N'About', 'page', '/about', 0, 60);
    PRINT '   ✅ about';

    -- 4.9 404 Not Found
    INSERT INTO tblSPA_Components (ComponentID, ComponentName, ComponentType, RoutePattern, RequireAuth, Priority)
    VALUES ('not-found', N'Page Not Found', 'page', '*', 0, 999);
    PRINT '   ✅ not-found';

    -- 4.10 UI Components (shared widgets)
    INSERT INTO tblSPA_Components (ComponentID, ComponentName, ComponentType, PreloadJS, RequireAuth, Priority)
    VALUES ('ui-modal', N'Modal Component', 'widget', 1, 0, 1000);
    PRINT '   ✅ ui-modal';

    INSERT INTO tblSPA_Components (ComponentID, ComponentName, ComponentType, PreloadJS, RequireAuth, Priority)
    VALUES ('ui-toast', N'Toast Component', 'widget', 1, 0, 1001);
    PRINT '   ✅ ui-toast';

    INSERT INTO tblSPA_Components (ComponentID, ComponentName, ComponentType, PreloadJS, RequireAuth, Priority)
    VALUES ('ui-loading', N'Loading Component', 'widget', 1, 0, 1002);
    PRINT '   ✅ ui-loading';

    INSERT INTO tblSPA_Components (ComponentID, ComponentName, ComponentType, PreloadJS, RequireAuth, Priority)
    VALUES ('ui-alert', N'Alert Component', 'widget', 1, 0, 1003);
    PRINT '   ✅ ui-alert';

    PRINT '';

    -- =============================================================================
    -- BƯỚC 5: INSERT TEMPLATES - SPA FRAMEWORK CORE
    -- =============================================================================
    PRINT '📄 BƯỚC 5: Insert SPA Framework templates...';

    -- 5.1 Framework HTML (index.html layout)
    INSERT INTO tblSPA_Templates (ComponentID, TemplateType, TemplateContent, Version, Description)
    VALUES ('spa-framework', 'html', N'
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1" />
    <title>{{PAGE_TITLE}} - Paradise HR</title>
    <style>{{FRAMEWORK_CSS}}</style>
    <style>{{COMPONENT_CSS}}</style>
</head>
<body>
    <div class="app-container" id="appContainer">
        <!-- Top Navigation -->
        <nav class="navbar">
            <div class="navbar-search">
                <input type="text" class="form-control" placeholder="Tìm kiếm...">
                <svg class="search-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <circle cx="11" cy="11" r="8"></circle>
                    <path d="m21 21-4.35-4.35"></path>
                </svg>
            </div>
            <div class="navbar-right">
                <a class="nav-link" href="#" data-icon="notification"></a>
                <a class="nav-link" href="#" data-icon="mailNotification"></a>
                <div class="navbar-user">
                    <div class="user-avatar">{{USER_AVATAR}}</div>
                    <span class="user-name">{{USER_NAME}}</span>
                </div>
            </div>
        </nav>

        <!-- Sidebar -->
        <aside class="sidebar d-flex flex-column" id="sidebar">
            <div class="sidebar-header">
                <button class="sidebar-toggle-btn" onclick="toggleSidebarCollapse()">
                    <svg width="31" height="31" fill="none">
                        <path stroke="#757780" stroke-width="2" d="M20.5225 3.863h-10.382c-3.6003 0-6.519 2.9187-6.519 6.5189v10.382c0 3.6003 2.9187 6.5189 6.519 6.5189h10.382c3.6002 0 6.5189-2.9186 6.5189-6.5189v-10.382c0-3.6002-2.9187-6.5189-6.5189-6.5189Z" />
                        <path stroke="#757780" stroke-linecap="round" stroke-width="2" d="M11.1063 4.1045v22.9369" />
                    </svg>
                </button>
                <div class="sidebar-brand">
                    {{BRAND_LOGO}}
                </div>
            </div>

            <ul class="sidebar-nav" id="sidebarNav">
                {{NAVIGATION_ITEMS}}
            </ul>

            <div class="sidebar-bottom">
                <a href="#" class="text-muted" data-tooltip="Thiết lập">
                    <i class="bi bi-gear"></i>
                    <span>Thiết lập</span>
                </a>
                <a href="#" class="text-danger" data-tooltip="Đăng xuất">
                    <i class="bi bi-box-arrow-right"></i>
                    <span>Đăng xuất</span>
                </a>
            </div>
        </aside>

        <!-- Main Content -->
        <main class="main-content" id="app">
            {{PAGE_CONTENT}}
        </main>

        <!-- Mobile Bottom Navigation -->
        <nav class="bottom-nav d-flex d-lg-none">
            <div class="bottom-nav-left">
                <a href="#" class="bottom-nav-item" data-link>
                    <i class="bi bi-search"></i>
                    <span>Search</span>
                </a>
                <a href="#" class="bottom-nav-item" data-link>
                    <i class="bi bi-qr-code-scan"></i>
                    <span>Scan</span>
                </a>
                <a href="/attendance" class="bottom-nav-item" data-link>
                    <i class="bi bi-calendar-check"></i>
                    <span>Check-in</span>
                </a>
            </div>
            <div class="bottom-nav-right">
                <a href="/requests" class="bottom-nav-item fab" data-link>
                    <i class="bi bi-pencil-square"></i>
                </a>
            </div>
        </nav>
    </div>

    <div id="modal-root"></div>
    <div id="toast-container"></div>

    <script>{{FRAMEWORK_JS}}</script>
    <script>{{COMPONENT_JS}}</script>
</body>
</html>
', '1.0.0', 'Main HTML layout framework');
    PRINT '   ✅ spa-framework HTML';

    -- 5.2 Framework Core JS (app.js + main.js combined)
    INSERT INTO tblSPA_Templates (ComponentID, TemplateType, TemplateContent, Version, Description)
    VALUES ('spa-framework', 'js', N'
// =============================================================================
// PARADISE HR - SPA FRAMEWORK CORE
// Version: 1.0.0
// =============================================================================

// Global SPA State
window.SPA = {
    navigation: {{NAVIGATION_DATA}},
    config: {{CONFIG_DATA}},
    translations: {{TRANSLATIONS}},
    user: {{USER_DATA}},
    cache: new Map(),
    currentComponent: null
};

// =============================================================================
// Component Base Class
// =============================================================================
class Component {
    constructor(props = {}) {
        this.props = props;
        this.el = document.createElement("div");
        this.state = {};
    }
    
    render() { return ""; }
    onMount() {}
    onUnmount() {}
    
    setHTML(html) {
        this.el.innerHTML = html;
        return this.el;
    }
    
    setState(newState) {
        this.state = { ...this.state, ...newState };
        this.update();
    }
    
    update() {
        if (this.el) {
            const html = this.render();
            this.el.innerHTML = typeof html === "string" ? html : "";
        }
    }
}

// =============================================================================
// Router
// =============================================================================
function pathToRegex(path) {
    if (path === "*" || path === "/*") return new RegExp(".*");
    const escaped = path
        .replace(/[.+?^${}()|[\]\\]/g, "\\$&")
        .replace(/\\\*/g, ".*")
        .replace(/:(\w+)/g, "([^\\/]+)");
    return new RegExp("^" + escaped + "$");
}

function getParams(match, route) {
    const values = match.slice(1);
    const keys = Array.from(route.path.matchAll(/:(\w+)/g)).map(m => m[1]);
    const params = {};
    keys.forEach((k, i) => params[k] = values[i]);
    return params;
}

class Router {
    constructor(routes = []) {
        this.routes = routes;
        this.currentComponent = null;
        this.outlet = document.getElementById("app");
        this.mode = "pushState" in history ? "history" : "hash";
    }
    
    start() {
        document.body.addEventListener("click", this.handleLinkClick.bind(this));
        window.addEventListener("popstate", this.onPopState.bind(this));
        window.addEventListener("hashchange", this.onPopState.bind(this));
        this.navigate(this.getCurrentPath(), { replace: true });
    }
    
    stop() {
        document.body.removeEventListener("click", this.handleLinkClick.bind(this));
        window.removeEventListener("popstate", this.onPopState.bind(this));
    }
    
    getCurrentPath() {
        return this.mode === "history" 
            ? (location.pathname || "/")
            : (location.hash.replace("#", "") || "/");
    }
    
    handleLinkClick(e) {
        const a = e.target.closest("a[data-link]");
        if (!a) return;
        const href = a.getAttribute("href");
        if (!href) return;
        e.preventDefault();
        this.navigate(href);
    }
    
    onPopState() {
        this.navigate(this.getCurrentPath(), { replace: true, fromPop: true });
    }
    
    matchRoute(path) {
        for (const route of this.routes) {
            const regex = pathToRegex(route.path);
            const match = path.match(regex);
            if (match) {
                return { route, params: getParams(match, route) };
            }
        }
        return null;
    }
    
    async navigate(path, opts = {}) {
        const result = this.matchRoute(path);
        if (!result) {
            const notFound = this.routes.find(r => r.path === "*");
            if (notFound) return this.loadRoute(notFound, {}, opts);
            console.warn("No route matched", path);
            return;
        }
        return this.loadRoute(result.route, result.params, opts);
    }
    
    async loadRoute(route, params = {}, opts = {}) {
        // Unmount previous
        if (this.currentComponent?.onUnmount) {
            try { this.currentComponent.onUnmount(); } catch (e) { console.error(e); }
        }
        
        // Update history
        if (!opts.fromPop) {
            const url = route.pathWithParams || route.path;
            if (this.mode === "history") {
                opts.replace ? history.replaceState({}, "", url) : history.pushState({}, "", url);
            } else {
                opts.replace ? location.replace("#" + url) : location.hash = url;
            }
        }
        
        // Show loading
        this.outlet.innerHTML = ''<div class="loading-container"><div class="spinner-border"></div><p>Đang tải...</p></div>'';
        
        try {
            // Load component from server or cache
            const component = await this.loadComponent(route.componentId, params);
            if (!component) throw new Error("Component not found");
            
            this.currentComponent = component;
            
            const html = await component.render();
            this.outlet.innerHTML = "";
            this.outlet.appendChild(component.setHTML(typeof html === "string" ? html : ""));
            
            if (component.onMount) component.onMount();
            if (route.title) document.title = route.title + " - Paradise HR";
            
            this.updateActiveNavLink(route);
        } catch (error) {
            console.error("Error loading component:", error);
            this.outlet.innerHTML = ''<div class="error-container"><h3>Lỗi tải trang</h3><p>'' + error.message + ''</p></div>'';
        }
    }
    
    async loadComponent(componentId, params) {
        const cacheKey = componentId + JSON.stringify(params);
        
        // Check cache
        if (SPA.cache.has(cacheKey)) {
            return SPA.cache.get(cacheKey);
        }
        
        // Check preloaded
        if (SPA.preloadedComponents && SPA.preloadedComponents[componentId]) {
            const ComponentClass = SPA.preloadedComponents[componentId];
            return new ComponentClass({ params });
        }
        
        // Load from server
        try {
            const response = await fetch("/api/spa/component", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    componentId: componentId,
                    params: params,
                    loginId: SPA.user?.loginId || 0,
                    languageId: SPA.config?.languageId || "VN"
                })
            });
            
            const data = await response.json();
            if (data.error) throw new Error(data.error);
            
            // Inject CSS
            if (data.css) {
                let style = document.getElementById("style-" + componentId);
                if (!style) {
                    style = document.createElement("style");
                    style.id = "style-" + componentId;
                    document.head.appendChild(style);
                }
                style.textContent = data.css;
            }
            
            // Create component from JS
            let ComponentClass = Component;
            if (data.js) {
                eval(data.js);
                if (window.ComponentClass) ComponentClass = window.ComponentClass;
            }
            
            const instance = new ComponentClass({ params, data: data.data });
            SPA.cache.set(cacheKey, instance);
            
            return instance;
        } catch (error) {
            console.error("Failed to load component:", error);
            return null;
        }
    }
    
    updateActiveNavLink(route) {
        document.querySelectorAll(".sidebar-nav .nav-link").forEach(link => {
            link.classList.remove("active");
            if (link.getAttribute("href") === route.path) {
                link.classList.add("active");
            }
        });
    }
}

// =============================================================================
// Sidebar Functions
// =============================================================================
function toggleSidebarCollapse() {
    const container = document.getElementById("appContainer");
    const sidebar = document.getElementById("sidebar");
    container?.classList.toggle("sidebar-collapsed");
    sidebar?.classList.toggle("collapsed");
}

function toggleSidebar() {
    const sidebar = document.getElementById("sidebar");
    sidebar?.classList.toggle("show");
}

// Close sidebar on outside click (mobile)
document.addEventListener("click", function(e) {
    const sidebar = document.getElementById("sidebar");
    const toggleBtn = document.querySelector(".navbar-toggler");
    
    if (window.innerWidth <= 768 &&
        sidebar && !sidebar.contains(e.target) &&
        toggleBtn && !toggleBtn.contains(e.target) &&
        sidebar.classList.contains("show")) {
        sidebar.classList.remove("show");
    }
});

// =============================================================================
// Initialize Routes & Start App
// =============================================================================
const routes = (SPA.navigation || []).map(item => ({
    path: item.path,
    componentId: item.id,
    title: item.title
}));

const router = new Router(routes);

document.addEventListener("DOMContentLoaded", () => {
    // Init UI Components
    if (window.UIComponents) window.uiComponents = new UIComponents();
    
    // Start Router
    router.start();
});

// Translation helper
function t(key) { return SPA.translations?.[key] || key; }

// Export for global access
window.Component = Component;
window.Router = Router;
window.router = router;
', '1.0.0', 'Core JavaScript framework with Router');
    PRINT '   ✅ spa-framework JS';

    PRINT '';

    -- =============================================================================
    -- BƯỚC 6: INSERT COMPONENT TEMPLATES
    -- =============================================================================
    PRINT '🧩 BƯỚC 6: Insert component templates...';

    -- 6.1 Dashboard Component
    INSERT INTO tblSPA_Templates (ComponentID, TemplateType, TemplateContent, Version, Description)
    VALUES ('dashboard', 'html', N'
<div class="dashboard-container">
    <!-- Mobile Dashboard -->
    <div class="mobile-dashboard d-block d-lg-none">
        <div class="user-header">
            <div class="user-info">
                <div class="user-avatar">{{USER_INITIALS}}</div>
                <div class="user-details">
                    <h3>{{USER_NAME}}</h3>
                    <p>{{USER_POSITION}}</p>
                </div>
            </div>
            <div class="date-badge">
                <span class="badge bg-warning text-dark px-3 py-2 rounded-pill">{{CURRENT_MONTH}}</span>
            </div>
        </div>

        <div class="time-card">
            <p class="mb-2 opacity-90">{{CURRENT_DATE}}</p>
            <div class="time-info">
                <div>
                    <small class="opacity-90">Giờ công tích lũy:</small>
                    <div class="time-display">{{WORK_HOURS}}</div>
                </div>
                <div class="text-end">
                    <small class="opacity-90">Tổng lương ước tính:</small>
                    <div class="d-flex align-items-center">
                        <span class="me-2">**********</span>
                        <i class="bi bi-eye"></i>
                    </div>
                </div>
            </div>
            <div class="progress" style="height: 4px;">
                <div class="progress-bar bg-warning" style="width: {{WORK_PROGRESS}}%"></div>
            </div>
            <small class="opacity-90">Còn lại {{REMAINING_DAYS}} ngày công</small>
        </div>

        <div class="apps-grid">
            <a href="#" class="app-item">
                <div class="app-icon blue"><i class="bi bi-list-ul"></i></div>
                <span class="app-name">Hồ sơ</span>
            </a>
            <a href="/requests" class="app-item" data-link>
                <div class="app-icon purple"><i class="bi bi-pencil"></i></div>
                <span class="app-name">Đơn yêu cầu</span>
            </a>
            <a href="/attendance" class="app-item" data-link>
                <div class="app-icon orange"><i class="bi bi-clock"></i></div>
                <span class="app-name">Giờ chấm công</span>
            </a>
            <a href="#" class="app-item">
                <div class="app-icon orange"><i class="bi bi-calendar"></i></div>
                <span class="app-name">Bảng công</span>
            </a>
            <a href="/payroll" class="app-item" data-link>
                <div class="app-icon purple"><i class="bi bi-currency-dollar"></i></div>
                <span class="app-name">Bảng lương</span>
            </a>
            <a href="#" class="app-item">
                <div class="app-icon cyan"><i class="bi bi-shield-check"></i></div>
                <span class="app-name">Thông báo</span>
            </a>
        </div>
    </div>

    <!-- Desktop Dashboard -->
    <div class="desktop-content d-none d-lg-block">
        <h1>Dashboard</h1>
        <p>Welcome to Paradise HR Dashboard</p>
        
        <div class="row g-4 mt-3">
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="stat-icon blue"><i class="bi bi-people"></i></div>
                    <div class="stat-info">
                        <h3>{{TOTAL_EMPLOYEES}}</h3>
                        <p>Nhân viên</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="stat-icon green"><i class="bi bi-check-circle"></i></div>
                    <div class="stat-info">
                        <h3>{{PRESENT_TODAY}}</h3>
                        <p>Có mặt hôm nay</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="stat-icon orange"><i class="bi bi-clock-history"></i></div>
                    <div class="stat-info">
                        <h3>{{PENDING_REQUESTS}}</h3>
                        <p>Đơn chờ duyệt</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="stat-icon purple"><i class="bi bi-calendar-event"></i></div>
                    <div class="stat-info">
                        <h3>{{ON_LEAVE}}</h3>
                        <p>Đang nghỉ phép</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
', '1.0.0', 'Dashboard page template');
    PRINT '   ✅ dashboard HTML';

    INSERT INTO tblSPA_Templates (ComponentID, TemplateType, TemplateContent, Version, Description)
    VALUES ('dashboard', 'js', N'
class DashboardComponent extends Component {
    constructor(props) {
        super(props);
        this.state = {
            stats: props.data?.stats || {},
            user: SPA.user || {}
        };
    }
    
    render() {
        return `{{DASHBOARD_HTML}}`;
    }
    
    onMount() {
        console.log("Dashboard mounted");
        this.loadStats();
    }
    
    async loadStats() {
        try {
            const response = await fetch("/api/dashboard/stats");
            const stats = await response.json();
            this.setState({ stats });
        } catch (error) {
            console.error("Error loading stats:", error);
        }
    }
}

window.ComponentClass = DashboardComponent;
', '1.0.0', 'Dashboard JavaScript');
    PRINT '   ✅ dashboard JS';

    -- 6.2 Employees Component
    INSERT INTO tblSPA_Templates (ComponentID, TemplateType, TemplateContent, Version, Description)
    VALUES ('employees', 'html', N'
<div class="employees-container">
    <div class="page-header">
        <h1>Quản lý nhân viên</h1>
        <button class="btn btn-primary" onclick="UI.modal.show({title: ''Thêm nhân viên'', content: ''Form here...''})">
            <i class="bi bi-plus-lg"></i> Thêm mới
        </button>
    </div>
    
    <div class="filter-bar">
        <input type="text" class="form-control" placeholder="Tìm kiếm nhân viên..." id="searchEmployee">
        <select class="form-select" id="filterDept">
            <option value="">Tất cả phòng ban</option>
            {{DEPARTMENT_OPTIONS}}
        </select>
    </div>
    
    <div class="employee-list" id="employeeList">
        {{EMPLOYEE_CARDS}}
    </div>
</div>
', '1.0.0', 'Employees list page');
    PRINT '   ✅ employees HTML';

    INSERT INTO tblSPA_Templates (ComponentID, TemplateType, TemplateContent, Version, Description)
    VALUES ('employees', 'js', N'
class EmployeesComponent extends Component {
    constructor(props) {
        super(props);
        this.state = {
            employees: [],
            loading: true,
            filter: { search: "", dept: "" }
        };
    }
    
    render() {
        if (this.state.loading) {
            return ''<div class="loading-container"><div class="spinner-border"></div></div>'';
        }
        return `{{EMPLOYEES_HTML}}`;
    }
    
    onMount() {
        this.loadEmployees();
        this.setupSearch();
    }
    
    async loadEmployees() {
        try {
            const response = await fetch("/api/employees");
            const employees = await response.json();
            this.setState({ employees, loading: false });
        } catch (error) {
            UI.toast.error("Không thể tải danh sách nhân viên");
            this.setState({ loading: false });
        }
    }
    
    setupSearch() {
        const searchInput = document.getElementById("searchEmployee");
        searchInput?.addEventListener("input", (e) => {
            this.filterEmployees(e.target.value);
        });
    }
    
    filterEmployees(query) {
        // Filter logic here
    }
}

window.ComponentClass = EmployeesComponent;
', '1.0.0', 'Employees JavaScript');
    PRINT '   ✅ employees JS';

    -- 6.3 About Component
    INSERT INTO tblSPA_Templates (ComponentID, TemplateType, TemplateContent, Version, Description)
    VALUES ('about', 'html', N'
<div class="about-container p-4">
    <h2>About Paradise HR</h2>
    <p>Hệ thống quản lý nhân sự hiện đại với các tính năng:</p>
    <ul>
        <li>Client-side routing (history & hash fallback)</li>
        <li>Component lifecycle: render, onMount, onUnmount</li>
        <li>Lazy loading components</li>
        <li>Glassmorphism UI design</li>
        <li>Mobile-first responsive</li>
    </ul>
    <p>Version: 1.0.0</p>
    <p>Built by: Lê Thiên Vũ</p>
</div>
', '1.0.0', 'About page');
    PRINT '   ✅ about HTML';

    -- 6.4 404 Not Found Component
    INSERT INTO tblSPA_Templates (ComponentID, TemplateType, TemplateContent, Version, Description)
    VALUES ('not-found', 'html', N'
<div class="not-found-container">
    <div class="not-found-background">
        <div class="floating-shape shape-1"></div>
        <div class="floating-shape shape-2"></div>
        <div class="floating-shape shape-3"></div>
    </div>

    <div class="not-found-content">
        <div class="not-found-number-wrapper">
            <div class="not-found-number">
                <span class="digit">4</span>
                <span class="digit">0</span>
                <span class="digit">4</span>
            </div>
        </div>

        <h1 class="not-found-title">Không tìm thấy trang</h1>
        <p class="not-found-subtitle">Trang bạn tìm kiếm không tồn tại hoặc đã bị di chuyển.</p>

        <div class="not-found-actions">
            <a href="/" data-link class="btn btn-primary btn-lg">
                <i class="bi bi-arrow-left"></i> Quay lại Dashboard
            </a>
        </div>
    </div>
</div>
', '1.0.0', '404 Not Found page');
    PRINT '   ✅ not-found HTML';

    PRINT '';

    -- =============================================================================
    -- BƯỚC 7: XÁC NHẬN THÀNH CÔNG
    -- =============================================================================
    PRINT '✅ BƯỚC 7: Xác nhận migration...';
    
    SELECT 'Components' AS [Table], COUNT(*) AS [Count] FROM tblSPA_Components
    UNION ALL
    SELECT 'Templates', COUNT(*) FROM tblSPA_Templates;
    
    PRINT '';
    PRINT 'Chi tiết Components:';
    SELECT ComponentID, ComponentName, ComponentType, RoutePattern FROM tblSPA_Components ORDER BY Priority;
    
    PRINT '';
    PRINT 'Chi tiết Templates:';
    SELECT ComponentID, TemplateType, Version, LEN(TemplateContent) AS ContentSize FROM tblSPA_Templates;

    -- =============================================================================
    -- COMMIT TRANSACTION
    -- =============================================================================
    COMMIT TRANSACTION FullMigration;
    
    PRINT '';
    PRINT '========================================';
    PRINT '✅ MIGRATION HOÀN TẤT THÀNH CÔNG!';
    PRINT '========================================';
    PRINT 'Backup tables: tblSPA_*_backup_' + @BackupTime;
    PRINT 'Thời gian hoàn tất: ' + CONVERT(VARCHAR, GETDATE(), 120);

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION FullMigration;
    
    PRINT '';
    PRINT '❌ LỖI MIGRATION!';
    PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    PRINT 'Error Message: ' + ERROR_MESSAGE();
    PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT '';
    PRINT '🔄 Đã ROLLBACK tất cả thay đổi.';
END CATCH

GO

-- =============================================================================
-- 🔄 ROLLBACK SCRIPT (CHẠY NẾU CẦN HOÀN TÁC)
-- =============================================================================
/*
-- Tìm backup tables
SELECT name, create_date FROM sys.tables 
WHERE name LIKE 'tblSPA_%_backup_%' ORDER BY create_date DESC;

-- Rollback (thay YYYYMMDD_HHMMSS bằng timestamp thực)
BEGIN TRAN;
DELETE FROM tblSPA_Templates;
DELETE FROM tblSPA_Components;
INSERT INTO tblSPA_Components SELECT * FROM tblSPA_Components_backup_YYYYMMDD_HHMMSS;
INSERT INTO tblSPA_Templates SELECT * FROM tblSPA_Templates_backup_YYYYMMDD_HHMMSS;
COMMIT;
*/
GO
