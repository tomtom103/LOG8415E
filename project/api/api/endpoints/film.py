import logging

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from api.api.deps import get_db
from pymysql.cursors import Cursor

logger = logging.getLogger(__name__)

router = APIRouter()

base_route = ""

@router.get(base_route)
def get_films(
    cursor: Cursor = Depends(get_db)
):
    modified_rows = cursor.execute(
        "SELECT * FROM film"
    )
    logger.info(f"Modified rows: {modified_rows}")
    return cursor.fetchall()