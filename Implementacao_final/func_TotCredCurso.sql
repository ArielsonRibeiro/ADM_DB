--
-- author: Vanilton Alves dos Santos Filho 
-- vanilton.filho96@academico.ifs.edu.br - 2019
-- 
CREATE FUNCTION func_TotCredCurso (@cod_curso SMALLINT)
RETURNS SMALLINT
AS
BEGIN
    DECLARE @total_creditos SMALLINT;

    SET @total_creditos = (
        SELECT SUM(qtd_cred)
            FROM Disciplina AS d INNER JOIN
                 Curriculo  AS cv ON (d.cod_disc = cv.cod_disc)
            WHERE cod_curso = @cod_curso
    );

    RETURN ISNULL(@total_creditos, 0);
END
GO
