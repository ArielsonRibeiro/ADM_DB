--1. O total de créditos do curso deve ser considerado como um campo calculado, ou seja, a sua
--alteração deve ocorrer em consequência de mudanças na grade do curso;
--USE SIGAA;


CREATE TRIGGER TG_ALTER_GRADE_CURSO_CALCULAR_CREDITOS ON [Curriculos]
    FOR INSERT, UPDATE, DELETE 
AS
BEGIN
    DECLARE
    @COD_CURSO TINYINT;
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
            WHERE CUR.COD_CURSO = @COD_CURSO)
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

-- 4.O número máximo de créditos de um curso é 220;
-- check;

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

CREATE TRIGGER TG_VERIFICAR_PRE_REQUISITOS ON [Curriculos]
    FOR INSERT, UPDATE
AS
    BEGIN
    DECLARE
          @COD_DISC INT
        , @COD_CURSO TINYINT
        , @CONT1 INT
        , @CONT2 INT;
        SELECT @COD_DISC = COD_DISC FROM inserted;
        SELECT @COD_CURSO = COD_CURSO FROM inserted;

        SELECT @CONT1 = COUNT(*) FROM [Pre_Requisitos] 
            WHERE COD_DISC = @COD_DISC;
        
        SELECT @CONT2 = COUNT(*) FROM Pre_Requisitos p 
            INNER JOIN Curriculos c on c.COD_DISC = p.COD_DISC_PRE
            WHERE p.COD_DISC = @COD_DISC AND c.COD_CURSO = @COD_CURSO;
            
        IF(@CONT1 != @CONT2)
            BEGIN
            RAISERROR('A DISCIPLINA QUE ESTÀ SENDO INSERIDO NÃO TEM OS PRÉ REQUISITOS CADASTRADO NO CURSO', 10 , 1 )
                ROLLBACK;
            END


    END
GO

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
            , @SEMESTRE TINYINT
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
-- 11. O total de vagas ocupadas não deve ser superior ao total de vagas disponíveis; 
--CHECK

-- 12. Um professor pode lecionar o máximo de 5 turmas por semestre;
CREATE TRIGGER TG_VALIDAR_TOTAL_TURMA_PROFESSOR ON Turmas
FOR INSERT, UPDATE
AS
    BEGIN
        DECLARE 
              @COD_PROF INT
            , @SEMESTRE TINYINT;
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

CREATE TRIGGER TG_VALIDAR_PRE_REQUISITO ON [Pre_Requisitos]
FOR INSERT, UPDATE
AS
    BEGIN
        DECLARE 
              @COD_DISC INT
            , @COD_DISC_PRE INT;
        SELECT @COD_DISC = COD_DISC FROM inserted;
        SELECT @COD_DISC_PRE = COD_DISC_PRE FROM inserted;

        IF EXISTS (SELECT * FROM Historicos_Escolares HE1
                            WHERE COD_DISC = @COD_DISC AND NOT EXISTS (SELECT * FROM Historicos_Escolares HE2 
                                                                        WHERE HE2.MAT_ALU = HE1.MAT_ALU AND HE2.COD_DISC = @COD_DISC_PRE))
            BEGIN
                RAISERROR('CONFLITO ENTRE O PRÉ REQUISITO E OS HISTORICOS DOS ALUNOS', 10 , 1 )
                ROLLBACK;
            END
        IF EXISTS (SELECT * FROM Curriculos C1
                            WHERE COD_DISC = @COD_DISC AND NOT EXISTS (SELECT * FROM Curriculos C2
                                                                        WHERE C2.COD_CURSO = C1.COD_CURSO AND C2.COD_DISC = @COD_DISC_PRE))
            BEGIN
                RAISERROR('CONFLITO ENTRE O PRÉ REQUISITO E AS CURRICULOS DOS CURSOS', 10 , 1 )
                ROLLBACK;
            END

        IF EXISTS (SELECT * FROM Tumas_Matriculadas T1
                            WHERE T1.COD_DISC = @COD_DISC AND NOT EXISTS (SELECT * FROM Tumas_Matriculadas T2
                                                                            WHERE T2.MAT_ALU = T1.MAT_ALU  
                                                                            AND T2.ANO = T1.ANO
                                                                            AND T2.SEMESTRE = T1.SEMESTRE
                                                                            AND T2.COD_DISC = @COD_DISC_PRE
                                                                            OR NOT EXISTS (SELECT * FROM Historicos_Escolares HE2 
                                                                                WHERE HE2.MAT_ALU = T1.MAT_ALU AND HE2.COD_DISC = @COD_DISC_PRE) ) )
            BEGIN
                RAISERROR('CONFLITO ENTRE O PRÉ REQUISITO E AS TURMAS MATRICULADAS', 10 , 1 )
                ROLLBACK;
            END


    END
