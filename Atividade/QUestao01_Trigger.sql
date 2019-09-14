--1. O total de créditos do curso deve ser considerado como um campo calculado, ou seja, a sua
--alteração deve ocorrer em consequência de mudanças na grade do curso;
--USE SIGAA;


CREATE TRIGGER TG_ALTER_GRADE_CURSO_CALCULAR_CREDITOS ON [Curriculos]
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

--2. A descrição do curso deve ser armazenada em caixa alta (maiúscula);

CREATE TRIGGER TG_SETUPPER_DSC_CURSO ON [Cursos]
    FOR INSERT, UPDATE 
AS
    BEGIN
        UPDATE Cursos
        SET NOM_CURSO = UPPER( (SELECT NOM_CURSO FROM inserted) )
        WHERE COD_CURSO = (SELECT COD_CURSO FROM INSERTED)
    END
GO

--3. O coordenador do curso deve estar sempre lotado no curso em que ele coordena;

ALTER TRIGGER TG_VALIDAR_COORDENADOR_CURSO ON [Cursos]
    FOR INSERT, UPDATE 
AS
    IF ( UPDATE(COD_COORD) AND (SELECT COUNT(COD_COORD) FROM inserted) != 0)
        BEGIN
            DECLARE
                @COD_CURSO_PROF INT
                , @COD_CURSO INT;
                
            SELECT @COD_CURSO_PROF = COD_CURSO FROM SIGAA.dbo.Professores;

            SELECT @COD_CURSO = COD_CURSO FROM inserted;

            IF(@COD_CURSO_PROF != @COD_CURSO)
                BEGIN
                RAISERROR('O COORDENADOR QUE ESTÁ SENDO CADASTRADO NÃO ESTA LOTADO NO CURSO, COM ISSO NÃO É POSSIVEL REALIZAR ESTA TRANSAÇÃO', 10 , 1 )
                ROLLBACK;
                END
        END
GO