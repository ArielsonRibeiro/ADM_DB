Use SIGAA;

INSERT INTO Curso VALUES (1, 120, 'Matematica Computacional', NULL);
INSERT INTO Curso VALUES (2, 120, 'Matematica ', NULL);
INSERT INTO Curso VALUES (3, 120, 'fisica', NULL);
INSERT INTO Curso VALUES (4, 120, 'Portugues', NULL);

Insert into Disciplina VALUES(1 , 2, 'Matematica');
Insert into Disciplina VALUES(2 , 2, 'MatematicaII');
Insert into Disciplina VALUES(3 , 2, 'MatematicaIII');
Insert into Disciplina VALUES(4 , 2, 'Calculo I');
Insert into Disciplina VALUES(5 , 1, 'MatematicaI');
Insert into Disciplina VALUES(6 , 1, 'MatematicaII');
Insert into Disciplina VALUES(7 , 1, 'MatematicaIII');

SELECT* From Disciplina
SELECT* From PreRequisito
SELECT * FROM Curso
DELETE from Curriculo

--Update Disciplina  set QTD_CRED = 12 WHERE cod_disc = 1

INSERT INTO PreRequisito VALUES(2, 1);
INSERT INTO PreRequisito VALUES(3, 2);
INSERT INTO PreRequisito VALUES(3, 4);

INSERT Curriculo VALUES(2, 1, 1)
INSERT Curriculo VALUES(2, 2, 2)
INSERT Curriculo VALUES(2, 4, 2)
INSERT Curriculo VALUES(2, 3, 3)

INSERT Curriculo VALUES(1, 5, 1)
INSERT Curriculo VALUES(1, 6, 2)
INSERT Curriculo VALUES(1, 7, 3)

INSERT Curriculo VALUES(2, 4, 2)-- Error


INSERT INTO Professor(COD_CURSO, COD_PROF, NOM_PROF) VALUES(1, 1, 'JEAN');
INSERT INTO Professor(COD_CURSO, COD_PROF, NOM_PROF) VALUES(1, 2, 'JOAO');
INSERT INTO Professor(COD_CURSO, COD_PROF, NOM_PROF) VALUES(2, 3, 'Pedro');
INSERT INTO Professor(COD_CURSO, COD_PROF, NOM_PROF) VALUES(2, 4, 'Lauro');


UPDATE Curso SET COD_COORD = 4 WHERE COD_CURSO = 2;

UPDATE Curso SET COD_COORD = 4 WHERE COD_CURSO = 1; -- Tem Que Gerar um Erro(trigger)

INSERT INTO Aluno(MAT_ALU, NOM_ALU, COD_CURSO, DAT_NASC, MGP, TOT_CRED )
    VALUES (1234, 'Henrique', 1, '12-02-2002', 0, 0) -----------------------------------------------
INSERT INTO Aluno(MAT_ALU, NOM_ALU, COD_CURSO, DAT_NASC, MGP, TOT_CRED )
    VALUES (1235, 'PAULO', 1, '12-02-2002', 0, 0)

INSERT INTO Aluno(MAT_ALU, NOM_ALU, COD_CURSO, DAT_NASC, MGP, TOT_CRED )
    VALUES (1236, 'PAULO_2',2, '12-02-2002', 0, 0)

INSERT INTO Aluno(MAT_ALU, NOM_ALU, COD_CURSO, DAT_NASC, MGP, TOT_CRED )
    VALUES (1238, 'PAULO_2',2, '12-02-2012', 0, 0) -- error Check


SELECT * From HistoricoEscolar

INSERT HistoricoEscolar(ANO       
, SEMESTRE
, COD_DISC
, MAT_ALU 
, MEDIA   
, FALTAS  
, SITUACAO) VALUES (
    2019, 2, 5, 1234, 5.0, 2, 'AP'
);

INSERT HistoricoEscolar(ANO       
, SEMESTRE
, COD_DISC
, MAT_ALU 
, MEDIA   
, FALTAS  
, SITUACAO) VALUES (
    2019, 1,6, 1235, 5.0, 2, 'AP'
);

SELECT * FROM Disciplina

INSERT INTO Turma(ANO
, SEMESTRE
, COD_DISC
, TURMA   
, TOT_VAGAS
, VAG_OCUP
, COD_PROF) VALUES(2019, 1,5, 'MA1', 20, 10, 1)

INSERT INTO Turma(ANO
, SEMESTRE
, COD_DISC
, TURMA   
, TOT_VAGAS
, VAG_OCUP
, COD_PROF) VALUES(2019, 1,6, 'MA1', 20, 10, 1)

INSERT INTO Turma(ANO
, SEMESTRE
, COD_DISC
, TURMA   
, TOT_VAGAS
, VAG_OCUP
, COD_PROF) VALUES(2019, 2,7, 'MA1', 20, 10, 1)



