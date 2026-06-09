CREATE SCHEMA IF NOT EXISTS dw;

CREATE TABLE IF NOT EXISTS dw.dim_produto (
    sk_produto              SERIAL PRIMARY KEY,
    produto_id              INTEGER UNIQUE,
    produto                 VARCHAR(150),
    categoria               VARCHAR(50),
    marca                   VARCHAR(50),
    fornecedor              VARCHAR(50),
    centro_distribuicao     VARCHAR(50),
    _loaded_at              TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS dw.dim_cliente (
    sk_cliente              SERIAL PRIMARY KEY,
    cliente_id              INTEGER UNIQUE,
    _loaded_at              TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS dw.dim_tempo (
    sk_tempo                SERIAL PRIMARY KEY,
    data_completa           DATE UNIQUE,
    ano                     INTEGER,
    trimestre               INTEGER,
    mes                     INTEGER,
    nome_mes                VARCHAR(10),
    semana_ano              INTEGER,
    dia                     INTEGER,
    dia_semana              INTEGER,
    nome_dia                VARCHAR(20),
    is_fim_semana           BOOLEAN,
    _loaded_at              TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS dw.dim_localidade (
    sk_localidade           SERIAL PRIMARY KEY,
    cidade                  VARCHAR(100),
    estado                  CHAR(2),
    _loaded_at              TIMESTAMP DEFAULT NOW(),
    CONSTRAINT uk_dim_localidade_cidade_estado UNIQUE (cidade, estado)
);

CREATE TABLE IF NOT EXISTS dw.dim_canal_venda (
    sk_canal_venda          SERIAL PRIMARY KEY,
    canal_venda             VARCHAR(50) UNIQUE,
    _loaded_at              TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS dw.dim_pagamento (
    sk_pagamento            SERIAL PRIMARY KEY,
    forma_pagamento         VARCHAR(50) UNIQUE,
    _loaded_at              TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS dw.fato_vendas (
    nk_pedido               INTEGER PRIMARY KEY,

    sk_tempo                INTEGER,
    sk_produto              INTEGER,
    sk_cliente              INTEGER,
    sk_localidade           INTEGER,
    sk_canal_venda          INTEGER,
    sk_pagamento            INTEGER,

    quantidade              INTEGER,
    preco_unitario          NUMERIC(12, 2),
    desconto                NUMERIC(12, 2),
    frete                   NUMERIC(12, 2),
    valor_total             NUMERIC(12, 2),
    valor_liquido           NUMERIC(12, 2),
    status_pedido           VARCHAR(30),

    _loaded_at              TIMESTAMP DEFAULT NOW(),

    CONSTRAINT fk_fato_vendas_tempo
        FOREIGN KEY (sk_tempo)
        REFERENCES dw.dim_tempo(sk_tempo),

    CONSTRAINT fk_fato_vendas_produto
        FOREIGN KEY (sk_produto)
        REFERENCES dw.dim_produto(sk_produto),

    CONSTRAINT fk_fato_vendas_cliente
        FOREIGN KEY (sk_cliente)
        REFERENCES dw.dim_cliente(sk_cliente),

    CONSTRAINT fk_fato_vendas_localidade
        FOREIGN KEY (sk_localidade)
        REFERENCES dw.dim_localidade(sk_localidade),

    CONSTRAINT fk_fato_vendas_canal_venda
        FOREIGN KEY (sk_canal_venda)
        REFERENCES dw.dim_canal_venda(sk_canal_venda),

    CONSTRAINT fk_fato_vendas_pagamento
        FOREIGN KEY (sk_pagamento)
        REFERENCES dw.dim_pagamento(sk_pagamento)
);

CREATE TABLE IF NOT EXISTS dw.fato_estoque (
    sk_produto              INTEGER PRIMARY KEY,

    estoque_inicial         INTEGER,
    entradas_periodo        INTEGER,
    estoque_atual           INTEGER,
    estoque_minimo          INTEGER,
    custo_unitario          NUMERIC(12, 2),
    valor_estoque_total     NUMERIC(12, 2),
    abaixo_minimo           BOOLEAN,
    centro_distribuicao     VARCHAR(100),

    _loaded_at              TIMESTAMP DEFAULT NOW(),

    CONSTRAINT fk_fato_estoque_produto
        FOREIGN KEY (sk_produto)
        REFERENCES dw.dim_produto(sk_produto)
);

CREATE TABLE IF NOT EXISTS dw.fato_devolucoes (
    nk_devolucao            INTEGER PRIMARY KEY,

    pedido_id               INTEGER,

    sk_tempo                INTEGER,
    sk_produto              INTEGER,
    sk_cliente              INTEGER,

    quantidade_devolvida    INTEGER,
    valor_devolvido         NUMERIC(12, 2),
    motivo_devolucao        VARCHAR(100),
    status_devolucao        VARCHAR(30),

    _loaded_at              TIMESTAMP DEFAULT NOW(),

    CONSTRAINT fk_fato_devolucoes_tempo
        FOREIGN KEY (sk_tempo)
        REFERENCES dw.dim_tempo(sk_tempo),

    CONSTRAINT fk_fato_devolucoes_produto
        FOREIGN KEY (sk_produto)
        REFERENCES dw.dim_produto(sk_produto),

    CONSTRAINT fk_fato_devolucoes_cliente
        FOREIGN KEY (sk_cliente)
        REFERENCES dw.dim_cliente(sk_cliente)
);