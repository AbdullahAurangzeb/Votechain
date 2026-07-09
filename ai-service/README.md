# VoteChain AI Service

Stateless Python microservice for voter identity verification (OCR, face recognition, liveness). Called by the Node.js backend over HTTP — not directly by Flutter or admin clients.

## Stack

- Python 3.11+
- FastAPI + Uvicorn
- EasyOCR, Pillow, OpenCV, NumPy

## Project Structure

```text
ai-service/
├── app/
│   ├── main.py              # FastAPI application entry
│   ├── api/                 # HTTP route handlers
│   ├── services/            # OCR, CNIC parser, face logic
│   ├── models/              # Pydantic request/response schemas
│   └── utils/               # Config, uploads, shared helpers
├── uploads/                 # Temporary upload directory (gitignored contents)
├── requirements.txt
├── .env.example
└── README.md
```

## Setup

1. Create and activate a virtual environment (Python 3.11+):

```bash
cd ai-service
python -m venv .venv
.venv\Scripts\activate   # Windows
# source .venv/bin/activate  # macOS/Linux
```

2. Install dependencies:

```bash
pip install -r requirements.txt
```

3. Copy environment template and adjust values:

```bash
copy .env.example .env   # Windows
# cp .env.example .env   # macOS/Linux
```

4. Run the development server:

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/health` | Service health probe |
| `POST` | `/ocr/extract` | Extract OCR text and parse Pakistani CNIC fields |
| `GET` | `/docs` | Swagger UI (OpenAPI interactive docs) |
| `GET` | `/redoc` | ReDoc API documentation |

## OCR: `POST /ocr/extract`

**Content-Type:** `multipart/form-data`

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `image` | file | yes | JPEG, PNG, or WebP (max 5 MB default) |

**Success response (`200`):**

```json
{
  "success": true,
  "rawText": ["ALI RAZA", "35202-1234567-1"],
  "parsed": {
    "name": "Ali Raza",
    "fatherName": "Muhammad Raza",
    "cnic": "35202-1234567-1",
    "dateOfBirth": "15 March 1998",
    "gender": "Male"
  }
}
```

**Error responses:**

| Status | Condition |
|--------|-----------|
| `400` | Unsupported file type, empty upload, or invalid image |
| `422` | Image is too blurry for reliable OCR |
| `500` | OCR processing failure |
| `503` | OCR engine not initialized |

## Test with Swagger

1. Start the service:

```bash
cd ai-service
.venv\Scripts\activate
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

2. Open Swagger UI in your browser:

```text
http://localhost:8000/docs
```

3. Verify health:

- Expand **GET `/health`**
- Click **Try it out** → **Execute**
- Expect `200` with `"status": "ok"`

4. Test OCR extraction:

- Expand **POST `/ocr/extract`**
- Click **Try it out**
- Under **image**, choose a CNIC photo (JPEG/PNG/WebP)
- Click **Execute**
- Expect `200` with `success: true`, `rawText`, and `parsed` fields

5. Test unsupported file type:

- Upload a `.pdf` or `.txt` file
- Expect `400` with message about unsupported file type

6. Test blurry image:

- Upload a heavily blurred photo
- Expect `422` with message about blurry image

## Test with curl

Health check:

```bash
curl http://localhost:8000/health
```

OCR extract:

```bash
curl -X POST "http://localhost:8000/ocr/extract" ^
  -H "accept: application/json" ^
  -H "Content-Type: multipart/form-data" ^
  -F "image=@C:\path\to\cnic-front.jpg"
```

## Environment Variables

See `.env.example` for all required variable names. Never commit `.env` files.

| Variable | Default | Purpose |
|----------|---------|---------|
| `PORT` | `8000` | Service port |
| `UPLOAD_MAX_FILE_SIZE_MB` | `5` | Max upload size |
| `EASYOCR_LANGUAGES` | `en` | EasyOCR language list |
| `OCR_BLUR_THRESHOLD` | `100.0` | Minimum sharpness score |

## Development Notes

- EasyOCR initializes **once** on startup via FastAPI lifespan.
- Uploaded images are saved temporarily and **deleted after processing**.
- OCR execution time is logged per request.
- The service is stateless — no database access.
