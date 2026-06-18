# Skin Type App

A cross-platform mobile application that performs AI-driven skin type analysis from a face photograph and delivers personalized skincare recommendations — ingredient suggestions, AM/PM routines, and makeup guidance — all backed by per-user persistent history.

## How It Works

1. The user opens the front camera and frames their face inside an on-screen oval guide.
2. The captured image goes through on-device **face detection** (Google ML Kit) to crop and isolate the face region.
3. The cropped image is sent to a **Node.js backend** hosted on Firebase App Hosting, which forwards it to the **Gemini 2.5 Flash** multimodal model with a structured dermatology prompt.
4. The model returns a JSON payload containing the detected skin type, symptoms, needs, recommended natural and active chemical ingredients (each with usage instructions and a personalized AI analysis), morning/evening routines, and makeup do's/don'ts.
5. The response is saved to **Cloud Firestore** under the authenticated user's document, and the UI updates reactively via Firestore snapshot listeners.

## Architecture

```
lib/
├── main.dart                     # Entry point, Firebase init, auth gate
├── firebase_options.dart         # Auto-generated Firebase config
├── models/
│   └── scan_model.dart           # ScanResult — Firestore deserialization
├── constants/
│   ├── app_colors.dart
│   └── profile_colors.dart
├── common/
│   ├── constants/
│   ├── theme/
│   └── widgets/
│       ├── common_widgets.dart
│       └── top_menu_overlay.dart  # App-wide slide-down navigation menu
├── core/
│   ├── database/
│   │   └── data_service.dart     # SharedPreferences wrapper (routine status, local cache)
│   ├── di/
│   │   └── providers.dart        # Dependency injection placeholder
│   ├── navigation/
│   │   └── app_router.dart
│   ├── services/
│   │   ├── auth_service.dart     # Firebase Auth (email/password)
│   │   ├── user_service.dart     # Firestore user profile CRUD
│   │   ├── scan_service.dart     # Scan persistence, favorites, history streams
│   │   └── backend/              # Node.js Express API (deployed separately)
│   │       ├── server.js
│   │       ├── package.json
│   │       ├── firebase.json
│   │       └── apphosting.yaml
│   └── utils/
└── features/                     # Feature-first module structure
    ├── login register/           # Email/password auth with DOB collection
    ├── home/                     # Dashboard: last scan summary, ingredient cards, routine CTA
    ├── face scan/                # Camera screen with oval face guide overlay (CustomPainter)
    ├── scan details/             # Full detail view for a single scan
    ├── scan history/             # Chronological list of past scans
    ├── natural ingredients/      # Natural ingredient cards with favorites toggle
    ├── chemical ingredients/     # Active ingredient cards with favorites toggle
    ├── favorite ingredients/     # Aggregated favorites view
    ├── Weekly Routine/           # Day-by-day AM/PM routine with completion tracking
    ├── profile/                  # User profile, scan history preview, settings, logout
    ├── profile information/      # Edit name, DOB, profile photo
    ├── FAQ/
    └── help/
```

Each feature follows a **views/screens + views/widgets** convention. The `home` feature additionally has `repositories/` and `viewmodels/` directories (currently scaffolded with `.gitkeep`), indicating a planned MVVM migration that hasn't been completed yet.

## Tech Stack

| Layer | Technology |
|---|---|
| **Client** | Flutter (Dart), SDK ≥ 3.9.2 |
| **Auth** | Firebase Authentication (email/password) |
| **Database** | Cloud Firestore (per-user scan subcollections) |
| **Local storage** | SharedPreferences (routine completion state, cached analysis) |
| **Face detection** | Google ML Kit Face Detection (on-device, accurate mode) |
| **Image processing** | `image` package — EXIF orientation bake + face-region crop |
| **Camera** | `camera` 0.11.3 — front-facing, medium resolution |
| **AI Backend** | Node.js / Express on Firebase App Hosting |
| **AI Model** | Google Gemini 2.5 Flash (multimodal, via `@google/generative-ai`) |
| **Image upload** | `multer` (memory storage, multipart/form-data) |

## Firestore Schema

```
users/{uid}
├── email: string
├── full_name: string
├── born_date: Timestamp
├── gender: string
├── profile_image_path: string (local device path)
├── created_at: Timestamp
├── updated_at: Timestamp
└── scans/{scanId}
    ├── meta: { source: string, model: string }
    ├── raw_ai_output: { ... }     // Full Gemini JSON response
    ├── image_path: string          // Local device path to cropped face image
    ├── created_at: Timestamp
    ├── dogal_favoriler/{ingredientName}     // Favorited natural ingredients
    │   ├── isim, temel_faydalar, nasil_kullanilir, ai_analizi
    │   └── saved_at: Timestamp
    └── kimyasal_favoriler/{ingredientName}  // Favorited chemical ingredients
        └── (same structure)
```

## Backend (server.js)

A single Express endpoint: `POST /analyze-skin`.

- Accepts a `multipart/form-data` request with an `image` field.
- Converts the uploaded buffer to base64 and constructs an inline data part for the Gemini API.
- The prompt instructs the model to act as a dermatologist and return a strictly typed JSON object with Turkish keys and English values (skin type, symptoms, needs, ingredients with personalized AI analysis, routines, makeup recommendations).
- Response parsing is minimal — the raw model output is forwarded to the client, which strips markdown code fences and deserializes.
- Deployed via `firebase apphosting` with `apphosting.yaml` (Cloud Run, `minInstances: 0`).

Health check: `GET /status`

## Data Flow

```
Camera → ML Kit (face bbox) → image crop → HTTP POST to backend
→ Gemini 2.5 Flash → structured JSON → Firestore write
→ Snapshot listener → UI rebuild
```

Local caching via `SkinAnalysisStorage` (SharedPreferences) is used in parallel for the weekly routine screen, so routine completion state persists across sessions without requiring a network call.

## Setup

### Prerequisites

- Flutter SDK ≥ 3.9.2
- Firebase project with Authentication and Firestore enabled
- Node.js ≥ 18 (for backend)
- A Gemini API key (or Vertex AI service account)

### Client

```bash
flutter pub get
flutter run
```

Firebase config is already baked into `firebase_options.dart` and `android/app/google-services.json`. If you're connecting to a different Firebase project, re-run `flutterfire configure`.

### Backend

```bash
cd lib/core/services/backend
cp .env.example .env   # Set GEMINI_API_KEY
npm install
npm start              # Runs on :8080
```

For production, deploy with Firebase App Hosting:

```bash
firebase apphosting:backends:create
```

The `apphosting.yaml` already specifies `minInstances: 0` to scale to zero when idle.

## Notes

- Image paths stored in Firestore are **local device paths**. This means scan images are not synced across devices — only the AI analysis results are. This is a deliberate trade-off to avoid cloud storage costs during development.
- The favorites system uses Firestore subcollections under each scan document, so favorites are scoped to the scan that produced them.
- The DI layer (`core/di/providers.dart`) is a placeholder. Services are currently instantiated directly in widgets.
- The `test_application/` directory contains an earlier prototype that predates the current architecture.
- The `test_scripts/` directory has a standalone Python script for testing Gemini image analysis via Vertex AI — useful for prompt iteration outside the app.

## License

Private — not published to pub.dev.
