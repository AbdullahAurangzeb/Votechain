import logging
import time
from pathlib import Path

from fastapi import APIRouter, File, UploadFile, status

from app.models.ocr import OcrExtractResponse, ParsedCnicResponse
from app.services.cnic_parser import parse_cnic_text
from app.services.ocr_service import ocr_service
from app.utils.config import get_settings
from app.utils.upload import delete_file, save_uploaded_image

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/ocr", tags=["OCR"])


def _to_response_field(value: str | None) -> str:
    """Normalizes nullable parser output to API empty-string defaults."""
    return value.strip() if value else ""


@router.post(
    "/extract",
    response_model=OcrExtractResponse,
    status_code=status.HTTP_200_OK,
    summary="Extract CNIC fields from an uploaded image",
    description=(
        "Accepts a CNIC image via multipart upload, runs EasyOCR, parses Pakistani "
        "CNIC fields deterministically, and deletes the temporary file after processing."
    ),
    responses={
        400: {"description": "Unsupported file type, empty upload, or invalid image"},
        422: {"description": "Image is too blurry for reliable OCR"},
        500: {"description": "OCR processing failure"},
        503: {"description": "OCR engine not initialized"},
    },
)
async def extract_ocr_text(
    image: UploadFile = File(..., description="CNIC image (JPEG, PNG, or WebP)"),
) -> OcrExtractResponse:
    """Extracts OCR text and parsed CNIC fields from an uploaded image."""
    settings = get_settings()
    temp_path: Path | None = None
    request_started = time.perf_counter()

    try:
        temp_path = await save_uploaded_image(image, settings)
        raw_text = ocr_service.extract_text(temp_path)
        parsed = parse_cnic_text(raw_text)

        response = OcrExtractResponse(
            success=True,
            rawText=raw_text,
            parsed=ParsedCnicResponse(
                name=_to_response_field(parsed.name),
                fatherName=_to_response_field(parsed.father_name),
                cnic=_to_response_field(parsed.cnic),
                dateOfBirth=_to_response_field(parsed.date_of_birth),
                gender=_to_response_field(parsed.gender),
            ),
        )

        elapsed_ms = (time.perf_counter() - request_started) * 1000
        logger.info(
            "OCR extract completed for %s in %.2f ms (%d text lines)",
            image.filename or temp_path.name,
            elapsed_ms,
            len(raw_text),
        )
        return response
    finally:
        if temp_path is not None:
            delete_file(temp_path)
