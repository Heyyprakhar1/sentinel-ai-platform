from fastapi import APIRouter
from fastapi.responses import JSONResponse

from app.services.cluster_service import (
    get_cluster_data
)

router = APIRouter()


@router.get("/cluster/overview")
def cluster_overview():

    data = get_cluster_data()

    return JSONResponse(
        content=data
    )
