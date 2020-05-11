USE master;
GO

-- First create a Login with the desired password.
CREATE LOGIN kc_principal WITH PASSWORD='nV3yN6q3Nb5!kwd';
-- Then create a user from the previous created login.
CREATE USER kc_principal FROM LOGIN kc_principal;

CREATE LOGIN kc_rd_1 WITH PASSWORD='!M96AmEHc@Gtw3c';
CREATE USER kc_rd_1 FROM LOGIN kc_rd_1;

CREATE LOGIN kc_wd_1 WITH PASSWORD='2YNV3pn^*H$b2k3';
CREATE USER kc_wd_1 FROM LOGIN kc_wd_1;
GO

-- Then go to the desired database where the user will have access to.
USE Keycloak;

-- Create again the same user but WITHOUT password.
CREATE USER kc_principal FOR LOGIN kc_principal WITH DEFAULT_SCHEMA = dbo;
-- Add the desired roles to the user. These roles will only apply to the selected database.
ALTER ROLE db_ddladmin ADD MEMBER kc_principal;
ALTER ROLE db_datareader ADD MEMBER kc_principal;
ALTER ROLE db_datawriter ADD MEMBER kc_principal;
-- To get all roles list, execute the following stored procedure:
-- EXEC sp_helprole;

CREATE USER kc_rd_1 FOR LOGIN kc_rd_1 WITH DEFAULT_SCHEMA = dbo;
ALTER ROLE db_datareader ADD MEMBER kc_rd_1;

CREATE USER kc_wd_1 FOR LOGIN kc_wd_1 WITH DEFAULT_SCHEMA = dbo;
ALTER ROLE db_datareader ADD MEMBER kc_wd_1;
ALTER ROLE db_datawriter ADD MEMBER kc_wd_1;
GO

-- You can check if the roles are correctly assigned by executing:
-- EXEC sp_helprolemember;