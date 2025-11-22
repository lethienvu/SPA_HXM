-- Insert base HTML template
INSERT INTO tblSPA_Templates (ComponentID, TemplateType, TemplateContent, Description)
VALUES ('ess-dashboard', 'html', N'
<div class="app-container" id="appContainer">
    <!-- Top Navigation -->
    <nav class="navbar navbar-expand-lg">
        <div class="container-fluid d-flex align-items-center">
            <!-- Search Bar -->
            <div class="navbar-search flex-grow-1 me-4">
                <div class="position-relative">
                    <i class="bi bi-search search-icon"></i>
                    <input type="text" class="form-control" placeholder="Tìm kiếm...">
                </div>
            </div>

            <button class="navbar-toggler d-lg-none" type="button" onclick="toggleSidebar()">
                <span class="navbar-toggler-icon"></span>
            </button>

            <!-- Right Icons -->
            <div class="navbar-icons ms-auto">
                <div class="d-flex align-items-center">
                    <a class="nav-link" href="#"><i class="bi bi-bell fs-5"></i></a>
                    <a class="nav-link" href="#"><i class="bi bi-gear fs-5"></i></a>
                    <a class="nav-link" href="#"><i class="bi bi-person-circle fs-5"></i></a>
                </div>
            </div>
        </div>
    </nav>


    <!-- Sidebar -->
    <aside class="sidebar d-flex flex-column" id="sidebar">
        <!-- Sidebar Header with Toggle -->
        <div class="sidebar-header">
            <!-- Toggle Button at top left -->
            <button class="sidebar-toggle-btn" onclick="toggleSidebarCollapse()">
                <svg width="31" height="31" fill="none">
                    <path stroke="#757780" stroke-width="2"
                        d="M20.5225 3.863h-10.382c-3.6003 0-6.519 2.9187-6.519 6.5189v10.382c0 3.6003 2.9187 6.5189 6.519 6.5189h10.382c3.6002 0 6.5189-2.9186 6.5189-6.5189v-10.382c0-3.6002-2.9187-6.5189-6.5189-6.5189Z" />
                    <path stroke="#757780" stroke-linecap="round" stroke-width="2" d="M11.1063 4.1045v22.9369" />
                    <path fill="#757780" stroke="#757780" stroke-width="2"
                        d="M7.485 10.141a.4831.4831 0 1 0-.0001-.9662.4831.4831 0 0 0 0 .9662ZM7.485 16.1769a.483.483 0 1 0-.0001-.9662.483.483 0 0 0 0 .9662ZM7.485 22.213a.483.483 0 1 0-.0001-.9662.483.483 0 0 0 0 .9662Z" />
                </svg>
            </button>

            <!-- Brand -->
            <div class="sidebar-brand d-flex align-items-center">
                <svg xmlns="http://www.w3.org/2000/svg" width="250" height="51" fill="none" viewBox="0 0 250 64"><g clip-path="url(#a)"><mask id="b" width="250" height="64" x="0" y="0" maskUnits="userSpaceOnUse" style="mask-type:luminance"><path fill="#fff" d="M250 0H0v64h250z" /></mask><g mask="url(#b)"><path fill="#71c11d" d="M78.227 48.186v-10.87c0-2.051-.002-2.057 1.963-2.433.322-.062.657-.045 1.128-.072v2.418c3.751-3.99 7.317-4.303 12.188-.08 2.22-1.925 4.804-3.135 7.8-3.022 2.928.111 5.484 1.215 7.572 3.909 0-1.062-.126-1.738.042-2.33.122-.428.574-.869.992-1.073.366-.18.938-.156 1.331-.002.349.136.822.575.824.883.047 6.873.036 13.747.036 20.822-.887 0-1.74.061-2.573-.038-.246-.029-.59-.495-.622-.79-.086-.802-.03-1.62-.03-2.59-.811.656-1.446 1.281-2.184 1.746-6.448 4.065-14.942.307-16.43-6.99-.51-2.499-.286-4.896.85-7.176.318-.638.217-1.032-.273-1.501-1.798-1.722-4.818-2.696-6.805-.842-1.047.977-1.942 2.555-2.1 3.953-.426 3.767-.428 7.583-.58 11.38-.036.898-.006 1.798-.006 2.774h-3.123zm15.279-.702c.122.344.221.699.37 1.031 2.386 5.348 9.481 6.59 13.265 2.326 2.221-2.502 2.62-6.258 1-9.422-1.493-2.915-4.305-4.379-7.796-4.11-4.97.381-8.1 5.702-6.84 10.175" /><path fill="#004c39" d="M236.29 41.21c-1.819 1.765-4.152 1.736-6.607 2.172 4.591 2.763 7.737 6.465 9.181 11.474.194.672.345 1.357.36 2.105-2.191-1.368-3.296-3.58-4.851-5.888v3.368l-.46.093-1.668-4.88-.257 3.304-.553.08-1.46-4.692-.161 2.745-.518.107-1.546-4.463-.187 1.888-.458.11c-.285-.67-.594-1.329-.847-2.01-.315-.845-.527-1.733-.898-2.552-.165-.364-.609-.603-.927-.9-.158.367-.451.732-.455 1.1-.035 3.497-.006 6.995-.038 10.493-.005.476-.181 1.327-.383 1.36-.834.136-1.713.058-2.565-.038-.118-.013-.247-.568-.248-.872-.013-8.765-.006-17.53-.017-26.296-.002-.788.31-1.121 1.103-1.099 3.502.097 7.011.06 10.503.29 3.488.23 6.197 3.425 6.272 6.949.05 2.323-.397 4.404-2.315 6.052m-5.823-1.18c.328-.023.663-.009.983-.075 2.56-.53 3.674-1.788 3.702-4.154.029-2.573-.997-4.075-3.624-4.452-2.265-.324-4.601-.178-6.906-.168-.222 0-.627.504-.633.782-.051 2.384-.014 4.77-.041 7.155-.007.706.283.931.959.921 1.775-.027 3.55-.008 5.56-.008" /><path fill="#72c31d" d="M138.64 28.686V56.27h-2.938v-3.336c-6.676 5.814-13.533 3.17-16.645-.661-3.493-4.302-3.292-10.872 1.09-15.041 3.887-3.7 10.454-4.674 15.515.628 0-3.304-.017-6.5.019-9.693.006-.478.181-1.309.416-1.362.737-.167 1.599-.196 2.29.056.258.095.179 1.11.253 1.825m-3.455 19.828c.159-1.082.446-2.163.456-3.246.049-5.03-3.775-8.465-8.788-7.953-4.763.486-8.222 5.664-6.674 10.37 1.019 3.1 3.931 5.478 6.898 5.688 3.608.255 6.474-1.406 8.108-4.859" /><path fill="#004c39" d="M15.627 60.006 2.072 41.74A10.52 10.52 0 0 1 .862 31.3l9.05-20.852a10.49 10.49 0 0 1 8.426-6.256l22.62-2.641a10.53 10.53 0 0 1 9.636 4.17l13.555 18.267a10.52 10.52 0 0 1 1.21 10.44L56.306 55.28a10.49 10.49 0 0 1-8.425 6.256l-22.62 2.64a10.48 10.48 0 0 1-9.635-4.17" /><path fill="#004b38" d="M210.846 35.583c0-2.182.056-4.242-.018-6.298-.054-1.522.944-1.32 1.901-1.375 1.028-.057 1.588.131 1.582 1.387-.049 8.521-.041 17.043-.005 25.565.003.988-.305 1.28-1.273 1.25-2.5-.081-2.171.26-2.183-2.179-.016-3.334-.031-6.67.014-10.004.012-.922-.297-1.206-1.211-1.196-3.76.041-7.521.054-11.28-.006-1.048-.017-1.226.399-1.217 1.305.038 3.581-.017 7.164.036 10.745.015 1.005-.255 1.373-1.31 1.34-1.933-.061-1.935-.002-1.936-1.93 0-8.235-.007-16.468.018-24.702.001-.486.169-1.345.393-1.392.824-.172 1.71-.121 2.557-.026.127.014.244.72.247 1.105.02 3.047.05 6.094-.011 9.14-.02 1 .327 1.254 1.281 1.243q5.577-.07 11.155 0c.969.013 1.357-.267 1.275-1.257-.072-.858-.015-1.727-.015-2.715" /><path fill="#72c31d" d="M170.457 54.311c-6.165-5.043-5.623-14.127.637-18.347 6.034-4.07 14.771-1.33 16.622 6.795.206.903.203 1.853.31 2.92h-18.448c-.595 2.183 1.578 5.891 4.115 6.994 2.168.942 4.286.898 6.459.161 2.203-.747 3.484-2.498 4.61-4.35 3.28 1.5 3.126 1.049.878 4.086-1.546 2.088-3.8 3.165-6.451 3.57-3.157.482-6.008-.05-8.732-1.829m.415-13.891-1.198 2.545h14.75c-.713-3.014-2.635-4.735-5.484-5.583-2.889-.86-6.639.707-8.068 3.038" /><path fill="#72c21d" d="M57.905 55.319c-.389-.277-.658-.58-.985-.796-4.025-2.67-5.811-7.437-4.555-12.195 1.154-4.368 5.105-7.62 9.816-7.846 1.436-.07 2.897.383 4.445.579 1.397.8 2.695 1.616 4.057 2.475 0-.514.036-1.15-.009-1.78-.058-.826.215-1.182 1.113-1.18 1.874.003 1.874-.042 1.874 1.84V56.25h-2.933V52.8c-3.847 3.63-8.045 4.44-12.823 2.519m7.458-17.886c-4.188-1.023-7.772.516-9.69 4.162-1.746 3.316-.912 7.573 2.013 10.08.376.322.903.47 1.526.77 3.536 1.768 7.792.875 9.961-2.013 2.806-3.734 2.108-10.623-3.81-12.999M151.871 51.217c1.343.656 2.551 1.5 3.887 2.012 1.372.527 3.221-.436 3.84-1.726.657-1.37.354-2.807-1.024-3.789-1.199-.853-2.544-1.501-3.82-2.248-1.481-.867-2.812-1.885-3.436-3.568-.766-2.068-.153-4.683 1.421-6.127 1.918-1.76 4.531-2.193 6.958-.975 1.189.596 2.236 1.474 3.347 2.225l.309.627c-.527.32-1.123.566-1.565.977-.58.539-1.01.492-1.609.04-.68-.514-1.41-1.012-2.195-1.326-1.539-.615-3.065-.016-3.747 1.337-.667 1.323-.33 2.523 1.145 3.502 1.739 1.153 3.608 2.117 5.308 3.32 3.344 2.365 2.657 7.691-.231 9.533-3.388 2.16-8.005 1.425-10.387-1.854a81 81 0 0 1 1.799-1.96" /><path fill="#73c41d" d="M146.8 56.012c-.93.21-1.843.306-2.952.422V36.316c0-1.732.001-1.731 1.776-1.721.361.002.722 0 1.192 0 0 7.184 0 14.242-.016 21.417" /><path fill="#71c11d" d="M146.782 26.698c1.461 1.72 1.156 3.513-.596 4.2-1.13.442-2.008.042-2.725-.774-.709-.807-.676-2.112.102-2.94.717-.762 1.57-1.35 2.71-.773.145.073.285.159.509.287" /><path fill="#fbfcfc" d="M22.698 37.38c-3.943 1.701-7.548 3.959-11.005 6.841.741-2.652 3.789-5.69 6.86-6.918 1.412-.565 2.874-1.01 4.323-1.477 1.412-.455 2.836-.871 4.363-1.338V9.908c.416-.027.73-.074 1.043-.063 4.783.16 9.597.052 14.343.56 6.293.674 10.127 5.42 10.096 11.805-.03 6.29-3.964 10.824-10.227 11.624-2.41.307-4.853.371-7.283.506-1.024.057-2.053.01-3.186.01V55.5h-4.72V36.253c-.9 2.215-.666 4.725-2.218 6.762v-3.468l-.28-.04q-.72 3.047-1.437 6.095l-.262-.04-.336-3.918-.204-.03-1.16 5.891-.318-.039-.31-2.474-.316-.07-1.357 4.329-.233-.012v-2.954c-1.571 2.27-1.657 5.295-4.096 7.044-.431-3.644 3.223-10.695 8.122-15.668-.006-.163-.104-.222-.202-.281m21.495-21.79c-3.921-1.764-8.08-1.002-12.17-1.273v15.737c3.315-.196 6.57-.203 9.768-.628 3.337-.443 5.311-2.64 6.002-5.89.648-3.044-.714-6.045-3.6-7.946" /><path fill="#004c39" d="M22.738 37.44c.059-.002.156.057.194.144-.092-.009-.123-.046-.194-.144" /></g></g><defs><clipPath id="a"><path fill="#fff" d="M0 0h250v64H0z" /></clipPath></defs></svg></defs></svg>
            </div>
        </div>

        <!-- Navigation Menu -->
        <ul class="sidebar-nav">
            <li class="nav-item">
                <a class="nav-link active" href="/" data-link data-tooltip="Dashboard">
                    <span><svg width="24" height="24" viewBox="0 0 24 24" fill="none"
                            xmlns="http://www.w3.org/2000/svg">
                            <path
                                d="M10.0703 2.81986L3.14027 8.36985C2.36027 8.98985 1.86027 10.2998 2.03027 11.2799L3.36027 19.2398C3.60027 20.6598 4.96026 21.8098 6.40026 21.8098H17.6003C19.0303 21.8098 20.4003 20.6498 20.6403 19.2398L21.9703 11.2799C22.1303 10.2998 21.6303 8.98985 20.8603 8.36985L13.9303 2.82984C12.8603 1.96984 11.1303 1.96986 10.0703 2.81986Z" />
                            <path
                                d="M12 15.5C13.3807 15.5 14.5 14.3807 14.5 13C14.5 11.6193 13.3807 10.5 12 10.5C10.6193 10.5 9.5 11.6193 9.5 13C9.5 14.3807 10.6193 15.5 12 15.5Z" />
                        </svg></span>
                    <span>Dashboard</span>
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="/employees" data-link data-tooltip="Employees">
                    <i class="bi bi-people"></i>
                    <span>Employees</span>
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="/requests" data-link data-tooltip="Create a request">
                    <i class="bi bi-file-text"></i>
                    <span>Create a request</span>
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="/attendance" data-link data-tooltip="Attendance">
                    <i class="bi bi-calendar-check"></i>
                    <span>Attendance</span>
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="/payroll" data-link data-tooltip="Payroll">
                    <i class="bi bi-currency-dollar"></i>
                    <span>Payroll</span>
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="/organization" data-link data-tooltip="Organization Chart">
                    <i class="bi bi-diagram-3"></i>
                    <span>Organization Chart</span>
                </a>
            </li>
        </ul>

        <!-- Bottom Links -->
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
        <!-- Mobile Dashboard -->
        <div class="mobile-dashboard d-block d-lg-none">
            <!-- User Header -->
            <div class="user-header">
                <div class="user-info">
                    <div class="user-avatar">TV</div>
                    <div class="user-details">
                        <h3>Thiên Vũ</h3>
                        <p>Tech Lead</p>
                    </div>
                </div>
                <div class="date-badge">
                    <span class="badge bg-warning text-dark px-3 py-2 rounded-pill">10/2025</span>
                </div>
            </div>

            <!-- Time Card -->
            <div class="time-card">
                <p class="mb-2 opacity-90">Thứ 3, 11/11/2025</p>
                <div class="time-info">
                    <div>
                        <small class="opacity-90">Giờ công tích lũy:</small>
                        <div class="time-display">120.00</div>
                    </div>
                    <div class="text-end">
                        <small class="opacity-90">Tổng lượng ước tính:</small>
                        <div class="d-flex align-items-center">
                            <span class="me-2">**********</span>
                            <i class="bi bi-eye"></i>
                        </div>
                    </div>
                </div>
                <div class="progress" style="height: 4px;">
                    <div class="progress-bar bg-warning" style="width: 60%"></div>
                    <div class="progress-bar bg-light" style="width: 40%"></div>
                </div>
                <small class="opacity-90">Còn lại 11/26 ngày công</small>
            </div>

            <!-- Apps Grid -->
            <div class="apps-grid">
                <a href="#" class="app-item">
                    <div class="app-icon blue"><i class="bi bi-list-ul"></i></div>
                    <span class="app-name">Hồ sơ</span>
                </a>
                <a href="#" class="app-item">
                    <div class="app-icon purple"><i class="bi bi-pencil"></i></div>
                    <span class="app-name">Đơn yêu cầu</span>
                </a>
                <a href="#" class="app-item">
                    <div class="app-icon orange"><i class="bi bi-clock"></i></div>
                    <span class="app-name">Giờ chấm công</span>
                </a>
                <a href="#" class="app-item">
                    <div class="app-icon orange"><i class="bi bi-calendar"></i></div>
                    <span class="app-name">Bảng công</span>
                </a>
                <a href="#" class="app-item">
                    <div class="app-icon purple"><i class="bi bi-currency-dollar"></i></div>
                    <span class="app-name">Bảng lương</span>
                </a>
                <a href="#" class="app-item">
                    <div class="app-icon cyan"><i class="bi bi-shield-check"></i></div>
                    <span class="app-name">Thông báo nội bộ</span>
                </a>
                <a href="#" class="app-item">
                    <div class="app-icon red"><i class="bi bi-file-text"></i></div>
                    <span class="app-name">Hợp đồng</span>
                </a>
                <a href="#" class="app-item">
                    <div class="app-icon cyan"><i class="bi bi-share"></i></div>
                    <span class="app-name">Báo cáo</span>
                </a>
            </div>
        </div>

        <!-- Desktop content mounts here -->
        <div class="desktop-content d-none d-lg-block">
            <!-- Desktop dashboard content -->
        </div>
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
            <!-- FAB Button -->
            <a href="/requests" class="bottom-nav-item fab" data-link>
                <i class="bi bi-pencil-square"></i>
            </a>
        </div>
    </nav>
</div>

<script>
    function toggleSidebarCollapse() {
        const appContainer = document.getElementById(''appContainer'');
        const sidebar = document.getElementById(''sidebar'');

        appContainer.classList.toggle(''sidebar - collapsed'');
        sidebar.classList.toggle(''collapsed'');
    }

    function toggleSidebar() {
        const sidebar = document.getElementById(''sidebar'');
        sidebar.classList.toggle(''show'');
    }

    // Close sidebar when clicking outside on mobile
    document.addEventListener(''click'', function (event) {
        const sidebar = document.getElementById(''sidebar'');
        const toggleBtn = document.querySelector(''.navbar - toggler'');

        if (window.innerWidth <= 768 &&
            !sidebar.contains(event.target) &&
            !toggleBtn.contains(event.target) &&
            sidebar.classList.contains(''show'')) {
            sidebar.classList.remove(''show'');
        }
    });
</script>
<script>{ { INJECTED_JS } }</script>

', 'Base HTML framework for SPA');
GO

-- Your existing styles.css content
INSERT INTO tblSPA_Templates (ComponentID, TemplateType, TemplateContent, Description)
VALUES ('ess-dashboard', 'css', N'
/* ==========================================================================
   PARADISE HR - STYLES
   ========================================================================== */

/* ==========================================================================
   1. RESET & BASE STYLES
   ========================================================================== */
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: -apple-system, BlinkMacSystemFont, ''Fira Sans'', Roboto, sans-serif;
    background-color: #f5f5f5;
    overflow-x: hidden;
}

/* ==========================================================================
   2. LAYOUT CONTAINER
   ========================================================================== */
.app-container {
    position: relative;
    min-height: 100vh;
}

/* ==========================================================================
   3. TOP NAVIGATION BAR
   ========================================================================== */
.navbar {
    position: fixed;
    top: 0;
    right: 0;
    left: 320px;
    height: 60px;
    background: transparent;
    border: none;
    box-shadow: none;
    z-index: 999;
    transition: left 0.3s ease;
}

.sidebar-collapsed .navbar {
    left: 120px;
}

.navbar .container-fluid {
    height: 60px;
    padding: 0 1.5rem;
}

.navbar-brand {
    color: #333 !important;
    font-weight: 600;
    font-size: 1.25rem;
}

.navbar .nav-link {
    color: #64748b !important;
    padding: 0.5rem !important;
    margin: 0 0.25rem;
    border-radius: 6px;
    transition: all 0.2s ease;
}

.navbar .nav-link:hover {
    color: #333 !important;
    background-color: rgba(0,0,0,0.05);
}

/* Navbar Search Bar */
.navbar-search {
    max-width: 400px;
    margin-left: auto;
}

.navbar-search .form-control {
    background-color: #f8f9fa;
    border: 1px solid #e2e8f0;
    color: #333;
    border-radius: 25px;
    padding: 0.75rem 1rem 0.75rem 2.5rem;
    font-size: 0.875rem;
    transition: all 0.3s ease;
}

.navbar-search .form-control::placeholder {
    color: #64748b;
}

.navbar-search .form-control:focus {
    background-color: white;
    border-color: #007bff;
    box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.1);
    color: #333;
}

