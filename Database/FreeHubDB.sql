-- ============================================================
-- FreeHubDB - Database Creation Script
-- Project: Free HUB (Ventastik4_Devs)
-- Date: April 2026
-- Database: Microsoft SQL Server
-- ============================================================

-- Create the database
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'FreeHubDB')
BEGIN
    CREATE DATABASE FreeHubDB;
END
GO

USE FreeHubDB;
GO

-- ============================================================
-- DROP EXISTING TABLES (in reverse dependency order)
-- ============================================================

IF OBJECT_ID('dbo.WithdrawalRequest', 'U') IS NOT NULL DROP TABLE dbo.WithdrawalRequest;
IF OBJECT_ID('dbo.Comment', 'U') IS NOT NULL DROP TABLE dbo.Comment;
IF OBJECT_ID('dbo.ChatSession', 'U') IS NOT NULL DROP TABLE dbo.ChatSession;
IF OBJECT_ID('dbo.Message', 'U') IS NOT NULL DROP TABLE dbo.Message;
IF OBJECT_ID('dbo.Notification', 'U') IS NOT NULL DROP TABLE dbo.Notification;
IF OBJECT_ID('dbo.Dispute', 'U') IS NOT NULL DROP TABLE dbo.Dispute;
IF OBJECT_ID('dbo.Rating', 'U') IS NOT NULL DROP TABLE dbo.Rating;
IF OBJECT_ID('dbo.Proposal', 'U') IS NOT NULL DROP TABLE dbo.Proposal;
IF OBJECT_ID('dbo.Transaction', 'U') IS NOT NULL DROP TABLE dbo.[Transaction];
IF OBJECT_ID('dbo.Wallet', 'U') IS NOT NULL DROP TABLE dbo.Wallet;
IF OBJECT_ID('dbo.Project', 'U') IS NOT NULL DROP TABLE dbo.Project;
IF OBJECT_ID('dbo.Freelancer', 'U') IS NOT NULL DROP TABLE dbo.Freelancer;
IF OBJECT_ID('dbo.Employer', 'U') IS NOT NULL DROP TABLE dbo.Employer;
IF OBJECT_ID('dbo.Admin', 'U') IS NOT NULL DROP TABLE dbo.Admin;
IF OBJECT_ID('dbo.[User]', 'U') IS NOT NULL DROP TABLE dbo.[User];
GO

-- ============================================================
-- TABLE: User
-- The base account table for all system users
-- ============================================================

CREATE TABLE dbo.[User]
(
    userID          INT IDENTITY(1,1)   PRIMARY KEY,
    firstName       NVARCHAR(100)       NOT NULL,
    lastName        NVARCHAR(100)       NOT NULL,
    email           NVARCHAR(255)       NOT NULL UNIQUE,
    contactNumber   NVARCHAR(20)        NULL,
    username        NVARCHAR(100)       NOT NULL UNIQUE,
    password        NVARCHAR(255)       NOT NULL,  -- Stored as hash
    accountStatus   NVARCHAR(20)        NOT NULL DEFAULT 'Active',
        -- Active, Inactive, Suspended
    dateCreated     DATETIME            NOT NULL DEFAULT GETDATE(),
    userType        NVARCHAR(20)        NOT NULL DEFAULT 'User',
        -- User, Freelancer, Employer, Admin
    ratingScore     DECIMAL(3,2)        NULL DEFAULT 0.00
);
GO

-- ============================================================
-- TABLE: Admin
-- Admin profiles are created manually in the database
-- ============================================================

CREATE TABLE dbo.Admin
(
    adminID         INT IDENTITY(1,1)   PRIMARY KEY,
    userID          INT                 NOT NULL,
    permissions     NVARCHAR(500)       NULL,

    CONSTRAINT FK_Admin_User
        FOREIGN KEY (userID)
        REFERENCES dbo.[User](userID)
);
GO

-- ============================================================
-- TABLE: Employer
-- Linked to User account when user selects "Become an Employer"
-- ============================================================

