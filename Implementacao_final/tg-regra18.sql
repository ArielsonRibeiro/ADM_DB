--
-- Vanilton Alves dos Santos Filho - 2019.2
-- vanilton.filho96@academico.ifs.edu.br
--
CREATE TRIGGER tg_regra18 ON TurmaMatriculada
FOR INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @matricula INT = (SELECT mat_alu FROM inserted);
    DECLARE @codigo_disciplina INT = (SELECT cod_disc FROM inserted);
    DECLARE @total_situacao SMALLINT = (SELECT COUNT(he.situacao)
                FROM Aluno AS a, HistoricoEscolar AS he
                WHERE a.mat_alu = @matricula and he.mat_alu = @matricula
                and he.cod_disc = @codigo_disciplina
                and he.situacao = 'AP');
    
    -- Se já existe o total de uma aprovação, então é garantia o suficiente
    -- para barrar a matrícula do aluno seguindo a definição da regra de negócio
    IF  @total_situacao = 1
    BEGIN
        RAISERROR('~> [ERRO] O aluno já se encontra aprovado na disciplina.', 16, 1);
        ROLLBACK;
    END
END
GO
