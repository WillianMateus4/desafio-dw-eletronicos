CREATE OR REPLACE PROCEDURE dw.load_fato_devolucoes()
LANGUAGE plpgsql AS $$
BEGIN

    INSERT INTO dw.fato_devolucoes (
        nk_devolucao,
        pedido_id,
        sk_tempo,
        sk_produto,
        sk_cliente,
        quantidade_devolvida,
        valor_devolvido,
        motivo_devolucao,
        status_devolucao,
        _loaded_at
    )

    SELECT
        d.devolucao_id,
        d.pedido_id,
        t.sk_tempo,
        p.sk_produto,
        c.sk_cliente,
        d.quantidade_devolvida,
        d.valor_devolvido,
        d.motivo_devolucao,
        d.status_devolucao,
        NOW()

    FROM staging.stg_devolucoes d

    LEFT JOIN dw.dim_tempo t
        ON t.data_completa = d.data_devolucao

    LEFT JOIN dw.dim_produto p
        ON p.produto_id = d.produto_id

    LEFT JOIN dw.dim_cliente c
        ON c.cliente_id = d.cliente_id

    ON CONFLICT (nk_devolucao)
    DO UPDATE SET
        pedido_id = EXCLUDED.pedido_id,
        sk_tempo = EXCLUDED.sk_tempo,
        sk_produto = EXCLUDED.sk_produto,
        sk_cliente = EXCLUDED.sk_cliente,
        quantidade_devolvida = EXCLUDED.quantidade_devolvida,
        valor_devolvido = EXCLUDED.valor_devolvido,
        motivo_devolucao = EXCLUDED.motivo_devolucao,
        status_devolucao = EXCLUDED.status_devolucao,
        _loaded_at = NOW();

    RAISE NOTICE 'fato_devolucoes carregada com UPSERT.';

END;
$$;