CREATE TABLE dbo.Employer
(
    employerID      INT IDENTITY(1,1)   PRIMARY KEY,
    userID          INT                 NOT NULL,
    companyName     NVARCHAR(200)       NOT NULL,
    industry        NVARCHAR(100)       NULL,
    description     NVARCHAR(MAX)       NULL,
    contactEmail    NVARCHAR(255)       NULL,

    CONSTRAINT FK_Employer_User
        FOREIGN KEY (userID)
        REFERENCES dbo.[User](userID)
);
GO

-- ============================================================
-- TABLE: Freelancer
-- Linked to User account when user selects "Become a Freelancer"
-- ============================================================

CREATE TABLE dbo.Freelancer
(
    freelancerID    INT IDENTITY(1,1)   PRIMARY KEY,
    userID          INT                 NOT NULL,
    skills          NVARCHAR(MAX)       NOT NULL,
    experience      NVARCHAR(MAX)       NULL,
    portfolioLinks  NVARCHAR(MAX)       NULL,
    hourlyRate      DECIMAL(10,2)       NOT NULL DEFAULT 0.00,

    CONSTRAINT FK_Freelancer_User
        FOREIGN KEY (userID)
        REFERENCES dbo.[User](userID)
);
GO

-- ============================================================
-- TABLE: Wallet
-- Each user has one wallet for managing funds
-- ============================================================

CREATE TABLE dbo.Wallet
(
    walletID        INT IDENTITY(1,1)   PRIMARY KEY,
    userID          INT                 NOT NULL,
    balance         DECIMAL(12,2)       NOT NULL DEFAULT 0.00,
    dateCreated     DATETIME            NOT NULL DEFAULT GETDATE(),
    walletStatus    NVARCHAR(20)        NOT NULL DEFAULT 'Active',
        -- Active, Frozen, Closed

    CONSTRAINT FK_Wallet_User
        FOREIGN KEY (userID)
        REFERENCES dbo.[User](userID)
);
GO

-- ============================================================
-- TABLE: Transaction
-- Records all wallet financial activities
-- ============================================================

CREATE TABLE dbo.[Transaction]
(
    transactionID       INT IDENTITY(1,1)   PRIMARY KEY,
    walletID            INT                 NOT NULL,
    itemDescription     NVARCHAR(500)       NULL,
    transactionType     NVARCHAR(50)        NOT NULL,
        -- Credit, Debit, Withdrawal, Refund
    transactionAmount   DECIMAL(12,2)       NOT NULL,
    transactionDate     DATETIME            NOT NULL DEFAULT GETDATE(),
    transactionStatus   NVARCHAR(20)        NOT NULL DEFAULT 'Completed',
        -- Completed, Pending, Failed
    reference           NVARCHAR(100)       NULL,
    paymentMethod       NVARCHAR(100)       NULL,

    CONSTRAINT FK_Transaction_Wallet
        FOREIGN KEY (walletID)
        REFERENCES dbo.Wallet(walletID)
);
GO

-- ============================================================
-- TABLE: Project
-- Employers post projects for freelancers to bid on
-- ============================================================

CREATE TABLE dbo.Project
(
    projectID       INT IDENTITY(1,1)   PRIMARY KEY,
    employerID      INT                 NOT NULL,
    title           NVARCHAR(300)       NOT NULL,
    description     NVARCHAR(MAX)       NOT NULL,
    category        NVARCHAR(100)       NOT NULL,
    budget          DECIMAL(12,2)       NOT NULL,
    budgetType      NVARCHAR(20)        NULL DEFAULT 'Fixed',
        -- Fixed, Hourly, Monthly
    dateCreated     DATETIME            NOT NULL DEFAULT GETDATE(),
    deadline        DATE                NOT NULL,
    projectStatus   NVARCHAR(20)        NOT NULL DEFAULT 'Open',
        -- Open, In Progress, Completed, Cancelled
    experienceLevel NVARCHAR(50)        NULL,
    skills          NVARCHAR(MAX)       NULL,

    CONSTRAINT FK_Project_Employer
        FOREIGN KEY (employerID)
        REFERENCES dbo.Employer(employerID)
);
GO

-- ============================================================
-- TABLE: Proposal
-- Freelancers submit proposals (bids) for projects
-- A freelancer can submit one proposal per project
-- ============================================================

