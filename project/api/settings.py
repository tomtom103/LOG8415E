from typing import List

from pydantic import BaseConfig

class Settings(BaseConfig):
    HOST: str = "0.0.0.0"
    PORT: int = 8000
    DB_USER: str = "ubuntu"
    DB_PASSWORD: str = "root"
    DB_NAME: str = "sakila"
    MASTER_NODE_IP: str = "44.211.245.180"
    SLAVE_NODE_IPS: List[str] = [
        "44.199.204.247",
        # "3.238.8.143",
        # "3.235.43.112",
    ]
    SQLALCHEMY_DATABASE_URI: str = ""

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"

CONFIG = Settings()