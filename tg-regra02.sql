--
-- author: Vanilton Alves dos Santos Filho 
-- vanilton.filho96@academico.ifs.edu.br - 2019
-- 
CREATE TRIGGER tg_regra02 ON Curso
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON
    -- Estou garantindo que através de um INSERT o usuário do banco
    -- não insira um valor qualquer para o total de créditos, já que
    -- o mesmo é um campo que depende de valores de outras tabelas;
    -- Por fim, faço o INSERT do nome do curso em uppercase utilizando
    -- a função built-in UPPER.
    INSERT INTO Curso VALUES (
          (SELECT cod_curso FROM inserted)
        , 0
        , (SELECT UPPER(nom_curso) FROM inserted)
        , NULL
    );
END
GO
