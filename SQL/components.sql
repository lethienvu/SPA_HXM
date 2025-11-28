delete from tblSPA_Components 
INSERT INTO tblSPA_Components (ComponentID, ComponentName, ComponentType, StoredProcedure, RoutePattern, MenuID, ParentComponentID, PreloadJS, RequireAuth, CacheMinutes, Priority)
VALUES
    ('about', 'About', 'page', NULL, '/about', NULL, NULL, 0, 0, 0, 60),
    ('alert', 'Alert Component', 'widget', NULL, NULL, NULL, NULL, 1, 0, 0, 2),
    ('attendance', 'Attendance', 'page', NULL, '/attendance', 'MnuWPT206', NULL, 0, 1, 0, 40),
    ('Breakcumps', 'Breakcumps Component', 'widget', NULL, NULL, NULL, NULL, 0, 1, 0, 2),
    ('Candidate', 'candidate', 'page', NULL, NULL, NULL, NULL, 0, 1, 0, 100),
    ('Contract', 'contract', 'page', NULL, NULL, NULL, NULL, 0, 1, 0, 100),
    ('dashboard', 'Dashboard', 'core', NULL, '/', 'MnuHRS2000', NULL, 1, 1, 0, 1),
    ('Department', 'department', 'page', NULL, NULL, NULL, NULL, 0, 1, 0, 100),
    ('EmployeeProfile', 'employee-profile', 'page', NULL, NULL, NULL, NULL, 0, 1, 0, 100),
    ('employees', 'Employees', 'page', NULL, '/employees', 'MnuHRS100', NULL, 0, 1, 0, 20),
    ('loading', 'Loading Component', 'widget', NULL, NULL, NULL, NULL, 1, 0, 0, 2),
    ('modal', 'Modal Component', 'widget', NULL, NULL, NULL, NULL, 1, 0, 0, 2),
    ('not-found', 'Page Not Found', 'page', NULL, '*', NULL, NULL, 0, 0, 0, 999),
    ('notifications', 'Notifications', 'page', NULL, NULL, NULL, NULL, 0, 1, 0, 3),
    ('payroll', 'Payroll Management', 'page', NULL, NULL, NULL, NULL, 0, 1, 0, 50),
    ('performance', 'Performance Management', 'page', NULL, NULL, NULL, NULL, 0, 1, 0, 100),
    ('recruitment', 'Recruitment Management', 'page', NULL, NULL, NULL, NULL, 0, 1, 0, 100),
    ('request', 'Request Management', 'page', NULL, NULL, NULL, NULL, 0, 1, 0, 100),
    ('Settings', 'settings', 'page', NULL, NULL, NULL, NULL, 0, 1, 0, 3),
    ('SidebarManager', 'sidebar-manager', 'widget', NULL, NULL, NULL, NULL, 0, 1, 0, 2),
    ('spa-framework', 'SPA Framework Core', 'core', NULL, '*', NULL, NULL, 1, 0, 0, 1),
    ('toast', 'Toast Component', 'widget', NULL, NULL, NULL, NULL, 1, 0, 0, 2),
    ('UIComponents', 'ui-components', 'widget', NULL, NULL, NULL, NULL, 0, 1, 0, 2);

