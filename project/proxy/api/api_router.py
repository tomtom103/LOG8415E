from fastapi import APIRouter, Depends

from .endpoints import (
    film,
    raw,
)
from .deps import check_header

api_router = APIRouter(
    prefix="/api",
)

api_router.include_router(
    film.router,
    tags=["film"],
    prefix="/film",
    dependencies=[Depends(check_header)]
)

api_router.include_router(
    raw.router,
    tags=["raw"],
    prefix="/raw",
    dependencies=[Depends(check_header)]
)