CREATE TABLE dbo.Proposal
(
    proposalID              INT IDENTITY(1,1)   PRIMARY KEY,
    projectID               INT                 NOT NULL,
    freelancerID            INT                 NOT NULL,
    coverLetter             NVARCHAR(MAX)       NOT NULL,
    proposedRate            DECIMAL(12,2)       NOT NULL,
    estimatedCompletionTime NVARCHAR(100)       NULL,
    status                  NVARCHAR(20)        NOT NULL DEFAULT 'Pending',
        -- Pending, Under Review, Approved, Rejected
    date                    DATETIME            NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_Proposal_Project
        FOREIGN KEY (projectID)
        REFERENCES dbo.Project(projectID),

    CONSTRAINT FK_Proposal_Freelancer
        FOREIGN KEY (freelancerID)
        REFERENCES dbo.Freelancer(freelancerID),

    -- A freelancer can submit only one proposal per project
    CONSTRAINT UQ_Proposal_Project_Freelancer
        UNIQUE (projectID, freelancerID)
);
GO

-- ============================================================
-- TABLE: Rating
-- Both freelancer and employer must rate each other after
-- project completion (1-5 stars with optional comment)
-- ============================================================

CREATE TABLE dbo.Rating
(
    ratingID        INT IDENTITY(1,1)   PRIMARY KEY,
    projectID       INT                 NOT NULL,
    raterUserID     INT                 NOT NULL,  -- The user giving the rating
    ratedUserID     INT                 NOT NULL,  -- The user receiving the rating
    score           INT                 NOT NULL,
        -- Constrained between 1 and 5
    ratingComment   NVARCHAR(MAX)       NULL,
    ratingDate      DATETIME            NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_Rating_Project
        FOREIGN KEY (projectID)
        REFERENCES dbo.Project(projectID),

    CONSTRAINT FK_Rating_RaterUser
        FOREIGN KEY (raterUserID)
        REFERENCES dbo.[User](userID),

    CONSTRAINT FK_Rating_RatedUser
        FOREIGN KEY (ratedUserID)
        REFERENCES dbo.[User](userID),

    CONSTRAINT CK_Rating_Score
        CHECK (score >= 1 AND score <= 5)
);
GO

-- ============================================================
-- TABLE: Dispute
-- Users can raise disputes related to projects/transactions
-- Admin resolves disputes
-- ============================================================

CREATE TABLE dbo.Dispute
(
    disputeID           INT IDENTITY(1,1)   PRIMARY KEY,
    userID              INT                 NOT NULL,
    projectID           INT                 NULL,
    transactionID       INT                 NULL,
    disputeDescription  NVARCHAR(MAX)       NOT NULL,
    reason              NVARCHAR(200)       NULL,
    status              NVARCHAR(20)        NOT NULL DEFAULT 'Open',
        -- Open, In Review, Resolved, Closed
    dateCreated         DATETIME            NOT NULL DEFAULT GETDATE(),
    adminID             INT                 NULL,
    adminComment        NVARCHAR(MAX)       NULL,
    resolvedDate        DATETIME            NULL,

    CONSTRAINT FK_Dispute_User
        FOREIGN KEY (userID)
        REFERENCES dbo.[User](userID),

    CONSTRAINT FK_Dispute_Project
        FOREIGN KEY (projectID)
        REFERENCES dbo.Project(projectID),

    CONSTRAINT FK_Dispute_Transaction
        FOREIGN KEY (transactionID)
        REFERENCES dbo.[Transaction](transactionID),

    CONSTRAINT FK_Dispute_Admin
        FOREIGN KEY (adminID)
        REFERENCES dbo.Admin(adminID)
);
GO

-- ============================================================
-- TABLE: Message
-- Internal messaging between users (text only)
-- ============================================================

CREATE TABLE dbo.Message
(
    messageID       INT IDENTITY(1,1)   PRIMARY KEY,
    senderID        INT                 NOT NULL,
    receiverID      INT                 NOT NULL,
    projectID       INT                 NULL,
    content         NVARCHAR(MAX)       NOT NULL,
    timeStamp       DATETIME            NOT NULL DEFAULT GETDATE(),
    status          NVARCHAR(20)        NOT NULL DEFAULT 'Sent',
        -- Sent, Delivered, Read

    CONSTRAINT FK_Message_Sender
        FOREIGN KEY (senderID)
        REFERENCES dbo.[User](userID),

    CONSTRAINT FK_Message_Receiver
        FOREIGN KEY (receiverID)
        REFERENCES dbo.[User](userID),

    CONSTRAINT FK_Message_Project
        FOREIGN KEY (projectID)
        REFERENCES dbo.Project(projectID)
);
GO

