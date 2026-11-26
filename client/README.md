# MindCare Flutter client

A mobile-first mental wellbeing companion built with Flutter. The client uses a
feature-based structure and connects to the FastAPI chat endpoint in `../server`.
It offers a supportive chat interface, mood check-in, and simple breathing and
grounding exercises. It does not provide diagnosis or replace professional care.

## Run locally

Start the API from the repository root:

```bash
cd server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

In another terminal:

```bash
cd client
flutter pub get
flutter run
```

The default API URL is selected for common local targets:

- Android emulator: `http://10.0.2.2:8000`
- iOS simulator: `http://127.0.0.1:8000`
- Flutter web: `http://localhost:8000`

For web development, run Flutter on the backend's default CORS origin:

```bash
flutter run -d chrome --web-port 5173
```

For a physical device or another host, pass the API URL at build/run time:

```bash
flutter run --dart-define=API_BASE_URL=http://YOUR_COMPUTER_LAN_IP:8000
```

The computer and device must be on the same network, and the API must listen on
`0.0.0.0`. Android debug builds allow cleartext HTTP for local development; use
HTTPS in production. For Flutter web, configure the backend's CORS allow-list
to include the web app's origin. iOS devices may require a local-network ATS
exception when connecting to a non-HTTPS development server.

The client reuses the API's returned session ID during the active chat. The
current backend keeps sessions in memory, so server restarts clear chat history;
the Flutter app does not persist conversation content locally.

## Project structure

```text
lib/
  app/                 App composition, navigation, and theme
  core/                API configuration and shared network errors
  features/
    chat/
      data/            HTTP data source and repository implementation
      domain/          Chat entities and repository contract
      presentation/    Chat controller, screen, and message widgets
    home/presentation/ Home and mood check-in
    wellbeing/          Breathing and grounding tools
test/                   API and widget tests
assets/images/           Existing project artwork
```

## Validation

```bash
flutter analyze
flutter test
```
