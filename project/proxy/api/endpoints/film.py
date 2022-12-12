import logging

from fastapi import APIRouter, Depends
from proxy.api.deps import get_db
from pymysql.cursors import Cursor

logger = logging.getLogger(__name__)

router = APIRouter()

base_route = ""
film_route = "/{film_id}"

@router.get(base_route)
def get_films(
    cursor: Cursor = Depends(get_db)
):
    modified_rows = cursor.execute(
        "SELECT * FROM film"
    )
    logger.info(f"Modified rows: {modified_rows}")
    return cursor.fetchall()

@router.get(film_route)
def get_film(
    film_id: int,
    cursor: Cursor = Depends(get_db)
):
    modified_rows = cursor.execute(
        f"SELECT * FROM film WHERE film_id = {film_id}",
    )
    logger.info(f"Modified rows: {modified_rows}")
    return cursor.fetchone()