INSERT INTO Turma(ANO
, SEMESTRE
, COD_DISC
, TURMA   
, TOT_VAGAS
, VAG_OCUP
, COD_PROF) VALUES(2019, 1, 1, 'MA1', 20, 10, 1)

INSERT INTO Turma(ANO
, SEMESTRE
, COD_DISC
, TURMA   
, TOT_VAGAS
, VAG_OCUP
, COD_PROF) VALUES(2019, 1, 2, 'MA2', 20, 10, 1)



INSERT INTO TurmaMatriculada(ANO 
, SEMESTRE
, COD_DISC
, TURMA
, MAT_ALU) VALUES(2019, 1, 2, 'MA2', 1234) -- Erro Trigger requisitos

INSERT INTO TurmaMatriculada(ANO 
, SEMESTRE
, COD_DISC
, TURMA
, MAT_ALU) VALUES(2019, 1, 1, 'MA1', 1236)


INSERT INTO TurmaMatriculada(ANO 
, SEMESTRE
, COD_DISC
, TURMA
, MAT_ALU) VALUES(2019, 1, 1, 'MA1', 1234) -- ERROR TIGRE VALIDACAO DISCIPLINA DO CURSO

INSERT INTO TurmaMatriculada(ANO 
    , SEMESTRE
    , COD_DISC
    , TURMA
    , MAT_ALU) VALUES(2019, 1, 2, 'MA2', 1235) -- tem que dar erro de trigger Disciplina nao pertence ao curso do aluno.;


INSERT INTO TurmaMatriculada(ANO 
, SEMESTRE
, COD_DISC
, TURMA
, MAT_ALU) VALUES(2019, 1, 5, 'MA1', 1234) 

 -- SELECT * FROM HistoricoEscolar
INSERT INTO TurmaMatriculada(ANO 
, SEMESTRE
, COD_DISC
, TURMA
, MAT_ALU) VALUES(2019, 1, 6, 'MA1', 1234);
--DELETE FROM TurmaMatriculada
SELECT *  FROM TurmaMatriculada
--INSERT Curriculo VALUES(2, 4, 1)
UPDATE TurmaMatriculada
    SET NOTA_3 = 10
    WHERE MAT_ALU = 1236 -- ERROR TRIGRE

UPDATE TurmaMatriculada
    SET NOTA_3 = 10, NOTA_2 = 10, NOTA_1 = 10
    WHERE MAT_ALU = 1236

UPDATE TurmaMatriculada
    SET NOTA_4 = 10
    WHERE MAT_ALU = 1236 -- ERROR TRIGRE

UPDATE TurmaMatriculada
    SET FALTAS_2 = 4
    WHERE MAT_ALU = 1236 -- ERROR TRIGRE

UPDATE TurmaMatriculada
    SET FALTAS_2 = 10
    WHERE MAT_ALU = 1236-- ERROR TRIGRE

INSERT INTO Turma(ANO
, SEMESTRE
, COD_DISC
, TURMA   
, TOT_VAGAS
, VAG_OCUP
, COD_PROF) VALUES(2019, 1, 4, 'MA2', 20, 0, 1)

UPDATE Disciplina SET QTD_CRED = 5
     WHERE COD_DISC =3
UPDATE Disciplina SET QTD_CRED = 5
     WHERE COD_DISC =2 -- tem que gerar erro (trigger)

UPDATE Disciplina SET NOM_DISC = 'mat1'
     WHERE COD_DISC =1 -- tem que gerar erro (trigger)

UPDATE Aluno SET NOM_ALU = 'PEDR52' WHERE MAT_ALU = 1236;


UPDATE HistoricoEscolar SET FALTAS = 2 WHERE MAT_ALU = 1234;

UPDATE HistoricoEscolar SET FALTAS = 2, SITUACAO = 'RP' WHERE MAT_ALU = 1235; -- tem que gerar erro (trigger)

delete TurmaMatriculada

DELETE Curriculo WHERE COD_DISC = 3;
INSERT INTO Curriculo VALUES(2, 4, 2)
INSERT INTO Curriculo VALUES(2, 3, 3)

INSERT INTO PreRequisito VALUES(2, 1)
UPDATE PreRequisito
    SET COD_DISC_PRE = 4
    WHERE COD_DISC = 2




SELECT * FROM Disciplina
SELECT * FROM PreRequisito
SELECT * FROM Curso
SELECT * FROM Professor
SELECT * FROM Aluno
SELECT * FROM Curriculo
SELECT * FROM HistoricoEscolar
SELECT * FROM Turma
SELECT * FROM TurmaMatriculada

UPDATE TurmaMatriculada
    SET
        NOTA_1 = 4
        , NOTA_2 = 6
        , NOTA_4 = 5
        , FALTAS_1 = 1
        , FALTAS_2 = 2
        , FALTAS_3 = 0
    WHERE MAT_ALU= 1236

DELETE HistoricoEscolar
USE Curso;