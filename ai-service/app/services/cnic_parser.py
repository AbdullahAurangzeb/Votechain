import re
from collections.abc import Callable
from dataclasses import dataclass

CNIC_REGEX = re.compile(r"\b(\d{5})[-\s]?(\d{7})[-\s]?(\d)\b")

DATE_NUMERIC_REGEX = re.compile(
    r"\b(\d{1,2})[./-](\d{1,2})[./-](\d{4})\b",
)

DATE_TEXT_REGEX = re.compile(
    r"\b(\d{1,2})\s+"
    r"(Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|"
    r"Jul(?:y)?|Aug(?:ust)?|Sep(?:tember)?|Oct(?:ober)?|Nov(?:ember)?|Dec(?:ember)?)"
    r"\s+(\d{4})\b",
    re.IGNORECASE,
)

GENDER_VALUE_REGEX = re.compile(r"\b(male|female|m|f)\b", re.IGNORECASE)

MONTH_NUMBER_TO_NAME = (
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
)

MONTH_NAMES = {
    "jan": "January",
    "january": "January",
    "feb": "February",
    "february": "February",
    "mar": "March",
    "march": "March",
    "apr": "April",
    "april": "April",
    "may": "May",
    "jun": "June",
    "june": "June",
    "jul": "July",
    "july": "July",
    "aug": "August",
    "august": "August",
    "sep": "September",
    "sept": "September",
    "september": "September",
    "oct": "October",
    "october": "October",
    "nov": "November",
    "november": "November",
    "dec": "December",
    "december": "December",
}

NOISE_LINE_PATTERNS = (
    re.compile(r"islamic republic", re.IGNORECASE),
    re.compile(r"national identity", re.IGNORECASE),
    re.compile(r"identity card", re.IGNORECASE),
    re.compile(r"government of pakistan", re.IGNORECASE),
    re.compile(r"country of stay", re.IGNORECASE),
    re.compile(r"date of issue", re.IGNORECASE),
    re.compile(r"date of expiry", re.IGNORECASE),
    re.compile(r"valid", re.IGNORECASE),
    re.compile(r"holder", re.IGNORECASE),
    re.compile(r"signature", re.IGNORECASE),
)

LABEL_PATTERNS = {
    "name": (
        re.compile(r"^name$", re.IGNORECASE),
        re.compile(r"^full\s+name$", re.IGNORECASE),
        re.compile(r"^name[:\s]+(?P<value>.+)$", re.IGNORECASE),
    ),
    "father_name": (
        re.compile(r"^father(?:'?s)?\s+name$", re.IGNORECASE),
        re.compile(r"^husband(?:'?s)?\s+name$", re.IGNORECASE),
        re.compile(r"^father\s*/\s*husband\s+name$", re.IGNORECASE),
        re.compile(
            r"^(?:father(?:'?s)?|husband(?:'?s)?)\s+name[:\s]+(?P<value>.+)$",
            re.IGNORECASE,
        ),
    ),
    "gender": (
        re.compile(r"^gender$", re.IGNORECASE),
        re.compile(r"^sex$", re.IGNORECASE),
        re.compile(r"^gender[:\s]+(?P<value>.+)$", re.IGNORECASE),
    ),
    "date_of_birth": (
        re.compile(r"^date\s+of\s+birth$", re.IGNORECASE),
        re.compile(r"^dob$", re.IGNORECASE),
        re.compile(r"^date\s+of\s+birth[:\s]+(?P<value>.+)$", re.IGNORECASE),
    ),
    "cnic": (
        re.compile(r"^identity\s+number$", re.IGNORECASE),
        re.compile(r"^cnic(?:\s+number)?$", re.IGNORECASE),
        re.compile(r"^nic$", re.IGNORECASE),
        re.compile(r"^identity\s+number[:\s]+(?P<value>.+)$", re.IGNORECASE),
    ),
}


