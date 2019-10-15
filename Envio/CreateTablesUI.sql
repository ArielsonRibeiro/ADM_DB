--
-- Vanilton Alves dos Santos Filho - 2019.2
-- vanilton.filho96@academico.ifs.edu.br
--
-- Este script cria as tabelas referentes ao banco de dados SIGAA.
-- Tentei ao máximo utilizar os melhores tipos de dados para cada definição campo
-- considerando as suas exigências.
-- 
DROP DATABASE SIGAA;
CREATE DATABASE SIGAA;
USE SIGAA;

PRINT '~> Criando tabela Disciplina...';
CREATE TABLE Disciplina (
	  cod_disc INT		     NOT NULL CHECK (cod_disc > 0)
	, qtd_cred SMALLINT    NOT NULL CHECK (qtd_cred > 0)
	, nom_disc VARCHAR(60) NOT NULL
	, CONSTRAINT disciplina_pk PRIMARY KEY (cod_disc)
);
GO

PRINT '~> Criando tabela PreRequisito...';
CREATE TABLE PreRequisito (
	  cod_disc     INT NOT NULL CHECK (cod_disc > 0)
	, cod_disc_pre INT NOT NULL CHECK (cod_disc_pre > 0)
	, CONSTRAINT prerequisito_pk PRIMARY KEY (cod_disc, cod_disc_pre)
	, CONSTRAINT prerequisito_cod_fk FOREIGN KEY (cod_disc)
											REFERENCES Disciplina(cod_disc)
	, CONSTRAINT prerequisito_pre_fk FOREIGN KEY (cod_disc_pre)
											REFERENCES Disciplina(cod_disc)
);
GO

PRINT '~> Criando tabela Curso...';
CREATE TABLE Curso (
	  cod_curso TINYINT    NOT NULL CHECK (cod_curso > 0)
	, tot_cred  SMALLINT    NOT NULL CHECK (tot_cred >= 0)
	, nom_curso VARCHAR(60) NOT NULL
	, cod_coord SMALLINT	         CHECK (cod_coord > 0)
	, CONSTRAINT curso_pk PRIMARY KEY (cod_curso)
);
GO

PRINT '~> Criando tabela Professor...';
CREATE TABLE Professor (
	  cod_prof  SMALLINT    NOT NULL CHECK (cod_prof > 0)
	, cod_curso TINYINT    NOT NULL CHECK (cod_curso > 0)
	, nom_prof  VARCHAR(60) NOT NULL
	, CONSTRAINT professor_pk PRIMARY KEY (cod_prof)
	, CONSTRAINT professor_curso_fk FOREIGN KEY (cod_curso)
								REFERENCES Curso(cod_curso)
);
GO

PRINT '~> Adicionando foreign key de Curso.cod_coord referenciando Professor.cod_prof...';
ALTER TABLE Curso ADD CONSTRAINT curso_fk
	FOREIGN KEY (cod_coord) REFERENCES Professor(cod_prof);
GO

PRINT '~> Criando tabela Aluno...';
CREATE TABLE Aluno (
      mat_alu   INT           NOT NULL CHECK (mat_alu > 0)
    , cod_curso TINYINT      NOT NULL CHECK (cod_curso > 0)
    , dat_nasc  SMALLDATETIME NOT NULL
    , tot_cred  SMALLINT      NOT NULL CHECK (tot_cred >= 0)
    , mgp       NUMERIC(4, 2) NOT NULL CHECK (mgp >= 0.0)
    , nom_alu   VARCHAR(60)   NOT NULL
    , CONSTRAINT aluno_pk PRIMARY KEY (mat_alu)
    , CONSTRAINT aluno_fk FOREIGN KEY (cod_curso)
                            REFERENCES Curso(cod_curso)
);
GO


