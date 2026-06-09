CREATE OR REPLACE PROCEDURE staging.load_stg_devolucoes()
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO staging.stg_devolucoes (
        devolucao_id,
        pedido_id,
        data_devolucao,
        cliente_id,
        produto_id,
        quantidade_devolvida,
        valor_devolvido,
        motivo_devolucao,
        status_devolucao,
        ano_devolucao,
        mes_devolucao,
        _loaded_at
    )
    SELECT
        devolucao_id,
        pedido_id,
        data_devolucao::DATE,
        cliente_id,
        produto_id,
        quantidade_devolvida,
        COALESCE(valor_devolvido, 0),
        INITCAP(TRIM(motivo_devolucao)),
        INITCAP(TRIM(status_devolucao)),
        EXTRACT(YEAR FROM data_devolucao::DATE)::INT,
        EXTRACT(MONTH FROM data_devolucao::DATE)::INT,
        NOW()
    FROM
        raw.raw_devolucoes
    ON CONFLICT (devolucao_id)
    DO UPDATE SET
        pedido_id = EXCLUDED.pedido_id,
        data_devolucao = EXCLUDED.data_devolucao,
        cliente_id = EXCLUDED.cliente_id,
        produto_id = EXCLUDED.produto_id,
        quantidade_devolvida = EXCLUDED.quantidade_devolvida,
        valor_devolvido = EXCLUDED.valor_devolvido,
        motivo_devolucao = EXCLUDED.motivo_devolucao,
        status_devolucao = EXCLUDED.status_devolucao,
        ano_devolucao = EXCLUDED.ano_devolucao,
        mes_devolucao = EXCLUDED.mes_devolucao,
        _loaded_at = NOW();
    RAISE NOTICE 'stg_devolucao carregado com UPSERT.';
END;
$$;