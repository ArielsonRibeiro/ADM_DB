-- 28. O total de faltas do histórico não pode exceder ao total de aulas da disciplina;
CREATE TRIGGER TG_VALIDAR_FALTAS_HIST ON [HistoricoEscolar]
FOR INSERT, UPDATE
AS
    BEGIN
    DECLARE
        @COD_DISC INT
        , @TOT_CRED INT
        , @FALTAS INT
        , @TOTAL_AULAS INT;

    SELECT @COD_DISC = COD_DISC
        ,  @FALTAS = FALTAS
        FROM inserted;

    SELECT @TOT_CRED = QTD_CRED FROM Disciplina 
        WHERE COD_DISC = @COD_DISC;
    
    SET @TOTAL_AULAS = @TOT_CRED *18;
    
    

    IF(@TOTAL_AULAS < @FALTAS)
     
        BEGIN
        RAISERROR('NÃO É POSSÍVEL ESTA QUANTIDADE DE FALTAS, EXCEDE O TOTAL DE AULAS', 10 , 1 );
            ROLLBACK;
        END

    END
GO
