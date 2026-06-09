CREATE OR REPLACE PROCEDURE dw.load_dim_canal_venda()
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO dw.dim_canal_venda (
        canal_venda,
        _loaded_at
    )
    SELECT DISTINCT
        canal_venda,
        NOW()
    FROM
        staging.stg_vendas
    WHERE
        canal_venda IS NOT NULL
    ON CONFLICT (canal_venda)
    DO UPDATE SET
        _loaded_at = NOW();
    RAISE NOTICE 'dim_canal_venda carregado com UPSERT.';
END;
$$;