@dataclass(frozen=True)
class ParsedCnic:
    """Structured CNIC fields extracted from OCR text."""

    name: str | None = None
    cnic: str | None = None
    date_of_birth: str | None = None
    gender: str | None = None
    father_name: str | None = None


def parse_cnic_text(raw_text: list[str]) -> ParsedCnic:
    """
    Parses Pakistani CNIC fields from EasyOCR text lines.

    Uses deterministic label matching and regular expressions only.
    """
    lines = _prepare_lines(raw_text)
    if not lines:
        return ParsedCnic()

    return ParsedCnic(
        name=_extract_name(lines),
        cnic=_extract_cnic(lines),
        date_of_birth=_extract_date_of_birth(lines),
        gender=_extract_gender(lines),
        father_name=_extract_father_name(lines),
    )


def _prepare_lines(raw_text: list[str]) -> list[str]:
    """Normalizes OCR lines and removes empty values."""
    prepared: list[str] = []
    for line in raw_text:
        normalized = _normalize_whitespace(line)
        if normalized:
            prepared.append(normalized)
    return prepared


def _normalize_whitespace(value: str) -> str:
    """Collapses repeated whitespace and trims OCR line noise."""
    return re.sub(r"\s+", " ", value.strip())


def _is_noise_line(line: str) -> bool:
    """Returns True when a line is generic CNIC card boilerplate."""
    if line.strip().lower() == "pakistan":
        return True
    return any(pattern.search(line) for pattern in NOISE_LINE_PATTERNS)


def _looks_like_label(line: str) -> bool:
    """Detects whether a line is likely a field label rather than a value."""
    normalized = line.strip()
    if _is_noise_line(normalized):
        return True

    for patterns in LABEL_PATTERNS.values():
        for pattern in patterns:
            match = pattern.fullmatch(normalized)
            if match and not match.groupdict().get("value"):
                return True

    return normalized.endswith(":") and len(normalized.split()) <= 4


def _extract_inline_value(line: str, patterns: tuple[re.Pattern[str], ...]) -> str | None:
    """Extracts a value embedded on the same line as a label."""
    for pattern in patterns:
        match = pattern.search(line)
        if not match:
            continue

        value = match.groupdict().get("value")
        if value:
            cleaned = _normalize_whitespace(value)
            if cleaned and not _looks_like_label(cleaned):
                return cleaned
    return None


def _extract_labeled_field(
    lines: list[str],
    field_key: str,
    *,
    validator: Callable[[str], bool] | None = None,
) -> str | None:
    """Extracts a field from a label line or the following OCR line."""
    patterns = LABEL_PATTERNS[field_key]

    for index, line in enumerate(lines):
        normalized = line.strip()
        if _is_noise_line(normalized):
            continue

        inline_value = _extract_inline_value(normalized, patterns)
        if inline_value and (validator is None or validator(inline_value)):
            return inline_value

        if not any(pattern.fullmatch(normalized) for pattern in patterns):
            continue

        for candidate in lines[index + 1 : index + 4]:
            if _is_noise_line(candidate) or _looks_like_label(candidate):
                continue
            if validator is not None and not validator(candidate):
                continue
            return candidate

    return None


def _extract_name(lines: list[str]) -> str | None:
    """Extracts the cardholder full name."""
    for index, line in enumerate(lines):
        normalized = line.strip()
        lower = normalized.lower()

        if "father" in lower or "husband" in lower:
            continue

        inline_value = _extract_inline_value(normalized, LABEL_PATTERNS["name"])
        if inline_value and _is_plausible_name(inline_value):
            return inline_value

        if not any(pattern.fullmatch(normalized) for pattern in LABEL_PATTERNS["name"]):
            continue

        for candidate in lines[index + 1 : index + 4]:
            if _is_noise_line(candidate) or _looks_like_label(candidate):
                continue
            if "father" in candidate.lower() or "husband" in candidate.lower():
                continue
            if _is_plausible_name(candidate):
                return candidate

    return None


def _extract_father_name(lines: list[str]) -> str | None:
    """Extracts the father or husband name when present."""
    value = _extract_labeled_field(
        lines,
        "father_name",
        validator=_is_plausible_name,
    )
    return value


