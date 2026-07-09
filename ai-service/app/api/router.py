from fastapi import APIRouter

from app.api.health import router as health_router
from app.api.ocr import router as ocr_router

api_router = APIRouter()
api_router.include_router(health_router)
api_router.include_router(ocr_router)
