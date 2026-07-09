import logging
import time
from pathlib import Path

import cv2
import easyocr
import numpy as np
from PIL import Image, UnidentifiedImageError

from app.utils.config import get_settings
from app.utils.exceptions import AIServiceError

logger = logging.getLogger(__name__)


class OcrService:
    """EasyOCR wrapper for extracting text from document images."""

    def __init__(self) -> None:
        self._reader: easyocr.Reader | None = None

    @property
    def is_ready(self) -> bool:
        """Whether the EasyOCR reader has been initialized."""
        return self._reader is not None

    def initialize(self) -> None:
        """Loads the EasyOCR reader once during application startup."""
        if self._reader is not None:
            logger.info("EasyOCR reader already initialized; skipping reload")
            return

        settings = get_settings()
        languages = [
            language.strip()
            for language in settings.easyocr_languages.split(",")
            if language.strip()
        ]
        if not languages:
            languages = ["en"]

        logger.info("Initializing EasyOCR reader for languages: %s", languages)
        start = time.perf_counter()

        try:
            self._reader = easyocr.Reader(languages, gpu=False)
        except Exception as exc:
            logger.exception("Failed to initialize EasyOCR reader")
            raise AIServiceError("Failed to initialize OCR engine", 500) from exc

        elapsed_ms = (time.perf_counter() - start) * 1000
        logger.info("EasyOCR reader initialized in %.2f ms", elapsed_ms)

    def shutdown(self) -> None:
        """Releases the OCR reader on application shutdown."""
        self._reader = None
        logger.info("EasyOCR reader released")

    def extract_text(self, image_path: str | Path) -> list[str]:
        """
        Extracts all detected text lines from an image file.

        Args:
            image_path: Absolute or relative path to the image file.

        Returns:
            A list of non-empty text strings detected in reading order.

        Raises:
            AIServiceError: When the service, file, or OCR processing fails.
        """
        if self._reader is None:
            raise AIServiceError("OCR service is not initialized", 503)

        path = Path(image_path)
        if not path.is_file():
            raise AIServiceError("Image file not found", 404)

        self._validate_image(path)
        image = self._load_image(path)
        self._validate_sharpness(image, path.name)

        start = time.perf_counter()
        try:
            results = self._reader.readtext(image)
        except Exception as exc:
            logger.exception("EasyOCR processing failed for %s", path.name)
            raise AIServiceError("OCR processing failed", 500) from exc
        finally:
            elapsed_ms = (time.perf_counter() - start) * 1000
            logger.info("OCR execution time for %s: %.2f ms", path.name, elapsed_ms)

        lines = [
            text.strip()
            for _bbox, text, _confidence in results
            if isinstance(text, str) and text.strip()
        ]

        if not lines:
            logger.warning("No OCR text detected for %s", path.name)

        return lines

    def _validate_image(self, path: Path) -> None:
        """Validates image integrity with Pillow before OCR processing."""
        try:
            with Image.open(path) as image:
                image.verify()
        except (UnidentifiedImageError, OSError) as exc:
            logger.warning("Invalid image file rejected for OCR: %s", path.name)
            raise AIServiceError("Invalid or unreadable image file", 400) from exc

    def _load_image(self, path: Path) -> np.ndarray:
        """Loads an image into an OpenCV-compatible NumPy array."""
        image = cv2.imread(str(path))
        if image is None:
            raise AIServiceError("Invalid or unreadable image file", 400)
        return image

    def _validate_sharpness(self, image: np.ndarray, filename: str) -> None:
        """Rejects blurry images that are unlikely to produce reliable OCR."""
        settings = get_settings()
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        variance = float(cv2.Laplacian(gray, cv2.CV_64F).var())
        logger.info("Image sharpness score for %s: %.2f", filename, variance)

        if variance < settings.ocr_blur_threshold:
            raise AIServiceError(
                "Image is too blurry. Please upload a clearer CNIC photo.",
                422,
            )


ocr_service = OcrService()
