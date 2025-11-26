USE Paradise_TRIPOD
GO
if object_id('[dbo].[sp_SPA_Main]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_SPA_Main] as select 1')
GO

ALTER PROCEDURE [dbo].[sp_SPA_Main]
    @LoginID INT = 3,
    @LoadType VARCHAR(20) = 'framework', -- 'framework' or 'component'
    @ComponentID VARCHAR(50) = NULL,
    @RouteParams NVARCHAR(MAX) = NULL,
    @LanguageID VARCHAR(3) = 'VN',
    @IsWeb INT = 2
AS
BEGIN
    SET NOCOUNT ON;

    IF(ISNULL(@LoadType, '') = '')
    BEGIN
        SET @LoadType = 'framework'
    END

    IF @LoadType = 'framework'
    BEGIN
        -- Load entire SPA framework (first load)
        EXEC sp_SPA_LoadFramework
            @LoginID = @LoginID,
            @LanguageID = @LanguageID,
            @IsWeb = @IsWeb;
    END
    ELSE IF @LoadType = 'component'
    BEGIN
        -- Lazy load specific component
        EXEC sp_SPA_LoadComponent
            @ComponentID = @ComponentID,
            @LoginID = @LoginID,
            @RouteParams = @RouteParams,
            @LanguageID = @LanguageID;
    END
    ELSE
    BEGIN
        SELECT 'error' AS status, 'Invalid LoadType' AS message;
    END
END
GO

exec sp_SPA_Main

USE Paradise_TRIPOD
GO
if object_id('[dbo].[sp_SPA_LoadFramework]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_SPA_LoadFramework] as select 1')
GO

ALTER PROCEDURE [dbo].[sp_SPA_LoadFramework]@LoginID INT,
	@LanguageID VARCHAR(3) = 'VN',
	@IsWeb INT = 2
AS
BEGIN
	SET NOCOUNT ON;

	-- ================================================================
	-- 1. GET USER PERMISSIONS
	-- ================================================================
	-- CREATE TABLE #UserPermissions (
	-- 	ObjectID INT,
	-- 	ObjectName NVARCHAR(200),
	-- 	FullAccess INT
	-- 	);

	-- EXEC SC_LoadFullRightObject @LoginID,
	-- 	'#UserPermissions';

	-- ================================================================
	-- 2. BUILD NAVIGATION MENU (JSON)
	-- ================================================================
	DECLARE @Navigation NVARCHAR(MAX);

	SELECT @Navigation = (
			SELECT c.ComponentID AS id,
				c.RoutePattern AS path,
				ISNULL(msg.Content, c.ComponentName) AS name,
				c.MenuID AS menuId,
				-- CASE
				-- 	WHEN p.FullAccess > 0
				-- 		THEN 1
				-- 	ELSE 0
				-- 	END AS canView,
                   1 AS canView,
				-- CASE
				-- 	WHEN p.FullAccess > 1
				-- 		THEN 1
				-- 	ELSE 0
				-- 	END AS canEdit,
                    			1 AS canEdit,
				c.PreloadJS AS preload
			FROM tblSPA_Components c
			LEFT JOIN MEN_Menu m
				ON c.MenuID = m.MenuID
			LEFT JOIN tblMD_Message msg
				ON msg.MessageID = c.MenuID
					AND msg.LANGUAGE = @LanguageID
			LEFT JOIN tblSC_Object o
				ON m.AssemblyName + '.' + m.ClassName = o.ObjectName
			WHERE c.ComponentType = 'page'
				AND c.ParentComponentID IS NULL
				-- AND (
				-- 	p.FullAccess > 0
				-- 	OR c.RequireAuth = 0
				-- 	)
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
    DECLARE @ComponentJS NVARCHAR(MAX) = N'';

	SELECT @BaseHTML = TemplateContent
	FROM tblSPA_Templates
	WHERE ComponentID = 'dashboard'
		AND TemplateType = 'html'

	SELECT @BaseCSS = TemplateContent
	FROM tblSPA_Templates
	WHERE ComponentID = 'dashboard'
		AND TemplateType = 'css'

	SELECT @BaseJS = TemplateContent
	FROM tblSPA_Templates
	WHERE ComponentID = 'dashboard'
		AND TemplateType = 'js'

        SELECT @ComponentJS += '<script>' + TemplateContent + '</script>'
	FROM tblSPA_Templates
	WHERE ComponentID = 'app'
		AND TemplateType = 'js'


    SELECT @ComponentJS += '<script>' + TemplateContent + '</script>'
	FROM tblSPA_Templates
	WHERE ComponentID = 'ui-components'
		AND TemplateType = 'js'

    SELECT @ComponentJS = '<script>' + TemplateContent + '</script>'
	FROM tblSPA_Templates
	WHERE ComponentID = 'modal'
		AND TemplateType = 'js'

     SELECT @ComponentJS += '<script>' + TemplateContent + '</script>'
	FROM tblSPA_Templates
	WHERE ComponentID = 'toast'
		AND TemplateType = 'js'

    SELECT @ComponentJS += '<script>' + TemplateContent + '</script>'
	FROM tblSPA_Templates
	WHERE ComponentID = 'alert'
		AND TemplateType = 'js'

    SELECT @ComponentJS += '<script>' + TemplateContent + '</script>'
	FROM tblSPA_Templates
	WHERE ComponentID = 'loading'
		AND TemplateType = 'js'

    SELECT @ComponentJS += '<script type="module">' + TemplateContent + '</script>'
	FROM tblSPA_Templates
	WHERE ComponentID = 'main'
		AND TemplateType = 'js'

    SELECT @ComponentJS += '<script type="module">' + TemplateContent + '</script>'
	FROM tblSPA_Templates
	WHERE ComponentID = 'icons'
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
			N'translations = {
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
			N'translations = {
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
	SELECT '<style>' +ISNULL(@BaseCSS, '') + '</style>' + ISNULL(@BaseHTML, '') + ISNULL(@ComponentJS, '') + '</script><script>' + ISNULL(@Navigation, '') + '</script><script>' + ISNULL(@Config, '') + ISNULL(@Translations, '') + '</script><script>' + ISNULL(@BaseJS, '') + '</script>' AS SPA_byTHIENVU;
END
GO

