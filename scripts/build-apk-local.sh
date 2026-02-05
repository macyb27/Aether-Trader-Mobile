#!/bin/bash

##############################################################################
# Local APK Build Script - No sandbox, no EAS cloud, no Python required.
#
# Prerequisites:
#   - Node.js 18+
#   - pnpm (or npm)
#   - Java JDK 17+
#   - Android SDK (ANDROID_HOME / ANDROID_SDK_ROOT set)
#
# Usage:
#   chmod +x scripts/build-apk-local.sh
#   ./scripts/build-apk-local.sh
#
# Output:
#   android/app/build/outputs/apk/release/app-release.apk
##############################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}  Aether Trader Pro - Local APK Build${NC}"
echo -e "${BLUE}==========================================${NC}"
echo ""

# -------------------------------------------------------------------
# Pre-flight checks
# -------------------------------------------------------------------
echo -e "${BLUE}> Checking prerequisites...${NC}"

# Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}x Node.js is not installed. Please install Node.js 18+.${NC}"
    exit 1
fi
echo -e "${GREEN}+ Node.js $(node -v)${NC}"

# Java
if ! command -v java &> /dev/null; then
    echo -e "${RED}x Java is not installed. Please install JDK 17+.${NC}"
    exit 1
fi
JAVA_VERSION=$(java -version 2>&1 | head -1)
echo -e "${GREEN}+ $JAVA_VERSION${NC}"

# Android SDK
if [ -z "$ANDROID_HOME" ] && [ -z "$ANDROID_SDK_ROOT" ]; then
    echo -e "${YELLOW}! ANDROID_HOME / ANDROID_SDK_ROOT not set.${NC}"
    echo -e "${YELLOW}  Expo prebuild may still work if Android SDK is on PATH.${NC}"
else
    echo -e "${GREEN}+ Android SDK: ${ANDROID_HOME:-$ANDROID_SDK_ROOT}${NC}"
fi

# Package manager
if command -v pnpm &> /dev/null; then
    PKG_INSTALL="pnpm install"
elif command -v yarn &> /dev/null; then
    PKG_INSTALL="yarn install"
else
    PKG_INSTALL="npm install --legacy-peer-deps"
fi
echo -e "${GREEN}+ Package manager: ${PKG_INSTALL%% *}${NC}"

echo ""

# -------------------------------------------------------------------
# Step 1: Install dependencies
# -------------------------------------------------------------------
echo -e "${BLUE}> Step 1: Installing dependencies...${NC}"
$PKG_INSTALL
echo -e "${GREEN}+ Dependencies installed${NC}"

# -------------------------------------------------------------------
# Step 2: Generate native Android project
# -------------------------------------------------------------------
echo -e "${BLUE}> Step 2: Generating native Android project (expo prebuild)...${NC}"
npx expo prebuild --platform android --clean
echo -e "${GREEN}+ Android project generated${NC}"

# -------------------------------------------------------------------
# Step 3: Build APK
# -------------------------------------------------------------------
echo -e "${BLUE}> Step 3: Building APK with Gradle...${NC}"
cd android
chmod +x gradlew
./gradlew assembleRelease --no-daemon
cd ..
echo -e "${GREEN}+ APK build complete${NC}"

# -------------------------------------------------------------------
# Step 4: Locate APK
# -------------------------------------------------------------------
APK_PATH=$(find android/app/build/outputs/apk/release -name "*.apk" -type f 2>/dev/null | head -1)

echo ""
echo -e "${BLUE}==========================================${NC}"
if [ -n "$APK_PATH" ]; then
    APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
    echo -e "${GREEN}+ APK built successfully!${NC}"
    echo ""
    echo "  Location: $APK_PATH"
    echo "  Size:     $APK_SIZE"
    echo ""
    echo "  Install on device:"
    echo "    adb install $APK_PATH"
    echo ""
    echo "  Or copy the APK to your phone and open it."
else
    echo -e "${RED}x APK not found. Check Gradle output above for errors.${NC}"
    exit 1
fi
echo -e "${BLUE}==========================================${NC}"
