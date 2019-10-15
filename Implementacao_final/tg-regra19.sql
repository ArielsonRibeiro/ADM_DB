-- 19. O aluno só pode efetuar matrículas em Disciplina que pertençam ao seu currículo;

CREATE TRIGGER TG_VALIDAR_DISCIPLINA_PERTENCE_AO_CURSO_DO_ALUNO ON [TurmaMatriculada]
FOR INSERT
AS
    BEGIN
    DECLARE
         @COD_DISC INT
        , @MAT_ALU INT
        , @CURSO_DISC SMALLINT
        , @CURSO_ALU SMALLINT;
    SELECT @COD_DISC = COD_DISC
            , @MAT_ALU = MAT_ALU
    FROM inserted;
    
    SELECT @CURSO_DISC = COD_CURSO FROM Curriculo WHERE COD_DISC = @COD_DISC;
    SELECT @CURSO_ALU = COD_CURSO FROM Aluno WHERE MAT_ALU = @MAT_ALU;
    

    IF(@CURSO_ALU != @CURSO_DISC)
        BEGIN
            RAISERROR('ESTÁ DISCIPLINA NÂO PERTENCE AO CURRICULO DO CURSO DO ALUNO!', 10 , 1 );
            ROLLBACK;
        END

    END
GO