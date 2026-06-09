CREATE SCHEMA IF NOT EXISTS staging;

CREATE TABLE IF NOT EXISTS staging.stg_vendas (
	pedido_id 		        INTEGER PRIMARY KEY,
    data_pedido 	        DATE,
    cliente_id 		        INTEGER,
    produto_id 		        INTEGER,
    produto	 		        VARCHAR(150),
    categoria 		        VARCHAR(50),
    marca 			        VARCHAR(50),
    quantidade 		        INTEGER,
    preco_unitario 	        NUMERIC(12, 2),
    desconto 		        NUMERIC(12, 2),
    frete 			        NUMERIC(12, 2),
    valor_total 	        NUMERIC(12, 2),
    valor_liquido 	        NUMERIC(12, 2),
    canal_venda 	        VARCHAR(50),
    forma_pagamento         VARCHAR(50),
    cidade 			        VARCHAR(100),
    estado			        CHAR(2),
    status_pedido 	        VARCHAR(30),
    ano_pedido              INTEGER,
    mes_pedido              INTEGER,
    _loaded_at 		        TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS staging.stg_estoque (
    produto_id              INTEGER PRIMARY KEY,
    produto                 VARCHAR(150),
    categoria               VARCHAR(50),
    marca                   VARCHAR(50),
    fornecedor              VARCHAR(50),
    estoque_inicial         INTEGER,
    entradas_periodo        INTEGER,
    estoque_atual           INTEGER,
    estoque_minimo          INTEGER,
    custo_unitario          NUMERIC(12, 2),
    valor_estoque_total     NUMERIC(12,2),
    abaixo_minimo           BOOLEAN,
    centro_distribuicao     VARCHAR(50),
    _loaded_at              TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS staging.stg_devolucoes (
    devolucao_id            INTEGER PRIMARY KEY,
    pedido_id               INTEGER,
    data_devolucao          DATE,
    cliente_id              INTEGER,
    produto_id              INTEGER,
    quantidade_devolvida    INTEGER,
    valor_devolvido         NUMERIC(12, 2),
    motivo_devolucao        VARCHAR(100),
    status_devolucao        VARCHAR(30),
    ano_devolucao           INTEGER,
    mes_devolucao           INTEGER,
    _loaded_at              TIMESTAMP DEFAULT NOW()
);