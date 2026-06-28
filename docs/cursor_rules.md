# Cursor Rules

Engineering rules for AI-assisted development on **VoteChain** — a blockchain-powered e-voting platform. Every AI-generated file must follow these standards.

## Project Stack

| Layer | Technology |
|-------|------------|
| Mobile | Flutter (latest stable), Material 3 |
| Admin Dashboard | React.js |
| Backend API | Node.js + Express |
| Database | MongoDB Atlas |
| AI Service | Python FastAPI, EasyOCR, DeepFace |
| Blockchain | Ethereum, Solidity, Ganache (dev), Sepolia Testnet (demo) |

---

## 1. Coding Standards

All code across the monorepo must adhere to the following principles:

* Write clean, readable, and maintainable code.
* Follow **SOLID** principles.
* Follow **Clean Architecture** — separate concerns into distinct layers.
* Keep functions small and focused on a single responsibility.
* Use meaningful, descriptive names for variables, functions, classes, and files.
* Never duplicate code — extract shared logic into reusable utilities, services, or components.
* Prefer **composition over inheritance**.

---

## 2. Flutter Rules

### Always Use

* Flutter **latest stable** release
* **Material 3** design system
* **Riverpod** for state management
* **GoRouter** for navigation
* **Dio** for HTTP networking
* **Freezed** for immutable data models
* **Json Serializable** for JSON serialization/deserialization

### Never

* Put business logic inside widgets.
* Make API calls directly from UI widgets.
* Create massive `StatefulWidget` classes.

### Prefer

* `StatelessWidget` for pure presentation.
* `ConsumerWidget` / `ConsumerStatefulWidget` for state-aware UI.
* **Feature-first architecture** — organize code by feature, not by type.

---

## 3. Folder Structure

Flutter mobile app must follow this layout:

```text
lib/
├── core/
├── shared/
├── features/
├── services/
├── routes/
├── theme/
└── widgets/
```

Every feature under `features/` must contain the three Clean Architecture layers:

```text
features/<feature_name>/
├── data/
├── domain/
└── presentation/
```

| Directory | Purpose |
|-----------|---------|
| `core/` | Constants, errors, utilities, base classes |
| `shared/` | Cross-feature models and helpers |
| `features/` | Feature modules (data / domain / presentation) |
| `services/` | App-wide services (API client, storage, etc.) |
| `routes/` | GoRouter configuration |
| `theme/` | Material 3 theme, colors, typography |
| `widgets/` | Reusable UI components shared across features |

---

## 4. State Management

* Use **Riverpod only** — no Provider, Bloc, GetX, or other state libraries.
* **Repositories** expose Riverpod providers and handle data access.
* **Controllers** (notifiers) manage feature state and business logic.
* **Widgets** remain presentation-only — they watch providers and render UI.

```text
Widget  →  watches  →  Controller (Notifier)  →  calls  →  Repository  →  API / DB
```

---

## 5. API Rules

* Use **REST** conventions for all HTTP endpoints.
* Use **Dio** as the HTTP client in Flutter; use standard HTTP libraries in backend.
* **Never hardcode URLs** — use environment configuration files.
* Centralize all API endpoints in a dedicated configuration or constants module.
* Handle errors consistently with typed error models.

Example endpoint configuration pattern:

```dart
// services/api/api_endpoints.dart
abstract final class ApiEndpoints {
  static const String baseUrl = String.fromEnvironment('API_BASE_URL');
  static const String elections = '/api/elections';
  static const String votes = '/api/votes';
}
```

---

## 6. Backend Rules

The Node.js backend must follow these conventions:

* **Node.js** with **Express** framework.
* **Repository Pattern** for data access — controllers never query MongoDB directly.
* **MVC** structure — Models, Views (JSON responses), Controllers.
* **JWT Authentication** for protected routes.
* **Validation Middleware** on all incoming request bodies and params.
* **Error Middleware** for centralized error handling and consistent response format.
* Use **async/await** exclusively — **no callback style**.

```text
Request  →  Validation Middleware  →  Auth Middleware  →  Controller  →  Repository  →  MongoDB
                                                                    ↓
                                                          Error Middleware
```

