--
-- author: Vanilton Alves dos Santos Filho 
-- vanilton.filho96@academico.ifs.edu.br - 2019
-- 
CREATE TRIGGER tg_regra12 ON Turma
FOR INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF @@ROWCOUNT = 0
        RETURN;
    
    DECLARE @cod_prof SMALLINT = (SELECT cod_prof FROM inserted) 
    DECLARE @semestre TINYINT= (SELECT semestre FROM inserted);
    DECLARE @qtd_turmas TINYINT =  (SELECT COUNT(p.cod_prof)
            FROM Turma AS t, Professor AS p
            WHERE t.cod_prof = @cod_prof
                AND t.semestre = @semestre
                AND p.cod_prof = @cod_prof
            );

    IF  @qtd_turmas > 5
    BEGIN
        RAISERROR('~> [ERRO] O limite do total de professor por semestre já foi alcançado.', 16, 1);
        ROLLBACK;
    END
END
GO
