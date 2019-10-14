-- 5. A mudança na quantidade de créditos das disciplinas só pode ser realizada se a mesma ainda
-- não estiver alocada à grade de um curso;

CREATE TRIGGER TG_ALTERAR_CREDITO_DISC ON [Disciplina]
    FOR UPDATE 
AS
    IF(UPDATE(QTD_CRED)) 
        BEGIN
            IF( EXISTS (SELECT *
                             FROM SIGAA.dbo.[Curriculo]
                             WHERE cod_disc = (SELECT cod_disc FROM inserted)) )
                BEGIN
                    RAISERROR('A DISCIPLINA QUE ESTÀ SENDO ALTERADAS A QUANTIDADE DE CREDITO ESTÀ ALOCADA A UM CURSO, COM ISSO NÃO É POSSÍVEL REALIZAR A TRANSAÇÃO', 10 , 1 )
                    ROLLBACK;
                END
            
        END
GO