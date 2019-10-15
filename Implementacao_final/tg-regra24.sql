-- 24. A quarta nota só pode ser preenchida se uma das anteriores estiver nula;

create trigger tg_preencher_4_nota on [TurmaMatriculada]
for insert, update
as
    if @@ROWCOUNT = 0 
        RETURN; 
    if(update(nota_4))
        begin
            declare
                  @n1 numeric(3,1)
                , @n2 numeric(3,1)
                , @n3 numeric(3,1);

            select @n1 = nota_1
                ,  @n2 = nota_2
                ,  @n3 = nota_3 from inserted;
            
            if ( (@n1 is not null) and (@n2 is not null) and (@n3 is not null))
                begin
                    raiserror('Não é possível cadastrar a 4º nota, pois o aluno já tem as 3 primeiras notas foram cadastradas', 10 , 1 );
                    rollback;
                end
        end
    
go