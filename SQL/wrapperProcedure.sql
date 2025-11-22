-- ====================================================================
-- PROC: sp_SPA_Main (Replaces sp_DashBoard)
-- PURPOSE: Main entry point - decides framework vs component load
-- ====================================================================

IF OBJECT_ID('sp_SPA_Main') IS NOT NULL DROP PROCEDURE sp_SPA_Main
GO



CREATE PROCEDURE sp_SPA_Main
    @LoginID INT = 3,
    @LoadType VARCHAR(20) = 'framework', -- 'framework' or 'component'
    @ComponentID VARCHAR(50) = NULL,
    @RouteParams NVARCHAR(MAX) = NULL,
    @LanguageID VARCHAR(3) = 'VN',
    @IsWeb INT = 2
AS
BEGIN
    SET NOCOUNT ON;
    
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

-- ====================================================================
-- HELPER: Register component shortcut
-- ====================================================================

IF OBJECT_ID('sp_SPA_RegisterComponent') IS NOT NULL DROP PROCEDURE sp_SPA_RegisterComponent
GO

CREATE PROCEDURE sp_SPA_RegisterComponent
    @ComponentID VARCHAR(50),
    @ComponentName NVARCHAR(200),
    @RoutePattern NVARCHAR(200),
    @MenuID VARCHAR(20) = NULL,
    @StoredProcedure VARCHAR(100) = NULL,
    @HTMLTemplate NVARCHAR(MAX) = NULL,
    @CSSTemplate NVARCHAR(MAX) = NULL,
    @JSTemplate NVARCHAR(MAX) = NULL,
    @ComponentType VARCHAR(20) = 'page',
    @PreloadJS BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Insert/Update component
    IF EXISTS (SELECT 1 FROM tblSPA_Components WHERE ComponentID = @ComponentID)
    BEGIN
        UPDATE tblSPA_Components
        SET ComponentName = @ComponentName,
            RoutePattern = @RoutePattern,
            MenuID = @MenuID,
            StoredProcedure = @StoredProcedure,
            ComponentType = @ComponentType,
            PreloadJS = @PreloadJS
        WHERE ComponentID = @ComponentID;
    END
    ELSE
    BEGIN
        INSERT INTO tblSPA_Components (
            ComponentID, ComponentName, ComponentType, RoutePattern, 
            MenuID, StoredProcedure, PreloadJS
        )
        VALUES (
            @ComponentID, @ComponentName, @ComponentType, @RoutePattern,
            @MenuID, @StoredProcedure, @PreloadJS
        );
    END
    
    -- Insert templates
    IF @HTMLTemplate IS NOT NULL
    BEGIN
        DELETE FROM tblSPA_Templates WHERE ComponentID = @ComponentID AND TemplateType = 'html';
        INSERT INTO tblSPA_Templates (ComponentID, TemplateType, TemplateContent)
        VALUES (@ComponentID, 'html', @HTMLTemplate);
    END
    
    IF @CSSTemplate IS NOT NULL
    BEGIN
        DELETE FROM tblSPA_Templates WHERE ComponentID = @ComponentID AND TemplateType = 'css';
        INSERT INTO tblSPA_Templates (ComponentID, TemplateType, TemplateContent)
        VALUES (@ComponentID, 'css', @CSSTemplate);
    END
    
    IF @JSTemplate IS NOT NULL
    BEGIN
        DELETE FROM tblSPA_Templates WHERE ComponentID = @ComponentID AND TemplateType = 'js';
        INSERT INTO tblSPA_Templates (ComponentID, TemplateType, TemplateContent)
        VALUES (@ComponentID, 'js', @JSTemplate);
    END
    
    SELECT 'success' AS status, 'Component registered successfully' AS message;
END
GO