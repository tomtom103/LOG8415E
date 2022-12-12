import paramiko
import dotenv

from typing import List, Optional
from pydantic import BaseConfig, BaseModel

class Settings(BaseConfig):
    HOST: str = "0.0.0.0"
    PORT: int = 8000
    DB_USER: str = "ubuntu"
    DB_PASSWORD: str = "root"
    DB_NAME: str = "sakila"
    MASTER_NODE_IP = "44.213.89.51"
    SLAVE_NODE_IPS = [
        "75.101.226.3",
        "18.207.182.189",
        "44.193.83.58"
    ]

    # Host used by SSHTunnelForwarder
    # Value is set by the check_header dependency
    CHOSEN_HOST: Optional[str] = None

    RSA_PRIVATE_KEY: Optional[paramiko.RSAKey] = None

CONFIG = Settings()

class LogConfig(BaseModel):
    """Logging configuration to be set for the server"""

    LOGGER_NAME: str = "mycoolapp"
    LOG_FORMAT: str = "%(levelprefix)s | %(asctime)s | %(message)s"
    LOG_LEVEL: str = "DEBUG"

    # Logging config
    version = 1
    disable_existing_loggers = False
    formatters = {
        "default": {
            "()": "uvicorn.logging.DefaultFormatter",
            "fmt": LOG_FORMAT,
            "datefmt": "%Y-%m-%d %H:%M:%S",
        },
    }
    handlers = {
        "default": {
            "formatter": "default",
            "class": "logging.StreamHandler",
            "stream": "ext://sys.stderr",
        },
    }
    loggers = {
        "api": {"handlers": ["default"], "level": LOG_LEVEL},
    }