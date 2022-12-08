from typing import List

from pydantic import BaseConfig

class Settings(BaseConfig):
    HOST: str = "0.0.0.0"
    PORT: int = 8000
    DB_USER: str = "ubuntu"
    DB_PASSWORD: str = "root"
    DB_NAME: str = "sakila"
    MASTER_NODE_IP: str = "35.175.123.158"
    BIND_ADDRESSES: List[str] = [
        # "slave1",
        "0.0.0.0"
        # "172.31.10.155"
        # "127.0.0.1",
        # "18.209.87.234",
    ]
    PYMYSQL_HOST: str = ""
    PYMYSQL_BIND_ADDRESS: str = ""

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"

CONFIG = Settings()