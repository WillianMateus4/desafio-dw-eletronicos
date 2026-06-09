CREATE OR REPLACE PROCEDURE dw.load_dim_produto()
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO dw.dim_produto(
        produto_id,
        produto,
        categoria,
        marca,
        fornecedor,
        centro_distribuicao,
        _loaded_at
    )
    WITH unificado AS (
        SELECT
           produto_id,
            produto,
            categoria,
            marca,
            fornecedor,
            centro_distribuicao,
            1 AS prioridade
        FROM
            staging.stg_estoque
        UNION ALL
        SELECT
            produto_id,
            produto,
            categoria,
            marca,
            NULL AS fornecedor,
            NULL AS centro_distribuicao,
            2 AS prioridade
        FROM
            staging.stg_vendas
    ),
    tratado AS (
        SELECT
            produto_id,
            produto,
            categoria,
            marca,
            fornecedor,
            centro_distribuicao,
            ROW_NUMBER() OVER (PARTITION BY produto_id ORDER BY prioridade) AS rn
        FROM
            unificado
    )
    SELECT
        produto_id,
        produto,
        categoria,
        marca,
        fornecedor,
        centro_distribuicao,
        NOW()
    FROM
        tratado
    WHERE
        rn = 1
    ON CONFLICT (produto_id)
    DO UPDATE SET
        produto = EXCLUDED.produto,
        categoria = EXCLUDED.categoria,
        marca = EXCLUDED.marca,
        fornecedor = EXCLUDED.fornecedor,
        centro_distribuicao = EXCLUDED.centro_distribuicao,
        _loaded_at = NOW();
    RAISE NOTICE 'dim_produto carregada com UPSERT.';
END;
$$;