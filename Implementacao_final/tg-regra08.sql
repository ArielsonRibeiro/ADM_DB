-- 8. A mudança dos dados de uma disciplina na grade só pode ser realizada enquanto nenhum
-- aluno tenha cursado a disciplina ou efetuado a matrícula na mesma;


CREATE TRIGGER TG_UPDATE_DISC ON [Disciplina]
    FOR UPDATE
AS
    BEGIN
        DECLARE 
            @COD_DISC INT;
            SELECT @COD_DISC = COD_DISC FROM deleted ;

        IF ( (SELECT COUNT(*) FROM SiGAA.dbo.TurmaMatriculada t
                LEFT JOIN Disciplina d ON d.COD_DISC = t.COD_DISC
                Where d.COD_DISC = @COD_DISC) > 0) 
            BEGIN
                RAISERROR('A DISCIPLINA QUE ESTÀ SENDO ALTERADAS JÁ TEVE OU TEM Aluno MATRICULADOS, COM ISSO NÃO É POSSÍVEL REALIZAR A TRANSAÇÃO', 10 , 1 )
                ROLLBACK;
            END


    END
GO