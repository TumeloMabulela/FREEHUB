-- =============================================
-- FreeHUB Database Schema Updates
-- Run this script against FreeHubDB
-- =============================================

-- Add new columns to User table for profile enhancements
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[User]') AND name = 'bio')
    ALTER TABLE [dbo].[User] ADD bio NVARCHAR(500) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[User]') AND name = 'location')
    ALTER TABLE [dbo].[User] ADD location NVARCHAR(100) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[User]') AND name = 'preferredLanguage')
    ALTER TABLE [dbo].[User] ADD preferredLanguage NVARCHAR(50) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[User]') AND name = 'profilePicture')
    ALTER TABLE [dbo].[User] ADD profilePicture NVARCHAR(255) NULL;

-- Add email verification columns
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[User]') AND name = 'emailVerified')
    ALTER TABLE [dbo].[User] ADD emailVerified BIT NOT NULL DEFAULT 0;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[User]') AND name = 'verificationToken')
    ALTER TABLE [dbo].[User] ADD verificationToken NVARCHAR(100) NULL;

-- Add password reset columns
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[User]') AND name = 'resetToken')
    ALTER TABLE [dbo].[User] ADD resetToken NVARCHAR(100) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[User]') AND name = 'resetTokenExpiry')
    ALTER TABLE [dbo].[User] ADD resetTokenExpiry DATETIME NULL;

-- Set existing users as verified (so they aren't locked out)
UPDATE [dbo].[User] SET emailVerified = 1 WHERE emailVerified = 0 AND userType != 'None';

PRINT 'Schema update completed successfully.';
