CREATE OR REPLACE PROCEDURE dw.run_dw()
LANGUAGE plpgsql AS $$
BEGIN

    RAISE NOTICE '======================================';
    RAISE NOTICE 'INICIANDO DATA WAREHOUSE';
    RAISE NOTICE '======================================';

    -- DIMENSOES
    CALL dw.load_dim_tempo();
    CALL dw.load_dim_produto();
    CALL dw.load_dim_cliente();
    CALL dw.load_dim_localidade();
    CALL dw.load_dim_canal_venda();
    CALL dw.load_dim_pagamento();

    -- FATOS
    CALL dw.load_fato_vendas();
    CALL dw.load_fato_devolucoes();
    CALL dw.load_fato_estoque();

    RAISE NOTICE '======================================';
    RAISE NOTICE 'DATA WAREHOUSE CONCLUIDO';
    RAISE NOTICE '======================================';

END;
$$;