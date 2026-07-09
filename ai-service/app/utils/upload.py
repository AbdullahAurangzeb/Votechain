import secrets
from pathlib import Path

from fastapi import UploadFile

from app.utils.config import Settings
from app.utils.exceptions import AIServiceError

ALLOWED_IMAGE_CONTENT_TYPES = {
    "image/jpeg",
    "image/png",
    "image/webp",
}

ALLOWED_IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp"}

CONTENT_TYPE_EXTENSIONS = {
    "image/jpeg": ".jpg",
    "image/png": ".png",
    "image/webp": ".webp",
}


def validate_image_upload(file: UploadFile, settings: Settings) -> None:
    """
    Validates multipart image uploads before OCR or face processing.

    Raises:
        AIServiceError: When the file type or size is invalid.
    """
    content_type = (file.content_type or "").lower()
    filename_extension = Path(file.filename or "").suffix.lower()

    if (
        content_type not in ALLOWED_IMAGE_CONTENT_TYPES
        and filename_extension not in ALLOWED_IMAGE_EXTENSIONS
    ):
        raise AIServiceError("Unsupported file type. Use JPEG, PNG, or WebP.", 400)

    if file.size is not None and file.size > settings.upload_max_file_size_bytes:
        raise AIServiceError(
            f"File too large. Maximum size is {settings.upload_max_file_size_mb}MB.",
            400,
        )


async def save_uploaded_image(file: UploadFile, settings: Settings) -> Path:
    """
    Persists an uploaded image to the configured uploads directory.

    Returns:
        Path to the saved temporary file.

    Raises:
        AIServiceError: When the upload is empty or exceeds size limits.
    """
    validate_image_upload(file, settings)

    content_type = (file.content_type or "").lower()
    filename_extension = Path(file.filename or "").suffix.lower()
    extension = CONTENT_TYPE_EXTENSIONS.get(content_type)
    if extension is None:
        extension = filename_extension if filename_extension in ALLOWED_IMAGE_EXTENSIONS else ".jpg"
    filename = f"ocr-{secrets.token_hex(8)}{extension}"
    destination = settings.upload_path / filename

    content = await file.read()
    if not content:
        raise AIServiceError("Uploaded image is empty", 400)

    if len(content) > settings.upload_max_file_size_bytes:
        raise AIServiceError(
            f"File too large. Maximum size is {settings.upload_max_file_size_mb}MB.",
            400,
        )

    destination.write_bytes(content)
    return destination


def delete_file(path: Path) -> None:
    """Removes a temporary file if it exists."""
    if path.is_file():
        path.unlink()
