IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.Project') AND name = 'isStarted')
BEGIN
    ALTER TABLE dbo.Project ADD isStarted BIT NOT NULL DEFAULT 0;
END