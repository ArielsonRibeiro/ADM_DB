--
-- author: Vanilton Alves dos Santos Filho 
-- vanilton.filho96@academico.ifs.edu.br - 2019
-- 
CREATE TRIGGER tg_regra01 ON Curriculo
FOR INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON

    IF @@ROWCOUNT = 0
        RETURN;

    DECLARE @cod_curso TINYINT;
    SET @cod_curso = (SELECT cod_curso FROM inserted);

    UPDATE Curso SET
        tot_cred = [dbo].func_TotCredCurso(@cod_curso)
        WHERE cod_curso = @cod_curso;
END
GO
