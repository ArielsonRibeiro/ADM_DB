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

CREATE TRIGGER TG_VALIDAR_COORDENADOR_CURSO ON [Cursos]
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

-- 5. A mudança na quantidade de créditos das disciplinas só pode ser realizada se a mesma ainda
-- não estiver alocada à grade de um curso;

CREATE TRIGGER TG_ALTERAR_CREDITO_DISC ON [Disciplinas]
    FOR UPDATE 
AS
    IF(UPDATE(QTD_CRED)) 
        BEGIN
            IF( EXISTS (SELECT *
                             FROM SIGAA.dbo.[Curriculos]
                             WHERE COD_DISC = (SELECT COD_DISC FROM inserted)) )
                BEGIN
                    RAISERROR('A DISCIPLINA QUE ESTÀ SENDO ALTERADAS A QUANTIDADE DE CREDITO ESTÀ ALOCADA A UM CURSO, COM ISSO NÃO É POSSÍVEL REALIZAR A TRANSAÇÃO', 10 , 1 )
                    ROLLBACK;
                END
            
        END
GO



-- 6. O nome da disciplina deve ser armazenada em caixa alta (maiúscula);

CREATE TRIGGER TG_SET_UPPER_NOME_DCIS ON [Disciplinas]
    FOR INSERT, UPDATE 
AS
    IF (UPDATE(NOM_DISC))
        BEGIN
            UPDATE Disciplinas
            SET NOM_DISC  = UPPER( (SELECT NOM_DISC  FROM inserted) )
            WHERE COD_DISC = (SELECT COD_DISC FROM INSERTED)
        END
GO

-- 7. Uma disciplina só pode estar em uma grade curricular caso as disciplinas que formam seu pré-
-- requisito já estejam alocadas em períodos anteriores;

-- CREATE TRIGGER TG_SET_UPPER_NOME_DCIS ON [Curriculos]
--     FOR INSERT, UPDATE 
-- AS
--     IF (UPDATE(COD_DISC))
--         BEGIN
--         DECLARE 
--             @COD_DISC_IN INT 
--             , @COD_CURSO_IN INT ;
--              SELECT @COD_DISC_IN = COD_DISC FROM inserted;
--              SELECT @COD_CURSO_IN  = COD_CURSO FROM inserted;

        
--         SELECT COUNT(*) FROM [Curriculos] cur
--              WHERE cur.COD_DISC =  SELECT COD_DISC_PRE
--                                          FROM SIGAA.dbo.[Pre_Requisitos] 
--                                             WHERE COD_DISC = (SELECT COD_DISC FROM inserted) AND Cur.COD_CURSO = SELECT COD_CURSO FROM inserted);

--             --SELECT COD_DISC_PRE FROM SIGAA.dbo.[Pre_Requisitos] WHERE COD_DISC = (SELECT COD_DISC FROM inserted);
--         END
-- GO

-- 8. A mudança dos dados de uma disciplina na grade só pode ser realizada enquanto nenhum
-- aluno tenha cursado a disciplina ou efetuado a matrícula na mesma;


CREATE TRIGGER TG_UPDATE_DISC ON [Disciplinas]
    FOR UPDATE
AS
    BEGIN
        DECLARE 
            @COD_DISC INT;
            SELECT @COD_DISC = COD_DISC FROM deleted ;

        IF ( (SELECT COUNT(*) FROM SiGAA.dbo.Tumas_Matriculadas t
                LEFT JOIN Disciplinas d ON d.COD_DISC = t.COD_DISC
                Where d.COD_DISC = @COD_DISC) > 0) 
            BEGIN
                RAISERROR('A DISCIPLINA QUE ESTÀ SENDO ALTERADAS JÁ TEVE OU TEM ALUNOS MATRICULADOS, COM ISSO NÃO É POSSÍVEL REALIZAR A TRANSAÇÃO', 10 , 1 )
                ROLLBACK;
            END


    END
GO

-- 9. O nome do professor deve ser armazenado em caixa alta (maiúscula);
CREATE TRIGGER TG_SET_UPPER_NOME_PROF ON Professores
FOR INSERT, UPDATE 
AS
    IF (UPDATE(NOM_PROF))
        BEGIN
            UPDATE Professores
            SET NOM_PROF  = UPPER( (SELECT NOM_PROF  FROM inserted) )
            WHERE COD_PROF = (SELECT COD_PROF FROM INSERTED)
        END
GO

-- 10. As vagas ocupadas da turma (vag_ocup) deve ser atualizada como efeito das mudanças nas
-- turmas matriculadas de cada aluno;
-- DUVIDA A PERGUNTAR AO PROFESSO
CREATE TRIGGER TG_ATUALIZAR_VAGAS_TURMA ON [Tumas_Matriculadas]
FOR INSERT, DELETE
AS
    BEGIN
        DECLARE
              @VAG_OCUP INT
            , @COD_DISC INT
            , @ANO INT
            , @SEMESTRE INT
            , @TURMA CHAR(3);
         

        IF EXISTS (SELECT * FROM INSERTED)
            BEGIN
                SELECT @COD_DISC = COD_DISC FROM inserted;
                SELECT @ANO = ANO FROM inserted;
                SELECT @SEMESTRE = SEMESTRE FROM inserted;
                SELECT @TURMA = TURMA FROM inserted;
                SELECT @VAG_OCUP = VAG_OCUP FROM SIGAA.dbo.Turmas WHERE COD_DISC = @COD_DISC;
                SELECT @VAG_OCUP = @VAG_OCUP+1;
            END
        ELSE
            BEGIN
                SELECT @COD_DISC = COD_DISC FROM deleted;
                SELECT @ANO = ANO FROM deleted;
                SELECT @SEMESTRE = SEMESTRE FROM deleted;
                SELECT @TURMA = TURMA FROM deleted;
                SELECT @VAG_OCUP = VAG_OCUP FROM SIGAA.dbo.Turmas WHERE COD_DISC = @COD_DISC;
                SELECT @VAG_OCUP = @VAG_OCUP - 1;
            END

        PRINT @COD_DISC
        PRINT @ANO 
        PRINT @SEMESTRE
        PRINT @TURMA
   

        UPDATE SIGAA.dbo.Turmas
            SET VAG_OCUP  = @VAG_OCUP
            WHERE COD_DISC = @COD_DISC AND ANO = @ANO AND SEMESTRE = @SEMESTRE AND TURMA = @TURMA;
    END
