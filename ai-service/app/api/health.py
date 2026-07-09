from datetime import UTC, datetime

from fastapi import APIRouter

from app.models.responses import HealthData, HealthResponse
from app.utils.config import get_settings

router = APIRouter(tags=["Health"])


@router.get(
    "/health",
    response_model=HealthResponse,
    summary="Service health probe",
    description="Returns the current health status of the VoteChain AI service.",
)
async def get_health() -> HealthResponse:
    """Infrastructure health check for orchestration and monitoring."""
    settings = get_settings()

    return HealthResponse(
        success=True,
        message="VoteChain AI service is running",
        data=HealthData(
            status="ok",
            service=settings.app_name,
            timestamp=datetime.now(UTC),
        ),
    )
