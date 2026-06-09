import os
import logging
import pandas as pd
from pathlib import Path
from dotenv import load_dotenv
from connection import engine

logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')
logger = logging.getLogger(__name__)

BASE_DIR = Path(__file__).resolve().parent.parent
env_path = BASE_DIR / ".env"
load_dotenv(dotenv_path=env_path)

def run_carga_raw():
    logger.info("Iniciando a carga de arquivos CSV para a camada RAW")
    
    datasets = {
        "raw_vendas": "PATH_VENDAS",
        "raw_estoque": "PATH_ESTOQUE",
        "raw_devolucoes": "PATH_DEVOLUCOES"
    }

    for table_name, env_var in datasets.items():
        file_path_str = os.getenv(env_var)
        
        if not file_path_str:
            logger.error(f"A variável de ambiente {env_var} não foi encontrada no .env!")
            continue 
            
        file_path = BASE_DIR / file_path_str
        nome_dominio = table_name.split('_')[1].capitalize()

        try:
            df = pd.read_csv(file_path, sep=",")
            if df.empty:
                logger.warning(f"O DataFrame de {nome_dominio} está vazio!")
            else:
                logger.info(f"Inserindo {len(df)} registros na tabela {table_name}...")
                df.to_sql(name=table_name, con=engine, schema="raw", if_exists="append", index=False)
                logger.info(f"Carga da tabela {table_name} concluída!")

        except FileNotFoundError:
            logger.error(f"Arquivo CSV não encontrado: {file_path}")
        except Exception as e:
            logger.error(f"Erro inesperado ao processar {table_name}: {e}")

if __name__ == "__main__":
    run_carga_raw()