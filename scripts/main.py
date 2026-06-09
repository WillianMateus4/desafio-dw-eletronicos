import logging
import run_raw
import carga_raw
import run_staging
import run_dw

logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')
logger = logging.getLogger(__name__)

def run_all():
    logger.info("🚀 Iniciando o pipeline...")
    
    try:
        # 1. Prepara a camada RAW (Cria schema)
        run_raw.run_pipeline()
        
        # 2. Faz a carga dos arquivos CSV para o RAW
        carga_raw.run_carga_raw()
        
        # 3. Executa as transformações para o Staging
        run_staging.run_pipeline()
        
        # 4. Carrega os dados finais no Data Warehouse (Dimensões e Fatos)
        run_dw.run_pipeline()
        
        logger.info("✅ Pipeline concluído com sucesso!")
        
    except Exception as e:
        logger.error(f"❌ Erro no pipeline: {e}")

if __name__ == "__main__":
    run_all()