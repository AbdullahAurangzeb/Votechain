from datetime import datetime
from typing import Any

from pydantic import BaseModel, Field


class HealthData(BaseModel):
    """Health probe payload."""

    status: str = Field(..., examples=["ok"])
    service: str = Field(..., examples=["votechain-ai-service"])
    timestamp: datetime


class HealthResponse(BaseModel):
    """Standard health endpoint response envelope."""

    success: bool = True
    confidence: float | None = None
    message: str
    data: HealthData


class AIResponse(BaseModel):
    """Base response schema for future OCR and face endpoints."""

    success: bool
    confidence: float | None = None
    message: str | None = None
    data: dict[str, Any] | None = None
