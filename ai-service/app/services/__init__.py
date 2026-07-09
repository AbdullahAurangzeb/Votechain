"""Business logic services for OCR, face recognition, and liveness detection."""

from app.services.cnic_parser import ParsedCnic, parse_cnic_text
from app.services.ocr_service import OcrService, ocr_service

__all__ = ["OcrService", "ocr_service", "ParsedCnic", "parse_cnic_text"]
