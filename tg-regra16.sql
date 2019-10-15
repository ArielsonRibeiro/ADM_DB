--
-- Vanilton Alves dos Santos Filho - 2019.2
-- vanilton.filho96@academico.ifs.edu.br
--
CREATE TRIGGER tg_regra16 ON Aluno
FOR INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF @@ROWCOUNT = 0
        RETURN;

    DECLARE @data_nascimento SMALLDATETIME = (SELECT dat_nasc FROM inserted);
    DECLARE @idade TINYINT = (FLOOR(DATEDIFF(DAY, @data_nascimento, GETDATE()) / 365.25))

    IF @idade < 16
    BEGIN
        RAISERROR('~> [ERRO] O aluno não possui idade mínima de 16 anos para ser cadastrado.', 9, 1);
        ROLLBACK;
    END
END
GO
