USE Paradise_TRIPOD
GO
if object_id('[dbo].[sp_Menu_LoadSimpleUI]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_Menu_LoadSimpleUI] as select 1')
GO

-- sp_Menu_LoadSimpleUI'VN',3
ALTER PROCEDURE [dbo].[sp_Menu_LoadSimpleUI] (@LanguageID CHAR(2) = 'EN', @LoginID INT = 3, @isWeb INT = 0)
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @StopUpdate BIT = 0

CREATE TABLE #tmpDataRight (FullAccess VARCHAR(50), ObjectName NVARCHAR(200), LoginID INT, ObjectID INT)

INSERT INTO #tmpDataRight (LoginID, ObjectID, FullAccess)
EXEC sp_SC_Right @LoginID

--
SELECT m.ParentMenuID, m.MenuID, isnull(msg.Content, m.MenuID + ':' + @LanguageID) Name, --
	CASE
		WHEN ISNULL(m.AssemblyName, '') IN ('', 'HPA')
			THEN 'DiagramForm'
		ELSE ClassName
		END ClassName, CASE
		WHEN ISNULL(m.AssemblyName, '') IN ('', 'HPA')
			THEN 'HPA.MasterData'
		ELSE AssemblyName
		END AssemblyName, --
	m.Priority, isnull(m.IsVisible, 0) IsVisible, m.glyphicon, m.NotUsePlatform
INTO #tmp_Menu
FROM MEN_Menu m
LEFT JOIN tblMD_Message msg ON msg.MessageID = m.MenuID AND msg.LANGUAGE = @LanguageID
WHERE (m.ParentMenuID = 'Mnu' OR (isnull(m.AssemblyName, '') = '' AND isnull(m.ClassName, '') = '')) OR MenuID = 'MnuPRL9999'

--la group
SELECT m.MenuID, isnull(isnull(msg.Content, msgvn.Content), m.MenuID + ':' + @LanguageID) Name, --
	dbo.fn_RemoveToneMark(isnull(msg.Content, msgvn.Content)) Content, isnull(m.ClassName, '') ClassName, m.Priority, m.ParentMenuID, --
	isnull(m.AssemblyName, '') AssemblyName, m.IsModal, m.IsCollapsed, m.ShortcutKeys, m.IsVisible, isnull(O.FullAccess, '0') FullAccess, --
	m.SupperAdmin, m.LargeTile, m.Colors, m.Notification, m.IsNotAjax, m.glyphicon, -- used for web
	m.GroupID, m.InstructionID
INTO #MenuList
FROM MEN_Menu m
LEFT JOIN (
	SELECT O.ObjectName, FullAccess
	FROM tblSC_Object O
	LEFT JOIN #tmpDataRight R ON O.ObjectID = R.ObjectID AND R.LoginID = @LoginID
	GROUP BY O.ObjectName, FullAccess
	) O ON O.ObjectName = m.AssemblyName + '.' + m.ClassName
LEFT JOIN tblMD_Message msg ON msg.MessageID = m.MenuID AND msg.LANGUAGE = @LanguageID
LEFT JOIN tblMD_Message msgvn ON msgvn.MessageID = m.MenuID AND msgvn.LANGUAGE = 'VN'
WHERE (len(isnull(m.superForm, '')) = 0)

-- hiển thị cha con theo Diagram menu
UPDATE m
SET ParentMenuID = w.ParentMenuID
FROM tblWorkFlow w
INNER JOIN #MenuList m ON w.CurrentMenuID = m.MenuID

-- phân quyền theo nhóm
UPDATE m
SET FullAccess = isnull(tmp.FullAccess, '0')
FROM #MenuList m
INNER JOIN (
	SELECT o.ObjectName, rg.FullAccess
	FROM tblUserGrantGroup ug
	INNER JOIN tblSC_GroupRight rg ON ug.UserGroupID = rg.UserGroupID AND ug.UserID = @LoginID AND isnull(rg.FullAccess, '0') <> '0'
	INNER JOIN tblSC_Object o ON rg.ObjectID = o.ObjectID
	LEFT JOIN #tmpDataRight tdr ON tdr.LoginID = @LoginID AND tdr.ObjectID = o.ObjectID
	WHERE tdr.ObjectID IS NULL
	) tmp ON m.AssemblyName + '.' + m.ClassName = tmp.ObjectName

-- phân quyền theo nhóm
UPDATE #MenuList
SET FullAccess = isnull(tmp.FullAccess, '0')
FROM #MenuList
INNER JOIN (
	SELECT o.ObjectName, rg.FullAccess
	FROM tblUserGrantGroup ug
	INNER JOIN tblSC_GroupRight rg ON ug.UserGroupID = rg.UserGroupID AND ug.UserID = @LoginID
	INNER JOIN tblSC_Object o ON rg.ObjectID = o.ObjectID
	) tmp ON #MenuList.AssemblyName + '.' + #MenuList.ClassName = tmp.ObjectName AND #MenuList.FullAccess = '8'

UPDATE #MenuList
SET FullAccess = '0'
WHERE FullAccess = '8'

UPDATE m
SET FullAccess = '32'
FROM #MenuList m
LEFT JOIN (
	SELECT ParentMenuID MenuID
	FROM #MenuList
	WHERE FullAccess <> '0'
	) m2 ON m2.MenuID = m.MenuID
