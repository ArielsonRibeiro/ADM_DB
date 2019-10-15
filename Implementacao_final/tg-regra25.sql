-- 25. Não pode ser lançada no histórico uma disciplina em um período em que o pré-requisito da
-- disciplina não tenha sido cursado em períodos anteriores;

CREATE TRIGGER TG_LANCAR_DISCIPLINA_VALIDAR_PRE_REQ ON [HistoricoEscolar]
FOR INSERT
AS
    BEGIN
    DECLARE
        @COD_DISC INT
        , @CONT1 INT
        , @CONT2 INT;
    SELECT @COD_DISC = COD_DISC FROM inserted;

    SELECT @CONT1 = COUNT(*) FROM [PreRequisito] WHERE COD_DISC = @COD_DISC;

    SELECT @CONT2 = COUNT(he.COD_DISC) FROM [HistoricoEscolar] he
    INNER JOIN (SELECT * FROM [PreRequisito]
                    WHERE COD_DISC = @COD_DISC) pr    
        ON he.COD_DISC = pr.COD_DISC_PRE
        WHERE UPPER(he.SITUACAO) = 'AP';

    IF  (@CONT1 != @CONT2)
        BEGIN
             RAISERROR ('O ALUNO NÃO POSSUI OS PRÉ-REQUISITOS SUFICIENTE PARA CADASTRAR ESSE DISCIPLINA NO HISTÓRICO', 10 , 1 );
            ROLLBACK;
        END
    END
GO