--
-- Vanilton Alves dos Santos Filho - 2019.2
-- vanilton.filho96@academico.ifs.edu.br
--
CREATE TRIGGER tg_regra17 ON TurmaMatriculada
FOR INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF @@ROWCOUNT = 0
        RETURN;

    DECLARE @matricula INT = (SELECT mat_alu FROM inserted);
    DECLARE @codigo_disciplina INT = (SELECT cod_disc FROM inserted);

    -- Vou recuperar a quantidade de pré-requisitos para a disciplina a ser matriculada
    -- e o total dentro desses pré-requisitos onde o aluno está aprovado, caso ambos
    -- sejam diferentes, um erro é lançado dizendo que ainda falta ser aprovado em alguma
    -- disciplina de pré-requisito para ser matriculado naquela que se está tentando no momento.

    DECLARE @total_prerequisitos SMALLINT = (SELECT COUNT(*) 
                                    FROM (SELECT pr.cod_disc_pre
                                            FROM PreRequisito pr 
                                            WHERE  pr.cod_disc = @codigo_disciplina) p);
    DECLARE @total_aprovadas SMALLINT = ((SELECT COUNT(he.situacao)
                                    FROM HistoricoEscolar AS he
                                    WHERE he.mat_alu = @matricula
                                        AND (he.cod_disc IN(SELECT pr.cod_disc_pre 
                                                                FROM PreRequisito pr 
                                                                WHERE pr.cod_disc = @codigo_disciplina
                                                            )
                                            )
                                        AND he.situacao = 'AP')
                                );

    IF @total_aprovadas != @total_prerequisitos
    BEGIN
        RAISERROR('~> [ERRO] Ainda é necessário estar aprovado em outros pré-requisitos', 16, 1);
        ROLLBACK;
    END 
END
GO