GO 


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
            SELECT @MAT_ALU = MAT_ALU FROM inserted;

            SELECT @TOT_CRED = SUM(d.QTD_CRED) FROM Historicos_Escolares he
                RIGHT JOIN Disciplinas d ON d.COD_DISC = he.COD_DISC
                WHERE he.MAT_ALU = @MAT_ALU AND he.SITUACAO = 'AP';

            SELECT @MGP = SUM(he.MEDIA)
                ,  @I = COUNT(*)
                FROM  Historicos_Escolares he WHERE MAT_ALU = @MAT_ALU;

            IF(@MGP IS NOT NULL AND @MGP != 0 )
                SELECT @MGP = @MGP/@I;
            ELSE
                SET @MGP = 0  
            IF(@TOT_CRED IS NULL )
                SET @TOT_CRED = 0 ;  

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
        , @CURSO_DISC TINYINT
        , @CURSO_ALU TINYINT;
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
        , @PERIODO TINYINT
        , @MAT_ALU INT
        , @ANO INT
        , @SEMESTRE INT
        , @COD_CURSO TINYINT
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
                , @N2 NUMERIC(3,1)
                , @N3 NUMERIC(3,1);

            SELECT @N1 = NOTA_1 FROM inserted;
            SELECT @N2 = NOTA_2 FROM inserted;
             SELECT @N3 = NOTA_3 FROM inserted;

            IF ( @N1 IS NULL AND @N2 IS NULL and @N3 IS NOT NULL)
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
-- 23. O valor das faltas em uma unidade não pode exceder a 1/3 do total de aulas da disciplina;
CREATE TRIGGER TG_VALIDAR_FALTAS_POR_UNIDADE ON [Tumas_Matriculadas]
FOR INSERT, UPDATE
AS
    BEGIN
    DECLARE
        @COD_DISC INT
        , @TOT_CRED INT
        , @FALTAS_1 INT
        , @FALTAS_2 INT
        , @FALTAS_3 INT
        , @UM_TERCO_TOTAL_AULAS NUMERIC(3, 1);

    SELECT @COD_DISC = COD_DISC
        , @FALTAS_1 = FALTAS_1
        , @FALTAS_2 = FALTAS_2
        , @FALTAS_3 = FALTAS_3
        FROM inserted;

    SELECT @TOT_CRED = QTD_CRED FROM Disciplinas 
        WHERE COD_DISC = @COD_DISC;
    
    SET @UM_TERCO_TOTAL_AULAS = (@TOT_CRED *18)/3;
    
    

    IF(@UM_TERCO_TOTAL_AULAS < @FALTAS_1 OR @UM_TERCO_TOTAL_AULAS < @FALTAS_2 OR @UM_TERCO_TOTAL_AULAS < @FALTAS_2)
        BEGIN
        RAISERROR('NÃO É POSSÍVEL ESTA QUANTIDADE DE FALTAS POR UNIDADE(APENAS 1/3 DO TOTAL É PERMITIDO', 10 , 1 );
            ROLLBACK;
        END

    END
GO

-- 24. A quarta nota só pode ser preenchida se uma das anteriores estiver nula;

CREATE TRIGGER TG_PREENCHER_4_NOTA ON [Tumas_Matriculadas]
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


    IF( (SELECT COUNT(*) FROM [Historicos_Escolares] WHERE COD_DISC = @COD_DISC AND MAT_ALU = MAT_ALU AND SITUACAO = 'AP') > 1)
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
        , @CURSO_DISC TINYINT
        , @CURSO_ALU TINYINT;
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
CREATE TRIGGER TG_VALIDAR_FALTAS_HIST ON [Historicos_Escolares]
FOR INSERT, UPDATE
AS
    BEGIN
    DECLARE
        @COD_DISC INT
        , @TOT_CRED INT
        , @FALTAS INT
        , @TOTAL_AULAS INT;

    SELECT @COD_DISC = COD_DISC
        , @FALTAS = FALTAS
        FROM inserted;

    SELECT @TOT_CRED = QTD_CRED FROM Disciplinas 
        WHERE COD_DISC = @COD_DISC;
    
    SET @TOTAL_AULAS = @TOT_CRED *18;
    
    

    IF(@TOTAL_AULAS < @FALTAS)
     
        BEGIN
        RAISERROR('NÃO É POSSÍVEL ESTA QUANTIDADE DE FALTAS, EXCEDE O TOTAL DE AULAS', 10 , 1 );
            ROLLBACK;
        END

    END
GO




-- 29. Deve ser validada a consistência da situação do histórico em relação aos dados de média e
-- faltas.

