# Aether Trader Pro - Termux Setup Guide

Vollständige Anleitung für APK-Build mit Expo EAS in Termux (Android).

---

## Warum Termux + EAS?

✅ **Build läuft in der Cloud** - Dein Android-Gerät sendet nur Code hoch
✅ **Keine Android Studio nötig** - Alles über Terminal
✅ **Funktioniert auf jedem Android-Gerät** - Auch auf älteren Geräten
✅ **APK wird automatisch gebaut** - Download nach 15-30 Minuten

---

## Voraussetzungen

- Android-Gerät mit Termux installiert
- Internetverbindung (WLAN empfohlen für Upload)
- GitHub Account
- Expo Account (kostenlos auf expo.dev)

---

## Schritt 1: Termux Einrichten

### 1.1 Termux Aktualisieren

```bash
pkg update && pkg upgrade -y
```

### 1.2 Benötigte Pakete Installieren

```bash
# Git
pkg install git -y

# Node.js (LTS Version)
pkg install nodejs-lts -y

# OpenSSL (für HTTPS)
pkg install openssl -y

# Prüfen ob alles installiert ist
node --version  # Sollte v20.x oder höher sein
npm --version   # Sollte 10.x oder höher sein
git --version   # Sollte 2.x oder höher sein
```

---

## Schritt 2: Repository Klonen

### Option A: Public Repository (Einfacher)

```bash
# Navigiere zu Home-Verzeichnis
cd ~

# Clone Repository
git clone https://github.com/macyb27/Aether-Trader-Mobile.git

# Wechsle in Verzeichnis
cd Aether-Trader-Mobile
```

### Option B: Private Repository (Mit Token)

```bash
# 1. Erstelle Personal Access Token auf GitHub:
#    https://github.com/settings/tokens
#    -> "Generate new token (classic)"
#    -> Wähle: repo (full control)
#    -> Kopiere Token

# 2. Clone mit Token:
git clone https://YOUR_TOKEN@github.com/macyb27/Aether-Trader-Mobile.git
cd Aether-Trader-Mobile
```

---

## Schritt 3: Dependencies Installieren

```bash
# Im Aether-Trader-Mobile Verzeichnis
npm install

# Das kann 5-10 Minuten dauern
# Bei Fehlern: npm install --legacy-peer-deps
```

---

## Schritt 4: Expo CLI Installieren

```bash
# Global installieren
npm install -g eas-cli

# Prüfen
eas --version
```

---

## Schritt 5: Expo Account Erstellen/Login

### 5.1 Account Erstellen (falls noch nicht vorhanden)

1. Öffne Browser auf deinem Gerät
2. Gehe zu: https://expo.dev/signup
3. Erstelle kostenlosen Account
4. Bestätige Email

### 5.2 In Termux Einloggen

```bash
# Login
eas login

# Eingeben:
# - Email: deine@email.com
# - Password: dein-passwort

# Erfolgreich wenn: "Logged in as [dein-username]"
```

---

## Schritt 6: EAS Build Konfigurieren

```bash
# Im Aether-Trader-Mobile Verzeichnis
eas build:configure

# Fragen beantworten:
# - "Generate a new Android Keystore?" -> YES
# - "Would you like to upload a Keystore?" -> NO (wird automatisch erstellt)
```

Dies erstellt `eas.json` Datei.

---

## Schritt 7: APK Bauen

### 7.1 Build Starten

```bash
# Production Build
eas build --platform android --profile production

# Oder Preview Build (schneller, für Testing):
eas build --platform android --profile preview
```

### 7.2 Was passiert jetzt?

1. **Code wird hochgeladen** (~2-5 Minuten)
   - Termux zeigt Upload-Fortschritt
   
2. **Build läuft in Expo Cloud** (~15-30 Minuten)
   - Du kannst Termux schließen
   - Build läuft weiter in der Cloud
   
3. **APK wird erstellt**
   - Du bekommst Link zum Download

### 7.3 Build-Status Prüfen

```bash
# Liste alle Builds
eas build:list

# Oder im Browser:
# https://expo.dev/accounts/[dein-username]/projects/aether-trader-pro/builds
```

---

## Schritt 8: APK Herunterladen

### Option A: Direkt in Termux

```bash
# Wenn Build fertig, zeigt EAS einen Download-Link:
# https://expo.dev/artifacts/...

# Download mit wget:
wget -O aether-trader.apk "DOWNLOAD_LINK_HIER"

# APK ist jetzt in ~/Aether-Trader-Mobile/aether-trader.apk
```

### Option B: Im Browser

1. Öffne Browser auf Android
2. Gehe zu: https://expo.dev
3. Login
4. Navigiere zu "Builds"
5. Klicke auf neuesten Build
6. Klicke "Download"
7. APK wird in Downloads-Ordner gespeichert

