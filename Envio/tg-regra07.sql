-- 7. Uma disciplina só pode estar em uma grade curricular caso as Disciplina que formam seu pré-
-- requisito já estejam alocadas em períodos anteriores;
CREATE TRIGGER TG_VERIFICAR_PreRequisito ON [Curriculo]
    FOR INSERT, UPDATE
AS
    BEGIN
    DECLARE
          @COD_DISC INT
        , @COD_CURSO SMALLINT
        , @CONT1 INT
        , @CONT2 INT;
        SELECT @COD_DISC = COD_DISC,
               @COD_CURSO = COD_CURSO FROM inserted;

        SELECT @CONT1 = COUNT(*) FROM [PreRequisito] 
            WHERE COD_DISC = @COD_DISC;
        
        SELECT @CONT2 = COUNT(*) FROM PreRequisito p 
            INNER JOIN Curriculo c on c.COD_DISC = p.COD_DISC_PRE
            WHERE p.COD_DISC = @COD_DISC AND c.COD_CURSO = @COD_CURSO;
            
        IF(@CONT1 != @CONT2)
            BEGIN
            RAISERROR('A DISCIPLINA QUE ESTÀ SENDO INSERIDO NÃO TEM OS PRÉ REQUISITOS CADASTRADO NO CURSO', 10 , 1 )
                ROLLBACK;
            END


    END
GO