import os
import logging
from pathlib import Path
from dotenv import load_dotenv
from urllib.parse import quote_plus
from sqlalchemy import create_engine, text

logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')
logger = logging.getLogger(__name__)

BASE_DIR = Path(__file__).resolve().parent.parent
env_path = BASE_DIR / ".env"
load_dotenv(dotenv_path=env_path)

host = os.getenv("DB_HOST", "localhost")
user = os.getenv("DB_USER")
database = os.getenv("DB_NAME")
port = os.getenv("DB_PORT")
password = os.getenv("DB_PASSWORD")

connection_string = (
    f"postgresql+psycopg2://{user}:{quote_plus(password)}@{host}:{port}/{database}"
)

engine = create_engine(connection_string)

try:
    with engine.connect() as conn:
        conn.execute(text("SELECT 1"))
        logger.info("✅ Conexão estabelecida com sucesso!")
except Exception as e:
    logger.error(f"❌ Erro inesperado: {e}")