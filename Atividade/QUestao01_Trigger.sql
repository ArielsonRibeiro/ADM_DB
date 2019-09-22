--1. O total de créditos do curso deve ser considerado como um campo calculado, ou seja, a sua
--alteração deve ocorrer em consequência de mudanças na grade do curso;
--USE SIGAA;


CREATE TRIGGER TG_ALTER_GRADE_CURSO_CALCULAR_CREDITOS ON [Curriculos]
    FOR INSERT, UPDATE, DELETE 
AS
BEGIN
    DECLARE
    @COD_CURSO INT;
    IF( (SELECT count(*) FROM inserted) > 0)
        BEGIN
           SELECT @COD_CURSO = COD_CURSO FROM inserted;    
        END
    ELSE
        BEGIN
           SELECT @COD_CURSO = COD_CURSO FROM deleted;        
        END

    UPDATE SIGAA.dbo.[Cursos]
        SET TOT_CRED = (Select SUM(disc.QTD_CRED)
            FROM Curriculos AS cur 
            RIGHT JOIN Disciplinas AS disc 
            ON disc.COD_DISC = cur.COD_DISC
            WHERE CUR.COD_CURSO = (SELECT COD_CURSO FROM INSERTED))
    WHERE COD_CURSO = @COD_CURSO;
    
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
CREATE TRIGGER TG_VALIDAR_REQUISITO_DISCIPLINA ON [Tumas_Matriculadas]
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
        ON he.COD_DISC = pr.COD_DISC_PRE
        WHERE UPPER(he.SITUACAO) = 'AP';

    IF  (@CONT1 != @CONT2)
        BEGIN
            RAISERROR('O ALUNO NÃO POSSUI OS PRÉ-REQUISITOS SUFICIENTE PARA CURSAR ESTA MATERIA', 10 , 1 );
            ROLLBACK;
        END
    END
GO

-- 18. A matrícula em disciplinas já cursadas (aprovadas) não pode ser feita;
CREATE TRIGGER TG_VALIDAR_DISCIPLINA_JA_CURSADA ON [Tumas_Matriculadas]
FOR INSERT
AS
    BEGIN
    DECLARE
        @COD_DISC INT
        , @MAT_ALU INT;
    SELECT @COD_DISC = COD_DISC
            , @MAT_ALU = MAT_ALU
    FROM inserted;


    IF(EXISTS (SELECT * FROM [Historicos_Escolares] WHERE COD_DISC = @COD_DISC AND MAT_ALU = MAT_ALU AND SITUACAO = 'AP'))
        BEGIN
        RAISERROR('O ALUNO JÀ CURSOU A DISCIPLINA', 10 , 1 );
            ROLLBACK;
        END

    END
GO


-- 19. O aluno só pode efetuar matrículas em disciplinas que pertençam ao seu currículo;

CREATE TRIGGER TG_VALIDAR_DISCIPLINA_PERTENCE_AO_CURSO_DO_ALUNO ON [Tumas_Matriculadas]
FOR INSERT
AS
    BEGIN
    DECLARE
        @COD_DISC INT
        , @MAT_ALU INT
        , @CURSO_DISC INT
        , @CURSO_ALU INT;
    SELECT @COD_DISC = COD_DISC
            , @MAT_ALU = MAT_ALU
    FROM inserted;
    
    SELECT @CURSO_DISC = COD_CURSO FROM Curriculos WHERE COD_DISC = @COD_DISC;
    SELECT @CURSO_ALU = COD_CURSO FROM Alunos WHERE MAT_ALU = @MAT_ALU;
    

    IF(@CURSO_ALU != @CURSO_DISC)
        BEGIN
        RAISERROR('ESTÁ DISCIPLINA NÂO PERTENCE AO CURRICULO DO CURSO DO ALUNO!', 10 , 1 );
            ROLLBACK;
        END

    END
GO


