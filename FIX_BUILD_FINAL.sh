#!/bin/bash

##############################################################################
# AETHER TRADER PRO - BUILD FIX SCRIPT (Standalone / No Sandbox)
#
# Prepares the project for building an APK without any sandbox environment.
# No Python, no EAS cloud, no sandbox CLI tools required.
#
# Usage:
#   chmod +x FIX_BUILD_FINAL.sh
#   ./FIX_BUILD_FINAL.sh
#
# After running this script, build with one of:
#   Option A (local):  npx expo prebuild --platform android && cd android && ./gradlew assembleRelease
#   Option B (EAS):    eas build --platform android --profile local --local
##############################################################################

set -e  # Exit on any error

echo "=========================================="
echo "AETHER TRADER PRO - BUILD FIX SCRIPT"
echo "(Standalone / No Sandbox)"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${BLUE}> $1${NC}"
}

print_success() {
    echo -e "${GREEN}+ $1${NC}"
}

print_error() {
    echo -e "${RED}x $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}! $1${NC}"
}

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    print_error "package.json not found. Please run this script from the project root directory."
    exit 1
fi

# -------------------------------------------------------------------
# Step 1: Detect package manager
# -------------------------------------------------------------------
print_step "Step 1: Detecting package manager..."

if [ -f "pnpm-lock.yaml" ]; then
    PKG_MGR="pnpm"
    INSTALL_CMD="pnpm install"
elif [ -f "yarn.lock" ]; then
    PKG_MGR="yarn"
    INSTALL_CMD="yarn install"
else
    PKG_MGR="npm"
    INSTALL_CMD="npm install --legacy-peer-deps"
fi

print_success "Using $PKG_MGR"

# -------------------------------------------------------------------
# Step 2: Clean old build artifacts (optional with --clean flag)
# -------------------------------------------------------------------
if [ "$1" = "--clean" ]; then
    print_step "Step 2: Cleaning up old dependencies (--clean flag set)..."
    rm -rf node_modules android ios .expo
    print_success "Cleaned up node_modules, android/, ios/, .expo/"
else
    print_step "Step 2: Skipping clean (pass --clean to force clean install)"
fi

# -------------------------------------------------------------------
# Step 3: Install dependencies
# -------------------------------------------------------------------
print_step "Step 3: Installing dependencies with $PKG_MGR..."
$INSTALL_CMD

if [ $? -ne 0 ]; then
    print_error "$PKG_MGR install failed. Trying with --force..."
    if [ "$PKG_MGR" = "npm" ]; then
        npm install --legacy-peer-deps --force
    elif [ "$PKG_MGR" = "pnpm" ]; then
        pnpm install --no-frozen-lockfile
    else
        yarn install --force
    fi
fi

print_success "Dependencies installed successfully"

# -------------------------------------------------------------------
# Step 4: Create .easignore file
# -------------------------------------------------------------------
print_step "Step 4: Creating .easignore file..."
cat > .easignore << 'EASIGNORE_EOF'
# Dependencies (EAS installs its own)
node_modules/
.pnpm-store/

# Version control
.git/
.gitignore

# Environment (secrets should be managed via EAS secrets or CI)
.env
.env.local
.env.*.local

# Build artifacts
dist/
build/
.next/
.expo/

# Logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# OS
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/
*.swp
*.swo

# Testing / coverage
coverage/
.nyc_output/

# Server-only files (not needed in mobile APK)
server/
drizzle/
drizzle.config.ts

# Scripts not needed at runtime
scripts/
FIX_BUILD_FINAL.sh

# Documentation
*.md

# Misc
.cache/
temp/
tmp/
EASIGNORE_EOF

print_success "Created .easignore file"

# -------------------------------------------------------------------
# Step 5: Verify critical files exist
# -------------------------------------------------------------------
print_step "Step 5: Verifying build readiness..."

required_files=("package.json" "app.config.ts" "eas.json" "metro.config.js" "babel.config.js" "global.css")
all_good=true

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        print_success "$file exists"
    else
        print_error "$file missing"
        all_good=false
    fi
done

# -------------------------------------------------------------------
# Step 6: Check for common issues
# -------------------------------------------------------------------
print_step "Step 6: Checking for common issues..."

# Check Node version
NODE_MAJOR=$(node -v | cut -d. -f1 | tr -d 'v')
if [ "$NODE_MAJOR" -lt 18 ]; then
    print_warning "Node.js $NODE_MAJOR detected. Version 18+ is recommended."
else
    print_success "Node.js version OK (v$(node -v | tr -d 'v'))"
fi

# Check if expo CLI is available
if npx expo --version > /dev/null 2>&1; then
    print_success "Expo CLI available"
else
    print_warning "Expo CLI not found. Install with: npm install -g expo-cli"
fi

echo ""
echo "=========================================="
if [ "$all_good" = true ]; then
    print_success "BUILD FIX COMPLETE - READY FOR APK BUILD"
    echo ""
    echo "Next steps (choose one):"
    echo ""
    echo "  Option A - Local Gradle build (no EAS account needed):"
    echo "    npx expo prebuild --platform android --clean"
    echo "    cd android && chmod +x gradlew && ./gradlew assembleRelease"
    echo ""
    echo "  Option B - EAS local build:"
    echo "    npx eas-cli build --platform android --profile local --local"
    echo ""
    echo "  Option C - EAS cloud build (requires EXPO_TOKEN):"
    echo "    eas build --platform android --profile production"
    echo ""
else
    print_error "Some files are missing. Please check above."
    exit 1
fi

echo "=========================================="
