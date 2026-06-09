CREATE OR REPLACE PROCEDURE dw.load_fato_vendas()
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO dw.fato_vendas (
        nk_pedido,
        sk_tempo,
        sk_produto,
        sk_cliente,
        sk_localidade,
        sk_canal_venda,
        sk_pagamento,
        quantidade,
        preco_unitario,
        desconto,
        frete,
        valor_total,
        valor_liquido,
        status_pedido,
        _loaded_at
    )
    SELECT
        v.pedido_id,
        t.sk_tempo,
        p.sk_produto,
        c.sk_cliente,
        l.sk_localidade,
        cv.sk_canal_venda,
        pg.sk_pagamento,
        v.quantidade,
        v.preco_unitario,
        v.desconto,
        v.frete,
        v.valor_total,
        v.valor_liquido,
        v.status_pedido,
        NOW()

    FROM staging.stg_vendas v

    LEFT JOIN dw.dim_tempo t
        ON t.data_completa = v.data_pedido

    LEFT JOIN dw.dim_produto p
        ON p.produto_id = v.produto_id

    LEFT JOIN dw.dim_cliente c
        ON c.cliente_id = v.cliente_id

    LEFT JOIN dw.dim_localidade l
        ON l.cidade = v.cidade
       AND l.estado = v.estado

    LEFT JOIN dw.dim_canal_venda cv
        ON cv.canal_venda = v.canal_venda

    LEFT JOIN dw.dim_pagamento pg
        ON pg.forma_pagamento = v.forma_pagamento

    ON CONFLICT (nk_pedido)
    DO UPDATE SET
        sk_tempo = EXCLUDED.sk_tempo,
        sk_produto = EXCLUDED.sk_produto,
        sk_cliente = EXCLUDED.sk_cliente,
        sk_localidade = EXCLUDED.sk_localidade,
        sk_canal_venda = EXCLUDED.sk_canal_venda,
        sk_pagamento = EXCLUDED.sk_pagamento,
        quantidade = EXCLUDED.quantidade,
        preco_unitario = EXCLUDED.preco_unitario,
        desconto = EXCLUDED.desconto,
        frete = EXCLUDED.frete,
        valor_total = EXCLUDED.valor_total,
        valor_liquido = EXCLUDED.valor_liquido,
        status_pedido = EXCLUDED.status_pedido,
        _loaded_at = NOW();
    RAISE NOTICE 'fato_vendas carregada com UPSERT.';
END;
$$;