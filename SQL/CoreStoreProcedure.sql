-- ====================================================================
-- PROC: sp_SPA_LoadFramework
-- PURPOSE: Load initial SPA framework (one-time load)
-- ====================================================================
IF OBJECT_ID('sp_SPA_LoadFramework') IS NOT NULL
	DROP PROCEDURE sp_SPA_LoadFramework
GO

CREATE PROCEDURE sp_SPA_LoadFramework @LoginID INT,
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

	EXEC SC_LoadFullRightObject @LoginID,
		'#UserPermissions';

	-- ================================================================
	-- 2. BUILD NAVIGATION MENU (JSON)
	-- ================================================================
	DECLARE @Navigation NVARCHAR(MAX);

	SELECT @Navigation = (
			SELECT c.ComponentID AS id,
				c.RoutePattern AS path,
				ISNULL(msg.Content, c.ComponentName) AS name,
				m.IconClass AS icon,
				c.MenuID AS menuId,
				CASE 
					WHEN p.FullAccess > 0
						THEN 1
					ELSE 0
					END AS canView,
				CASE 
					WHEN p.FullAccess > 1
						THEN 1
					ELSE 0
					END AS canEdit,
				c.PreloadJS AS preload
			FROM tblSPA_Components c
			LEFT JOIN MEN_Menu m
				ON c.MenuID = m.MenuID
			LEFT JOIN tblMD_Message msg
				ON msg.MessageID = c.MenuID
					AND msg.LANGUAGE = @LanguageID
			LEFT JOIN tblSC_Object o
				ON m.AssemblyName + '.' + m.ClassName = o.ObjectName
			LEFT JOIN #UserPermissions p
				ON p.ObjectID = o.ObjectID
			WHERE c.ComponentType = 'page'
				AND c.ParentComponentID IS NULL
				AND (
					p.FullAccess > 0
					OR c.RequireAuth = 0
					)
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

	SELECT @BaseCSS = TemplateContent
	FROM tblSPA_Templates
	WHERE ComponentID = 'spa-framework'
		AND TemplateType = 'css'

	SELECT @BaseJS = TemplateContent
	FROM tblSPA_Templates
	WHERE ComponentID = 'spa-framework'
		AND TemplateType = 'js'

	-- ================================================================
	-- 4. GET PRELOAD COMPONENTS (Dashboard, modals, etc.)
	-- ================================================================
	DECLARE @PreloadComponents NVARCHAR(MAX);

	SELECT @PreloadComponents = (
			SELECT c.ComponentID AS [id],
				c.RoutePattern AS [route],
				c.StoredProcedure AS [proc],
				(
					SELECT TemplateContent
					FROM tblSPA_Templates
					WHERE ComponentID = c.ComponentID
						AND TemplateType = 'js'
					) AS [js]
			FROM tblSPA_Components c
			WHERE c.PreloadJS = 1
			FOR JSON PATH
			);

	-- ================================================================
	-- 5. GET CONFIGURATION
	-- ================================================================
	DECLARE @Config NVARCHAR(MAX);

	SELECT @Config = (
			SELECT ConfigKey AS [key],
				ConfigValue AS [value],
				ConfigType AS [type]
			FROM tblSPA_Config
			WHERE Category IN ('routing', 'api', 'feature')
			FOR JSON PATH
			);

	-- ================================================================
	-- 6. GET TRANSLATIONS (keep current approach)
	-- ================================================================
	DECLARE @Translations NVARCHAR(MAX) = N'';

	IF @LanguageID = 'EN'
	BEGIN
		SET @Translations = 
			N'{
            "hello": "Hello!",
            "dashboard": "Dashboard",
            "leave": "Leave",
            "ot": "Overtime",
            "attendance": "Attendance",
            "personal": "Personal"
        }'
			;
	END
	ELSE
	BEGIN
		SET @Translations = 
			N'{
            "hello": "Xin chào!",
            "dashboard": "Trang chủ",
            "leave": "Nghỉ phép",
            "ot": "Tăng ca",
            "attendance": "Chấm công",
            "personal": "Cá nhân"
        }'
			;
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
	SELECT ISNULL(@BaseCSS, '') + ISNULL(@BaseHTML, '') + ISNULL(@BaseJS, '') + ISNULL(@Navigation, '') + ISNULL(@Config, '') + ISNULL(@Translations, '') AS SPA_byTHIENVU;

	DROP TABLE #UserPermissions;