-- 20. O limite máximo de créditos matriculados em um mesmo período é dado pelo período de
-- maior quantidade de créditos do curso;
CREATE TRIGGER TG_VALIDAR_QTD_MAXIMA_CREDITO ON [Tumas_Matriculadas]
FOR INSERT
AS
    BEGIN
    DECLARE
        @COD_DISC INT
        , @PERIODO INT
        , @MAT_ALU INT
        , @ANO INT
        , @SEMESTRE INT
        , @COD_CURSO INT
        , @QTD_CRED_MAIOR_PER INT
        , @QTD_CRED_MAT INT;
    SELECT @COD_DISC = COD_DISC, @MAT_ALU = MAT_ALU, @ANO = ANO, @SEMESTRE = SEMESTRE FROM inserted;

    SELECT @PERIODO = PERIODO, @COD_CURSO = COD_CURSO FROM Curriculos WHERE COD_DISC = @COD_DISC;

    -- SELECT @QTD_CRED_MAIOR_PER = SUM(D.QTD_CRED) FROM Curriculos C
    --     INNER JOIN Disciplinas D ON D.COD_DISC = C.COD_DISC
    --     WHERE (C.PERIODO = @PERIODO AND C.COD_CURSO = @COD_CURSO);
    
    SELECT TOP 1 @QTD_CRED_MAIOR_PER = SUM(D.QTD_CRED) FROM Disciplinas D
    INNER JOIN Curriculos C ON C.COD_DISC = D.COD_DISC
    WHERE C.COD_CURSO = @COD_CURSO
    GROUP BY C.PERIODO
    ORDER BY 1 DESC;

    SELECT @QTD_CRED_MAT = SUM(D.QTD_CRED) FROM Tumas_Matriculadas TM
        INNER JOIN Disciplinas D ON D.COD_DISC =  TM.COD_DISC
        WHERE MAT_ALU = @MAT_ALU AND ANO = @ANO AND SEMESTRE = @SEMESTRE;
    
    IF(@QTD_CRED_MAIOR_PER < @QTD_CRED_MAT)
        BEGIN
        RAISERROR('O ALUNO NÃO PODE SE MATRICULAR NESSA DISCIPLINA, POIS EXCEDE O NÚMERO MAXIMO DE CRÉDITO DE UM MESMO PERÍODO!', 10 , 1 );
            ROLLBACK;
        END

    END
GO


-- 21. Sequencialmente, o aluno só pode ter uma nota com o valor nulo, ou seja, a nota 3 não pode
-- ser preenchida se pelo menos uma das notas anteriores (1 e 2) possuírem valor;

CREATE TRIGGER TG_VALIDAR_ORDEM_NOTAS ON [Tumas_Matriculadas]
FOR INSERT, UPDATE
AS
    IF(UPDATE(NOTA_3))
        BEGIN
            DECLARE
                @N1 NUMERIC(3,1)
                , @N2 NUMERIC(3,1);

            SELECT @N1 = NOTA_1 FROM inserted;
            SELECT @N2 = NOTA_2 FROM inserted;

            IF ( @N1 IS NULL AND @N2 IS NULL)
                BEGIN
                    RAISERROR('NÃO É POSSÍVEL CADASTRAR A 3º NOTA SEM QUE PELO MENOS UMA NOTA ESTEJA CADASTRADA', 10 , 1 );
                    ROLLBACK;
                END
        END
    
GO

-- 22. As faltas devem ser preenchidas sequencialmente, ou seja, as faltas da segunda unidade só
--  podem ser lançadas quando as da primeira já o tiverem sido;

CREATE TRIGGER TG_VALIDAR_ORDEM_FALTAS ON [Tumas_Matriculadas]
FOR INSERT, UPDATE
AS
    BEGIN
        DECLARE
            @F INT;
        IF(UPDATE(FALTAS_2))
            BEGIN
                SELECT @F = FALTAS_1 FROM inserted;
                IF ( @F IS NULL)
                    BEGIN
                        RAISERROR('NÃO É POSSIVEL CADASTRAR AS FALTAS DA 2ª UNIDADES SEM ANTES TERC CADASTRADA DA 1ª', 10 , 1 );
                        ROLLBACK;
                    END
            END
        IF(UPDATE(FALTAS_3))
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
-- 23. O valor das faltas em uma unidade não pode exceder a 1/3 do total de aulas da disciplina;


-- 24. A quarta nota só pode ser preenchida se uma das anteriores estiver nula;

