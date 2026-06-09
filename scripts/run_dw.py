import logging
from pathlib import Path
from sqlalchemy import text
from connection import engine

logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')
logger = logging.getLogger(__name__)

BASE_DIR = Path(__file__).resolve().parent.parent
SQL_DIR = BASE_DIR / "sql" / "dw"

def execute_sql_file(filename):
    """Lê um arquivo .sql e o executa no banco de dados."""
    file_path = SQL_DIR / filename
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            sql_command = file.read()
            
            with engine.begin() as conn:
                conn.execute(text(sql_command))
        logger.info(f"Arquivo '{filename}' executado com sucesso!")
    except Exception as e:
        logger.error(f"Erro ao executar '{filename}': {e}")
        raise

def run_pipeline():
    logger.info("Iniciando a automação da camada DW")

    execute_sql_file('dw.sql')

    execute_sql_file('dim_canal_venda.sql')
    execute_sql_file('dim_cliente.sql')
    execute_sql_file('dim_localidade.sql')
    execute_sql_file('dim_pagamento.sql')
    execute_sql_file('dim_produto.sql')
    execute_sql_file('dim_tempo.sql')
    execute_sql_file('fato_vendas.sql')
    execute_sql_file('fato_estoque.sql')
    execute_sql_file('fato_devolucoes.sql')
    execute_sql_file('procedure_dw_orquestradora.sql')

    logger.info("Executando a carga da camada DW...")
    try:
        with engine.begin() as conn:
            conn.execute(text("CALL dw.run_dw();"))
            logger.info("Camada DW carregada com sucesso!")
            
    except Exception as e:
         logger.error(f"Erro ao processar as procedures: {e}")

if __name__ == "__main__":
    run_pipeline()