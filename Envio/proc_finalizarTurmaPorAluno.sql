--
-- Vanilton Alves dos Santos Filho - 2019.2
-- vanilton.filho96@academico.ifs.edu.br
--
CREATE PROCEDURE proc_finalizarTurmaPorAluno
    @mat_alu INT
  , @cod_disc INT
  , @turma CHAR(3)
AS
BEGIN
    DECLARE @media DECIMAL (3,1);
    DECLARE @nota1 DECIMAL(3, 1), @nota2 DECIMAL(3, 1), @nota3 DECIMAL(3, 1), @nota4 DECIMAL(3, 1);
    DECLARE @total_faltas SMALLINT;
    DECLARE @faltas1 SMALLINT, @faltas2 SMALLINT, @faltas3 SMALLINT;

    SET @nota1 = ISNULL((
        SELECT tm.nota_1
            FROM TurmaMatriculada tm, Aluno a
            WHERE tm.mat_alu = a.mat_alu AND a.mat_alu = @mat_alu AND tm.cod_disc = @cod_disc AND tm.turma = @turma
    ), 0);

    SET @nota2 = ISNULL((
        SELECT tm.nota_2
            FROM TurmaMatriculada tm, Aluno a
            WHERE tm.mat_alu = a.mat_alu AND a.mat_alu = @mat_alu AND tm.cod_disc = @cod_disc AND tm.turma = @turma    
    ), 0);

    SET @nota3 = ISNULL((
        SELECT tm.nota_3
            FROM TurmaMatriculada tm, Aluno a
        WHERE tm.mat_alu = a.mat_alu AND a.mat_alu = @mat_alu AND tm.cod_disc = @cod_disc AND tm.turma = @turma    
    ), 0);

    SET @nota4 = ISNULL((
        SELECT tm.nota_4
            FROM TurmaMatriculada tm, Aluno a
        WHERE tm.mat_alu = a.mat_alu AND a.mat_alu = @mat_alu AND tm.cod_disc = @cod_disc AND tm.turma = @turma    
    ), 0);

    SET @media = (@nota1 + @nota2 + @nota3 + @nota4) / 4;


    SET @faltas1 = ISNULL((
        SELECT tm.faltas_1
            FROM TurmaMatriculada tm, Aluno a
        WHERE tm.mat_alu = a.mat_alu AND a.mat_alu = @mat_alu AND tm.cod_disc = @cod_disc AND tm.turma = @turma   
    ), 0);

    SET @faltas2 = ISNULL((
        SELECT tm.faltas_2
            FROM TurmaMatriculada tm, Aluno a
        WHERE tm.mat_alu = a.mat_alu AND a.mat_alu = @mat_alu AND tm.cod_disc = @cod_disc AND tm.turma = @turma   
    ), 0);

    SET @faltas3 = ISNULL((
        SELECT tm.faltas_3
            FROM TurmaMatriculada tm, Aluno a
        WHERE tm.mat_alu = a.mat_alu AND a.mat_alu = @mat_alu AND tm.cod_disc = @cod_disc AND tm.turma = @turma   
    ), 0);
    
    SET @total_faltas = @faltas1 + @faltas2 + @faltas3;

    DECLARE @situacao CHAR(2);
    IF @total_faltas > (@total_faltas * (0.25))
    BEGIN
        SET @situacao = 'RF';
    END
    ELSE IF @media >= 5
    BEGIN  
        SET @situacao = 'AP';
    END
    ELSE
    BEGIN
        SET @situacao = 'RM';
    END 

    INSERT INTO HistoricoEscolar VALUES (
          (SELECT ano FROM TurmaMatriculada WHERE mat_alu = @mat_alu AND cod_disc = @cod_disc AND turma = @turma)
        , (SELECT semestre FROM TurmaMatriculada WHERE mat_alu = @mat_alu AND cod_disc = @cod_disc AND turma = @turma)
        , @cod_disc
        , @mat_alu
        , @media
        , @total_faltas
        , @situacao
    );
END
GO
