-- 26. Só pode existir uma ocorrência com aprovação para uma disciplina do histórico. Além disso,
-- está ocorrência deve ser cronologicamente a última da disciplina no histórico do aluno;
CREATE TRIGGER TG_LANCAR_DISCIPLINA_VALIDAR_ALUNO_JA_CURSOU ON [HistoricoEscolar]
FOR INSERT
AS
    BEGIN
    DECLARE
        @COD_DISC INT
        , @MAT_ALU INT;
    SELECT @COD_DISC = COD_DISC
            , @MAT_ALU = MAT_ALU
    FROM inserted;


    IF( (SELECT COUNT(*) FROM [HistoricoEscolar] WHERE COD_DISC = @COD_DISC AND MAT_ALU = MAT_ALU AND SITUACAO = 'AP') > 1)
        BEGIN
        RAISERROR('O ALUNO JÀ CURSOU A DISCIPLINA E TEVE APROVAÇÃO, COM ISSO NÃO É POSSÍVEL CADASTRAR ESSA DISCIPLINA', 10 , 1 );
            ROLLBACK;
        END

    END
GO