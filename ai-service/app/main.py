import asyncio
import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.router import api_router
from app.services.ocr_service import ocr_service
from app.utils.config import get_settings
from app.utils.exceptions import AIServiceError, ai_service_error_handler, unhandled_exception_handler

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(name)s | %(message)s",
)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(_app: FastAPI):
    """Application startup and shutdown lifecycle hooks."""
    settings = get_settings()
    settings.upload_path.mkdir(parents=True, exist_ok=True)

    logger.info("Starting OCR engine initialization")
    await asyncio.to_thread(ocr_service.initialize)

    yield

    ocr_service.shutdown()


def create_app() -> FastAPI:
    """Creates and configures the FastAPI application."""
    settings = get_settings()

    app = FastAPI(
        title=settings.app_name,
        version="0.1.0",
        debug=settings.debug,
        lifespan=lifespan,
        docs_url="/docs",
        redoc_url="/redoc",
    )

    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    app.include_router(api_router)
    app.add_exception_handler(AIServiceError, ai_service_error_handler)
    app.add_exception_handler(Exception, unhandled_exception_handler)

    return app


app = create_app()
