Use SIGAA;

INSERT INTO Cursos VALUES (1, 120, 'Matematica Computacional', NULL);
INSERT INTO Cursos VALUES (2, 120, 'Matematica ', NULL);
INSERT INTO Cursos VALUES (3, 120, 'fisica', NULL);
INSERT INTO Cursos VALUES (4, 120, 'Portugues', NULL);

Insert into Disciplinas VALUES(1 , 2, 'Matematica');
Insert into Disciplinas VALUES(2 , 2, 'MatematicaII');
Insert into Disciplinas VALUES(3 , 2, 'MatematicaIII');

Insert into Disciplinas VALUES(4 , 2, 'Calculo I');
Insert into Disciplinas VALUES(5 , 1, 'MatematicaI');
Insert into Disciplinas VALUES(6 , 1, 'MatematicaII');
Insert into Disciplinas VALUES(7 , 1, 'MatematicaIII');


INSERT INTO Pre_Requisitos VALUES(2, 1);
INSERT INTO Pre_Requisitos VALUES(3, 2);
INSERT INTO Pre_Requisitos VALUES(3, 4);

INSERT Curriculos VALUES(2, 1, 1)
INSERT Curriculos VALUES(2, 2, 2)
INSERT Curriculos VALUES(2, 3, 3)
INSERT Curriculos VALUES(2, 4, 2)

INSERT Curriculos VALUES(1, 5, 1)
INSERT Curriculos VALUES(1, 6, 2)
INSERT Curriculos VALUES(1, 7, 3)


INSERT INTO Professores(COD_CURSO, COD_PROF, NOM_PROF) VALUES(1, 1, 'JEAN');
INSERT INTO Professores(COD_CURSO, COD_PROF, NOM_PROF) VALUES(1, 2, 'JOAO');
INSERT INTO Professores(COD_CURSO, COD_PROF, NOM_PROF) VALUES(2, 3, 'Pedro');
INSERT INTO Professores(COD_CURSO, COD_PROF, NOM_PROF) VALUES(2, 4, 'Lauro');


UPDATE Cursos SET COD_COORD = 4 WHERE COD_CURSO = 2;

UPDATE Cursos SET COD_COORD = 4 WHERE COD_CURSO = 1; -- Tem Que Gerar um Erro(trigger)

INSERT INTO Alunos(MAT_ALU, NOM_ALU, COD_CURSO, DAT_NASC, MGP, TOT_CRED )
    VALUES (1234, 'Henrique', 1, '12-02-2003', 0, 0)
INSERT INTO Alunos(MAT_ALU, NOM_ALU, COD_CURSO, DAT_NASC, MGP, TOT_CRED )
    VALUES (1235, 'PAULO', 1, '12-02-2002', 0, 0)

INSERT INTO Alunos(MAT_ALU, NOM_ALU, COD_CURSO, DAT_NASC, MGP, TOT_CRED )
    VALUES (1236, 'PAULO_2',2, '12-02-2002', 0, 0)




INSERT Historicos_Escolares(ANO       
, SEMESTRE
, COD_DISC
, MAT_ALU 
, MEDIA   
, FALTAS  
, SITUACAO) VALUES (
    2019, 1, 1, 1234, 5.0, 12, 'AP'
);

INSERT Historicos_Escolares(ANO       
, SEMESTRE
, COD_DISC
, MAT_ALU 
, MEDIA   
, FALTAS  
, SITUACAO) VALUES (
    2019, 1, 1, 1235, 6.0, 22, 'RP'
);
SELECT * FROM Disciplinas
INSERT INTO Turmas(ANO
, SEMESTRE
, COD_DISC
, TURMA   
, TOT_VAGAS
, VAG_OCUP
, COD_PROF) VALUES(2019, 1,5, 'MA1', 20, 10, 1)

INSERT INTO Turmas(ANO
, SEMESTRE
, COD_DISC
, TURMA   
, TOT_VAGAS
, VAG_OCUP
, COD_PROF) VALUES(2019, 1,6, 'MA1', 20, 10, 1)

