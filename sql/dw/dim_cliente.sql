CREATE OR REPLACE PROCEDURE dw.load_dim_cliente()
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO dw.dim_cliente(
        cliente_id,
        _loaded_at
    )
    SELECT
        cliente_id,
        NOW()
    FROM (
        SELECT DISTINCT
            cliente_id
        FROM
            staging.stg_vendas
        UNION
        SELECT DISTINCT
            cliente_id
        FROM
            staging.stg_devolucoes
    ) clientes
    ON CONFLICT (cliente_id)
    DO UPDATE SET
        _loaded_at = NOW();
    RAISE NOTICE 'dim_cliente carregado com UPSERT.';
END;
$$;