GO
-- 11. O total de vagas ocupadas não deve ser superior ao total de vagas disponíveis; CHECK

-- 12. Um professor pode lecionar o máximo de 5 turmas por semestre;
CREATE TRIGGER TG_VALIDAR_TOTAL_TURMA_PROFESSOR ON Turmas
FOR INSERT, UPDATE
AS
    BEGIN
        DECLARE 
              @COD_PROF INT
            , @SEMESTRE INT;
            SELECT @COD_PROF = @COD_PROF FROM Turmas;

        IF ( (SELECT COUNT(*) FROM Turmas
                WHERE COD_PROF = @COD_PROF AND SEMESTRE = @SEMESTRE ) = 5)
            BEGIN
                RAISERROR('O PROFESSOR INFORMADO JÁ LECIONA COM A CARGA MÁXIMA DE DISCIPINAS POSSÍVEL', 10 , 1 )
                ROLLBACK;
            END
    END
GO
-- 13. A adição ou modificação de pré-requisitos de uma disciplina só pode ser realizada se não gerar
-- nenhuma inconsistência em relação aos currículos cadastrados, os históricos dos alunos e as
-- disciplinas matriculadas.


-- 14. O total de créditos cursados e a mgp do aluno deve ser modificado automaticamente pela
-- alteração do histórico do aluno;
CREATE TRIGGER TG_ALUNO_MGP ON [Historicos_Escolares]
FOR UPDATE, INSERT
AS
    BEGIN
        DECLARE 
              @MAT_ALU INT
            , @TOT_CRED  INT
            , @MGP NUMERIC(4, 2)
            , @I INT;
            SELECT @MAT_ALU = MAT_ALU FROM deleted;

            SELECT @TOT_CRED = SUM(d.QTD_CRED) FROM Historicos_Escolares he
                RIGHT JOIN Disciplinas d ON d.COD_DISC = he.COD_DISC
                WHERE he.MAT_ALU = @MAT_ALU AND he.SITUACAO = 'AP';

            SELECT @MGP = SUM(he.MEDIA)
                ,  @I = COUNT(*)
                FROM  Historicos_Escolares he WHERE MAT_ALU = @MAT_ALU;

            SELECT @MGP = @MGP/@I;
            PRINT @MGP
            PRINT @TOT_CRED
            UPDATE Alunos
                SET TOT_CRED = @TOT_CRED
                    , MGP = @MGP
                WHERE MAT_ALU = @MAT_ALU;    
        
    END
GO


-- 15. O aluno só pode ser modificado de curso se não possuir históricos ou matrículas em
-- disciplinas;

CREATE TRIGGER TG_UPDATE_ALUNO ON [Alunos]
FOR UPDATE
AS
    IF(UPDATE(COD_CURSO))
    BEGIN
        DECLARE 
            @MAT_ALU INT;
        SELECT @MAT_ALU = MAT_ALU FROM deleted;

        IF ( (SELECT COUNT(*) FROM SIGAA.dbo.[Historicos_Escolares] WHERE MAT_ALU = @MAT_ALU) > 0
            OR (SELECT COUNT(*) FROM SIGAA.dbo.[Tumas_Matriculadas] WHERE MAT_ALU = @MAT_ALU) > 0 )
            BEGIN
                RAISERROR('O ALUNO JÁ POSSUI HISTÓRICO ESCOLAR OU JÁ ESTÁ MATRICULADO,
                     COM ISSO NÃO É POSSÍVEL REALIZAR ESSA OPERAÇÃO', 10 , 1 )
                ROLLBACK;
            END
    END
GO

-- 16. A idade mínima para alunos é de 16 anos. CHECK

-- 17. Um aluno não pode realizar matrícula em uma disciplina para a qual não possua o pré-
-- requisito;
CREATE TRIGGER TG_CALIDAR_REQUISITO_DISCIPLINA ON [Tumas_Matriculadas]
FOR INSERT
AS
    BEGIN
    DECLARE
        @COD_DISC INT
        , @CONT1 INT
        , @CONT2 INT;
    SELECT @COD_DISC = COD_DISC FROM inserted;

    SELECT @CONT1 = COUNT(*) FROM [Pre_Requisitos] WHERE COD_DISC = @COD_DISC;

    SELECT @CONT2 = COUNT(he.COD_DISC) FROM [Historicos_Escolares] he
    INNER JOIN (SELECT * FROM [Pre_Requisitos]
                    WHERE COD_DISC = @COD_DISC) pr    
        ON he.COD_DISC = pr.COD_DISC;

    IF  (@CONT1 != @CONT2)
        BEGIN
            RAISERROR('O ALUNO NÃO POSSUI OS PRÉ-REQUISITOS SUFICIENTE PARA CURSAR ESTA MATERIA', 10 , 1 );
            ROLLBACK;
        END
    END
GO
