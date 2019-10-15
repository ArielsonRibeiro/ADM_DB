-- 29. Deve ser validada a consistência da situação do histórico em relação aos dados de média e
-- faltas.

CREATE TRIGGER TG_VALIDAR_CONSISTENCIA_SITUACAO ON [HistoricoEscolar]
FOR INSERT, UPDATE
AS
    BEGIN
        DECLARE
            @COD_DISC INT
            , @TOT_CRED INT
            , @MEDIA NUMERIC(4,1)
            , @SITUACAO CHAR(2)
            , @FALTAS INT
            , @TOTAL_AULAS INT;

        SELECT @COD_DISC = COD_DISC
            , @FALTAS = FALTAS
            , @MEDIA = MEDIA
            , @SITUACAO = SITUACAO
            FROM inserted;

        SELECT @TOT_CRED = QTD_CRED FROM Disciplina 
            WHERE COD_DISC = @COD_DISC;
        
        SET @TOTAL_AULAS = @TOT_CRED *18;
        
        
        IF(  (( (@TOTAL_AULAS * 0.25) > @FALTAS) OR @MEDIA >= 5 ) AND @SITUACAO != 'AP')
            BEGIN
            RAISERROR('O ALUNO FOI APROVADO!, MAS CONSTA REPROVADO, NÃO É POSSÍVEL FAZER ESTE CADASTRO', 10 , 1 );
                ROLLBACK;
            END
        ELSE IF(  ( @MEDIA < 5 ) AND @SITUACAO IN ('AP', 'RF')  )
            BEGIN
                RAISERROR('O ALUNO FOI REPROVADO POR MÉDIA!, MAS A SITUCÃO NAO CONSTA ESTE CASO', 10 , 1 );
                ROLLBACK;
            END
        ELSE IF(  ( (@TOTAL_AULAS * 0.25) < @FALTAS)  AND @SITUACAO IN ('AP', 'RM')  )
            BEGIN
                RAISERROR('O ALUNO FOI REPROVADO POR FALTA!, MAS A SITUCÃO NAO CONSTA ESTE CASO', 10 , 1 );
                ROLLBACK;
            END

    END
GO