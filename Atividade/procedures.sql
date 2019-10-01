CREATE PROCEDURE DBO.INSERIR_ALUNO
      @MAT_ALU   INT           
    , @COD_CURSO TINYINT       
    , @DAT_NASC  DATE          
    , @TOT_CRED  INT           
    , @MGP       NUMERIC(4, 2) 
    , @NOM_ALU   VARCHAR(60) 
AS
    BEGIN
        INSERT INTO Alunos(   
            MAT_ALU   
            , COD_CURSO 
            , DAT_NASC  
            , TOT_CRED  
            , MGP       
            , NOM_ALU   )
        VALUES(
            @MAT_ALU  
            , @COD_CURSO
            , @DAT_NASC 
            , @TOT_CRED 
            , @MGP      
            , @NOM_ALU  
            )   
    END
GO
    
-- EXECUTE dbo.INSERIR_ALUNO
--     112
--   , 1
--   , "1998-02-02"
--   , 0
--   , 0
--   ,"jOÃO"
-- GO

CREATE PROCEDURE DBO.MODIFICAR_ALUNO
      @MAT_ALU   INT           
    , @COD_CURSO TINYINT       
    , @DAT_NASC  DATE          
    , @TOT_CRED  INT           
    , @MGP       NUMERIC(4, 2)
    , @NOM_ALU   VARCHAR(60) 
AS
    BEGIN
        UPDATE Alunos
            SET 
                MAT_ALU      = ISNULL(@MAT_ALU, MAT_ALU)
                , COD_CURSO  = ISNULL(@COD_CURSO, COD_CURSO)
                , DAT_NASC   = ISNULL(@DAT_NASC, DAT_NASC)
                , TOT_CRED   = ISNULL(@TOT_CRED, TOT_CRED)
                , MGP        = ISNULL(@MGP, MGP)
                , NOM_ALU    = ISNULL(@NOM_ALU, NOM_ALU)
            WHERE MAT_ALU = @MAT_ALU;
    END
GO
-- EXECUTE dbo.MODIFICAR_ALUNO
--     112
--   , 1
--   , "1998-02-03"
--   , 0
--   , 0
--   ,"jOÃO"
-- GO

-- SELECT * FROM Alunos WHERE MAT_ALU = 112

CREATE PROCEDURE DBO.EXCLUIR_ALUNO
      @MAT_ALU   INT           
AS
    BEGIN
        DELETE Alunos WHERE MAT_ALU = @MAT_ALU;
    END
GO
-- EXECUTE dbo.EXCLUIR_ALUNO
--     112
-- GO

CREATE PROCEDURE DBO.INSERIR_CURRICULO
      @COD_CURSO  TINYINT 
    , @COD_DISC   INT     
    , @PERIODO    TINYINT 
AS
    BEGIN
        INSERT INTO Curriculos(
              COD_CURSO 
            , COD_DISC  
            , PERIODO   
        )VALUES(
              @COD_CURSO  
            , @COD_DISC   
            , @PERIODO   
        );
    END
GO

CREATE PROCEDURE DBO.MODIFICAR_CURRICULO
      @COD_CURSO  TINYINT 
    , @COD_DISC   INT     
    , @PERIODO    TINYINT 
AS
    BEGIN
        UPDATE Curriculos
            SET 
                  COD_CURSO = ISNULL(@COD_CURSO, COD_CURSO)
                , COD_DISC  = ISNULL(@COD_DISC, COD_DISC)
                , PERIODO   = ISNULL(@PERIODO, PERIODO)    
            WHERE COD_CURSO = @COD_CURSO AND COD_DISC = @COD_DISC;       
    END
GO

CREATE PROCEDURE DBO.EXCLUIR_CURRICULO
      @COD_CURSO  TINYINT 
    , @COD_DISC   INT     
AS
    BEGIN
        DELETE Curriculos WHERE COD_CURSO = @COD_CURSO AND COD_DISC = @COD_DISC;     
    END
GO

CREATE PROCEDURE DBO.INSERIR_CURSO
      @COD_CURSO TINYINT     
    , @TOT_CRED  INT         
    , @NOM_CURSO VARCHAR(60) 
    , @COD_COORD INT
AS
    BEGIN
        INSERT INTO Cursos(
            COD_CURSO 
            , TOT_CRED  
            , NOM_CURSO 
            , COD_COORD 
        )VALUES(
            @COD_CURSO
            , @TOT_CRED 
            , @NOM_CURSO
            , @COD_COORD
        );
    END  
