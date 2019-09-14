--O total de créditos do curso deve ser considerado como um campo calculado, ou seja, a sua
--alteração deve ocorrer em consequência de mudanças na grade do curso;
--USE SIGAA;


CREATE TRIGGER TG_ALTER_GRADE_CURSO ON [Curriculos]
    FOR INSERT, UPDATE, DELETE 
AS
    BEGIN
        UPDATE SIGAA.dbo.[Cursos]
            SET TOT_CRED = (Select SUM(disc.QTD_CRED)
                FROM Curriculos AS cur 
                RIGHT JOIN Disciplinas AS disc 
                ON disc.COD_DISC = cur.COD_DISC
                WHERE CUR.COD_CURSO = (SELECT COD_CURSO FROM INSERTED))
        WHERE COD_CURSO = (SELECT COD_CURSO FROM INSERTED)
                

    END
GO