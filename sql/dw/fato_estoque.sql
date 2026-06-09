CREATE OR REPLACE PROCEDURE dw.load_fato_estoque()
LANGUAGE plpgsql AS $$
BEGIN

    INSERT INTO dw.fato_estoque (
        sk_produto,
        estoque_inicial,
        entradas_periodo,
        estoque_atual,
        estoque_minimo,
        custo_unitario,
        valor_estoque_total,
        abaixo_minimo,
        centro_distribuicao,
        _loaded_at
    )

    SELECT
        p.sk_produto,
        e.estoque_inicial,
        e.entradas_periodo,
        e.estoque_atual,
        e.estoque_minimo,
        e.custo_unitario,
        e.valor_estoque_total,
        e.abaixo_minimo,
        e.centro_distribuicao,
        NOW()

    FROM staging.stg_estoque e

    LEFT JOIN dw.dim_produto p
        ON p.produto_id = e.produto_id

    ON CONFLICT (sk_produto)
    DO UPDATE SET
        estoque_inicial = EXCLUDED.estoque_inicial,
        entradas_periodo = EXCLUDED.entradas_periodo,
        estoque_atual = EXCLUDED.estoque_atual,
        estoque_minimo = EXCLUDED.estoque_minimo,
        custo_unitario = EXCLUDED.custo_unitario,
        valor_estoque_total = EXCLUDED.valor_estoque_total,
        abaixo_minimo = EXCLUDED.abaixo_minimo,
        centro_distribuicao = EXCLUDED.centro_distribuicao,
        _loaded_at = NOW();

    RAISE NOTICE 'fato_estoque carregada com UPSERT.';

END;
$$;