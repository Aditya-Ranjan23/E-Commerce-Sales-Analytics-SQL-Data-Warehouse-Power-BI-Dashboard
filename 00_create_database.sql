/*
Project: E-Commerce Analytics
Purpose: Create the SQL Server database and schemas used by the project.
Run first.
*/

USE master;
GO

IF DB_ID(N'ECommerceAnalytics') IS NULL
BEGIN
    CREATE DATABASE ECommerceAnalytics;
END;
GO

ALTER DATABASE ECommerceAnalytics SET RECOVERY SIMPLE;
GO

USE ECommerceAnalytics;
GO

IF SCHEMA_ID(N'raw') IS NULL
    EXEC(N'CREATE SCHEMA raw');
GO

IF SCHEMA_ID(N'dw') IS NULL
    EXEC(N'CREATE SCHEMA dw');
GO

IF SCHEMA_ID(N'mart') IS NULL
    EXEC(N'CREATE SCHEMA mart');
GO

