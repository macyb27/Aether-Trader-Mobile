# Aether Trader Pro - APK Build Anleitung (Ohne Sandbox)

Vollständige Anleitung zum Erstellen einer Android APK für Aether Trader Pro **ohne** Sandbox-Umgebung.

---

## Voraussetzungen

### System Requirements
- **Node.js** 18+ (empfohlen: 22.x)
- **pnpm** 9+ (oder npm / yarn)
- **Git**
- **Java JDK** 17+ (für lokalen Gradle-Build)
- **Android SDK** (für lokalen Build) *oder* **Expo/EAS Account** (für Cloud-Build)

---

## Schnellstart

```bash
# 1. Repository klonen
git clone <repo-url>
cd <repo-name>

# 2. Dependencies installieren
pnpm install

# 3. Build-Script ausführen (optional, empfohlen)
chmod +x FIX_BUILD_FINAL.sh
./FIX_BUILD_FINAL.sh

# 4. APK bauen (lokaler Gradle-Build)
npx expo prebuild --platform android --clean
cd android && chmod +x gradlew && ./gradlew assembleRelease
```

Die fertige APK liegt unter: `android/app/build/outputs/apk/release/app-release.apk`

---

## Build-Optionen

### Option A: Lokaler Gradle-Build (Empfohlen, kein Account nötig)

**Voraussetzungen:** Java JDK 17+, Android SDK

```bash
# Native Android-Projekt generieren
npx expo prebuild --platform android --clean

# APK bauen
cd android
chmod +x gradlew
./gradlew assembleRelease

# APK befindet sich in:
# android/app/build/outputs/apk/release/app-release.apk
```

### Option B: EAS Local Build

```bash
# EAS CLI installieren (einmalig)
npm install -g eas-cli

# Lokalen Build starten (kein EAS-Account für --local nötig)
eas build --platform android --profile local --local
```

### Option C: EAS Cloud Build

```bash
# EAS CLI installieren und einloggen
npm install -g eas-cli
eas login

# Cloud-Build starten
eas build --platform android --profile production
```

### Option D: GitHub Actions (CI/CD)

Das Repository enthält einen GitHub Actions Workflow unter `.github/workflows/build-apk.yml`.

1. Push auf `main` / `master` oder manueller Trigger
2. APK wird als Artifact heruntergeladen
3. Keine EAS/Sandbox-Abhängigkeit

---

## Environment Variables (Optional)

Für volle Backend-Konnektivität, erstelle eine `.env` Datei:

```bash
# .env
EXPO_PUBLIC_API_BASE_URL=https://your-api-server.com
EXPO_PUBLIC_APP_ID=your_app_id
EXPO_PUBLIC_OAUTH_PORTAL_URL=https://your-oauth-portal.com
EXPO_PUBLIC_OAUTH_SERVER_URL=https://your-oauth-server.com
```

**Ohne `.env` Datei:** Die App läuft im Offline-Modus mit lokalen Daten (AsyncStorage).

Für CI/CD-Builds können diese als Secrets konfiguriert werden:
- GitHub Actions: Settings -> Secrets -> `API_BASE_URL`, `APP_ID`
- EAS: `eas secret:create --scope project --name API_BASE_URL --value "https://..."`

---

## Was funktioniert ohne Sandbox

| Feature | Status | Anmerkung |
|---------|--------|-----------|
| React Native / Expo App | Funktioniert | Vollständig standalone |
| TensorFlow.js (ML) | Funktioniert | Läuft direkt auf dem Gerät |
| Alpaca & Finnhub APIs | Funktioniert | API-Keys in .env konfigurieren |
| AsyncStorage (lokale Daten) | Funktioniert | Offline-First |
| Push Notifications | Funktioniert | expo-notifications |
| Genetic Algorithms | Funktioniert | Reine JavaScript-Implementierung |
| Transfer Learning | Funktioniert | TensorFlow.js |
| OAuth / Login | Funktioniert | Deep-Link-basiert |
| Trading Dashboard | Funktioniert | Vollständig |
| Onboarding | Funktioniert | Vollständig |

---

## APK testen

### Auf Gerät installieren

```bash
# Via ADB (USB-Debugging aktiviert)
adb install android/app/build/outputs/apk/release/app-release.apk

# Oder: APK direkt auf das Gerät kopieren und öffnen
# (Erfordert "Unbekannte Quellen" / "Install unknown apps" in den Android-Einstellungen)
```

### Testing Checklist

- [ ] App startet ohne Crashes
- [ ] Onboarding Flow funktioniert
- [ ] Dashboard zeigt Daten an
- [ ] Trading-Features funktionieren
- [ ] Push-Benachrichtigungen funktionieren
- [ ] Daten werden lokal gespeichert
- [ ] Keine Sandbox-Fehler in Logs

---

## Troubleshooting

### "Module not found" Fehler
```bash
rm -rf node_modules
pnpm install
npx expo prebuild --platform android --clean
```

### Gradle Build schlägt fehl
```bash
cd android && ./gradlew clean
cd .. && npx expo prebuild --platform android --clean
cd android && ./gradlew assembleRelease
```

### APK ist zu groß (>100MB)
1. In `app.config.ts` sind bereits nur `armeabi-v7a` und `arm64-v8a` Architekturen konfiguriert
2. Ungenutzte Assets aus `assets/` entfernen
3. Für Play Store: AAB statt APK verwenden

### API-Verbindung funktioniert nicht
1. Prüfe `.env` Datei: `EXPO_PUBLIC_API_BASE_URL` muss gesetzt sein
2. Stelle sicher, dass der API-Server erreichbar ist
3. Ohne API-URL läuft die App im Offline-Modus

---

## Projektstruktur (APK-relevant)

```
├── app/                    # Expo Router Seiten
│   ├── (tabs)/             # Tab-Navigation
│   ├── onboarding.tsx      # Onboarding-Screens
│   └── _layout.tsx         # Root Layout
├── components/             # Wiederverwendbare UI-Komponenten
├── constants/              # Konfiguration & Konstanten
├── lib/                    # Business Logic
│   ├── agents/             # Trading-Agenten (JS/TS)
│   ├── services/           # API-Services
│   ├── _core/              # Auth, API, Theme
│   └── *.ts                # Stores, Notifications, etc.
├── assets/                 # Bilder & Icons
├── app.config.ts           # Expo-Konfiguration
├── eas.json                # EAS Build-Profile
├── metro.config.js         # Metro Bundler
└── FIX_BUILD_FINAL.sh      # Build-Vorbereitung
```
