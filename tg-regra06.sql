--
-- Vanilton Alves dos Santos Filho - 2019.2
-- vanilton.filho96@academico.ifs.edu.br
--
CREATE TRIGGER tg_regra06 ON Disciplina
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    -- Já fiz o INSERT diretamente recuperando os valores da
    -- tabela inserted
    INSERT INTO Disciplina VALUES (
          (SELECT cod_disc FROM inserted)
        , (SELECT qtd_cred FROM inserted)
        , (SELECT UPPER(nom_disc) FROM inserted)
    );
END
GO