CREATE TRIGGER TG_VALIDAR_CONSISTENCIA_SITUACAO ON [Historicos_Escolares]
FOR INSERT, UPDATE
AS
    BEGIN
        DECLARE
            @COD_DISC INT
            , @TOT_CRED INT
            , @MEDIA NUMERIC(4,1)
            , @SITUACAO CHAR(2)
            , @FALTAS INT
            , @TOTAL_AULAS INT;

        SELECT @COD_DISC = COD_DISC
            , @FALTAS = FALTAS
            , @MEDIA = MEDIA
            , @SITUACAO = SITUACAO
            FROM inserted;

        SELECT @TOT_CRED = QTD_CRED FROM Disciplinas 
            WHERE COD_DISC = @COD_DISC;
        
        SET @TOTAL_AULAS = @TOT_CRED *18;
        
        
        IF(  (( (@TOTAL_AULAS * 0.25) > @FALTAS) OR @MEDIA >= 5 ) AND @SITUACAO != 'AP')
            BEGIN
            RAISERROR('O ALUNO FOI APROVADO!, MAS CONSTA REPROVADO, NÃO É POSSÍVEL FAZER ESTE CADASTRO', 10 , 1 );
                ROLLBACK;
            END
        ELSE IF(  ( @MEDIA < 5 ) AND @SITUACAO IN ('AP', 'RF')  )
            BEGIN
                RAISERROR('O ALUNO FOI REPROVADO POR MÉDIA!, MAS A SITUCÃO NAO CONSTA ESTE CASO', 10 , 1 );
                ROLLBACK;
            END
        ELSE IF(  ( (@TOTAL_AULAS * 0.25) < @FALTAS)  AND @SITUACAO IN ('AP', 'RM')  )
            BEGIN
                RAISERROR('O ALUNO FOI REPROVADO POR FALTA!, MAS A SITUCÃO NAO CONSTA ESTE CASO', 10 , 1 );
                ROLLBACK;
            END

    END
GO


-- 30. Deve existir uma rotina para finalizar a turma, transferindo os dados da matrícula para o
-- histórico.

CREATE TRIGGER TG_FINALIZAR_TURMA ON [Tumas_Matriculadas]
FOR INSERT, UPDATE
AS
    BEGIN
    DECLARE
        @COD_DISC INT
        , @ANO INT
        , @MAT_ALU INT
        , @SEMESTRE TINYINT
        , @TOT_CRED INT
        , @FALTAS_1 INT
        , @FALTAS_2 INT
        , @FALTAS_3 INT
        , @N1 NUMERIC(3,1)
        , @N2 NUMERIC(3,1)
        , @N3 NUMERIC(3,1)
        , @N4 NUMERIC(3,1)
        , @TOTAL_FALTAS INT
        , @MEDIA NUMERIC(4, 1)
        , @SITUACAO CHAR(2)
        , @TOTAL_AULAS INT
        , @COUNT_QTD_AV INT;

    
    
    SELECT @COD_DISC = COD_DISC
        , @ANO = ANO
        , @SEMESTRE = SEMESTRE
        , @MAT_ALU = MAT_ALU 
        , @FALTAS_1 = FALTAS_1
        , @FALTAS_2 = FALTAS_2
        , @FALTAS_3 = FALTAS_3
        , @N1 = NOTA_1
        , @N2 = NOTA_2
        , @N3 = NOTA_3
        , @N4 = NOTA_4
        FROM inserted;

    SET @COUNT_QTD_AV = 0;
    IF(@N1 IS NOT NULL)
        SET @COUNT_QTD_AV += 1;
    IF(@N2 IS NOT NULL)
        SET @COUNT_QTD_AV +=1;
    IF(@N3 IS NOT NULL)
        SET @COUNT_QTD_AV +=1;
    IF(@N4 IS NOT NULL)
        SET @COUNT_QTD_AV +=1;
    PRINT @COUNT_QTD_AV

    IF(@FALTAS_1 IS NOT NULL AND @FALTAS_2 IS NOT NULL  AND @FALTAS_3 IS NOT NULL AND @COUNT_QTD_AV > 2)
        BEGIN
            SET @TOTAL_FALTAS = @FALTAS_1+@FALTAS_2+@FALTAS_3;
            SET @MEDIA = (ISNULL(@N1, 0) + ISNULL(@N2, 0) + ISNULL(@N3, 0) + ISNULL(@N4, 0))/3;

            SELECT @TOT_CRED = QTD_CRED FROM Disciplinas 
                WHERE COD_DISC = @COD_DISC;

            SET @TOTAL_AULAS = @TOT_CRED *18;

            IF(@MEDIA < 5)
                BEGIN
                    SET @SITUACAO = 'RM';
                END
            ELSE IF( (@TOTAL_AULAS * 0.25) < @TOTAL_FALTAS)
                BEGIN
                    SET @SITUACAO = 'RF';
                END
            ELSE
                BEGIN
                    SET @SITUACAO = 'AP';
                END

            INSERT Historicos_Escolares(ANO       
                , SEMESTRE
                , COD_DISC
                , MAT_ALU 
                , MEDIA   
                , FALTAS  
                , SITUACAO) VALUES (
                    @ANO, @SEMESTRE,@COD_DISC, @MAT_ALU, @MEDIA, @TOTAL_FALTAS, @SITUACAO
                );
            
            END
    END
   
GO