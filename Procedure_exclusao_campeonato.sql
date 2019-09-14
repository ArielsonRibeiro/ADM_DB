CREATE PROCEDURE dbo.EXCLUIR_CAMPEONATO
    @p_cod_camp int 
AS
    BEGIN
        DELETE FROM campeonatos
            WHERE cod_camp = @p_cod_camp
    END

EXEC dbo.EXCLUIR_CAMPEONATO
    112