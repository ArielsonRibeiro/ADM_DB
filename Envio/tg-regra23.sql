-- 23. O valor das faltas em uma unidade não pode exceder a 1/3 do total de aulas da disciplina;
CREATE TRIGGER TG_VALIDAR_FALTAS_POR_UNIDADE ON [TurmaMatriculada]
FOR INSERT, UPDATE
AS
    BEGIN
    DECLARE
        @COD_DISC INT
        , @TOT_CRED INT
        , @FALTAS_1 INT
        , @FALTAS_2 INT
        , @FALTAS_3 INT
        , @UM_TERCO_TOTAL_AULAS NUMERIC(3, 1);

    SELECT @COD_DISC = COD_DISC
        , @FALTAS_1 = FALTAS_1
        , @FALTAS_2 = FALTAS_2
        , @FALTAS_3 = FALTAS_3
        FROM inserted;

    SELECT @TOT_CRED = QTD_CRED FROM Disciplina 
        WHERE COD_DISC = @COD_DISC;
    
    SET @UM_TERCO_TOTAL_AULAS = (@TOT_CRED *18)/3;
    
    

    IF(@UM_TERCO_TOTAL_AULAS < @FALTAS_1 OR @UM_TERCO_TOTAL_AULAS < @FALTAS_2 OR @UM_TERCO_TOTAL_AULAS < @FALTAS_2)
        BEGIN
        RAISERROR('NÃO É POSSÍVEL ESTA QUANTIDADE DE FALTAS POR UNIDADE(APENAS 1/3 DO TOTAL É PERMITIDO', 10 , 1 );
            ROLLBACK;
        END

    END
GO