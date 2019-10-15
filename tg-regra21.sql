-- 21. Sequencialmente, o aluno só pode ter uma nota com o valor nulo, ou seja, a nota 3 não pode
-- ser preenchida se pelo menos uma das notas anteriores (1 e 2) possuírem valor;
-- João Filipe
CREATE TRIGGER tg_regra21 
ON TurmaMatriculada 
FOR INSERT, UPDATE 
AS 
  BEGIN 

      IF @@ROWCOUNT = 0 
        RETURN; 

      DECLARE @v_nota1 NUMERIC(3, 1), 
              @v_nota2 NUMERIC(3, 1), 
              @v_nota3 NUMERIC(3, 1);

      /* BEGIN Notas sequenciais */ 
      SELECT @v_nota1 = nota_1, 
             @v_nota2 = nota_2, 
             @v_nota3 = nota_3
      FROM   inserted 

      IF ( @v_nota3 >= 0 
           AND @v_nota2 IS NULL 
           AND @v_nota1 IS NULL ) 
        BEGIN 
            ROLLBACK TRANSACTION 

            RAISERROR( 
'Não é possível lançar a terceira nota, pois as anteriores não foram lançadas' 
,11,1) 
END 
/* END Notas sequenciais */ 
END 

go 
