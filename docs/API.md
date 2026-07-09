# API

REST API endpoints, request/response formats, and authentication for the VoteChain backend.

Base URL: `/api/v1`

## Response Envelope

All endpoints return:

```json
{
  "success": true,
  "message": "Description of result",
  "data": {},
  "errors": null
}
```

Error responses set `success` to `false` and may include an `errors` array for validation failures.

---

## Health

### `GET /api/v1/health`

Infrastructure health probe.

**Response `200`**

```json
{
  "success": true,
  "message": "VoteChain API is running",
  "data": {
    "status": "ok",
    "timestamp": "2026-07-05T18:00:00.000Z"
  },
  "errors": null
}
```

---

## Authentication

### `POST /api/v1/auth/register`

Registers a new voter account.

**Body**

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `fullName` | string | yes | Max 120 characters |
| `email` | string | yes | Must be unique |
| `phoneNumber` | string | yes | E.g. `+92 300 0000000` |
| `password` | string | yes | Min 8 characters |
| `cnic` | string | no | Format: `35202-1234567-1` |

**Response `201`**

```json
{
  "success": true,
  "message": "Registration successful",
  "data": {
    "user": {
      "_id": "...",
      "fullName": "Arslan Khalid",
      "email": "user@example.com",
      "phoneNumber": "+92 300 0000000",
      "role": "voter",
      "approvalStatus": "pending",
      "verificationStatus": "not_started",
      "faceRegistered": false,
      "createdAt": "...",
      "updatedAt": "..."
    }
  },
  "errors": null
}
```

**Errors**

| Status | Condition |
|--------|-----------|
| `409` | Email or CNIC already registered |
| `422` | Validation failed |

---

### `POST /api/v1/auth/login`

Authenticates a user and returns a JWT access token.

**Body**

| Field | Type | Required |
|-------|------|----------|
| `email` | string | yes |
| `password` | string | yes |

**Response `200`**

```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "_id": "...",
      "fullName": "Arslan Khalid",
      "email": "user@example.com",
      "phoneNumber": "+92 300 0000000",
      "role": "voter",
      "approvalStatus": "pending",
      "verificationStatus": "not_started",
      "faceRegistered": false
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  },
  "errors": null
}
```

**Errors**

| Status | Condition |
|--------|-----------|
| `401` | Invalid email or password |
| `422` | Validation failed |

---

### `GET /api/v1/auth/me`

Returns the authenticated user's profile.

**Headers**

```
Authorization: Bearer <access_token>
```

**Response `200`**

```json
{
  "success": true,
  "message": "Profile retrieved successfully",
  "data": {
    "user": {
      "_id": "...",
      "fullName": "Arslan Khalid",
      "email": "user@example.com",
      "phoneNumber": "+92 300 0000000",
      "role": "voter",
      "approvalStatus": "pending",
      "verificationStatus": "not_started",
      "faceRegistered": false
    }
  },
  "errors": null
}
```

**Errors**

| Status | Condition |
|--------|-----------|
| `401` | Missing, invalid, or expired token |
| `404` | User not found |

---

## Verification

### `POST /api/v1/verification/extract`

Extracts CNIC fields from an uploaded image via the AI OCR service. **Authenticated users only.**

**Headers**

```
Authorization: Bearer <access_token>
Content-Type: multipart/form-data
```

**Body (multipart)**

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `image` | file | yes | CNIC image (JPEG, PNG, WebP, or PDF) |

**Response `200`**

```json
{
  "success": true,
  "message": "CNIC extracted successfully",
  "data": {
    "rawText": ["PAKISTAN", "NATIONAL IDENTITY CARD", "..."],
    "parsed": {
      "name": "Arslan Khalid",
      "cnic": "35202-1234567-1",
      "dateOfBirth": "15 March 1998",
      "gender": "Male",
      "fatherName": "Muhammad Khalid"
    }
  },
  "errors": null
}
```

**Errors**

| Status | Condition |
|--------|-----------|
| `400` | Missing image or unsupported file type |
| `401` | Missing, invalid, or expired token |
| `502` | OCR service returned an unsuccessful result |
| `503` | Backend unable to reach AI service |

---

### `POST /api/v1/verification/submit`

Submits completed identity verification after face registration. **Authenticated users only.**

**Headers**

```
Authorization: Bearer <access_token>
```

**Body**

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `cnicNumber` | string | yes | Format: `35202-1234567-1` |
| `cnicFrontImageUrl` | string | yes | URL of CNIC front image |
| `cnicBackImageUrl` | string | yes | URL of CNIC back image |

**Response `201`**

```json
{
  "success": true,
  "message": "Verification submitted successfully",
  "data": {
    "status": {
      "verificationStatus": "pending",
      "approvalStatus": "pending",
      "faceRegistered": true,
      "cnic": "35202-1234567-1",
      "cnicFrontImageUrl": "https://placeholder.votechain.local/uploads/cnic-front.jpg",
      "cnicBackImageUrl": "https://placeholder.votechain.local/uploads/cnic-back.jpg",
      "verificationSubmittedAt": "2026-07-08T02:00:00.000Z"
    }
  },
  "errors": null
}
```

**Side effects**

- Sets `verificationStatus` to `pending`
- Sets `faceRegistered` to `true`
- Stores CNIC number, image URLs, and submission timestamp

**Errors**

| Status | Condition |
|--------|-----------|
| `401` | Missing, invalid, or expired token |
| `409` | Verification already submitted, or CNIC already registered |
| `422` | Validation failed |

---

### `GET /api/v1/verification/status`

Returns the authenticated user's verification status. **Authenticated users only.**

**Headers**

```
Authorization: Bearer <access_token>
```

**Response `200`**

```json
{
  "success": true,
  "message": "Verification status retrieved successfully",
  "data": {
    "status": {
      "verificationStatus": "pending",
      "approvalStatus": "pending",
      "faceRegistered": true,
      "cnic": "35202-1234567-1",
      "cnicFrontImageUrl": "https://placeholder.votechain.local/uploads/cnic-front.jpg",
      "cnicBackImageUrl": "https://placeholder.votechain.local/uploads/cnic-back.jpg",
      "verificationSubmittedAt": "2026-07-08T02:00:00.000Z"
    }
  },
  "errors": null
}
```

**Errors**

| Status | Condition |
|--------|-----------|
| `401` | Missing, invalid, or expired token |
| `404` | User not found |
