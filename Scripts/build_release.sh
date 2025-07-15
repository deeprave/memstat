#!/bin/bash

# Master script to build release version and create distribution packages

set -e  # Exit on error

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_DIR="$( cd "$SCRIPT_DIR/.." >/dev/null 2>&1 && pwd )"

# Configuration
APP_NAME="MemStat"
SCHEME_NAME="MemStat"

echo "=== ${APP_NAME} Release Builder ==="
echo ""

# Change to project directory
cd "$PROJECT_DIR"

# Get version
VERSION=$(git describe --tags --always --dirty 2>/dev/null || echo "unknown")
VERSION_CLEAN=${VERSION#v}
echo "Version: ${VERSION_CLEAN}"
echo ""

# Clean build directory
echo "Cleaning build directory..."
rm -rf build/

# Build Release version
echo "Building Release configuration..."
xcodebuild -scheme "${SCHEME_NAME}" \
    -configuration Release \
    -derivedDataPath build \
    clean build \
    ONLY_ACTIVE_ARCH=NO \
    | xcpretty || xcodebuild -scheme "${SCHEME_NAME}" \
        -configuration Release \
        -derivedDataPath build \
        clean build \
        ONLY_ACTIVE_ARCH=NO

echo ""
echo "Build completed successfully!"
echo ""

# Ask about code signing
echo "Do you want to code sign the app for distribution?"
echo "1) Yes, code sign now"
echo "2) No, skip code signing"
echo ""
read -p "Enter choice (1-2): " sign_choice

case $sign_choice in
    1)
        echo ""
        "${SCRIPT_DIR}/codesign_app.sh"
        echo ""
        echo "Code signing completed. For distribution, you may also want to notarize:"
        echo "  ./Scripts/notarize_app.sh --submit"
        echo ""
        ;;
    2)
        echo ""
        echo "⚠️  Skipping code signing."
        echo "Note: Unsigned apps may not run on other Macs due to Gatekeeper."
        echo ""
        ;;
    *)
        echo "Invalid choice. Skipping code signing."
        echo ""
        ;;
esac

# Ask what to package
echo "What would you like to create?"
echo "1) ZIP file only"
echo "2) DMG file only" 
echo "3) Both ZIP and DMG"
echo "4) Skip packaging"
echo ""
read -p "Enter choice (1-4): " choice

case $choice in
    1)
        echo ""
        "${SCRIPT_DIR}/package_zip.sh"
        ;;
    2)
        echo ""
        # Try styled DMG first, fall back to basic if create-dmg is not available
        if command -v create-dmg &> /dev/null; then
            "${SCRIPT_DIR}/package_dmg_styled.sh"
        else
            "${SCRIPT_DIR}/package_dmg.sh"
        fi
        ;;
    3)
        echo ""
        "${SCRIPT_DIR}/package_zip.sh"
        echo ""
        if command -v create-dmg &> /dev/null; then
            "${SCRIPT_DIR}/package_dmg_styled.sh"
        else
            "${SCRIPT_DIR}/package_dmg.sh"
        fi
        ;;
    4)
        echo "Skipping packaging."
        ;;
    *)
        echo "Invalid choice. Skipping packaging."
        ;;
esac

echo ""
echo "✅ All done!"
echo ""
echo "Release build location: build/Release/${APP_NAME}.app"
if [ -d "dist" ]; then
    echo "Distribution packages: dist/"
    ls -la dist/
fi