-------------------------------------------------
-- Faturamento por mês
-------------------------------------------------
SELECT
    t.ano,
    t.mes,
    SUM(f.valor_total) AS faturamento_bruto,
    SUM(f.valor_liquido) AS faturamento_liquido
FROM 
    dw.fato_vendas f
JOIN
    dw.dim_tempo t
    ON t.sk_tempo = f.sk_tempo
WHERE
    f.status_pedido != 'Cancelado'
GROUP BY
    t.ano, t.mes
ORDER BY
    t.ano, t.mes;


-------------------------------------------------
-- Faturamento por produto
-------------------------------------------------
SELECT
	p.sk_produto,
	p.produto,
    SUM(f.valor_total) AS faturamento_bruto,
    SUM(f.valor_liquido) AS faturamento_liquido
FROM 
    dw.fato_vendas f
JOIN 
    dw.dim_produto p
    ON p.sk_produto = f.sk_produto
WHERE
    f.status_pedido != 'Cancelado'
GROUP BY
    p.sk_produto, p.produto
ORDER BY
    p.sk_produto, p.produto;
    

-------------------------------------------------
-- Faturamento por categoria
-------------------------------------------------
SELECT
	p.categoria,
    SUM(f.valor_total) AS faturamento_bruto,
    SUM(f.valor_liquido) AS faturamento_liquido
FROM 
    dw.fato_vendas f
JOIN 
    dw.dim_produto p
    ON p.sk_produto = f.sk_produto
WHERE
    f.status_pedido != 'Cancelado'
GROUP BY
    p.categoria
ORDER BY
    p.categoria;


-------------------------------------------------
-- Faturamento por estado
-------------------------------------------------
SELECT
	l.cidade,
	l.estado,
    SUM(f.valor_total) AS faturamento_bruto,
    SUM(f.valor_liquido) AS faturamento_liquido
FROM 
    dw.fato_vendas f
JOIN 
    dw.dim_localidade l
    ON l.sk_localidade = f.sk_localidade
WHERE
    f.status_pedido != 'Cancelado'
GROUP BY
    l.cidade, l.estado
ORDER BY
    l.cidade, l.estado;


-------------------------------------------------
-- Vendas por canal
-------------------------------------------------
SELECT
	cv.canal_venda,
	COUNT(*) AS qtd_pedidos,
	SUM(f.valor_total) AS faturamento_bruto,
    SUM(f.valor_liquido) AS faturamento_liquido
FROM 
    dw.fato_vendas f
JOIN 
    dw.dim_canal_venda cv
    ON cv.sk_canal_venda = f.sk_canal_venda
WHERE
    f.status_pedido != 'Cancelado'
GROUP BY
    cv.canal_venda
ORDER BY
    cv.canal_venda;


-------------------------------------------------
-- Vendas por forma de pagamento
-------------------------------------------------
SELECT
	p.forma_pagamento,
	COUNT(*) AS qtd_pedidos,
	SUM(f.valor_total) AS faturamento_bruto,
    SUM(f.valor_liquido) AS faturamento_liquido
FROM 
    dw.fato_vendas f
JOIN 
    dw.dim_pagamento p
    ON p.sk_pagamento = f.sk_pagamento
WHERE
    f.status_pedido != 'Cancelado'
GROUP BY
    p.forma_pagamento
ORDER BY
    p.forma_pagamento;


-------------------------------------------------
-- Percentual de devoluções
-------------------------------------------------
WITH totais AS (
	SELECT
    	(SELECT COUNT(*) FROM dw.fato_vendas WHERE status_pedido <> 'Cancelado') AS total_vendas,
    	(SELECT COUNT(*) FROM dw.fato_devolucoes WHERE status_devolucao = 'Concluída') AS total_devolucoes
)
SELECT
	total_vendas,
	total_devolucoes,
    ROUND(100.0 * total_devolucoes / NULLIF(total_vendas, 0), 2) AS pct_devolucoes
FROM
	totais;


-------------------------------------------------
-- Valor perdido com devoluções
-------------------------------------------------
SELECT
	SUM(valor_devolvido)
FROM
	dw.fato_devolucoes
WHERE
	status_devolucao = 'Concluída';


-------------------------------------------------
-- Faturamento líquido
-------------------------------------------------
SELECT
    SUM(valor_liquido) AS faturamento_liquido
FROM 
    dw.fato_vendas
WHERE
    status_pedido != 'Cancelado';


-------------------------------------------------
-- Produtos abaixo do estoque mínimo
-------------------------------------------------
SELECT
	p.produto_id,
	p.produto,
	e.estoque_atual,
	e.estoque_minimo,
	e.abaixo_minimo,
	e.centro_distribuicao
FROM 
    dw.fato_estoque e
JOIN
	dw.dim_produto p
	ON p.sk_produto = e.sk_produto
WHERE
	e.abaixo_minimo = True
ORDER BY
	e.estoque_atual DESC;