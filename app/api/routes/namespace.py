from fastapi import APIRouter
from fastapi.responses import JSONResponse

from app.services.namespace_service import (
    get_namespace_details,
    get_namespace_rca
)

router = APIRouter()


@router.get("/namespace/{namespace_name}")
def namespace_details(namespace_name: str):

    data = get_namespace_details(
        namespace_name
    )

    return JSONResponse(
        content=data
    )


@router.get("/namespace/{namespace_name}/rca")
def namespace_rca(namespace_name: str):

    data = get_namespace_rca(
        namespace_name
    )

    return JSONResponse(
        content=data
    )
