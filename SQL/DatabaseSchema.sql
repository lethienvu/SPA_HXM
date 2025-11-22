
-- ====================================================================
-- TABLE 1: Component Registry (Đăng ký components)
-- ====================================================================
IF OBJECT_ID('tblSPA_Components') IS NOT NULL DROP TABLE tblSPA_Components
GO

CREATE TABLE tblSPA_Components (
    ComponentID VARCHAR(50) PRIMARY KEY,
    ComponentName NVARCHAR(200) NOT NULL,
    ComponentType VARCHAR(20) DEFAULT 'page', -- 'page', 'layout', 'widget', 'modal'
    StoredProcedure VARCHAR(100), -- NULL = load from template table
    RoutePattern NVARCHAR(200), -- '/dashboard', '/leave/:id', '/ot/register'
    MenuID VARCHAR(20), -- Link to MEN_Menu
    ParentComponentID VARCHAR(50), -- For nested routes
    PreloadJS BIT DEFAULT 0, -- Load JS immediately with framework
    RequireAuth BIT DEFAULT 1,
    CacheMinutes INT DEFAULT 0, -- 0 = no cache
    Priority INT DEFAULT 100
);


-- ====================================================================
-- TABLE 2: Component Templates (UI templates in DB)
-- ====================================================================
IF OBJECT_ID('tblSPA_Templates') IS NOT NULL DROP TABLE tblSPA_Templates
GO

CREATE TABLE tblSPA_Templates (
    TemplateID INT IDENTITY(1,1) PRIMARY KEY,
    ComponentID VARCHAR(50) NOT NULL,
    TemplateType VARCHAR(20) NOT NULL, -- 'html', 'css', 'js'
    TemplateContent NVARCHAR(MAX),
    Version VARCHAR(20) DEFAULT '1.0.0',
    Description NVARCHAR(500)
);

-- ====================================================================
-- TABLE 3: SPA Configuration
-- ====================================================================
IF OBJECT_ID('tblSPA_Config') IS NOT NULL DROP TABLE tblSPA_Config
GO

CREATE TABLE tblSPA_Config (
    ConfigKey VARCHAR(100) PRIMARY KEY,
    ConfigValue NVARCHAR(MAX),
    ConfigType VARCHAR(20) DEFAULT 'string', -- 'string', 'json', 'number', 'bool'
    Category VARCHAR(50), -- 'routing', 'theme', 'api', 'feature'
    Description NVARCHAR(500)
);

-- ====================================================================
-- TABLE 4: Component Dependencies (for lazy loading optimization)
-- ====================================================================
IF OBJECT_ID('tblSPA_Dependencies') IS NOT NULL DROP TABLE tblSPA_Dependencies
GO

CREATE TABLE tblSPA_Dependencies (
    DependencyID INT IDENTITY(1,1) PRIMARY KEY,
    ComponentID VARCHAR(50) NOT NULL,
    DependsOnComponentID VARCHAR(50),
    DependsOnLibrary VARCHAR(100), -- 'chart.js', 'fullcalendar', etc.
    LoadOrder INT DEFAULT 1
);


-- 1. Base Layout (loaded once)
INSERT INTO tblSPA_Components (ComponentID, ComponentName, ComponentType, RoutePattern, PreloadJS)
VALUES ('spa-framework-byVu', N'SPA Framework Core', 'layout', '*', 1);

-- 2. Dashboard (hybrid: proc + template)
INSERT INTO tblSPA_Components (ComponentID, ComponentName, ComponentType, StoredProcedure, RoutePattern, MenuID, PreloadJS)
VALUES ('ess-dashboard', N'ESS Dashboard', 'page', '', '/', '', 1);