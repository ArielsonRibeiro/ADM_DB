--
-- author: Vanilton Alves dos Santos Filho 
-- vanilton.filho96@academico.ifs.edu.br - 2019
-- 
CREATE TRIGGER tg_regra03 ON Curso
FOR UPDATE
AS
BEGIN
    SET NOCOUNT ON
    IF @@ROWCOUNT = 0
        RETURN;
    
    DECLARE @cod_coord_in SMALLINT = (SELECT cod_coord FROM inserted);
    DECLARE @cod_coord_del SMALLINT = (SELECT cod_coord FROM deleted);
    -- Com este IF vamos evitar ter que fazer uma série de ações desnecessárias
    -- sabendo que o dado que se está inserindo é o mesmo.
    IF @cod_coord_in = @cod_coord_del
        RETURN;

    -- Para um professor ser coordenador, ele precisa estar alocado no mesmo curso
    IF UPDATE(cod_coord)
    BEGIN
        DECLARE @cod_curso TINYINT = (SELECT cod_curso FROM inserted);
        DECLARE @cod_coordenador SMALLINT =  (
                SELECT cod_prof
                    FROM Professor AS p
                    WHERE p.cod_curso = @cod_curso AND p.cod_prof = @cod_coord_in
            );
        
        IF @cod_coordenador IS NULL
        BEGIN
            RAISERROR('[ERRO]~> O professor precisa estar lotado no curso para ser coordenador.', 16, 1); 
            ROLLBACK;
        END
        ELSE
        BEGIN
            DECLARE @cod_curso_del TINYINT = (SELECT cod_curso FROM deleted);
            UPDATE Curso SET
                cod_coord = @cod_coordenador
                WHERE cod_curso = @cod_curso_del;
        END
    END
END
GO
