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
exec sp_spa_main @LoginID=3,@LoadType=NULL,@ComponentID=NULL,@RouteParams=NULL,@LanguageID='VN',@IsWeb=1