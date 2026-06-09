CREATE OR REPLACE PROCEDURE staging.run_staging()
LANGUAGE plpgsql AS $$
BEGIN

    RAISE NOTICE 'Iniciando carga STAGING';

    CALL staging.load_stg_vendas();
    CALL staging.load_stg_devolucoes();
    CALL staging.load_stg_estoque();

    RAISE NOTICE 'Carga STAGING concluida';

END;
$$;