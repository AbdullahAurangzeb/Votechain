from fastapi import Request
from fastapi.responses import JSONResponse


class AIServiceError(Exception):
    """Base operational error for the AI service."""

    def __init__(self, message: str, status_code: int = 400) -> None:
        super().__init__(message)
        self.message = message
        self.status_code = status_code


async def ai_service_error_handler(
    _request: Request,
    exc: AIServiceError,
) -> JSONResponse:
    """Maps domain errors to standardized JSON responses."""
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "success": False,
            "confidence": None,
            "message": exc.message,
            "data": None,
        },
    )


async def unhandled_exception_handler(
    _request: Request,
    _exc: Exception,
) -> JSONResponse:
    """Returns a safe response for unexpected server failures."""
    return JSONResponse(
        status_code=500,
        content={
            "success": False,
            "confidence": None,
            "message": "Internal server error",
            "data": None,
        },
    )
