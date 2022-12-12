import logging
import paramiko

from logging.config import dictConfig
from fastapi import FastAPI

from .api.api_router import api_router
from .settings import CONFIG, LogConfig

dictConfig(LogConfig().dict())
logger = logging.getLogger("api")

app = FastAPI(debug=True)

app.include_router(api_router)

@app.on_event("startup")
async def on_startup():
    logger.info("Starting up")
    CONFIG.RSA_PRIVATE_KEY = paramiko.RSAKey.from_private_key_file("labsuser.pem")

@app.on_event("shutdown")
async def on_shutdown():
    logger.info("Shutting down")


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "proxy.main:app",
        host=CONFIG.HOST,
        port=CONFIG.PORT,
        reload=True,
        reload_dirs=[]
    )

