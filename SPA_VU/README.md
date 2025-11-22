SPA HYBRID FOR PARADISE HXM
Dev: LÊ THIÊN VŨ


KIẾN TRÚC TỔNG QUAN
┌─────────────────────────────────────────────────────────────┐
│                    SQL SERVER LAYER                          │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Core Procs   │  │  Component   │  │ Translation  │      │
│  │ (Framework)  │  │   Tables     │  │    Tables    │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
├─────────────────────────────────────────────────────────────┤
│                   CLIENT LAYER (Browser)                     │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ SPA Router   │  │  Component   │  │    State     │      │
│  │  (app.js)    │  │   Loader     │  │  Management  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘

DATABASE SCHEMA

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

-- ====================================================================
-- INSERT: Core Framework Components
-- ====================================================================

-- 1. Base Layout (loaded once)
INSERT INTO tblSPA_Components (ComponentID, ComponentName, ComponentType, RoutePattern, PreloadJS, IsActive)
VALUES ('spa-framework', N'SPA Framework Core', 'layout', '*', 1, 1);

-- 2. Dashboard (hybrid: proc + template)
INSERT INTO tblSPA_Components (ComponentID, ComponentName, ComponentType, StoredProcedure, RoutePattern, MenuID, PreloadJS, IsActive)
VALUES ('dashboard', N'Dashboard', 'page', 'sp_DashBoard_Real', '/', 'MnuHRS2000', 1, 1);


GO

CORE STORED PROCEDURES
-- ====================================================================
-- PROC: sp_SPA_LoadFramework
-- PURPOSE: Load initial SPA framework (one-time load)
-- ====================================================================

IF OBJECT_ID('sp_SPA_LoadFramework') IS NOT NULL DROP PROCEDURE sp_SPA_LoadFramework
GO

CREATE PROCEDURE sp_SPA_LoadFramework
    @LoginID INT,
    @LanguageID VARCHAR(3) = 'VN',
    @IsWeb INT = 2
