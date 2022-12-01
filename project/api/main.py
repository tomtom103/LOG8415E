import uvicorn
import logging
from fastapi import FastAPI

from .api.api_router import api_router
from .settings import CONFIG

logger = logging.getLogger(__name__)

app = FastAPI(debug=True)

app.include_router(api_router)

@app.on_event("startup")
async def on_startup():
    ...

@app.on_event("shutdown")
async def on_shutdown():
    ...


if __name__ == "__main__":
    uvicorn.run(
        "api.main:app",
        host=CONFIG.HOST,
        port=CONFIG.PORT,
        reload=True,
        reload_dirs=["api"]
    )
