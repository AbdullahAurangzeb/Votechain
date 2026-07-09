from functools import lru_cache
from pathlib import Path

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict

BASE_DIR = Path(__file__).resolve().parents[2]


class Settings(BaseSettings):
    """Validated environment configuration for the VoteChain AI service."""

    model_config = SettingsConfigDict(
        env_file=BASE_DIR / ".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    app_name: str = Field(default="VoteChain AI Service", alias="APP_NAME")
    environment: str = Field(default="development", alias="ENVIRONMENT")
    host: str = Field(default="0.0.0.0", alias="HOST")
    port: int = Field(default=8000, alias="PORT")
    debug: bool = Field(default=True, alias="DEBUG")

    cors_origin: str = Field(
        default="http://localhost:5000",
        alias="CORS_ORIGIN",
    )

    upload_dir: str = Field(default="uploads", alias="UPLOAD_DIR")
    upload_max_file_size_mb: int = Field(default=5, alias="UPLOAD_MAX_FILE_SIZE_MB")

    easyocr_languages: str = Field(default="en", alias="EASYOCR_LANGUAGES")
    ocr_blur_threshold: float = Field(default=100.0, alias="OCR_BLUR_THRESHOLD")

    @property
    def is_production(self) -> bool:
        return self.environment.lower() == "production"

    @property
    def cors_origins(self) -> list[str]:
        return [
            origin.strip()
            for origin in self.cors_origin.split(",")
            if origin.strip()
        ]

    @property
    def upload_path(self) -> Path:
        path = BASE_DIR / self.upload_dir
        path.mkdir(parents=True, exist_ok=True)
        return path

    @property
    def upload_max_file_size_bytes(self) -> int:
        return self.upload_max_file_size_mb * 1024 * 1024


@lru_cache
def get_settings() -> Settings:
    """Returns a cached settings instance."""
    return Settings()