.navbar-search .search-icon {
    position: absolute;
    left: 0.75rem;
    top: 50%;
    transform: translateY(-50%);
    color: #64748b;
    font-size: 0.875rem;
    z-index: 10;
}

/* ==========================================================================
   4. SIDEBAR
   ========================================================================== */
.sidebar {
    position: fixed;
    top: 20px;
    left: 20px;
    bottom: 20px;
    width: 280px;
    z-index: 1000;
    transition: all 0.3s ease;
    display: flex;
    flex-direction: column;
    
    /* Glass morphism effect */
    background: rgba(255, 255, 255, 0.25);
    backdrop-filter: blur(20px);
    -webkit-backdrop-filter: blur(20px);
    border: 1px solid rgba(255, 255, 255, 0.18);
    border-radius: 20px;
    
    /* Shadow for depth */
    box-shadow: 
        0 8px 32px rgba(0, 0, 0, 0.1),
        0 0 0 1px rgba(255, 255, 255, 0.05) inset;
    
    overflow: hidden;
}

.sidebar::before {
    content: '''';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: linear-gradient(
        135deg,
        rgba(255, 255, 255, 0.1) 0%,
        rgba(255, 255, 255, 0.05) 50%,
        rgba(255, 255, 255, 0.02) 100%
    );
    pointer-events: none;
}

/* Collapsed state */
.sidebar.collapsed {
    width: 80px;
}

/* Chỉ ẩn text khi collapsed, giữ lại icons */
.sidebar.collapsed .sidebar-brand span,
.sidebar.collapsed .nav-link span,
.sidebar.collapsed .sidebar-bottom span {
    opacity: 0;
    pointer-events: none;
    width: 0;
    overflow: hidden;
}

/* Sidebar Header */
.sidebar-header {
    padding: 24px 20px;
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
    position: relative;
    z-index: 2;
    flex-shrink: 0;
}

.sidebar-toggle-btn {
    position: absolute;
    top: 20px;
    right: 20px;
    background: rgba(255, 255, 255, 0.2);
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 10px;
    width: 36px;
    height: 36px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #333;
    transition: all 0.3s ease;
    backdrop-filter: blur(10px);
    -webkit-backdrop-filter: blur(10px);
    cursor: pointer;
    z-index: 10;
}

.sidebar-toggle-btn:hover {
    background: rgba(255, 255, 255, 0.3);
    transform: scale(1.05);
}

.sidebar.collapsed .sidebar-toggle-btn {
    right: 22px;
}

/* Sidebar Brand */
.sidebar-brand {
    margin-top: 50px;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 12px;
    color: #333;
    text-decoration: none;
    font-weight: 600;
    font-size: 18px;
    transition: all 0.3s ease;
    position: relative;
}

.sidebar-brand img {
    height: 40px;
    border-radius: 8px;
    flex-shrink: 0;
    transition: all 0.3s ease;
}

/* Logo thay đổi khi collapsed */
.sidebar.collapsed .sidebar-brand {
    justify-content: center;
}

.sidebar.collapsed .sidebar-brand img {
    content: url("data:image/svg+xml,%3Csvg width=''32'' height=''32'' viewBox=''0 0 500 500'' fill=''none'' xmlns=''http://www.w3.org/2000/svg''%3E%3Cpath d=''M117.991 455.538L15.6432 317.104C7.3432 305.875 2.12893 292.653 0.528929 278.765C-1.07583 264.878 0.986021 250.814 6.50983 237.978L74.848 79.9428C80.3669 67.1268 89.1526 55.9967 100.319 47.673C111.486 39.3497 124.643 34.1272 138.462 32.532L309.257 12.5147C323.081 10.931 337.077 13.0173 349.843 18.5636C362.605 24.1104 373.7 32.9234 382.009 44.1215L484.358 182.56C492.657 193.788 497.871 207.008 499.472 220.895C501.075 234.783 499.013 248.847 493.491 261.683L425.152 419.72C419.629 432.531 410.837 443.653 399.67 451.978C388.504 460.295 375.352 465.525 361.538 467.13L190.743 487.144C176.919 488.764 162.914 486.691 150.138 481.140C137.367 475.593 126.281 466.763 117.991 455.538Z'' fill=''%23004C39''/%3E%3Cpath d=''M171.385 284.054C141.616 296.947 114.398 314.059 88.2959 335.905C93.8908 315.806 116.9 292.782 140.088 283.469C150.748 279.188 161.787 275.825 172.73 272.28C183.388 268.828 194.144 265.674 205.674 262.14C205.674 200.409 205.674 138.449 205.674 75.8546C208.815 75.6499 211.187 75.2925 213.547 75.3716C249.667 76.5829 286.01 75.7688 321.85 79.6197C369.364 84.7247 398.311 120.691 398.079 169.087C397.85 216.758 368.15 251.117 320.856 257.178C302.659 259.511 284.214 259.996 265.865 261.019C258.139 261.449 250.367 261.09 241.809 261.09C241.809 314.857 241.809 367.743 241.809 421.386C229.712 421.386 218.392 421.386 206.173 421.386C206.173 372.95 206.173 324.23 206.173 275.512C199.382 292.305 201.144 311.326 189.422 326.764C189.422 318.003 189.422 309.24 189.422 300.478C188.717 300.376 188.011 300.273 187.307 300.172C183.692 315.57 180.076 330.97 176.46 346.368C175.801 346.268 175.141 346.169 174.482 346.07C173.637 336.169 172.792 326.267 171.947 316.368C171.434 316.295 170.921 316.224 170.409 316.151C167.486 331.032 164.564 345.911 161.642 360.792C160.843 360.694 160.044 360.595 159.246 360.498C158.467 354.246 157.689 347.995 156.911 341.744C156.114 341.566 155.317 341.386 154.519 341.208C151.103 352.147 147.687 363.086 144.271 374.024C143.685 373.995 143.1 373.965 142.514 373.935C142.514 366.472 142.514 359.009 142.514 351.544C130.65 368.755 130.005 391.677 111.589 404.931C108.329 377.317 135.92 323.872 172.909 286.188C172.863 284.947 172.124 284.501 171.385 284.054ZM333.689 118.914C304.079 105.545 272.68 111.318 241.796 109.267C241.796 148.821 241.796 187.292 241.796 228.53C266.828 227.047 291.401 226.996 315.553 223.775C340.746 220.417 355.652 203.772 360.871 179.137C365.761 156.064 355.476 133.322 333.689 118.914Z'' fill=''%23FBFCFC''/%3E%3C/svg%3E");
    width: 32px;
    height: 32px;
}

/* Navigation Menu */
.sidebar-nav {
    list-style: none;
    padding: 20px 16px;
    margin: 0;
    flex: 1;
    position: relative;
    z-index: 2;
    overflow-y: auto;
}

.sidebar-nav .nav-item {
    margin-bottom: 8px;
}

.sidebar-nav .nav-link {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 12px 16px;
    color: rgba(51, 51, 51, 0.8);
    text-decoration: none;
    border-radius: 12px;
    transition: all 0.3s ease;
    font-weight: 500;
    position: relative;
    overflow: hidden;
    white-space: nowrap;
}

.sidebar.collapsed .sidebar-nav .nav-link {
    justify-content: center;
    padding: 12px 8px;
}

.sidebar-nav .nav-link::before {
    content: '''';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(255, 255, 255, 0.1);
    opacity: 0;
    transition: opacity 0.3s ease;
}