PRINT '~> Criando tabela Turma...';
CREATE TABLE Turma (
      ano       SMALLINT  NOT NULL  CHECK (ano > 0)
    , semestre  TINYINT  NOT NULL  CHECK (semestre IN (1, 2))
    , cod_disc  INT       NOT NULL  CHECK (cod_disc > 0)
    , turma     CHAR(3)   NOT NULL
    , tot_vagas SMALLINT  NOT NULL  CHECK (tot_vagas > 0)
    , vag_ocup  SMALLINT  NOT NULL  CHECK (vag_ocup >= 0 )
    , cod_prof  SMALLINT    CHECK (cod_prof > 0)
    , CONSTRAINT turma_pk PRIMARY KEY (ano, semestre, cod_disc, turma)
    , CONSTRAINT turma_disc_fk FOREIGN KEY (cod_disc)
                            REFERENCES Disciplina(cod_disc)
	, CONSTRAINT turma_prof_fk FOREIGN KEY (cod_prof)
							REFERENCES Professor(cod_prof)
);
GO

PRINT '~> Criando tabela Curriculo...';
CREATE TABLE Curriculo (
      cod_curso TINYINT NOT NULL CHECK (cod_curso > 0)
    , cod_disc  INT      NOT NULL CHECK (cod_disc > 0)
    , periodo   SMALLINT NOT NULL CHECK (periodo > 0)
    , CONSTRAINT curriculo_pk PRIMARY KEY (cod_curso, cod_disc)
    , CONSTRAINT curriculo_curso_fk FOREIGN KEY (cod_curso)
                                REFERENCES Curso(cod_curso)
    , CONSTRAINT curriculo_disc_fk FOREIGN KEY (cod_disc)
                                REFERENCES Disciplina(cod_disc)   
);
GO

PRINT '~> Criando tabela HistoricoEscolar...';
CREATE TABLE HistoricoEscolar (
    ano       SMALLINT      NOT NULL CHECK (ano > 0)
  , semestre  TINYINT       NOT NULL CHECK (semestre IN (1, 2))
  , cod_disc  INT           NOT NULL CHECK (cod_disc > 0)
  , mat_alu   INT           NOT NULL CHECK (mat_alu > 0)
  , media     NUMERIC(4, 2) NOT NULL CHECK (media >= 0.0)
  , faltas    SMALLINT      NOT NULL CHECK (faltas >= 0)
  , situacao  CHAR(2)       NOT NULL CHECK (situacao IN ('AP', 'RF', 'RM'))
  , CONSTRAINT historico_escolar_pk PRIMARY KEY (ano, semestre, cod_disc, mat_alu)
  , CONSTRAINT historico_escolar_disc_fK FOREIGN KEY (cod_disc)
                                      REFERENCES Disciplina(cod_disc)
  , CONSTRAINT historico_escolar_mat_fk FOREIGN KEY (mat_alu)
                                      REFERENCES Aluno(mat_alu)
);
GO 



PRINT '~> Criando tabela TurmaMatriculada...';
CREATE TABLE TurmaMatriculada (
      ano      SMALLINT NOT NULL CHECK (ano > 0)
    , semestre TINYINT  NOT NULL CHECK (semestre IN (1, 2))
    , cod_disc INT      NOT NULL CHECK (cod_disc > 0)
    , turma    CHAR(3)  NOT NULL
    , mat_alu  INT      NOT NULL CHECK (mat_alu > 0)
    , nota_1   NUMERIC(3, 1)     CHECK (nota_1 >= 0)
    , nota_2   NUMERIC(3, 1)     CHECK (nota_2 >= 0)
    , nota_3   NUMERIC(3, 1)     CHECK (nota_3 >= 0)
    , nota_4   NUMERIC(3, 1)     CHECK (nota_4 >= 0)
    , faltas_1 SMALLINT CHECK (faltas_1 >= 0)
    , faltas_2 SMALLINT CHECK (faltas_2 >= 0)
    , faltas_3 SMALLINT CHECK (faltas_3 >= 0)
   , CONSTRAINT turma_matriculada_pk PRIMARY KEY (ano, semestre, cod_disc, turma, mat_alu)
    , CONSTRAINT turma_matriculada_disc_fk FOREIGN KEY (ano, semestre, cod_disc, turma)
                                              REFERENCES Turma(ano, semestre, cod_disc, turma)
    , CONSTRAINT turma_matriculada_mat_fk FOREIGN KEY (mat_alu)
                                            REFERENCES Aluno(mat_alu)
);
GO

PRINT '~>> OK! Todas as tabelas foram criadas, coragem e se divirta! :)';