GO  

CREATE PROCEDURE DBO.MODIFICAR_CURSO
      @COD_CURSO TINYINT     
    , @TOT_CRED  INT         
    , @NOM_CURSO VARCHAR(60) 
    , @COD_COORD INT
AS
    BEGIN
        UPDATE Cursos
            SET
                COD_CURSO   = ISNULL(@COD_CURSO, COD_CURSO)
                , TOT_CRED  = ISNULL(@TOT_CRED, TOT_CRED)
                , NOM_CURSO = ISNULL(NOM_CURSO, NOM_CURSO)
                , COD_COORD = COD_COORD 
        WHERE COD_CURSO = @COD_CURSO;
    END  
GO  

CREATE PROCEDURE DBO.EXCLUIR_CURSO
      @COD_CURSO TINYINT     
    , @TOT_CRED  INT         
    , @NOM_CURSO VARCHAR(60) 
    , @COD_COORD INT
AS
    BEGIN
        DELETE Cursos
        WHERE COD_CURSO = @COD_CURSO;
    END  
GO  

CREATE PROCEDURE DBO.INSERIR_DISCIPLINA
      @COD_DISC   INT         
    , @QTD_CRED   TINYINT     
    , @NOM_DISC   VARCHAR(60) 
AS
    BEGIN
        INSERT INTO Disciplinas(
                COD_DISC 
            , QTD_CRED 
            , NOM_DISC 
        ) VALUES(
            @COD_DISC 
            , @QTD_CRED 
            , @NOM_DISC                 
        );
    END
GO

CREATE PROCEDURE DBO.MODIFICAR_DISCIPLINA
      @COD_DISC   INT         
    , @QTD_CRED   TINYINT     
    , @NOM_DISC   VARCHAR(60) 
AS
    BEGIN
        UPDATE Disciplinas
            SET 
                  COD_DISC = @COD_DISC
                , QTD_CRED = ISNULL(@QTD_CRED, QTD_CRED)
                , NOM_DISC = ISNULL(@NOM_DISC, NOM_DISC)
            WHERE COD_DISC = @COD_DISC;
        
    END
GO

CREATE PROCEDURE DBO.EXCLUIR_DISCIPLINA
      @COD_DISC   INT         
AS
    BEGIN
        DELETE Disciplinas WHERE COD_DISC = @COD_DISC; 
    END
GO

CREATE PROCEDURE DBO.INSERIR_PRE_REQUISITO_DISCIPLINA
      @COD_DISC       INT 
    , @COD_DISC_PRE INT 
AS
    BEGIN
        INSERT INTO Pre_Requisitos(
             COD_DISC     
            , COD_DISC_PRE 
        ) VALUES (
              @COD_DISC    
            , @COD_DISC_PRE
        );
    END
GO

CREATE PROCEDURE DBO.MODIFICAR_PRE_REQUISITO_DISCIPLINA
      @COD_DISC     INT 
    , @COD_DISC_PRE INT
AS
    BEGIN
        UPDATE Pre_Requisitos
            SET 
                  COD_DISC     = @COD_DISC    
                , COD_DISC_PRE = @COD_DISC_PRE
            WHERE   COD_DISC     = @COD_DISC
                AND COD_DISC_PRE = @COD_DISC_PRE;
    END
GO

CREATE PROCEDURE DBO.EXCLUIR_PRE_REQUISITO_DISCIPLINA
      @COD_DISC     INT 
    , @COD_DISC_PRE INT
AS
    BEGIN
        DELETE Pre_Requisitos
            WHERE   COD_DISC     = @COD_DISC
                AND COD_DISC_PRE = @COD_DISC_PRE;
    END
GO

CREATE PROCEDURE DBO.INSERIR_HISTORICO_ESCOLAR
      @ANO      INT          
    , @SEMESTRE TINYINT      
    , @COD_DISC INT          
    , @MAT_ALU  INT          
    , @MEDIA    NUMERIC(4,2) 
    , @FALTAS   INT          
    , @SITUACAO CHAR(2)
AS
    BEGIN
        INSERT INTO Historicos_Escolares(
              ANO      
            , SEMESTRE 
            , COD_DISC 
            , MAT_ALU  
            , MEDIA    
            , FALTAS   
            , SITUACAO 
        ) VALUES(
              @ANO      
            , @SEMESTRE 
            , @COD_DISC 
            , @MAT_ALU  
            , @MEDIA    
            , @FALTAS   
            , @SITUACAO 
        );
    END
