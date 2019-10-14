--
-- Vanilton Alves dos Santos Filho - 2019.2
-- vanilton.filho96@academico.ifs.edu.br
--
CREATE TRIGGER tg_regra15 ON Aluno
FOR UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @matricula INT = (SELECT mat_alu FROM inserted);

    IF UPDATE(cod_curso)
    BEGIN
        IF EXISTS (SELECT *
                    FROM Aluno a, TurmaMatriculada tm
                    WHERE  tm.mat_alu = @matricula) OR
           EXISTS (SELECT *
                    FROM Aluno a, HistoricoEscolar he
                    WHERE he.mat_alu = @matricula)
        BEGIN
           RAISERROR('~> [ERRO] O aluno não pode ser modificado de curso por já possuir histórico ou estar cadastrado em disciplinas .', 16, 1);
           ROLLBACK; 
        END
    END

END
GO
