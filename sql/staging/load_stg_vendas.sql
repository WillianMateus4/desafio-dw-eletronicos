CREATE OR REPLACE PROCEDURE staging.load_stg_vendas()
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO staging.stg_vendas(
        pedido_id,
        data_pedido,
        cliente_id,
        produto_id,
        produto,
        categoria,
        marca,
        quantidade,
        preco_unitario,
        desconto,
        frete,
        valor_total,
        valor_liquido,
        canal_venda,
        forma_pagamento,
        cidade,
        estado,
        status_pedido,
        ano_pedido,
        mes_pedido,
        _loaded_at
    )
    SELECT
        pedido_id,
        data_pedido::DATE,
        cliente_id,
        produto_id,
        TRIM(produto),
        TRIM(categoria),
        TRIM(marca),
        quantidade,
        preco_unitario,
        COALESCE(desconto, 0),
        COALESCE(frete, 0),
        valor_total,
        ROUND(valor_total - COALESCE(frete, 0), 2),
        INITCAP(TRIM(canal_venda)),
        INITCAP(TRIM(forma_pagamento)),
        INITCAP(TRIM(cidade)),
        UPPER(TRIM(estado)),
        INITCAP(TRIM(status_pedido)),
        EXTRACT(YEAR FROM data_pedido::DATE)::INT,
        EXTRACT(MONTH FROM data_pedido::DATE)::INT,
            NOW()
    FROM
        raw.raw_vendas
    ON CONFLICT (pedido_id)
    DO UPDATE SET
        data_pedido = EXCLUDED.data_pedido,
        cliente_id = EXCLUDED.cliente_id,
        produto_id = EXCLUDED.produto_id,
        produto = EXCLUDED.produto,
        categoria = EXCLUDED.categoria,
        marca = EXCLUDED.marca,
        quantidade = EXCLUDED.quantidade,
        preco_unitario = EXCLUDED.preco_unitario,
        desconto = EXCLUDED.desconto,
        frete = EXCLUDED.frete,
        valor_total = EXCLUDED.valor_total,
        valor_liquido = EXCLUDED.valor_liquido,
        canal_venda = EXCLUDED.canal_venda,
        forma_pagamento = EXCLUDED.forma_pagamento,
        cidade = EXCLUDED.cidade,
        estado = EXCLUDED.estado,
        status_pedido = EXCLUDED.status_pedido,
        ano_pedido = EXCLUDED.ano_pedido,
        mes_pedido = EXCLUDED.mes_pedido,
        _loaded_at = NOW();
    RAISE NOTICE 'stg_vendas carregando com UPSERT.';
END;
$$;