-- ============================================================
-- TABLE: Notification
-- System notifications for users (messages, project updates, etc.)
-- ============================================================

CREATE TABLE dbo.Notification
(
    notificationID  INT IDENTITY(1,1)   PRIMARY KEY,
    userID          INT                 NOT NULL,
    type            NVARCHAR(50)        NOT NULL,
        -- Message, Project, Proposal, Payment, Welcome, System
    content         NVARCHAR(MAX)       NOT NULL,
    notificationTimestamp DATETIME      NOT NULL DEFAULT GETDATE(),
    status          NVARCHAR(20)        NOT NULL DEFAULT 'Unread',
        -- Unread, Read, Archived

    CONSTRAINT FK_Notification_User
        FOREIGN KEY (userID)
        REFERENCES dbo.[User](userID)
);
GO

-- ============================================================
-- TABLE: ChatSession
-- Tracks chat sessions between users
-- ============================================================

CREATE TABLE dbo.ChatSession
(
    sessionID       INT IDENTITY(1,1)   PRIMARY KEY,
    participant1ID  INT                 NOT NULL,
    participant2ID  INT                 NOT NULL,
    projectID       INT                 NULL,
    startTime       DATETIME            NOT NULL DEFAULT GETDATE(),
    endTime         DATETIME            NULL,
    status          NVARCHAR(20)        NOT NULL DEFAULT 'Active',
        -- Active, Ended

    CONSTRAINT FK_ChatSession_Participant1
        FOREIGN KEY (participant1ID)
        REFERENCES dbo.[User](userID),

    CONSTRAINT FK_ChatSession_Participant2
        FOREIGN KEY (participant2ID)
        REFERENCES dbo.[User](userID),

    CONSTRAINT FK_ChatSession_Project
        FOREIGN KEY (projectID)
        REFERENCES dbo.Project(projectID)
);
GO

-- ============================================================
-- TABLE: Comment
-- Comments on projects (discussion feature)
-- ============================================================

CREATE TABLE dbo.Comment
(
    commentID       INT IDENTITY(1,1)   PRIMARY KEY,
    projectID       INT                 NOT NULL,
    userID          INT                 NOT NULL,
    commentText     NVARCHAR(MAX)       NOT NULL,
    commentDate     DATETIME            NOT NULL DEFAULT GETDATE(),
    replyToCommentID INT               NULL,

    CONSTRAINT FK_Comment_Project
        FOREIGN KEY (projectID)
        REFERENCES dbo.Project(projectID),

    CONSTRAINT FK_Comment_User
        FOREIGN KEY (userID)
        REFERENCES dbo.[User](userID),

    CONSTRAINT FK_Comment_ReplyTo
        FOREIGN KEY (replyToCommentID)
        REFERENCES dbo.Comment(commentID)
);
GO

-- ============================================================
-- TABLE: WithdrawalRequest
-- Withdrawal requests from user wallets
-- ============================================================

CREATE TABLE dbo.WithdrawalRequest
(
    withdrawID      INT IDENTITY(1,1)   PRIMARY KEY,
    walletID        INT                 NOT NULL,
    amount          DECIMAL(12,2)       NOT NULL,
    bankingDetails  NVARCHAR(500)       NOT NULL,
    requestDate     DATETIME            NOT NULL DEFAULT GETDATE(),
    withdrawalStatus NVARCHAR(20)       NOT NULL DEFAULT 'Pending',
        -- Pending, Approved, Completed, Rejected
    adminID         INT                 NULL,
    adminComment    NVARCHAR(MAX)       NULL,
    processedDate   DATETIME            NULL,

    CONSTRAINT FK_WithdrawalRequest_Wallet
        FOREIGN KEY (walletID)
        REFERENCES dbo.Wallet(walletID),

    CONSTRAINT FK_WithdrawalRequest_Admin
        FOREIGN KEY (adminID)
        REFERENCES dbo.Admin(adminID)
);
GO


