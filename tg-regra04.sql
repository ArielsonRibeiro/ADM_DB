CREATE TRIGGER tg_regra04 ON Curriculo
FOR INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON

    IF @@ROWCOUNT = 0
        RETURN;

    DECLARE @cod_curso TINYINT = (SELECT cod_curso FROM inserted);
    DECLARE @total_creditos SMALLINT = (SELECT tot_cred 
                            FROM Curso 
                            WHERE cod_curso = @cod_curso);

    IF @total_creditos > 220
    BEGIN
        RAISERROR(
            '[ERRO]~> Um curso pelas regras de negócio não pode ter mais de 220 de créditos.',
            16, 1
        );
        ROLLBACK;
    END
END
GO