.sidebar-nav .nav-link:hover::before {
    opacity: 1;
}

.sidebar-nav .nav-link.active {
    background: rgba(22, 163, 74, 0.15);
    color: #16a34a;
    backdrop-filter: blur(10px);
    -webkit-backdrop-filter: blur(10px);
    box-shadow: 0 4px 20px rgba(22, 163, 74, 0.1);
}

.sidebar-nav .nav-link i {
    font-size: 18px;
    width: 20px;
    text-align: center;
    flex-shrink: 0;
    opacity: 1 !important;
    display: block !important;
}

/* Sidebar Bottom */
.sidebar-bottom {
    padding: 20px 16px 24px;
    border-top: 1px solid rgba(255, 255, 255, 0.1);
    position: relative;
    z-index: 2;
    flex-shrink: 0;
}

.sidebar-bottom a {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 12px 16px;
    text-decoration: none;
    border-radius: 12px;
    transition: all 0.3s ease;
    font-weight: 500;
    margin-bottom: 8px;
    position: relative;
    overflow: hidden;
    white-space: nowrap;
}

.sidebar.collapsed .sidebar-bottom a {
    justify-content: center;
    padding: 12px 8px;
}

.sidebar-bottom a::before {
    content: '''';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(255, 255, 255, 0.1);
    opacity: 0;
    transition: opacity 0.3s ease;
}

.sidebar-bottom a:hover::before {
    opacity: 1;
}

.sidebar-bottom a.text-danger {
    color: #dc2626 !important;
}

.sidebar-bottom a i {
    font-size: 16px;
    width: 20px;
    text-align: center;
    flex-shrink: 0;
    opacity: 1 !important;
    display: block !important;
}

/* Tooltip for collapsed sidebar */
.sidebar.collapsed [data-tooltip]:hover::after {
    content: attr(data-tooltip);
    position: absolute;
    left: 100%;
    top: 50%;
    transform: translateY(-50%);
    margin-left: 10px;
    padding: 8px 12px;
    background: rgba(0, 0, 0, 0.8);
    color: white;
    border-radius: 8px;
    font-size: 12px;
    white-space: nowrap;
    z-index: 1000;
    backdrop-filter: blur(10px);
    -webkit-backdrop-filter: blur(10px);
}

.sidebar.collapsed [data-tooltip]:hover::before {
    content: '''';
    position: absolute;
    left: 100%;
    top: 50%;
    transform: translateY(-50%);
    margin-left: 4px;
    border: 6px solid transparent;
    border-right-color: rgba(0, 0, 0, 0.8);
    z-index: 1000;
}