-- ============================================================
-- INDEXES for performance
-- ============================================================

CREATE INDEX IX_User_Email ON dbo.[User](email);
CREATE INDEX IX_User_Username ON dbo.[User](username);
CREATE INDEX IX_Project_EmployerID ON dbo.Project(employerID);
CREATE INDEX IX_Project_Status ON dbo.Project(projectStatus);
CREATE INDEX IX_Proposal_ProjectID ON dbo.Proposal(projectID);
CREATE INDEX IX_Proposal_FreelancerID ON dbo.Proposal(freelancerID);
CREATE INDEX IX_Transaction_WalletID ON dbo.[Transaction](walletID);
CREATE INDEX IX_Message_SenderID ON dbo.Message(senderID);
CREATE INDEX IX_Message_ReceiverID ON dbo.Message(receiverID);
CREATE INDEX IX_Notification_UserID ON dbo.Notification(userID);
CREATE INDEX IX_Rating_ProjectID ON dbo.Rating(projectID);
CREATE INDEX IX_Dispute_UserID ON dbo.Dispute(userID);
GO


-- ============================================================
-- SEED DATA: Test accounts as per FSSB Section 4.3
-- Passwords are hashed using SHA256 for security
-- ============================================================

-- Note: In production, use proper password hashing (bcrypt/PBKDF2).
-- These are SHA256 hashes for demonstration purposes.

-- Admin: admin@freehub.co.za / admin@2026
INSERT INTO dbo.[User] (firstName, lastName, email, contactNumber, username, password, accountStatus, userType, ratingScore)
VALUES (
    'System',
    'Administrator',
    'admin@freehub.co.za',
    '0000000000',
    'admin@freehub.co.za',
    '8b3ce0c3977ee6e8d53efeb1fb5b4f82bfb85e44b706c4eded197bd78875da67',
    'Active',
    'Admin',
    NULL
);

-- Freelancer: freelancer@freehub.co.za / free@2026
INSERT INTO dbo.[User] (firstName, lastName, email, contactNumber, username, password, accountStatus, userType, ratingScore)
VALUES (
    'Thabo',
    'Mokoena',
    'freelancer@freehub.co.za',
    '0712345678',
    'freelancer@freehub.co.za',
    '1f81397415ab9129b5a95e8277cc55a8265e1656d49c321b9bba8f013d00964f',
    'Active',
    'Freelancer',
    4.5
);

-- Employer: employer@freehub.co.za / emp@2026
INSERT INTO dbo.[User] (firstName, lastName, email, contactNumber, username, password, accountStatus, userType, ratingScore)
VALUES (
    'John',
    'Smith',
    'employer@freehub.co.za',
    '0823456789',
    'employer@freehub.co.za',
    '8c6621f34cad2a8ced988287ff66f6ff71e1ad5f91b3abe80081ae2d391a1195',
    'Active',
    'Employer',
    4.8
);
GO

-- Create Admin profile for the admin user
INSERT INTO dbo.Admin (userID, permissions)
VALUES (1, 'Full Access - Manage Users, Disputes, Refunds, Platform Settings');
GO

-- Create Freelancer profile
INSERT INTO dbo.Freelancer (userID, skills, experience, portfolioLinks, hourlyRate)
VALUES (
    2,
    'Web Design, UI/UX Design, HTML, CSS, JavaScript, React',
    '5+ years of experience in designing and developing modern, responsive websites. Specializes in creating user-friendly interfaces that drive conversions and improve user experience.',
    'https://behance.net/thabomokoena, https://dribbble.com/thabomokoena',
    350.00
);
GO

-- Create Employer profile
INSERT INTO dbo.Employer (userID, companyName, industry, description, contactEmail)
VALUES (
    3,
    'TechStore SA',
    'Information Technology',
    'We provide innovative digital solutions and IT services to help businesses grow. Looking for skilled freelancers for our ongoing projects.',
    'employer@freehub.co.za'
);
GO

-- Create Wallets for all users
INSERT INTO dbo.Wallet (userID, balance, walletStatus)
VALUES (1, 0.00, 'Active');

INSERT INTO dbo.Wallet (userID, balance, walletStatus)
VALUES (2, 12450.00, 'Active');