INSERT INTO Turmas(ANO
, SEMESTRE
, COD_DISC
, TURMA   
, TOT_VAGAS
, VAG_OCUP
, COD_PROF) VALUES(2019, 2,7, 'MA1', 20, 10, 1)



INSERT INTO Turmas(ANO
, SEMESTRE
, COD_DISC
, TURMA   
, TOT_VAGAS
, VAG_OCUP
, COD_PROF) VALUES(2019, 1, 1, 'MA1', 20, 10, 1)

INSERT INTO Turmas(ANO
, SEMESTRE
, COD_DISC
, TURMA   
, TOT_VAGAS
, VAG_OCUP
, COD_PROF) VALUES(2019, 1, 2, 'MA2', 20, 10, 1)



INSERT INTO Tumas_Matriculadas(ANO 
, SEMESTRE
, COD_DISC
, TURMA
, MAT_ALU) VALUES(2019, 1, 2, 'MA2', 1234) -- Erro Trigger requisitos

INSERT INTO Tumas_Matriculadas(ANO 
, SEMESTRE
, COD_DISC
, TURMA
, MAT_ALU) VALUES(2019, 1, 1, 'MA1', 1236) -- Erro Trigger Validacao de Disciplina do curso


INSERT INTO Tumas_Matriculadas(ANO 
, SEMESTRE
, COD_DISC
, TURMA
, MAT_ALU) VALUES(2019, 1, 1, 'MA1', 1236)

INSERT INTO Tumas_Matriculadas(ANO 
    , SEMESTRE
    , COD_DISC
    , TURMA
    , MAT_ALU) VALUES(2019, 1, 2, 'MA2', 1234) -- tem que dar erro de trigger Disciplina nao pertence ao curso do aluno.;


INSERT INTO Tumas_Matriculadas(ANO 
, SEMESTRE
, COD_DISC
, TURMA
, MAT_ALU) VALUES(2019, 1, 5, 'MA1', 1234) 
INSERT INTO Tumas_Matriculadas(ANO 
, SEMESTRE
, COD_DISC
, TURMA
, MAT_ALU) VALUES(2019, 1, 6, 'MA1', 1234)  --eRROR tIGRES q20.
--DELETE FROM Tumas_Matriculadas

--INSERT Curriculos VALUES(2, 4, 1)
UPDATE Tumas_Matriculadas
    SET NOTA_3 = 10
    WHERE MAT_ALU = 1234 -- ERROR TRIGRE

UPDATE Tumas_Matriculadas
    SET NOTA_3 = 10, NOTA_2 = 10, NOTA_1 = 10
    WHERE MAT_ALU = 1234

UPDATE Tumas_Matriculadas
    SET NOTA_4 = 10
    WHERE MAT_ALU = 1234 -- ERROR TRIGRE

UPDATE Tumas_Matriculadas
    SET FALTAS_2 = 10
    WHERE MAT_ALU = 1234


INSERT INTO Turmas(ANO
, SEMESTRE
, COD_DISC
, TURMA   
, TOT_VAGAS
, VAG_OCUP
, COD_PROF) VALUES(2019, 1, 4, 'MA2', 20, 0, 1)

UPDATE Disciplinas SET QTD_CRED = 5
     WHERE COD_DISC =3
UPDATE Disciplinas SET QTD_CRED = 5
     WHERE COD_DISC =2 -- tem que gerar erro (trigger)

UPDATE Disciplinas SET NOM_DISC = 'mat1'
     WHERE COD_DISC =1 -- tem que gerar erro (trigger)

UPDATE Alunos SET NOM_ALU = 'PEDR52' WHERE MAT_ALU = 1234;


UPDATE Historicos_Escolares SET MEDIA = 7 WHERE MAT_ALU = 1234;

delete Tumas_Matriculadas




SELECT * FROM Disciplinas
SELECT * FROM Pre_Requisitos
SELECT * FROM Cursos
SELECT * FROM Professores
SELECT * FROM Alunos
SELECT * FROM Curriculos
SELECT * FROM Historicos_Escolares
SELECT * FROM Turmas
SELECT * FROM Tumas_Matriculadas

USE Curso;