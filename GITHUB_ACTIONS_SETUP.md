# GitHub Actions - Automatische APK Builds

Dieser Workflow baut automatisch eine APK bei jedem Push zum Repository.

---

## Setup (Einmalig)

### Schritt 1: Expo Token erstellen

1. Gehe zu: https://expo.dev/accounts/[dein-username]/settings/access-tokens
2. Klicke auf **"Create Token"**
3. Name: `GITHUB_ACTIONS`
4. Kopiere den Token (wird nur einmal angezeigt!)

### Schritt 2: Token zu GitHub hinzufügen

1. Gehe zu: https://github.com/macyb27/Aether-Trader-Mobile/settings/secrets/actions
2. Klicke auf **"New repository secret"**
3. Name: `EXPO_TOKEN`
4. Value: [Dein kopierter Expo Token]
5. Klicke **"Add secret"**

### Schritt 3: API Keys hinzufügen (Optional)

Wenn du API Keys brauchst (Alpaca, Finnhub):

1. Gehe zu: https://github.com/macyb27/Aether-Trader-Mobile/settings/secrets/actions
2. Füge hinzu:
   - `ALPACA_API_KEY`
   - `ALPACA_API_SECRET`
   - `FINNHUB_API_KEY`

---

## Verwendung

### Automatischer Build

Der Build startet automatisch bei:
- ✅ Push zu `master` oder `main` Branch
- ✅ Pull Request zu `master` oder `main`

### Manueller Build

1. Gehe zu: https://github.com/macyb27/Aether-Trader-Mobile/actions
2. Wähle **"Build Android APK"**
3. Klicke **"Run workflow"**
4. Wähle Branch (z.B. `master`)
5. Klicke **"Run workflow"**

---

## APK Herunterladen

### Nach EAS Build (Standard):

1. Warte 15-30 Minuten (Build läuft in Expo Cloud)
2. Gehe zu: https://expo.dev
3. Login mit deinem Account
4. Navigiere zu **"Builds"**
5. Finde deinen Build und klicke **"Download"**

### Nach lokalem Build (Alternative):

1. Gehe zu: https://github.com/macyb27/Aether-Trader-Mobile/actions
2. Klicke auf den neuesten erfolgreichen Build
3. Scrolle nach unten zu **"Artifacts"**
4. Klicke auf **"app-release"** zum Download

---

## Build-Status Prüfen

### GitHub Actions:
https://github.com/macyb27/Aether-Trader-Mobile/actions

### Expo Dashboard:
https://expo.dev/accounts/[dein-username]/projects/aether-trader-pro/builds

---

## Troubleshooting

### Problem: "EXPO_TOKEN not found"

**Lösung:** Token wurde nicht als Secret hinzugefügt. Siehe Schritt 2 oben.

### Problem: Build schlägt fehl mit "EAS CLI error"

**Lösung:** 
1. Prüfe ob Expo Token gültig ist
2. Erstelle neuen Token auf expo.dev
3. Update GitHub Secret

### Problem: "No such project"

**Lösung:** EAS Projekt muss initialisiert werden:
```bash
# Lokal ausführen (einmalig)
eas build:configure
git add eas.json
git commit -m "Add EAS configuration"
git push
```

### Problem: Build dauert zu lange

**Lösung:** 
- EAS Builds dauern 15-30 Minuten (normal)
- Lokale Builds sind schneller, aber komplexer
- Aktiviere lokalen Build: Setze `if: false` auf `if: true` in `build-local` Job

---

## Build-Typen

### EAS Build (Standard)
- ✅ Einfach
- ✅ Keine lokale Konfiguration
- ✅ Automatisches Signing
- ⏱️ 15-30 Minuten
- 💰 Kostenlos (begrenzte Builds/Monat)

### Lokaler Build (Alternative)
- ✅ Schneller (5-10 Minuten)
- ✅ Unbegrenzte Builds
- ❌ Komplexere Konfiguration
- ❌ Manuelles Signing nötig

---

## Workflow anpassen

### Nur bei Tag-Push bauen:

```yaml
on:
  push:
    tags:
      - 'v*'
```

### Nur manuell bauen:

```yaml
on:
  workflow_dispatch:
```

### Bei jedem Commit bauen:

```yaml
on:
  push:
    branches: ['**']
```

---

## Kosten

### GitHub Actions:
- ✅ Kostenlos für Public Repositories
- ✅ 2000 Minuten/Monat für Private Repositories

### Expo EAS Build:
- ✅ Kostenlos: Begrenzte Builds
- 💰 $29/Monat: Unbegrenzte Builds

---

## Nächste Schritte

1. ✅ Expo Token erstellen und zu GitHub hinzufügen
2. ✅ Code pushen → Build startet automatisch
3. ✅ APK von Expo Dashboard herunterladen
4. ✅ APK auf Android-Gerät installieren und testen

Bei Fragen: Siehe APK_BUILD_GUIDE.md
