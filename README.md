# 🏪 Data Warehouse: Vendas de Eletrônicos

![Python](https://img.shields.io/badge/python-3670A0?style=flat-square&logo=python&logoColor=ffdd54)
![Pandas](https://img.shields.io/badge/pandas-%23150458.svg?style=flat-square&logo=pandas&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/postgresql-4169e1?style=flat-square&logo=postgresql&logoColor=white)
![SQLAlchemy](https://img.shields.io/badge/SQLAlchemy-cc0000?style=flat-square&logo=sqlalchemy&logoColor=white)


## 📋 Índice

- [📌 Descrição do Projeto](#-descrição-do-projeto)
- [🏗️ Arquitetura (Fluxo de Dados)](#️-arquitetura-fluxo-de-dados)
- [🔧 Componentes do Pipeline](#-componentes-do-pipeline)
  - [RAW — Carga dos Dados Brutos](#raw--carga-dos-dados-brutos)
  - [Staging — Transformação e Limpeza](#staging--transformação-e-limpeza)
  - [DW — Data Warehouse (Dimensões e Fatos)](#dw--data-warehouse-dimensões-e-fatos)
  - [Análises — Consultas de Negócio](#análises--consultas-de-negócio)
- [📁 Estrutura do Repositório](#-estrutura-do-repositório)
- [🛠️ Ferramentas e Tecnologias](#️-ferramentas-e-tecnologias)
- [👤 Autor](#-autor)



<br>

## 📌 Descrição do Projeto

Desafio proposto pelo [Walter Gonzaga](https://www.youtube.com/@gonzagadosdados) na comunidade [ComuniDados](https://www.linkedin.com/company/comuni-dados/), com o objetivo de construir um Data Warehouse completo do zero para um e-commerce de eletrônicos.

O projeto implementa um pipeline de dados em três camadas: os arquivos CSV brutos (vendas, estoque e devoluções) são ingeridos sem modificação na camada **RAW**, tratados e padronizados via SQL na camada **Staging**, e por fim carregados em um schema dimensional no padrão **Star Schema** no PostgreSQL, com tabelas de dimensão e fato prontas para análises de negócio.

<br>

## 🏗️ Arquitetura (Fluxo de Dados)

```
  vendas.csv   ─┐
  estoque.csv  ─┼──▶  [ RAW ]   ──▶   [ STAGING ]   ──▶   [ DW ]   ──▶   Análises
  devolucoes   ─┘
                       ingestão        limpeza e            Star Schema
                       sem             padronização         dim_* + fato_*
                       transformação   via SQL              via procedures
```

<br>

## 🔧 Componentes do Pipeline

### RAW — Carga dos Dados Brutos
**Arquivos:** `scripts/run_raw.py` · `scripts/carga_raw.py` · `sql/raw/raw.sql`

Responsável por criar o schema `raw` no PostgreSQL e ingerir os arquivos CSV de origem sem nenhuma transformação.

- `run_raw.py` executa o script `sql/raw/raw.sql`, que cria o schema `raw` e as tabelas `raw_vendas`, `raw_estoque` e `raw_devolucoes`
- `carga_raw.py` lê os caminhos dos arquivos CSV a partir das variáveis de ambiente (`PATH_VENDAS`, `PATH_ESTOQUE`, `PATH_DEVOLUCOES`), faz a leitura com Pandas e insere os registros via SQLAlchemy com `if_exists='append'`
- Em caso de arquivo não encontrado ou variável de ambiente ausente, o erro é registrado em log sem interromper as demais cargas

---

### Staging — Transformação e Limpeza
**Arquivos:** `scripts/run_staging.py` · `sql/staging/`

Responsável por padronizar e limpar os dados brutos do schema `raw`, preparando-os para a carga no DW.

| Arquivo SQL | O que faz |
| :--- | :--- |
| `staging.sql` | Cria o schema `staging` e as tabelas `stg_vendas`, `stg_estoque` e `stg_devolucoes` |
| `load_stg_vendas.sql` | Limpa e tipifica os dados de vendas (datas, valores numéricos, strings) |
| `load_stg_estoque.sql` | Normaliza dados de estoque, calcula campos como `valor_estoque_total` e `abaixo_minimo` |
| `load_stg_devolucoes.sql` | Padroniza dados de devoluções, alinha chaves com vendas |
| `procedure_stg_orquestradora.sql` | Cria a procedure `staging.run_staging()` que orquestra a carga das três tabelas em sequência |

---

### DW — Data Warehouse (Dimensões e Fatos)
**Arquivos:** `scripts/run_dw.py` · `sql/dw/`

Responsável por criar o schema dimensional `dw` e popular as tabelas de dimensão e fato a partir dos dados tratados no staging.

**Dimensões:**

| Tabela | Chave Natural | Descrição |
| :--- | :--- | :--- |
| `dim_produto` | `produto_id` | Produto, categoria, marca, fornecedor e centro de distribuição |
| `dim_cliente` | `cliente_id` | Identificação do cliente |
| `dim_tempo` | `data_completa` | Datas com granularidade de ano, trimestre, mês, semana, dia, etc. |
| `dim_localidade` | `(cidade, estado)` | Localidade de entrega |
| `dim_canal_venda` | `canal_venda` | Canal pelo qual a venda foi realizada |
| `dim_pagamento` | `forma_pagamento` | Forma de pagamento utilizada |

<br>

**Fatos:**

| Tabela | Chave Primária | Métricas Principais |
| :--- | :--- | :--- |
| `fato_vendas` | `nk_pedido` | `quantidade`, `preco_unitario`, `desconto`, `frete`, `valor_total`, `valor_liquido` |
| `fato_estoque` | `sk_produto` | `estoque_inicial`, `entradas_periodo`, `estoque_atual`, `estoque_minimo`, `valor_estoque_total`, `abaixo_minimo` |
| `fato_devolucoes` | `nk_devolucao` | `quantidade_devolvida`, `valor_devolvido`, `motivo_devolucao`, `status_devolucao` |

> **Por que usar Surrogate Keys (SK)?**  
> As tabelas de dimensão usam chaves artificiais (`SERIAL`) como PK, enquanto as chaves de negócio são armazenadas separadamente (`produto_id`, `cliente_id`, etc.). Isso isola o DW de mudanças nos sistemas de origem e melhora a performance dos JOINs.

---

### Análises — Consultas de Negócio
**Arquivo:** `sql/analises/analises.sql`

Conjunto de queries SQL prontas para responder às principais perguntas de negócio sobre os dados carregados no DW:

| # | Análise |
|:---|:---|
| 1 | Faturamento por mês |
| 2 | Faturamento por produto |
| 3 | Faturamento por categoria |
| 4 | Faturamento por estado/cidade |
| 5 | Vendas por canal de venda |
| 6 | Vendas por forma de pagamento |
| 7 | Percentual de devoluções |
| 8 | Valor perdido com devoluções |
| 9 | Faturamento líquido |
| 10 | Produtos abaixo do estoque mínimo |

<br>

## 📁 Estrutura do Repositório
```text
desafio-dw-eletronicos/
├── 📁 data/
│   ├── desafio2_vendas.csv         # Dados brutos de vendas
│   ├── desafio2_estoque.csv        # Dados brutos de estoque
│   └── desafio2_devolucoes.csv     # Dados brutos de devoluções
├── 📁 docs/
│   └── desafio_2_guia_completo.pdf # Enunciado e requisitos do desafio
├── 📁 scripts/
│   ├── connection.py               # Configuração do engine SQLAlchemy
│   ├── carga_raw.py                # Ingestão dos CSVs para a camada RAW
│   ├── run_raw.py                  # Automação da camada RAW
│   ├── run_staging.py              # Automação da camada Staging
│   ├── run_dw.py                   # Automação da camada DW
│   └── main.py                     # Execução completa do pipeline (RAW → Staging → DW)
├── 📁 sql/
│   ├── 📁 raw/
│   │   └── raw.sql                 # Criação do schema e tabelas brutas
│   ├── 📁 staging/
│   │   ├── staging.sql             # Criação do schema staging
│   │   ├── load_stg_vendas.sql     # Transformação de vendas
│   │   ├── load_stg_estoque.sql    # Transformação de estoque
│   │   ├── load_stg_devolucoes.sql # Transformação de devoluções
│   │   └── procedure_stg_orquestradora.sql
│   ├── 📁 dw/
│   │   ├── dw.sql                  # Criação do schema DW (dimensões + fatos)
│   │   ├── dim_produto.sql
│   │   ├── dim_cliente.sql
│   │   ├── dim_tempo.sql
│   │   ├── dim_localidade.sql
│   │   ├── dim_canal_venda.sql
│   │   ├── dim_pagamento.sql
│   │   ├── fato_vendas.sql
│   │   ├── fato_estoque.sql
│   │   ├── fato_devolucoes.sql
│   │   └── procedure_dw_orquestradora.sql
│   └── 📁 analises/
│       └── analises.sql            # Consultas analíticas de negócio
├── .env                            # Variáveis de ambiente (não versionado)
├── .gitignore
├── README.md
└── requirements.txt
```

<br>

## 🛠️ Ferramentas e Tecnologias

| Nome | Versão | Uso no Projeto |
| :--- | :--- | :--- |
| **Python** | ≥ 3.10 | Scripts de ingestão e orquestração do pipeline |
| **PostgreSQL** | ≥ 14 | Banco de dados relacional (schemas RAW, Staging e DW) |
| **Pandas** | 3.0.3 | Leitura e ingestão dos arquivos CSV |
| **SQLAlchemy** | 2.0.50 | Conexão e execução de comandos no banco de dados |
| **psycopg2-binary** | 2.9.12 | Driver PostgreSQL para o SQLAlchemy |
| **python-dotenv** | 1.2.2 | Carregamento das variáveis de ambiente do `.env` |

<br>

## 👤 Autor

**Willian Mateus** | *Data Analyst & Business Intelligence*

ℹ️ Para saber mais sobre mim, ver meus outros projetos ou entrar em contato, visite meu [Perfil do GitHub](https://github.com/WillianMateus4).
