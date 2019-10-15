--
-- Vanilton Alves dos Santos Filho - 2019.2
-- vanilton.filho96@academico.ifs.edu.br
--
CREATE TRIGGER tg_regra13 ON PreRequisito
FOR INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF @@ROWCOUNT = 0
        RETURN;

    IF EXISTS (
        SELECT cv.cod_disc
            FROM Curriculo AS cv
                WHERE cv.cod_disc = (SELECT cod_disc FROM inserted)
    ) OR EXISTS (
        SELECT he.cod_disc
            FROM HistoricoEscolar AS he
                WHERE he.cod_disc = (SELECT cod_disc FROM inserted)
    ) OR EXISTS (
        SELECT tm.cod_disc
            FROM TurmaMatriculada AS tm
                WHERE tm.cod_disc = (SELECT cod_disc FROM inserted)
    )
    BEGIN
        RAISERROR('~> [ERRO] Para não causar inconsistência, a disciplina não pode ser ter o seu 
                    pré-requisito inserido ou modificada já que se encontra em uso.', 16, 1);
        ROLLBACK;
    END
END
GO
