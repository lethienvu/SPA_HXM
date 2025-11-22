USE Paradise_TRIPOD
GO
if object_id('[dbo].[sp_SPA_LoadComponent]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_SPA_LoadComponent] as select 1')
GO

ALTER PROCEDURE [dbo].[sp_SPA_LoadComponent]
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
    -- CREATE TABLE #Permission (FullAccess INT);
    -- INSERT INTO #Permission
    -- EXEC SC_LoadFullRightObject @LoginID = @LoginID, @MenuID = @MenuID;

    -- IF NOT EXISTS (SELECT 1 FROM #Permission WHERE FullAccess > 0)
    -- BEGIN
    --     SELECT 'error' AS status, 'Access denied' AS message;
    --     RETURN;
    -- END

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
END
GO