-- Criando uma Stored procedure
CREATE PROCEDURE DBO.CRIAR_CAMPEONATO
    @p_cod_camp int ,
	@p_dsc_camp varchar(40) ,
	@p_ano int ,
	@p_tipo char(1) ,
	@p_dat_ini smalldatetime ,
	@p_dat_fim smalldatetime ,
	@p_def_tipo char(2)
AS
    BEGIN
        INSERT INTO campeonatos(
            [cod_camp]
        ,   [dsc_camp]
        ,   [ano]
        ,   [tipo]
        ,   [dat_ini]
        ,   [dat_fim]
        ,   [def_tipo])
      VALUES(
            @p_cod_camp
        ,   @p_dsc_camp 
        ,   @p_ano
        ,   @p_tipo 
        ,   @p_dat_ini 
        ,   @p_dat_fim
        ,   @p_def_tipo
      )
    END

-- Executando a Stored procedure
EXECUTE dbo.CRIAR_CAMPEONATO
   112
  ,"Brasileirão 2019"
  , "2019"
  , "N"
  ,"2019-02-02"
  ,"2019-12-11"
  , NULL
GO