/* ==========================================================================
   5. MAIN CONTENT
   ========================================================================== */
.main-content {
    margin-left: 320px;
    margin-top: 60px;
    min-height: calc(100vh - 60px);
    padding: 20px;
    background-color: #fefefe;
    transition: margin-left 0.3s ease;
    position: relative;
}

.sidebar-collapsed .main-content {
    margin-left: 120px;
}

/* ==========================================================================
   6. MOBILE STYLES
   ========================================================================== */
@media (max-width: 991.98px) {
    /* Layout adjustments */
    .navbar {
        display: none;
    }
    
    .sidebar {
        transform: translateX(-100%);
        top: 0;
        left: 0;
        right: auto;
        bottom: 0;
        border-radius: 0 20px 20px 0;
        width: 280px;
    }
    
    .sidebar.show {
        transform: translateX(0);
    }
    
    .main-content {
        margin-left: 0;
        margin-top: 0;
        padding: 0 0 120px 0;
        min-height: 100vh;
    }
    
    /* Mobile Dashboard */
    .mobile-dashboard {
        display: block;
        padding: 1rem;
    }
    
    .user-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 1.5rem;
        background: white;
        padding: 1rem;
        border-radius: 12px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    }
    
    .user-info {
        display: flex;
        align-items: center;
    }
    
    .user-avatar {
        width: 48px;
        height: 48px;
        border-radius: 50%;
        background: linear-gradient(135deg, #3b82f6, #1d4ed8);
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
        font-weight: 600;
        margin-right: 1rem;
    }
    
    .user-avatar img {
        width: 100%;
        height: 100%;
        border-radius: 50%;
        object-fit: cover;
    }
    
    .user-details h3 {
        margin: 0;
        font-size: 1.1rem;
        color: #1f2937;
    }
    
    .user-details p {
        margin: 0;
        font-size: 0.875rem;
        color: #6b7280;
    }
    
    .date-badge .badge {
        font-size: 0.875rem;
        padding: 0.5rem 1rem;
    }
    
    /* Time Card */
    .time-card {
        background: linear-gradient(135deg, #16a34a 0%, #059669 100%);
        color: white;
        padding: 1.5rem;
        border-radius: 16px;
        margin-bottom: 2rem;
        box-shadow: 0 4px 12px rgba(22, 163, 74, 0.2);
    }
    
    .time-info {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 1rem;
    }
    
    .time-display {
        background: rgba(255,255,255,0.2);
        padding: 0.5rem 1rem;
        border-radius: 25px;
        font-size: 1.25rem;
        font-weight: 600;
    }
    
    .progress {
        height: 4px;
        background: rgba(255,255,255,0.2);
        border-radius: 2px;
        margin-bottom: 0.5rem;
    }
    
    .progress-bar {
        background: rgba(255,255,255,0.8);
        border-radius: 2px;
    }
    
    /* Apps Grid */
    .apps-grid {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 1rem;
        margin-bottom: 2rem;
    }
    
    .app-item {
        display: flex;
        flex-direction: column;
        align-items: center;
        text-decoration: none;
        color: #374151;
        padding: 1.5rem 1rem;
        background: white;
        border-radius: 16px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        transition: all 0.2s ease;
    }
    
    .app-item:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 16px rgba(0,0,0,0.1);
        color: #374151;
        text-decoration: none;
    }
    
    .app-icon {
        width: 48px;
        height: 48px;
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        margin-bottom: 0.75rem;
        font-size: 1.5rem;
        color: white;
    }
    
    .app-icon.bg-primary { background: linear-gradient(135deg, #3b82f6, #1d4ed8); }
    .app-icon.bg-info { background: linear-gradient(135deg, #8b5cf6, #7c3aed); }
    .app-icon.bg-warning { background: linear-gradient(135deg, #f97316, #ea580c); }
    .app-icon.bg-success { background: linear-gradient(135deg, #10b981, #059669); }
    .app-icon.bg-danger { background: linear-gradient(135deg, #ef4444, #dc2626); }
    .app-icon.bg-secondary { background: linear-gradient(135deg, #06b6d4, #0891b2); }
    
    .app-name {
        font-size: 0.875rem;
        font-weight: 500;
        text-align: center;
    }
    
    
    /* Bottom Navigation */
    .bottom-nav {
        position: fixed;
        bottom: 20px;
        left: 20px;
        right: 20px;
        height: 80px;
        background: rgba(255, 255, 255, 0.85);
        backdrop-filter: blur(20px);
        -webkit-backdrop-filter: blur(20px);
        border: 1px solid rgba(255, 255, 255, 0.3);
        border-radius: 25px;
        box-shadow: 
            0 8px 32px rgba(0, 0, 0, 0.08),
            0 0 0 1px rgba(255, 255, 255, 0.1) inset;
        z-index: 1000;
        padding: 0 24px;
        display: flex;
        align-items: center;
    }
    
    /* Container for left items */
    .bottom-nav-left {
        display: flex;
        gap: 32px;
        flex: 1;
    }
    
    /* Container for right FAB */
    .bottom-nav-right {
        flex: none;
    }
    
    .bottom-nav-item {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        text-decoration: none;
        color: #64748b;
        transition: all 0.3s ease;
        padding: 8px 12px;
        border-radius: 15px;
        position: relative;
        overflow: hidden;
        gap: 4px;
        min-width: 50px;
    }
    
    .bottom-nav-item::before {
        content: '''';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: rgba(255, 255, 255, 0.4);
        opacity: 0;
        transition: opacity 0.3s ease;
        border-radius: 15px;
    }
    
    .bottom-nav-item:hover::before {
        opacity: 1;
    }
    
    .bottom-nav-item i {
        font-size: 22px;
        color: #64748b;
        transition: color 0.3s ease;
    }
    
    .bottom-nav-item span {
        font-size: 10px;
        font-weight: 500;
        color: #64748b;
        transition: color 0.3s ease;
        margin-top: 2px;
    }
    
    .bottom-nav-item:hover i,
    .bottom-nav-item:hover span {
        color: #333;
    }
    
    /* FAB (Floating Action Button) */
    .bottom-nav-item.fab {
        width: 56px;
        height: 56px;
        background: linear-gradient(135deg, #16a34a, #22c55e);
        border-radius: 50%;
        flex: none;
        box-shadow: 
            0 4px 20px rgba(22, 163, 74, 0.25),
            0 0 0 1px rgba(255, 255, 255, 0.2) inset;
        backdrop-filter: blur(10px);
        -webkit-backdrop-filter: blur(10px);
        position: relative;
        top: -4px;
        margin-left: 16px;
    }
    
    .bottom-nav-item.fab::before {
        background: rgba(255, 255, 255, 0.2);
        border-radius: 50%;
    }
    
    .bottom-nav-item.fab i {
        font-size: 24px;
        color: white;
    }
    
    .bottom-nav-item.fab:hover {
        transform: scale(1.05);
        box-shadow: 
            0 6px 25px rgba(22, 163, 74, 0.35),
            0 0 0 1px rgba(255, 255, 255, 0.25) inset;
    }
    
    /* Home indicator */
    .bottom-nav::after {
        content: '''';
        position: absolute;
        bottom: 8px;
        left: 50%;
        transform: translateX(-50%);
        width: 134px;
        height: 5px;
        background: rgba(0, 0, 0, 0.3);
        border-radius: 3px;
    }
    
    /* ...existing code... */
}

/* ==========================================================================
   7. DESKTOP ONLY STYLES
   ========================================================================== */
@media (min-width: 992px) {
    .mobile-dashboard,
    .bottom-nav {
        display: none;
    }
    
    .desktop-content {
        display: block !important;
    }
}

/* ==========================================================================
   8. SCROLLBAR STYLING
   ========================================================================== */
.sidebar::-webkit-scrollbar,
.sidebar-nav::-webkit-scrollbar {
    width: 4px;
}

.sidebar::-webkit-scrollbar-track,
.sidebar-nav::-webkit-scrollbar-track {
    background: transparent;
}

.sidebar::-webkit-scrollbar-thumb,
.sidebar-nav::-webkit-scrollbar-thumb {
    background-color: rgba(0, 0, 0, 0.2);
    border-radius: 2px;
}

.sidebar::-webkit-scrollbar-thumb:hover,
.sidebar-nav::-webkit-scrollbar-thumb:hover {
    background-color: rgba(0, 0, 0, 0.3);
}

/* ==========================================================================
   9. UTILITY CLASSES
   ========================================================================== */
.opacity-90 {
    opacity: 0.9 !important;
}

.text-muted {
    color: #6b7280 !important;
}

.text-danger {
    color: #dc2626 !important;
}

/* ==========================================================================
   10. ANIMATIONS & TRANSITIONS
   ========================================================================== */
@keyframes fadeIn {
    from {
        opacity: 0;
        transform: translateY(10px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

.mobile-dashboard > * {
    animation: fadeIn 0.3s ease-out;
}

.mobile-dashboard > *:nth-child(2) {
    animation-delay: 0.1s;
}

.mobile-dashboard > *:nth-child(3) {
    animation-delay: 0.2s;
}
', 'Base CSS styles for framework');
GO

INSERT INTO tblSPA_Templates (ComponentID, TemplateType, TemplateContent, Description)
VALUES ('ess-dashboard', 'js', N'
// ====================================================================
// SPA FRAMEWORK - Core Router & Component Loader
// ====================================================================

// Global app state
window.SPA = {
    navigation: {{NAVIGATION_DATA}},
    config: {{CONFIG_DATA}},
    translations: {{TRANSLATIONS}},
    preloadedComponents: {{PRELOAD_COMPONENTS}},
    currentComponent: null,
    cache: {}
};

// ====================================================================
// Component Base Class
// ====================================================================
class Component {
    constructor(props = {}) {
        this.props = props;
        this.el = document.createElement("div");
        this.data = null;
    }
    
    async render() {
        return "";
    }
    
    onMount() {}
    onUnmount() {}
    
    setHTML(html) {
        this.el.innerHTML = html;
        return this.el;
    }
    
    async loadData() {
        // Override in subclasses
        return null;
    }
}

// ====================================================================
// Component Loader (Lazy Loading from SQL)
// ====================================================================
class ComponentLoader {
    static async load(componentId, params = {}) {
        // Check cache first
        const cacheKey = componentId + JSON.stringify(params);
        if (SPA.cache[cacheKey]) {
            console.log("Loading from cache:", componentId);
            return SPA.cache[cacheKey];
        }
        
        try {
            // Call SQL Server to get component
            const response = await fetch("/api/component", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    procedure: "sp_SPA_LoadComponent",
                    params: {
                        ComponentID: componentId,
                        LoginID: window.loginID || 3,
                        RouteParams: JSON.stringify(params),
                        LanguageID: window.languageID || "VN"
                    }
                })
            });
            
            const result = await response.json();
            
            if (result.status === "error") {
                throw new Error(result.message);
            }
            
            // Inject CSS if exists
            if (result.css) {
                const styleId = "style-" + componentId;
                let styleEl = document.getElementById(styleId);
                if (!styleEl) {
                    styleEl = document.createElement("style");
                    styleEl.id = styleId;
                    document.head.appendChild(styleEl);
                }
                styleEl.textContent = result.css;
            }
            
            // Create component class from JS string
            let ComponentClass = Component; // default
            if (result.js) {
                eval(result.js); // Will define ComponentClass
            }
            
            // Create instance
            const instance = new ComponentClass({ params, data: result.data });
            
            // Cache it
            SPA.cache[cacheKey] = instance;
            
            return instance;
            
        } catch (error) {
            console.error("Error loading component:", error);
            return null;
        }
    }
}

// ====================================================================
// Router
// ====================================================================
class Router {
    constructor(routes = []) {
        this.routes = routes;
        this.currentComponent = null;
        this.outlet = document.getElementById("app");
        
        this.handleLinkClick = this.handleLinkClick.bind(this);
        this.onPopState = this.onPopState.bind(this);
    }
    
    start() {
        document.body.addEventListener("click", this.handleLinkClick);
        window.addEventListener("popstate", this.onPopState);
        
        // Build navigation
        this.buildNavigation();
        
        // Navigate to current path
        this.navigate(window.location.pathname, { replace: true });
    }
    
    buildNavigation() {
        const nav = SPA.navigation || [];
        const sidebarNav = document.getElementById("sidebarNav");
        
        if (!sidebarNav) return;
        
        nav.forEach(item => {
            if (!item.canView) return;
            
            const li = document.createElement("li");
            li.className = "nav-item";
            li.innerHTML = `
                <a href="${item.path}" class="nav-link" data-link>
                    <i class="${item.icon}"></i>
                    <span>${item.name}</span>
                </a>
            `;
            sidebarNav.appendChild(li);
        });
    }
    
    handleLinkClick(e) {
        const a = e.target.closest("a[data-link]");
        if (!a) return;
        
        const href = a.getAttribute("href");
        if (!href || href === "#") return;
        
        e.preventDefault();
        this.navigate(href);
    }
    
    onPopState() {
        this.navigate(window.location.pathname, { replace: true });
    }
    
    matchRoute(path) {
        for (const route of this.routes) {
            const regex = this.pathToRegex(route.path);
            const match = path.match(regex);
            if (match) {
                const params = this.getParams(match, route);
                return { route, params };
            }
        }
        return null;
    }
    
    pathToRegex(path) {
        return new RegExp(
            "^" + path.replace(/\//g, "\\/").replace(/:\w+/g, "([^\\/]+)") + "$"
        );
    }
    
    getParams(match, route) {
        const values = match.slice(1);
        const keys = Array.from(route.path.matchAll(/:(\w+)/g)).map(m => m[1]);
        const params = {};
        keys.forEach((k, i) => (params[k] = values[i]));
        return params;
    }
    
    async navigate(path, opts = {}) {
        // Find matching route
        const result = this.matchRoute(path);
        if (!result) {
            console.warn("No route matched:", path);
            return;
        }
        
        const { route, params } = result;
        
        // Update history
        if (!opts.replace) {
            history.pushState({}, "", path);
        }
        
        // Load component
        await this.loadRoute(route, params);
    }
    
    async loadRoute(route, params = {}) {
        // Unmount previous
        if (this.currentComponent && this.currentComponent.onUnmount) {
            this.currentComponent.onUnmount();
        }
        
        // Show loading
        this.outlet.innerHTML = "<div class=\"loading\">Loading...</div>";
        
        // Load component
        const component = await ComponentLoader.load(route.componentId, params);
        
        if (!component) {
            this.outlet.innerHTML = "<div class=\"error\">Failed to load component</div>";
            return;
        }
        
        this.currentComponent = component;
        
        // Render
        const html = await component.render();
        this.outlet.innerHTML = "";
        this.outlet.appendChild(component.setHTML(html));
        
        // Mount
        if (component.onMount) {
            component.onMount();
        }
    }
}

// ====================================================================
// Initialize Routes from Navigation
// ====================================================================
const routes = (SPA.navigation || []).map(item => ({
    path: item.path,
    componentId: item.id
}));

// ====================================================================
// Start App
// ====================================================================
const router = new Router(routes);

(function initRouter() {
  function start() { router.start(); }

  if (document.readyState === ''loading'') {
    document.addEventListener(''DOMContentLoaded'', start);
  } else {
    start();
  }
})();

// ====================================================================
// Translation Helper
// ====================================================================
function t(key) {
    return SPA.translations[key] || key;
}
', 'Base JavaScript framework with router and component loader');
GO