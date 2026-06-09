CREATE OR REPLACE PROCEDURE dw.load_dim_pagamento()
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO dw.dim_pagamento(
        forma_pagamento,
        _loaded_at
    )
    SELECT DISTINCT
        forma_pagamento,
        NOW()
    FROM
        staging.stg_vendas
    WHERE
        forma_pagamento IS NOT NULL
    ON CONFLICT (forma_pagamento)
    DO UPDATE SET
        _loaded_at = NOW();
    RAISE NOTICE 'dim_pagamento carregado com UPSERT.';
END;
$$;