--
-- Vanilton Alves dos Santos Filho - 2019.2
-- vanilton.filho96@academico.ifs.edu.br
--
CREATE TRIGGER tg_regra11 ON Turma
FOR INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF @@ROWCOUNT = 0
        RETURN;

    DECLARE @total_vagas SMALLINT = (SELECT tot_vagas FROM inserted);
    DECLARE @vagas_ocupadas SMALLINT = (SELECT vag_ocup FROM inserted);

    IF @vagas_ocupadas > @total_vagas
    BEGIN
        RAISERROR('~> [ERRO] O limite do total de vagas já foi alcançado para esta turma.', 16, 1);
        ROLLBACK;
    END
END
GO