def _extract_gender(lines: list[str]) -> str | None:
    """Extracts and normalizes the gender field."""
    labeled_value = _extract_labeled_field(lines, "gender", validator=_is_gender_value)
    if labeled_value:
        return _normalize_gender(labeled_value)

    for line in lines:
        if _is_noise_line(line):
            continue
        match = GENDER_VALUE_REGEX.search(line)
        if match and _is_gender_value(match.group(1)):
            return _normalize_gender(match.group(1))

    return None


def _extract_date_of_birth(lines: list[str]) -> str | None:
    """Extracts and normalizes the date of birth."""
    labeled_value = _extract_labeled_field(lines, "date_of_birth")
    if labeled_value:
        normalized = _normalize_date_string(labeled_value)
        if normalized:
            return normalized

    blocked_indices = _blocked_date_indices(lines)
    for index, line in enumerate(lines):
        if index in blocked_indices or _is_noise_line(line) or _looks_like_label(line):
            continue
        normalized = _normalize_date_string(line)
        if normalized:
            return normalized

    return None


def _blocked_date_indices(lines: list[str]) -> set[int]:
    """Skips issue/expiry label regions when searching for birth dates."""
    blocked: set[int] = set()
    for index, line in enumerate(lines):
        lower = line.lower()
        if "date of issue" in lower or "date of expiry" in lower:
            blocked.update(range(index, min(index + 2, len(lines))))
    return blocked


def _extract_cnic(lines: list[str]) -> str | None:
    """Extracts and formats the CNIC number."""
    labeled_value = _extract_labeled_field(lines, "cnic")
    if labeled_value:
        formatted = _format_cnic(labeled_value)
        if formatted:
            return formatted

    for line in lines:
        formatted = _format_cnic(line)
        if formatted:
            return formatted

    return None


def _format_cnic(value: str) -> str | None:
    """Formats a CNIC string as #####-#######-#."""
    match = CNIC_REGEX.search(value)
    if not match:
        return None
    return f"{match.group(1)}-{match.group(2)}-{match.group(3)}"


def _normalize_date_string(value: str) -> str | None:
    """Normalizes supported OCR date formats to `DD Month YYYY`."""
    text_match = DATE_TEXT_REGEX.search(value)
    if text_match:
        day = int(text_match.group(1))
        month_key = text_match.group(2).lower()
        year = text_match.group(3)
        month = MONTH_NAMES.get(month_key)
        if month:
            return f"{day:02d} {month} {year}"

    numeric_match = DATE_NUMERIC_REGEX.search(value)
    if numeric_match:
        day = int(numeric_match.group(1))
        month = int(numeric_match.group(2))
        year = numeric_match.group(3)
        if 1 <= month <= 12:
            return f"{day:02d} {MONTH_NUMBER_TO_NAME[month - 1]} {year}"

    return None


def _is_plausible_name(value: str) -> bool:
    """Validates that a value looks like a person's name."""
    cleaned = _normalize_whitespace(value)
    if not cleaned or len(cleaned) < 3:
        return False
    if CNIC_REGEX.search(cleaned):
        return False
    if DATE_NUMERIC_REGEX.search(cleaned) or DATE_TEXT_REGEX.search(cleaned):
        return False
    if _is_gender_value(cleaned):
        return False
    if not re.search(r"[A-Za-z]", cleaned):
        return False
    return bool(re.fullmatch(r"[A-Za-z][A-Za-z\s'.-]*", cleaned))


def _is_gender_value(value: str) -> bool:
    """Returns True when the value is a gender token."""
    return bool(GENDER_VALUE_REGEX.fullmatch(value.strip()))


def _normalize_gender(value: str) -> str | None:
    """Normalizes gender tokens to `Male` or `Female`."""
    token = value.strip().lower()
    if token in {"m", "male"}:
        return "Male"
    if token in {"f", "female"}:
        return "Female"
    return None