ALTER TRIGGER TG_PREENCHER_4_NOTA ON [Tumas_Matriculadas]
FOR INSERT, UPDATE
AS
    IF(UPDATE(NOTA_4))
        BEGIN
            DECLARE
                @N1 NUMERIC(3,1)
                , @N2 NUMERIC(3,1)
                , @N3 NUMERIC(3,1);

            SELECT @N1 = NOTA_1 FROM inserted;
            SELECT @N2 = NOTA_2 FROM inserted;
            SELECT @N3 = NOTA_3 FROM inserted;
            IF ( (@N1 IS NOT NULL) AND (@N2 IS NOT NULL) AND (@N3 IS NOT NULL))
                BEGIN
                    RAISERROR('NÃO É POSSÍVEL CADASTRAR A 4º NOTA, POIS O ALUNO JÁ TEM AS 3 PRIMEIRAS NOTAS CADASTRADAS', 10 , 1 );
                    ROLLBACK;
                END
        END
    
GO

-- 25. Não pode ser lançada no histórico uma disciplina em um período em que o pré-requisito da
-- disciplina não tenha sido cursado em períodos anteriores;

CREATE TRIGGER TG_LANCAR_DISCIPLINA_VALIDAR_PRE_REQ ON [Historicos_Escolares]
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
        ON he.COD_DISC = pr.COD_DISC_PRE
        WHERE UPPER(he.SITUACAO) = 'AP';

    IF  (@CONT1 != @CONT2)
        BEGIN
            RAISERROR('O ALUNO NÃO POSSUI OS PRÉ-REQUISITOS SUFICIENTE PARA CADASTRAR ESSE DISCIPLINA NO HISTÓRICO', 10 , 1 );
            ROLLBACK;
        END
    END
GO

-- 26. Só pode existir uma ocorrência com aprovação para uma disciplina do histórico. Além disso,
-- está ocorrência deve ser cronologicamente a última da disciplina no histórico do aluno;
CREATE TRIGGER TG_LANCAR_DISCIPLINA_VALIDAR_ALUNO_JA_CURSOU ON [Historicos_Escolares]
FOR INSERT
AS
    BEGIN
    DECLARE
        @COD_DISC INT
        , @MAT_ALU INT;
    SELECT @COD_DISC = COD_DISC
            , @MAT_ALU = MAT_ALU
    FROM inserted;


    IF(EXISTS (SELECT * FROM [Historicos_Escolares] WHERE COD_DISC = @COD_DISC AND MAT_ALU = MAT_ALU AND SITUACAO = 'AP'))
        BEGIN
        RAISERROR('O ALUNO JÀ CURSOU A DISCIPLINA E TEVE APROVAÇÃO, COM ISSO NÃO É POSSÍVEL CADASTRAR ESSA DISCIPLINA', 10 , 1 );
            ROLLBACK;
        END

    END
GO

-- 27. Não podem ser lançadas disciplinas que não pertençam a grade curricular do aluno;
CREATE TRIGGER TG_VALIDAR_DISCIPLINA_PERTENCE_AO_CURSO_DO_ALUNO_LANCAR_HISTORICO ON [Historicos_Escolares]
FOR INSERT
AS
    BEGIN
    DECLARE
        @COD_DISC INT
        , @MAT_ALU INT
        , @CURSO_DISC INT
        , @CURSO_ALU INT;
    SELECT @COD_DISC = COD_DISC
            , @MAT_ALU = MAT_ALU
    FROM inserted;
    
    SELECT @CURSO_DISC = COD_CURSO FROM Curriculos WHERE COD_DISC = @COD_DISC;
    SELECT @CURSO_ALU = COD_CURSO FROM Alunos WHERE MAT_ALU = @MAT_ALU;
    

    IF(@CURSO_ALU != @CURSO_DISC)
        BEGIN
        RAISERROR('ESTÁ DISCIPLINA NÂO PERTENCE AO CURRICULO DO CURSO DO ALUNO, COM ISSO NÃO PODE SER LANÇADA!', 10 , 1 );
            ROLLBACK;
        END

    END
GO

-- 28. O total de faltas do histórico não pode exceder ao total de aulas da disciplina;


-- 29. Deve ser validada a consistência da situação do histórico em relação aos dados de média e
-- faltas.

CREATE TRIGGER VALIDAR_CONSISTENCIA_HISTORICO_ALU ON [Historicos_Escolares]
FOR INSERT, UPDATE
AS
    
GO

-- 30. Deve existir uma rotina para finalizar a turma, transferindo os dados da matrícula para o
-- histórico.