GO

CREATE PROCEDURE DBO.MODIFICAR_HISTORICO_ESCOLAR
      @ANO      INT          
    , @SEMESTRE TINYINT      
    , @COD_DISC INT          
    , @MAT_ALU  INT          
    , @MEDIA    NUMERIC(4,2) 
    , @FALTAS   INT          
    , @SITUACAO CHAR(2)
AS
    BEGIN
        UPDATE Historicos_Escolares
            SET
                 ANO       = @ANO      
                , SEMESTRE = @SEMESTRE 
                , COD_DISC = @COD_DISC 
                , MAT_ALU  = @MAT_ALU  
                , MEDIA    = @MEDIA    
                , FALTAS   = @FALTAS   
                , SITUACAO = @SITUACAO 

            WHERE   ANO      = @ANO     
                AND SEMESTRE = @SEMESTRE
                AND COD_DISC = @COD_DISC
                AND  MAT_ALU = @MAT_ALU;
    END
GO

CREATE PROCEDURE DBO.EXCLUIR_HISTORICO_ESCOLAR
      @ANO      INT          
    , @SEMESTRE TINYINT      
    , @COD_DISC INT          
    , @MAT_ALU  INT
AS
    BEGIN
        DELETE Historicos_Escolares 
            WHERE   ANO      = @ANO     
                AND SEMESTRE = @SEMESTRE
                AND COD_DISC = @COD_DISC
                AND  MAT_ALU = @MAT_ALU;
    END
GO

CREATE PROCEDURE DBO.INSERIR_PROFESSOR
      @COD_PROF    INT        
    , @COD_CURSO TINYINT    
    , @NOM_PROF  VARCHAR(60)
AS
    BEGIN
        INSERT INTO Professores(
              COD_PROF  
            , COD_CURSO 
            , NOM_PROF  
        ) VALUES(
              @COD_PROF  
            , @COD_CURSO 
            , @NOM_PROF  
        );
    END
GO

CREATE PROCEDURE DBO.MODIFICAR_PROFESSOR
      @COD_PROF    INT        
    , @COD_CURSO TINYINT    
    , @NOM_PROF  VARCHAR(60)
AS
    BEGIN
        UPDATE Professores
            SET
                  COD_PROF  = @COD_PROF       
                , COD_CURSO = @COD_CURSO  
                , NOM_PROF  = @NOM_PROF 
            WHERE COD_PROF = @COD_PROF;
    END
GO

CREATE PROCEDURE DBO.EXCLUIR_PROFESSOR
      @COD_PROF    INT        
    , @COD_CURSO TINYINT    
    , @NOM_PROF  VARCHAR(60)
AS
    BEGIN
        DELETE Professores
            WHERE COD_PROF = @COD_PROF;
    END
GO

CREATE PROCEDURE DBO.INSERIR_TURMA_MATRICULADA
      @ANO       INT            
    , @SEMESTRE  TINYINT        
    , @COD_DISC  INT            
    , @TURMA     CHAR(3)        
    , @MAT_ALU   INT            
    , @NOTA_1    NUMERIC(3, 1)
    , @NOTA_2    NUMERIC(3, 1)
    , @NOTA_3    NUMERIC(3, 1)
    , @NOTA_4    NUMERIC(3, 1)
    , @FALTAS_1  INT
    , @FALTAS_2  INT
    , @FALTAS_3  INT
AS
    BEGIN
        INSERT INTO Tumas_Matriculadas(
              ANO      
            , SEMESTRE 
            , COD_DISC 
            , TURMA    
            , MAT_ALU  
            , NOTA_1   
            , NOTA_2   
            , NOTA_3   
            , NOTA_4   
            , FALTAS_1 
            , FALTAS_2 
            , FALTAS_3        
        ) VALUES (
              @ANO     
            , @SEMESTRE
            , @COD_DISC
            , @TURMA   
            , @MAT_ALU 
            , @NOTA_1  
            , @NOTA_2  
            , @NOTA_3  
            , @NOTA_4  
            , @FALTAS_1
            , @FALTAS_2
            , @FALTAS_3
        );
    END
GO

