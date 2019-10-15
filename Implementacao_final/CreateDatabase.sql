--
-- Vanilton Alves dos Santos Filho - 2019.2
-- vanilton.filho96@academico.ifs.edu.br
--
-- Verificamos se já existe o banco, caso já
-- exista então deletamos ele e criamos outro com
-- o mesmo nome conforme definido pelo estudo de caso.

IF EXISTS (SELECT Name From master.dbo.sysdatabases WHERE Name = N'SIGAA')
    DROP DATABASE [SIGAA];
GO

CREATE DATABASE SIGAA;
GO

USE SIGAA;
GO
