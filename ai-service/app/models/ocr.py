"""Pydantic schemas for OCR endpoints."""

from pydantic import BaseModel, Field


class ParsedCnicResponse(BaseModel):
    """Structured Pakistani CNIC fields parsed from OCR text."""

    name: str = ""
    fatherName: str = ""
    cnic: str = ""
    dateOfBirth: str = ""
    gender: str = ""


class OcrExtractResponse(BaseModel):
    """OCR text extraction and CNIC parsing response."""

    success: bool = Field(..., examples=[True])
    rawText: list[str] = Field(
        default_factory=list,
        examples=[["ISLAMIC REPUBLIC OF PAKISTAN", "ALI RAZA", "35202-1234567-1"]],
    )
    parsed: ParsedCnicResponse = Field(default_factory=ParsedCnicResponse)
