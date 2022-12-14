import logging

from fastapi import APIRouter, Depends
from pydantic import BaseModel
from proxy.api.deps import get_db
from pymysql.cursors import Cursor

logger = logging.getLogger("api")

router = APIRouter()

base_route = ""

class SQLQuery(BaseModel):
    sql: str

@router.post(base_route)
async def post_raw_sql(
    sql: SQLQuery,
    cursor: Cursor = Depends(get_db)
):
    modified_rows = cursor.execute(
        sql.sql
    )
    logger.info(f"Modified rows: {modified_rows}")
    return cursor.fetchall()