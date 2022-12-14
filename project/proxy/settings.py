import paramiko
import functools

from typing import List, Optional
from pydantic import BaseSettings, BaseModel, validator

@functools.lru_cache
def get_settings():
    return Settings()

class Settings(BaseSettings):
    HOST: str = "0.0.0.0"
    PORT: int = 8000
    DB_USER: str = "ubuntu"
    DB_PASSWORD: str = "root"
    DB_NAME: str = "sakila"

    # Master and Slave ips
    # These are set via environment variables
    MASTER_NODE_IP: str = ""
    SLAVE_NODE_0_IP: str = ""
    SLAVE_NODE_1_IP: str = ""
    SLAVE_NODE_2_IP: str = ""

    ALL_NODE_IPS: List[str] = []
    @validator("ALL_NODE_IPS", pre=True)
    def set_all_node_ips(cls, v, values) -> List[str]:
        return [
            values["MASTER_NODE_IP"],
            values["SLAVE_NODE_0_IP"],
            values["SLAVE_NODE_1_IP"],
            values["SLAVE_NODE_2_IP"],
        ]

    # Host used by SSHTunnelForwarder
    # Value is set by the check_header dependency
    CHOSEN_HOST: Optional[str] = None

    # File is read from labsuser.pem file
    # This is required by SSHTunnelForwarder
    RSA_PRIVATE_KEY: Optional[paramiko.RSAKey] = None

    class Config:
        env_file = '.env'
        env_file_encoding = "utf-8"

CONFIG = get_settings()

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