---

## 7. Database Rules

* Use **MongoDB Atlas** as the primary database.
* Core collections:

| Collection | Purpose |
|------------|---------|
| `Users` | Registered voters and administrators |
| `Elections` | Election metadata and lifecycle |
| `Candidates` | Candidate profiles linked to elections |
| `Votes` | Cast vote records (off-chain references) |
| `Notifications` | User notifications and alerts |
| `AuditLogs` | Immutable audit trail for security events |

* **Never duplicate data** — store references, not copies.
* Always use **ObjectId references** for relationships between documents.
* Index frequently queried fields.

---

## 8. Blockchain Rules

* Smart contracts must be written in **Solidity**.
* Use **Ganache** during local development and testing.
* Use **Sepolia Testnet** for demonstrations and staging.
* **Never store sensitive user information on-chain** (PII, biometrics, credentials).
* Only store **voting records** and **transaction references** on-chain.
* Keep contract logic minimal — heavy validation belongs off-chain.

---

## 9. AI Service Rules

* Use **Python FastAPI** for the AI microservice.
* Separate **OCR** (EasyOCR) and **Face Recognition** (DeepFace) into independent service modules.
* **Do not mix AI logic with backend logic** — the Node.js backend communicates with the AI service via HTTP.
* AI endpoints must be stateless and return structured JSON responses.
* Handle model loading and inference errors gracefully with clear error codes.

```text
Flutter / Backend  →  HTTP  →  FastAPI AI Service
                                      ├── OCR Service (EasyOCR)
                                      └── Face Recognition Service (DeepFace)
```

---

## 10. UI Rules

* The UI must **exactly match** the Google Stitch designs in `design/stitch-screens/`.
* Use **Material 3** components and theming throughout.
* Maintain consistent design tokens:

| Token | Rule |
|-------|------|
| Spacing | Use the 4dp/8dp grid from Stitch designs |
| Typography | Use theme text styles — no inline font overrides |
| Colors | Use theme color scheme — no hardcoded hex values |
| Border radius | Match Stitch corner radii via theme |
| Shadows | Use Material 3 elevation, not custom box shadows |

* **Do not redesign screens** unless explicitly requested.
* Extract repeated UI patterns into reusable widgets under `widgets/`.

---

## 11. Git Rules

* Make **small, focused commits** — one logical change per commit.
* Write **meaningful commit messages** that describe the *why*, not just the *what*.
* Use **feature branches** for all new work (`feature/`, `fix/`, `docs/` prefixes).
* **Never commit secrets** — no API keys, private keys, `.env` files, or credentials.
* Keep `.env.example` updated with required variable names (no values).

---

## 12. Documentation Rules

* Every **major class** must contain a brief doc comment explaining its purpose.
* Every **API endpoint** must be documented in `docs/API.md`.
* Keep **README.md** updated when setup steps or architecture change.
* Update relevant docs in `docs/` when adding new features or changing contracts.
* Use JSDoc (backend), Dart doc comments (Flutter), and Python docstrings (AI service).

---

## 13. General AI Rules

When generating code for VoteChain, AI assistants must:

* **Follow existing architecture** — read surrounding code before writing new files.
* **Never invent new architecture** — do not introduce new patterns, libraries, or folder structures without explicit approval.
* **Reuse existing components** — check `widgets/`, `shared/`, and `core/` before creating duplicates.
* **Prefer reusable widgets** over one-off inline UI.
* **Ask for clarification** if requirements are ambiguous or conflict with these rules.
* **Do not change UI** unless explicitly requested — match Stitch designs exactly.
* **Minimize scope** — only change files required by the task.
* **Match existing conventions** — naming, formatting, import style, and error handling patterns.

---

## Quick Reference Checklist

Before submitting any AI-generated code, verify:

- [ ] Follows Clean Architecture layer separation
- [ ] Uses approved stack libraries only
- [ ] No business logic in UI widgets
- [ ] No hardcoded URLs or secrets
- [ ] No sensitive data on-chain
- [ ] UI matches Stitch designs
- [ ] Doc comments on major classes
- [ ] Small, focused diff — no unrelated changes
