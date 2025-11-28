INSERT INTO tblSPA_Components (ComponentID, ComponentName, ComponentType, StoredProcedure, RoutePattern, MenuID, ParentComponentID, PreloadJS, RequireAuth, CacheMinutes, Priority)
VALUES
    ('ui-components', 'UI Components', 'widget', NULL, NULL, NULL, NULL, 1, 0, 0, 1003),
    ('icons', 'Icons Component', 'widget', NULL, NULL, NULL, NULL, 1, 0, 0, 1002),
    ('app', 'SPA App JS', 'js', NULL, NULL, NULL, NULL, 1, 0, 0, 1000),
    ('main', 'Main JS', 'js', NULL, NULL, NULL, NULL, 1, 0, 0, 1001);

