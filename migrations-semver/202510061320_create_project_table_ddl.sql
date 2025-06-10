CREATE TABLE [dbo].[Project] (
    [ProjectId] INT IDENTITY(1,1) PRIMARY KEY,
    [Name] NVARCHAR(100) NOT NULL,
    [Description] NVARCHAR(500) NULL,
    [StartDate] DATE NOT NULL,
    [EndDate] DATE NULL,
    [Status] NVARCHAR(50) NOT NULL DEFAULT 'New',
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETDATE(),
    [UpdatedAt] DATETIME2 NULL
);