---

## Schritt 9: APK Installieren

### 9.1 Installation Vorbereiten

1. Öffne **Einstellungen** auf Android
2. Gehe zu **Sicherheit** oder **Apps**
3. Aktiviere **"Installation aus unbekannten Quellen"**
   - Für Termux oder deinen Dateimanager

### 9.2 APK Installieren

```bash
# Option A: Via Termux
termux-open aether-trader.apk

# Option B: Via Dateimanager
# 1. Öffne Dateimanager
# 2. Navigiere zu: Downloads/ oder Termux-Home/
# 3. Tippe auf aether-trader.apk
# 4. Folge Installationsanweisungen
```

### 9.3 App Starten

1. Finde "Aether Trader Pro" in deinen Apps
2. Öffne die App
3. Gehe durch Onboarding
4. Fertig! 🎉

---

## Troubleshooting

### Problem: "npm: command not found"

**Lösung:**
```bash
pkg install nodejs-lts -y
```

### Problem: "git: command not found"

**Lösung:**
```bash
pkg install git -y
```

### Problem: "eas: command not found"

**Lösung:**
```bash
npm install -g eas-cli
# Termux neu starten
exit
# Termux wieder öffnen
```

### Problem: "EACCES: permission denied"

**Lösung:**
```bash
# Nie sudo in Termux verwenden!
# Stattdessen:
npm config set prefix ~/.npm-global
export PATH=~/.npm-global/bin:$PATH
npm install -g eas-cli
```

### Problem: "Network request failed"

**Lösung:**
- Prüfe Internetverbindung
- Nutze WLAN statt Mobile Data
- Versuche es später nochmal

### Problem: Build schlägt fehl mit "Out of memory"

**Lösung:**
- Das ist ein Cloud-Problem, nicht dein Gerät
- Versuche Preview Build: `eas build --platform android --profile preview`
- Oder warte und versuche es später

### Problem: "Could not read package.json"

**Lösung:**
```bash
# Stelle sicher, dass du im richtigen Verzeichnis bist
cd ~/Aether-Trader-Mobile
ls -la  # Sollte package.json zeigen
```

### Problem: APK Installation blockiert

**Lösung:**
1. Einstellungen → Sicherheit
2. "Installation aus unbekannten Quellen" aktivieren
3. Für Termux oder Dateimanager erlauben

---

## Tipps für Termux

### Termux-Speicher Zugriff

```bash
# Erlaube Termux Zugriff auf Android-Speicher
termux-setup-storage

# Jetzt kannst du auf Downloads zugreifen:
cd ~/storage/downloads
```

### Termux im Hintergrund Laufen Lassen

```bash
# Installiere Termux:Boot (optional)
# Oder nutze "Acquire wakelock" in Termux-Einstellungen
```

### Schnellerer Build

```bash
# Preview Build (schneller, kleinere APK)
eas build --platform android --profile preview --non-interactive
```

---

## Alternative: GitHub Actions

Wenn Termux zu langsam ist, nutze GitHub Actions:

1. Siehe `GITHUB_ACTIONS_SETUP.md`
2. Push Code zu GitHub
3. APK wird automatisch gebaut
4. Download von GitHub oder Expo

---

## Kosten

### Termux:
✅ **Kostenlos** - Open Source

### Expo EAS Build:
✅ **Kostenlos** - Erste Builds pro Monat
💰 **$29/Monat** - Unbegrenzte Builds (optional)

### GitHub Actions:
✅ **Kostenlos** - Für Public Repositories

---

## Zusammenfassung

```bash
# 1. Termux Setup
pkg update && pkg upgrade -y
pkg install git nodejs-lts -y

# 2. Repository Klonen
cd ~
git clone https://github.com/macyb27/Aether-Trader-Mobile.git
cd Aether-Trader-Mobile

# 3. Dependencies
npm install

# 4. EAS CLI
npm install -g eas-cli
eas login

# 5. Build Konfigurieren
eas build:configure

# 6. APK Bauen
eas build --platform android --profile production

# 7. Warten (15-30 Min)
# 8. APK Herunterladen und Installieren
```

**Geschätzte Gesamtzeit:** 45-60 Minuten (inkl. Wartezeit)

---

## Nächste Schritte

1. ✅ Termux einrichten
2. ✅ Repository klonen
3. ✅ EAS Build starten
4. ✅ APK installieren
5. ✅ App testen

Bei Fragen: Siehe `APK_BUILD_GUIDE.md` oder `GITHUB_ACTIONS_SETUP.md`

---

## Wichtige Links

- **Expo Dashboard:** https://expo.dev
- **GitHub Repository:** https://github.com/macyb27/Aether-Trader-Mobile
- **Termux Wiki:** https://wiki.termux.com
- **EAS Build Docs:** https://docs.expo.dev/build/introduction/
