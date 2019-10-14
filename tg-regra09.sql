-- 9. O nome do professor deve ser armazenado em caixa alta (maiúscula);
CREATE TRIGGER TG_SET_UPPER_NOME_PROF ON Professor
FOR INSERT, UPDATE 
AS
    IF (UPDATE(NOM_PROF))
        BEGIN
            UPDATE Professor
            SET NOM_PROF  = UPPER( (SELECT NOM_PROF  FROM inserted) )
            WHERE COD_PROF = (SELECT COD_PROF FROM INSERTED)
        END
GO