WHERE m2.MenuID IS NOT NULL OR m.ParentMenuID = 'Mnu'

UPDATE m
SET IsVisible = 0
FROM #MenuList m
INNER JOIN (
	SELECT MenuID
	FROM #MenuList
	WHERE ParentMenuID = 'Mnu'
	
	EXCEPT
	
	(
		SELECT ParentMenuID
		FROM #MenuList
		WHERE ClassName <> 'OK' AND ParentMenuID <> 'Mnu' AND IsVisible = 1 AND FullAccess <> '0'
		GROUP BY ParentMenuID
		
		UNION
		
		SELECT MenuID
		FROM #MenuList
		WHERE ParentMenuID = 'Mnu' AND AssemblyName NOT IN ('', 'HPA')
		)
	) m2 ON m2.MenuID = m.MenuID



DELETE m
FROM #MenuList m
LEFT JOIN (
	SELECT MenuID ParentMenuID
	FROM MEN_Menu
	WHERE IsVisible = '0'
	GROUP BY MenuID
	) m2 ON m2.ParentMenuID = m.ParentMenuID
WHERE m2.ParentMenuID IS NOT NULL OR m.FullAccess = '0' OR (m.SupperAdmin = 1 AND @LoginID NOT IN (3, 8)) OR (m.ClassName = 'OK' OR m.IsVisible <> 1)

-- danh cho menu moi
DECLARE @MaxCount INT, @MinCount INT

SELECT MappedItem, count(MappedItem) MappedCount, cast(0 AS BIT) LargeTile
INTO #MenuListmpData
FROM tblSearchHistory
GROUP BY MappedItem

SET @MaxCount = (
		SELECT max(MappedCount)
		FROM #MenuListmpData
		)
SET @MinCount = (
		SELECT min(MappedCount)
		FROM #MenuListmpData
		)

UPDATE #MenuListmpData
SET LargeTile = 1
WHERE MappedCount > (@MaxCount + @MinCount) / 2

UPDATE #MenuList
SET LargeTile = tmp.LargeTile
FROM #MenuList t
INNER JOIN #MenuListmpData tmp ON t.MenuID = tmp.MappedItem AND t.LargeTile IS NULL

UPDATE m
SET m.IsVisible = 0
FROM #tmp_Menu m
WHERE m.ClassName = 'DiagramForm'

UPDATE m
SET m.IsVisible = 1
FROM #tmp_Menu m
INNER JOIN #MenuList mn ON mn.ParentMenuID = m.MenuID AND mn.IsVisible = 1 AND mn.FullAccess <> '0'
WHERE m.MenuID NOT IN ('MnuMDT000') AND m.ParentMenuID = 'Mnu' AND EXISTS (
		SELECT 1
		FROM tblWorkFlow w
		WHERE w.CurrentMenuID = mn.MenuID AND w.ParentMenuID = m.MenuID
		)

IF EXISTS (
		SELECT *
		FROM tblParameter
		WHERE Code = 'DisableHomeMenu' AND Value = '1'
		)
	DELETE #tmp_Menu
	WHERE MenuID = 'MnuHOME000'

UPDATE #tmp_Menu
SET IsVisible = 0
WHERE MenuID IN ('MnuEXT000')

IF EXISTS (
		SELECT 1
		FROM #MenuList mn
		WHERE mn.MenuID = 'MnuMDT010' AND mn.IsVisible = 1 AND mn.FullAccess > 0
		)
	UPDATE #tmp_Menu
	SET IsVisible = 1
	WHERE MenuID = 'MnuHOME000'

IF isnull((
			SELECT count(1)
			FROM #tmp_Menu
			WHERE ParentMenuID = 'Mnu' AND IsVisible = 1
			), 0) < 2
	UPDATE #tmp_Menu
	SET glyphicon = 'Home'
	WHERE MenuID = 'MnuWPT000'

UPDATE #tmp_Menu
SET IsVisible = 0
WHERE MenuID IN ('MnuSID000')

UPDATE t
SET IsVisible = 0
FROM #tmp_Menu t
CROSS APPLY dbo.SplitString(t.NotUsePlatform, '&') tt
WHERE dbo.TRIM(isnull(nullif(tt.Items, ''), '-1')) = @isWeb

IF (isnull(@isWeb, 0) <> 0)
BEGIN
	UPDATE #tmp_Menu
	SET IsVisible = 0

	UPDATE #tmp_Menu
	SET IsVisible = 1
	WHERE MenuID = 'MnuHRS2000'
END
ELSE
BEGIN
	UPDATE #tmp_Menu
	SET IsVisible = 0
	WHERE MenuID = 'MnuHRS2000'
END

IF object_id('sp_Menu_LoadSimpleUI_PortalView') IS NULL
	EXEC ('CREATE PROCEDURE dbo.sp_Menu_LoadSimpleUI_PortalView @StopUpdate bit output, @LoginID int, @IsWeb bit as')

SET @StopUpdate = 0

EXEC dbo.sp_Menu_LoadSimpleUI_PortalView @StopUpdate OUTPUT, @LoginID, @isWeb

IF @StopUpdate = 0
	SELECT m.*
	FROM #tmp_Menu m
	ORDER BY m.IsVisible DESC, m.Priority
GO