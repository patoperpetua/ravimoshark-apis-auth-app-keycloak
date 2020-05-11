USE master;
GO

IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Keycloak')
BEGIN
	CREATE DATABASE Keycloak;
END