AS
BEGIN
    SET NOCOUNT ON;
    
    -- ================================================================
    -- 1. GET USER PERMISSIONS
    -- ================================================================
    CREATE TABLE #UserPermissions (
        ObjectID INT,
        ObjectName NVARCHAR(200),
        FullAccess INT
    );
    
    EXEC SC_LoadFullRightObject @LoginID, '#UserPermissions';
    
    -- ================================================================
    -- 2. BUILD NAVIGATION MENU (JSON)
    -- ================================================================
    DECLARE @Navigation NVARCHAR(MAX);
    
    SELECT @Navigation = (
        SELECT 
            c.ComponentID AS id,
            c.RoutePattern AS path,
            ISNULL(msg.Content, c.ComponentName) AS name,
            m.IconClass AS icon,
            c.MenuID AS menuId,
            CASE WHEN p.FullAccess > 0 THEN 1 ELSE 0 END AS canView,
            CASE WHEN p.FullAccess > 1 THEN 1 ELSE 0 END AS canEdit,
            c.PreloadJS AS preload
        FROM tblSPA_Components c
        LEFT JOIN MEN_Menu m ON c.MenuID = m.MenuID
        LEFT JOIN tblMD_Message msg ON msg.MessageID = c.MenuID AND msg.Language = @LanguageID
        LEFT JOIN tblSC_Object o ON m.AssemblyName + '.' + m.ClassName = o.ObjectName
        LEFT JOIN #UserPermissions p ON p.ObjectID = o.ObjectID
        WHERE c.ComponentType = 'page'
          AND c.IsActive = 1
          AND c.ParentComponentID IS NULL
          AND (p.FullAccess > 0 OR c.RequireAuth = 0)
          AND ISNULL(m.NotUsePlatform, '') NOT LIKE '%' + CAST(@IsWeb AS VARCHAR(5)) + '%'
        ORDER BY c.Priority
        FOR JSON PATH
    );
    
    -- ================================================================
    -- 3. GET FRAMEWORK BASE TEMPLATES
    -- ================================================================
    DECLARE @BaseHTML NVARCHAR(MAX) = N'';
    DECLARE @BaseCSS NVARCHAR(MAX) = N'';
    DECLARE @BaseJS NVARCHAR(MAX) = N'';
    
    SELECT @BaseHTML = TemplateContent
    FROM tblSPA_Templates
    WHERE ComponentID = 'spa-framework' 
      AND TemplateType = 'html'
      AND IsActive = 1;
    
    SELECT @BaseCSS = TemplateContent
    FROM tblSPA_Templates
    WHERE ComponentID = 'spa-framework' 
      AND TemplateType = 'css'
      AND IsActive = 1;
    
    SELECT @BaseJS = TemplateContent
    FROM tblSPA_Templates
    WHERE ComponentID = 'spa-framework' 
      AND TemplateType = 'js'
      AND IsActive = 1;
    
    -- ================================================================
    -- 4. GET PRELOAD COMPONENTS (Dashboard, modals, etc.)
    -- ================================================================
    DECLARE @PreloadComponents NVARCHAR(MAX);
    
    SELECT @PreloadComponents = (
        SELECT 
            c.ComponentID AS id,
            c.RoutePattern AS route,
            c.StoredProcedure AS proc,
            (SELECT TemplateContent FROM tblSPA_Templates WHERE ComponentID = c.ComponentID AND TemplateType = 'js' AND IsActive = 1) AS js
        FROM tblSPA_Components c
        WHERE c.PreloadJS = 1 
          AND c.IsActive = 1
        FOR JSON PATH
    );
    
    -- ================================================================
    -- 5. GET CONFIGURATION
    -- ================================================================
    DECLARE @Config NVARCHAR(MAX);
    
    SELECT @Config = (
        SELECT ConfigKey AS [key], ConfigValue AS value, ConfigType AS type
        FROM tblSPA_Config
        WHERE IsActive = 1 AND Category IN ('routing', 'api', 'feature')
        FOR JSON PATH
    );
    
    -- ================================================================
    -- 6. GET TRANSLATIONS (keep current approach)
    -- ================================================================
    DECLARE @Translations NVARCHAR(MAX) = N'';
    
    IF @LanguageID = 'EN'
    BEGIN
        SET @Translations = N'{
            "hello": "Hello!",
            "dashboard": "Dashboard",
            "leave": "Leave",
            "ot": "Overtime",
            "attendance": "Attendance",
            "personal": "Personal"
        }';
    END
    ELSE
    BEGIN
        SET @Translations = N'{
            "hello": "Xin chào!",
            "dashboard": "Trang chủ",
            "leave": "Nghỉ phép",
            "ot": "Tăng ca",
            "attendance": "Chấm công",
            "personal": "Cá nhân"
        }';
    END
    
    -- ================================================================
    -- 7. INJECT DATA INTO TEMPLATES
    -- ================================================================
    SET @BaseJS = REPLACE(@BaseJS, '{{NAVIGATION_DATA}}', ISNULL(@Navigation, '[]'));
    SET @BaseJS = REPLACE(@BaseJS, '{{PRELOAD_COMPONENTS}}', ISNULL(@PreloadComponents, '[]'));
    SET @BaseJS = REPLACE(@BaseJS, '{{CONFIG_DATA}}', ISNULL(@Config, '{}'));
    SET @BaseJS = REPLACE(@BaseJS, '{{TRANSLATIONS}}', @Translations);
    
    -- ================================================================
    -- 8. RETURN FRAMEWORK
    -- ================================================================
    SELECT 
        @BaseCSS AS CSS,
        @BaseHTML AS HTML,
        @BaseJS AS JavaScript,
        @Navigation AS NavigationJSON,
        @Config AS ConfigJSON,
        @Translations AS TranslationsJSON;
        
    DROP TABLE #UserPermissions;
END
GO