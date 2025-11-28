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
	DECLARE @appJS NVARCHAR(MAX) = N'';
	DECLARE @mainJS NVARCHAR(MAX) = N'';
    DECLARE @ComponentJS NVARCHAR(MAX) = N'';
    DECLARE @HomeJS NVARCHAR(MAX) = N'';
    DECLARE @pageJS NVARCHAR(MAX) = N'';


	SELECT @BaseHTML = TemplateContent
	FROM tblSPA_Templates
	WHERE ComponentID = 'spa-framework'
		AND TemplateType = 'html'

	SELECT @BaseCSS = '<style>' + CHAR(13) + TemplateContent + CHAR(13) + '</style>'
	FROM tblSPA_Templates
	WHERE ComponentID = 'dashboard'
		AND TemplateType = 'css'

    SELECT @ComponentJS = ISNULL(@ComponentJS, '') +
    ISNULL((
        SELECT CAST('<script>' + TemplateContent + '</script>' AS NVARCHAR(MAX))
        FROM tblSPA_Templates s
		LEFT JOIN tblSPA_Components c ON s.ComponentID = c.ComponentID
        WHERE c.ComponentType = 'widget'
            AND TemplateType = 'js'
		ORDER BY c.Priority
        FOR XML PATH(''), TYPE
    ).value('.', 'NVARCHAR(MAX)'), '')

	SELECT @pageJS = ISNULL(@pageJS, '') +
    ISNULL((
        SELECT CAST('<script>' + TemplateContent + '</script>' AS NVARCHAR(MAX))
        FROM tblSPA_Templates s
		LEFT JOIN tblSPA_Components c ON s.ComponentID = c.ComponentID
        WHERE c.ComponentType = 'page'
            AND TemplateType = 'js'
		ORDER BY c.Priority
        FOR XML PATH(''), TYPE
    ).value('.', 'NVARCHAR(MAX)'), '')

	SELECT @appJS = ISNULL(@appJS, '') +
    ISNULL((
        SELECT CAST('<script>' + TemplateContent + '</script>' AS NVARCHAR(MAX))
        FROM tblSPA_Templates s
        WHERE s.ComponentID IN ('app')
        FOR XML PATH(''), TYPE
    ).value('.', 'NVARCHAR(MAX)'), '')

	SELECT @mainJS = ISNULL(@mainJS, '') +
    ISNULL((
        SELECT CAST('<script>' + TemplateContent + '</script>' AS NVARCHAR(MAX))
        FROM tblSPA_Templates s
        WHERE s.ComponentID IN ('main')
        FOR XML PATH(''), TYPE
    ).value('.', 'NVARCHAR(MAX)'), '')

	SELECT @HomeJS = ISNULL(@HomeJS, '') +
    ISNULL((
        SELECT CAST('<script>' + TemplateContent + '</script>' AS NVARCHAR(MAX))
        FROM tblSPA_Templates s
		LEFT JOIN tblSPA_Components c ON s.ComponentID = c.ComponentID
        WHERE c.ComponentID = 'Home'
            AND TemplateType = 'js'
		ORDER BY c.Priority
        FOR XML PATH(''), TYPE
    ).value('.', 'NVARCHAR(MAX)'), '')

	-- ================================================================
	-- 4. GET PRELOAD COMPONENTS (Dashboard, modals, etc.)
	-- ================================================================
	DECLARE @PreloadComponents NVARCHAR(MAX);

	-- SELECT @PreloadComponents = (
	-- 		SELECT c.ComponentID AS [id],
	-- 			c.RoutePattern AS [route],
	-- 			c.StoredProcedure AS [proc],
	-- 			(
	-- 				SELECT TemplateContent
	-- 				FROM tblSPA_Templates
	-- 				WHERE ComponentID = c.ComponentID
	-- 					AND TemplateType = 'js'
	-- 				) AS [js]
	-- 		FROM tblSPA_Components c
	-- 		WHERE c.PreloadJS = 1
	-- 		FOR JSON PATH
	-- 		);

	-- ================================================================
	-- 5. GET CONFIGURATION
	-- ================================================================
	DECLARE @Config NVARCHAR(MAX);

	-- SELECT @Config = (
	-- 		SELECT ConfigKey AS [key],
	-- 			ConfigValue AS [value],
	-- 			ConfigType AS [type]
	-- 		FROM tblSPA_Config
	-- 		WHERE Category IN ('routing', 'api', 'feature')
	-- 		FOR JSON PATH
	-- 		);

	-- ================================================================
	-- 6. GET TRANSLATIONS (keep current approach)
	-- ================================================================
	DECLARE @Translations NVARCHAR(MAX) = N'';

	-- IF @LanguageID = 'EN'
	-- BEGIN
	-- 	SET @Translations =
	-- 		N'translations = {
    --         "hello": "Hello!",
    --         "dashboard": "Dashboard",
    --         "leave": "Leave",
    --         "ot": "Overtime",
    --         "attendance": "Attendance",
    --         "personal": "Personal"
    --     }'
	-- 		;
	-- END
	-- ELSE
	-- BEGIN
	-- 	SET @Translations =
	-- 		N'translations = {
    --         "hello": "Xin chào!",
    --         "dashboard": "Trang chủ",
    --         "leave": "Nghỉ phép",
    --         "ot": "Tăng ca",
    --         "attendance": "Chấm công",
    --         "personal": "Cá nhân"
    --     }'
	-- 		;
	-- END

	-- ================================================================
	-- 7. INJECT DATA INTO TEMPLATES
	-- ================================================================
	-- SET @BaseJS = REPLACE(@BaseJS, '{{NAVIGATION_DATA}}', ISNULL(@Navigation, '[]'));
	-- SET @BaseJS = REPLACE(@BaseJS, '{{PRELOAD_COMPONENTS}}', ISNULL(@PreloadComponents, '[]'));
	-- SET @BaseJS = REPLACE(@BaseJS, '{{CONFIG_DATA}}', ISNULL(@Config, '{}'));
	-- SET @BaseJS = REPLACE(@BaseJS, '{{TRANSLATIONS}}', @Translations);

	-- ================================================================
	-- 8. RETURN FRAMEWORK
	-- ================================================================
	SELECT ISNULL(@BaseCSS, '') + ISNULL(@BaseHTML, '')  + ISNULL(@ComponentJS, '') + '<script>' + ISNULL(@Navigation, '') + '</script><script>' + ISNULL(@Config, '') + ISNULL(@Translations, '') + '</script>' + ISNULL(@appJS, '')  + ISNULL(@HomeJS, '') + ISNULL(@pageJS, '') + ISNULL(@mainJS, '') AS SPA_byTHIENVU;
END
GO
EXEC sp_SPA_Main