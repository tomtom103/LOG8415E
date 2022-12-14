import logging

from fastapi import APIRouter, Depends, Response
from proxy.api.deps import get_db
from pymysql.cursors import Cursor

from proxy.settings import CONFIG

logger = logging.getLogger("api")

router = APIRouter()

base_route = ""
film_route = "/{film_id}"

@router.get(base_route)
def get_films(
    response: Response,
    cursor: Cursor = Depends(get_db)
):
    modified_rows = cursor.execute(
        "SELECT * FROM film"
    )
    response.headers["X-Total-Row-Count"] = str(modified_rows)
    response.headers["X-Instance-IP"] = CONFIG.CHOSEN_HOST
    logger.info(f"Modified rows: {modified_rows}")
    return cursor.fetchall()

@router.get(film_route)
def get_film(
    film_id: int,
    response: Response,
    cursor: Cursor = Depends(get_db)
):
    modified_rows = cursor.execute(
        f"SELECT * FROM film WHERE film_id = {film_id}",
    )
    response.headers["X-Total-Row-Count"] = str(modified_rows)
    response.headers["X-Instance-IP"] = CONFIG.CHOSEN_HOST
    return cursor.fetchone()