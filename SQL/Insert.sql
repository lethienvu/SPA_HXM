SELECT CASE WHEN t.ComponentID IS NULL OR s.ComponentID IS NULL THEN '-' ELSE t.ComponentID END, t.ComponentID, s.ComponentName, s.ComponentType, t.TemplateContent, t.[Version], s.Priority FROM tblSPA_Components s left join tblSPA_Templates t on s.ComponentID = t.ComponentID ORDER BY s.Priority

SELECT * 
FROM tblSPA_Templates s
		LEFT JOIN tblSPA_Components c ON s.ComponentID = c.ComponentID
        WHERE c.ComponentType = 'widget'
            AND TemplateType = 'js'
		ORDER BY c.Priority





