IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Keycloak')
BEGIN
	DROP DATABASE Keycloak;
END
GO

RESTORE DATABASE [Keycloak] FROM DISK = N'/opt/backup/keycloak.bak';