import logging

from fastapi import APIRouter, Depends, Response
from pydantic import BaseModel
from proxy.api.deps import get_db
from pymysql.cursors import Cursor

from proxy.settings import CONFIG

logger = logging.getLogger("api")

router = APIRouter()

base_route = ""

class SQLQuery(BaseModel):
    sql: str

@router.post(base_route)
async def post_raw_sql(
    sql: SQLQuery,
    response: Response,
    cursor: Cursor = Depends(get_db)
):
    modified_rows = cursor.execute(
        sql.sql
    )
    response.headers["X-Total-Row-Count"] = str(modified_rows)
    response.headers["X-Instance-IP"] = CONFIG.CHOSEN_HOST
    return cursor.fetchall()