CREATE PROCEDURE DBO.MODIFICAR_TURMA_MATRICULADA
      @ANO       INT            
    , @SEMESTRE  TINYINT        
    , @COD_DISC  INT            
    , @TURMA     CHAR(3)        
    , @MAT_ALU   INT            
    , @NOTA_1    NUMERIC(3, 1)
    , @NOTA_2    NUMERIC(3, 1)
    , @NOTA_3    NUMERIC(3, 1)
    , @NOTA_4    NUMERIC(3, 1)
    , @FALTAS_1  INT
    , @FALTAS_2  INT
    , @FALTAS_3  INT
AS
    BEGIN
        UPDATE Tumas_Matriculadas
            SET
                  ANO      = @ANO       
                , SEMESTRE = @SEMESTRE  
                , COD_DISC = @COD_DISC  
                , TURMA    = @TURMA     
                , MAT_ALU  = @MAT_ALU   
                , NOTA_1   = ISNULL(@NOTA_1, @NOTA_1)
                , NOTA_2   = ISNULL(@NOTA_2, @NOTA_2)  
                , NOTA_3   = ISNULL(@NOTA_3, @NOTA_3) 
                , NOTA_4   = ISNULL(@NOTA_4, @NOTA_4)  
                , FALTAS_1 = ISNULL(@FALTAS_1, @FALTAS_1)
                , FALTAS_2 = ISNULL(@FALTAS_2, @FALTAS_2) 
                , FALTAS_3 = ISNULL(@FALTAS_3, @FALTAS_3)  
            WHERE   ANO      = @ANO     
                AND SEMESTRE = @SEMESTRE
                AND COD_DISC = @COD_DISC
                AND TURMA    = @TURMA   
                AND MAT_ALU  = @MAT_ALU;
    END
GO

CREATE PROCEDURE DBO.EXCLUIR_TURMA_MATRICULADA
      @ANO       INT            
    , @SEMESTRE  TINYINT        
    , @COD_DISC  INT            
    , @TURMA     CHAR(3)        
    , @MAT_ALU   INT
AS
    BEGIN
        DELETE Tumas_Matriculadas
            WHERE   ANO      = @ANO     
                AND SEMESTRE = @SEMESTRE
                AND COD_DISC = @COD_DISC
                AND TURMA    = @TURMA   
                AND MAT_ALU  = @MAT_ALU; 

    END
GO

CREATE PROCEDURE DBO.INSERIR_TURMA
      @ANO       INT    
    , @SEMESTRE  TINYINT
    , @COD_DISC  INT    
    , @TURMA     CHAR(3)
    , @TOT_VAGAS INT    
    , @VAG_OCUP  INT    
    , @COD_PROF  INT
AS
    BEGIN
        INSERT INTO Turmas(
              ANO       
            , SEMESTRE  
            , COD_DISC  
            , TURMA     
            , TOT_VAGAS 
            , VAG_OCUP  
            , COD_PROF 
        ) VALUES (
              @ANO      
            , @SEMESTRE 
            , @COD_DISC 
            , @TURMA    
            , @TOT_VAGAS
            , @VAG_OCUP 
            , @COD_PROF 
        );
    END
GO

CREATE PROCEDURE DBO.MODIFICAR_TURMA
      @ANO       INT    
    , @SEMESTRE  TINYINT
    , @COD_DISC  INT    
    , @TURMA     CHAR(3)
    , @TOT_VAGAS INT    
    , @VAG_OCUP  INT    
    , @COD_PROF  INT
AS
    BEGIN
        UPDATE Turmas
            SET 
              ANO       = @ANO      
            , SEMESTRE  = @SEMESTRE 
            , COD_DISC  = @COD_DISC 
            , TURMA     = @TURMA    
            , TOT_VAGAS = ISNULL(@TOT_VAGAS, TOT_VAGAS)
            , VAG_OCUP  = ISNULL(@VAG_OCUP, VAG_OCUP)
            , COD_PROF  = @COD_PROF
            WHERE   ANO  = @ANO      
                AND SEMESTRE  = @SEMESTRE 
                AND COD_DISC  = @COD_DISC 
                AND TURMA     = @TURMA;

    END
GO

CREATE PROCEDURE DBO.EXCLUIR_TURMA
      @ANO       INT    
    , @SEMESTRE  TINYINT
    , @COD_DISC  INT    
    , @TURMA     CHAR(3)
AS
    BEGIN
        DELETE Turmas
            WHERE   ANO  = @ANO      
                AND SEMESTRE  = @SEMESTRE 
                AND COD_DISC  = @COD_DISC 
                AND TURMA     = @TURMA;

    END
GO