CREATE OR REPLACE PROCEDURE dw.load_dim_tempo()
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO dw.dim_tempo (
        data_completa,
        ano,
        trimestre,
        mes,
        nome_mes,
        semana_ano,
        dia,
        dia_semana,
        nome_dia,
        is_fim_semana,
        _loaded_at
    )
    WITH todas_datas AS (
        SELECT data_pedido AS data
        FROM staging.stg_vendas

        UNION

        SELECT data_devolucao AS data
        FROM staging.stg_devolucoes
    )
    SELECT
        data AS data_completa,
        EXTRACT(YEAR FROM data)::INT AS ano,
        EXTRACT(QUARTER FROM data)::INT AS trimestre,
        EXTRACT(MONTH FROM data)::INT AS mes,
        TRIM(TO_CHAR(data, 'Month')) AS nome_mes,
        EXTRACT(WEEK FROM data)::INT AS semana_ano,
        EXTRACT(DAY FROM data)::INT AS dia,
        EXTRACT(DOW FROM data)::INT AS dia_semana,
        TRIM(TO_CHAR(data, 'Day')) AS nome_dia,
        EXTRACT(DOW FROM data) IN (0, 6) AS is_fim_semana,
        NOW() AS _loaded_at
    FROM
        todas_datas
    WHERE 
        data IS NOT NULL
    ON CONFLICT (data_completa)
    DO UPDATE SET
        ano = EXCLUDED.ano,
        trimestre = EXCLUDED.trimestre,
        mes = EXCLUDED.mes,
        nome_mes = EXCLUDED.nome_mes,
        semana_ano = EXCLUDED.semana_ano,
        dia = EXCLUDED.dia,
        dia_semana = EXCLUDED.dia_semana,
        nome_dia = EXCLUDED.nome_dia,
        is_fim_semana = EXCLUDED.is_fim_semana,
        _loaded_at = NOW();
    RAISE NOTICE 'dim_tempo carregado com UPSERT.';
END;
$$;