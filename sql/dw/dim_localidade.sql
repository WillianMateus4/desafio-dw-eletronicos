CREATE OR REPLACE PROCEDURE dw.load_dim_localidade()
LANGUAGE plpgsql AS $$
BEGIN

    INSERT INTO dw.dim_localidade (
        cidade,
        estado,
        _loaded_at
    )
    SELECT DISTINCT
        cidade,
        estado,
        NOW()
    FROM staging.stg_vendas
    WHERE cidade IS NOT NULL
      AND estado IS NOT NULL

    ON CONFLICT (cidade, estado)
    DO UPDATE SET
        _loaded_at = NOW();

    RAISE NOTICE 'dim_localidade carregada com UPSERT.';

END;
$$;