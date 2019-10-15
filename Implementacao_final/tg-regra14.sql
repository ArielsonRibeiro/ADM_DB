-- 14. O total de créditos cursados e a mgp do aluno deve ser modificado automaticamente pela
-- alteração do histórico do aluno;
CREATE TRIGGER TG_ALUNO_MGP ON [HistoricoEscolar]
FOR UPDATE, INSERT
AS
    BEGIN
        DECLARE 
              @MAT_ALU INT
            , @TOT_CRED  INT
            , @MGP NUMERIC(4, 2)
            , @I INT;
            SELECT @MAT_ALU = MAT_ALU FROM inserted;

            SELECT @TOT_CRED = SUM(d.QTD_CRED) FROM HistoricoEscolar he
                RIGHT JOIN Disciplina d ON d.COD_DISC = he.COD_DISC
                WHERE he.MAT_ALU = @MAT_ALU AND he.SITUACAO = 'AP';

            SELECT @MGP = SUM(he.MEDIA * di.QTD_CRED )
                ,  @I = COUNT(di.QTD_CRED)
                FROM  HistoricoEscolar he
                INNER JOIN Disciplina di on di.COD_DISC = he.COD_DISC
                 WHERE MAT_ALU = @MAT_ALU;

            IF(@MGP IS NOT NULL AND @MGP != 0 )
                SELECT @MGP = @MGP/@I;
            ELSE
                SET @MGP = 0  
            IF(@TOT_CRED IS NULL )
                SET @TOT_CRED = 0 ;  

            UPDATE Aluno
                SET TOT_CRED = @TOT_CRED
                    , MGP = @MGP
                WHERE MAT_ALU = @MAT_ALU;    
        
    END
GO