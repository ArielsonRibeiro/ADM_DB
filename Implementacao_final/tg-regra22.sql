-- 22. As faltas devem ser preenchidas sequencialmente, ou seja, as faltas da segunda unidade só
--  podem ser lançadas quando as da primeira já o tiverem sido;

CREATE TRIGGER TG_VALIDAR_ORDEM_FALTAS ON [TurmaMatriculada]
FOR INSERT, UPDATE
AS
    BEGIN
        DECLARE
              @F INT
            , @F2 INT
            , @F3 INT;
            SELECT @F2 = FALTAS_2 FROM inserted;
            SELECT @F3 = FALTAS_3 FROM inserted;
        IF(UPDATE(FALTAS_2) AND @F2 IS NOT NULL)
            BEGIN
                SELECT @F = FALTAS_1 FROM inserted;
                IF ( @F IS NULL)
                    BEGIN
                        RAISERROR('NÃO É POSSIVEL CADASTRAR AS FALTAS DA 2ª UNIDADES SEM ANTES TERC CADASTRADA DA 1ª', 10 , 1 );
                        ROLLBACK;
                    END
            END
        IF(UPDATE(FALTAS_3) AND @F3 IS NOT NULL)
            BEGIN
                SELECT @F = FALTAS_2 FROM inserted;
                IF ( @F IS NULL)
                    BEGIN
                        RAISERROR('nÃO É POSSIVEL CADASTRAR AS FALTAS DA 3ª UNIDADES SEM ANTES TERC CADASTRADA DA 2ª', 10 , 1 );
                        ROLLBACK;
                    END
            END
    END
    
GO