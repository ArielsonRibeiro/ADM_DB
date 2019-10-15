CREATE TRIGGER TG_ATUALIZAR_VAGAS_TURMA ON [TurmaMatriculada]
FOR INSERT, DELETE
AS
    BEGIN
        DECLARE
              @VAG_OCUP INT
            , @COD_DISC INT
            , @ANO INT
            , @SEMESTRE SMALLINT
            , @TURMA CHAR(3);
         

        IF EXISTS (SELECT * FROM INSERTED)
            BEGIN
                SELECT @COD_DISC = COD_DISC
                     , @ANO = ANO
                     , @SEMESTRE = SEMESTRE
                     , @TURMA = TURMA FROM inserted;
                SELECT @VAG_OCUP = VAG_OCUP + 1 FROM SIGAA.dbo.Turma WHERE COD_DISC = @COD_DISC AND ANO = @ANO AND SEMESTRE = @SEMESTRE AND TURMA = @TURMA;
            END
        ELSE
            BEGIN
                SELECT @COD_DISC = COD_DISC
                     , @ANO = ANO
                     , @SEMESTRE = SEMESTRE
                     , @TURMA = TURMA FROM deleted;
                SELECT @VAG_OCUP = VAG_OCUP -1 FROM SIGAA.dbo.Turma WHERE COD_DISC = @COD_DISC AND ANO = @ANO AND SEMESTRE = @SEMESTRE AND TURMA = @TURMA;
            END

        UPDATE SIGAA.dbo.Turma
            SET VAG_OCUP  = @VAG_OCUP
            WHERE COD_DISC = @COD_DISC AND ANO = @ANO AND SEMESTRE = @SEMESTRE AND TURMA = @TURMA;
    END
GO