END
GO

-- ====================================================================
-- PROC: sp_SPA_LoadComponent
-- PURPOSE: Lazy load a specific component (called by client-side router)
-- ====================================================================

IF OBJECT_ID('sp_SPA_LoadComponent') IS NOT NULL DROP PROCEDURE sp_SPA_LoadComponent
GO

CREATE PROCEDURE sp_SPA_LoadComponent
    @ComponentID VARCHAR(50),
    @LoginID INT,
    @RouteParams NVARCHAR(MAX) = NULL, -- JSON: {"id": "123", "type": "annual"}
    @LanguageID VARCHAR(3) = 'VN'
AS
BEGIN
    SET NOCOUNT ON;
    
    -- ================================================================
    -- 1. VALIDATE COMPONENT EXISTS AND USER HAS ACCESS
    -- ================================================================
    DECLARE @MenuID VARCHAR(20);
    DECLARE @StoredProcedure VARCHAR(100);
    
    SELECT 
        @MenuID = MenuID,
        @StoredProcedure = StoredProcedure
    FROM tblSPA_Components
    WHERE ComponentID = @ComponentID
    
    IF @MenuID IS NULL
    BEGIN
        SELECT 'error' AS status, 'Component not found' AS message;
        RETURN;
    END
    
    -- Check permissions
    CREATE TABLE #Permission (FullAccess INT);
    INSERT INTO #Permission
    EXEC SC_LoadFullRightObject @LoginID, @MenuID;
    
    IF NOT EXISTS (SELECT 1 FROM #Permission WHERE FullAccess > 0)
    BEGIN
        SELECT 'error' AS status, 'Access denied' AS message;
        RETURN;
    END
    
    -- ================================================================
    -- 2. PARSE ROUTE PARAMS
    -- ================================================================
    DECLARE @ID VARCHAR(36) = NULL;
    DECLARE @Type VARCHAR(50) = NULL;
    
    IF @RouteParams IS NOT NULL
    BEGIN
        SELECT @ID = JSON_VALUE(@RouteParams, '$.id');
        SELECT @Type = JSON_VALUE(@RouteParams, '$.type');
    END
    
    -- ================================================================
    -- 3. LOAD COMPONENT (Hybrid approach)
    -- ================================================================
    DECLARE @HTML NVARCHAR(MAX) = N'';
    DECLARE @CSS NVARCHAR(MAX) = N'';
    DECLARE @JS NVARCHAR(MAX) = N'';
    DECLARE @Data NVARCHAR(MAX) = NULL;
    
    -- A. If component has stored procedure → call it for data
    IF @StoredProcedure IS NOT NULL
    BEGIN
        DECLARE @SQL NVARCHAR(MAX);
        CREATE TABLE #ProcResult (DataJSON NVARCHAR(MAX));
        
        SET @SQL = N'INSERT INTO #ProcResult EXEC ' + @StoredProcedure + 
                   N' @LoginID, @LanguageID, @ID';
        
        EXEC sp_executesql @SQL, 
            N'@LoginID INT, @LanguageID VARCHAR(3), @ID VARCHAR(36)',
            @LoginID, @LanguageID, @ID;
        
        SELECT @Data = DataJSON FROM #ProcResult;
        DROP TABLE #ProcResult;
    END
    
    -- B. Load templates from table
    SELECT @HTML = TemplateContent
    FROM tblSPA_Templates
    WHERE ComponentID = @ComponentID 
      AND TemplateType = 'html'
    
    SELECT @CSS = TemplateContent
    FROM tblSPA_Templates
    WHERE ComponentID = @ComponentID 
      AND TemplateType = 'css'
    
    SELECT @JS = TemplateContent
    FROM tblSPA_Templates
    WHERE ComponentID = @ComponentID 
      AND TemplateType = 'js'
    
    -- ================================================================
    -- 4. RETURN COMPONENT BUNDLE
    -- ================================================================
    SELECT 
        'success' AS status,
        @ComponentID AS componentId,
        @HTML AS html,
        @CSS AS css,
        @JS AS js,
        @Data AS data;
        
    DROP TABLE #Permission;
END
GO


