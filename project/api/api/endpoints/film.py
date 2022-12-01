import logging

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from api.api.deps import get_db

logger = logging.getLogger(__name__)

router = APIRouter()

base_route = ""

@router.get(base_route)
def get_films(
    session: Session = Depends(get_db)
):
    films = session.execute(
        "SELECT * FROM film"
    ).all()

    logger.info(f"Films: {films}")
    
    return films