INSERT INTO dbo.Wallet (userID, balance, walletStatus)
VALUES (3, 25000.00, 'Active');
GO

-- Create a sample project
INSERT INTO dbo.Project (employerID, title, description, category, budget, budgetType, deadline, projectStatus, experienceLevel, skills)
VALUES (
    1,
    'E-commerce Website Redesign',
    'We need a modern and user-friendly redesign of our existing e-commerce website. The goal is to improve UX/UI, increase conversion rate, and ensure mobile responsiveness. The project includes front-end and back-end development.',
    'Web Development',
    15000.00,
    'Fixed',
    '2026-06-30',
    'Open',
    'Intermediate',
    'HTML, CSS, JavaScript, React, UI/UX Design'
);
GO

-- Create a sample proposal from the freelancer
INSERT INTO dbo.Proposal (projectID, freelancerID, coverLetter, proposedRate, estimatedCompletionTime, status)
VALUES (
    1,
    1,
    'I have over 5 years of experience in designing and developing modern, responsive websites. I specialize in creating user-friendly interfaces that drive conversions and improve user experience. For your e-commerce website redesign, I will focus on a clean, intuitive design that reflects your brand and enhances the shopping experience. I will ensure the site is fully responsive, optimized for SEO, and built with performance in mind.',
    12000.00,
    '15 days',
    'Pending'
);
GO

-- Create sample notifications
INSERT INTO dbo.Notification (userID, type, content, status)
VALUES (2, 'Welcome', 'Welcome to FreeHUB! Complete your profile to start finding projects.', 'Read');

INSERT INTO dbo.Notification (userID, type, content, status)
VALUES (3, 'Proposal', 'You have received a new proposal for your E-commerce Website Redesign project.', 'Unread');
GO

-- Create sample messages
INSERT INTO dbo.Message (senderID, receiverID, projectID, content, status)
VALUES (
    3, 2, 1,
    'Hi Thabo, I saw your proposal for the website redesign. Can we discuss the project timeline?',
    'Delivered'
);

INSERT INTO dbo.Message (senderID, receiverID, projectID, content, status)
VALUES (
    2, 3, 1,
    'Hi John, thanks for reaching out! I am available to discuss the project. When would be a good time?',
    'Sent'
);
GO


-- ============================================================
-- VERIFICATION: Display table counts
-- ============================================================

PRINT '============================================';
PRINT 'FreeHubDB created successfully!';
PRINT '============================================';
PRINT '';

SELECT 'Users' AS TableName, COUNT(*) AS RecordCount FROM dbo.[User]
UNION ALL
SELECT 'Admins', COUNT(*) FROM dbo.Admin
UNION ALL
SELECT 'Employers', COUNT(*) FROM dbo.Employer
UNION ALL
SELECT 'Freelancers', COUNT(*) FROM dbo.Freelancer
UNION ALL
SELECT 'Wallets', COUNT(*) FROM dbo.Wallet
UNION ALL
SELECT 'Projects', COUNT(*) FROM dbo.Project
UNION ALL
SELECT 'Proposals', COUNT(*) FROM dbo.Proposal
UNION ALL
SELECT 'Notifications', COUNT(*) FROM dbo.Notification
UNION ALL
SELECT 'Messages', COUNT(*) FROM dbo.Message;
GO


USE FreeHubDB;
GO

-- 1. Add LastSeen tracking to User table
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.[User]') AND name = 'lastSeen')
BEGIN
    ALTER TABLE dbo.[User] ADD lastSeen DATETIME NULL DEFAULT GETDATE();
END
GO

-- 2. Add ReadReceipt timestamp tracking to Message table
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Message') AND name = 'readTimestamp')
BEGIN
    ALTER TABLE dbo.Message ADD readTimestamp DATETIME NULL;
END
GO

GO

-- Add attachment column to Message table
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Message') AND name = 'attachmentUrl')
BEGIN
    ALTER TABLE dbo.Message ADD attachmentUrl NVARCHAR(500) NULL;
END
GO

-- Add attachment column to Project table
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Project') AND name = 'attachmentUrl')
BEGIN
    ALTER TABLE dbo.Project ADD attachmentUrl NVARCHAR(500) NULL;
END
GO