# Version Management Scripts

## Setting up automatic version generation

To automatically generate version information from git tags on each build, you have several options:

### Option 1: Xcode Build Phase (Recommended)

Add a Run Script Build Phase to your Xcode project:

1. Open MemStat.xcodeproj in Xcode
2. Select the MemStat target
3. Go to the "Build Phases" tab
4. Click the "+" button and select "New Run Script Phase"
5. Drag the new "Run Script" phase to be **before** the "Compile Sources" phase
6. Rename it to "Generate Version Info" (optional but recommended)
7. In the script text area, add:
   ```bash
   "${PROJECT_DIR}/Scripts/generate_version.sh"
   ```
8. Configure Input/Output Files for build optimization:
   - Input Files: `$(PROJECT_DIR)/.git/HEAD`, `$(PROJECT_DIR)/.git/index`
   - Output Files: `$(PROJECT_DIR)/MemStat/Version.swift`

### Option 2: Using Make

A Makefile is provided for building with automatic version generation:

```bash
make              # Build debug version
make release      # Build release version
make test         # Run tests
make clean        # Clean build artifacts
make show-version # Display current version info
```

### Option 3: Using the Build Script

Use the provided build script that always updates the version:

```bash
./Scripts/build.sh                          # Build debug version
./Scripts/build.sh -c Release               # Build release version
./Scripts/build.sh -a test                  # Run tests
./Scripts/build.sh -c Release -a archive    # Create archive
```

### How it works:

- The script reads git tags using `git describe`
- Creates MemStat/Version.swift with version information
- Version format: "v1.0.0" for tagged commits, "v1.0.0-5-g3a4b5c6" for commits after tags
- Adds "-dirty" suffix if there are uncommitted changes
- The About dialog will show the version without the "v" prefix

### Creating version tags:

To create a new version tag:
```bash
git tag -a v1.0.1 -m "Version 1.0.1"
git push origin v1.0.1
```

The version will automatically update on the next build.

## Building and Packaging for Distribution

### Quick Start

To build a release version and create distribution packages:
```bash
./Scripts/build_release.sh
```

This script will:
1. Build the app in Release configuration
2. Ask if you want to create a ZIP, DMG, or both
3. Generate distribution files in the `dist/` directory

### Individual Packaging Scripts

#### Creating a ZIP file

```bash
./Scripts/package_zip.sh
```

Creates a ZIP file suitable for distribution. Users can extract it and drag the app to Applications.

**Note**: Requires the app to be code signed. The script will abort if the app is not properly signed.

#### Creating a DMG file

Basic DMG (no special styling):
```bash
./Scripts/package_dmg.sh
```

Styled DMG with custom window (requires `create-dmg`):
```bash
./Scripts/package_dmg_styled.sh
```

The styled DMG includes:
- Custom window size and icon positioning
- Application shortcut for easy installation
- Professional appearance

**Note**: Both DMG scripts require the app to be code signed. The scripts will abort if the app is not properly signed.

To install `create-dmg`:
```bash
brew install create-dmg
```

## Code Signing and Notarization

For distributing outside the Mac App Store, your app must be code signed and notarized.

### Prerequisites

1. **Apple Developer Account**: You need a paid Apple Developer account
2. **Developer ID Certificate**: Install "Developer ID Application" certificate in Keychain
3. **App-Specific Password**: Generate one at [appleid.apple.com](https://appleid.apple.com) → Sign-In and Security → App-Specific Passwords

### Code Signing

To code sign your app:
```bash
./Scripts/codesign_app.sh
```

This script will:
- List available signing identities
- Sign the app with hardened runtime
- Verify the signature

You can also set the `CODESIGN_IDENTITY` environment variable:
```bash
export CODESIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)"
./Scripts/codesign_app.sh
```

### Notarization

First, set up notarization credentials (recommended - one time setup):
```bash
xcrun notarytool store-credentials "notarytool-password" \
  --apple-id "your@email.com" \
  --team-id "TEAMID" \
  --password "app-specific-password"
```

To check if your app is ready for notarization:
```bash
./Scripts/notarize_app.sh
```

To actually submit for notarization:
```bash
export NOTARIZE_PROFILE="notarytool-password"
./Scripts/notarize_app.sh --submit
```

Alternatively, use environment variables:
```bash
export NOTARIZE_APPLE_ID="your@email.com"
export NOTARIZE_PASSWORD="app-specific-password"
export NOTARIZE_TEAM_ID="TEAMID"
./Scripts/notarize_app.sh --submit
```

### Complete Distribution Workflow

1. **Build Release**: `./Scripts/build_release.sh`
2. **Code Sign**: Choose "Yes" when prompted, or run `./Scripts/codesign_app.sh`
3. **Notarize** (optional): `./Scripts/notarize_app.sh --submit`
4. **Package**: Choose packaging option or run individual packaging scripts

### Distribution Checklist

For distributing outside the Mac App Store:

1. ✅ **Code Signing**: Sign the app with a Developer ID certificate (**REQUIRED**)
2. ✅ **Notarization**: Submit the app to Apple for notarization (optional but recommended)
3. ✅ **Stapling**: Attach notarization ticket to the app (if notarized)
4. **Package Creation**: Create ZIP/DMG for distribution

**Important**: All packaging scripts will abort if the app is not code signed. Code signing is mandatory for distribution.

### File Locations

- **Release Build**: `build/Build/Products/Release/MemStat.app`
- **Distribution Packages**: `dist/MemStat-{version}.zip` and `dist/MemStat-{version}.dmg`

### Version Numbering

Packages are automatically named with the git version:
- Tagged release: `MemStat-1.0.1.zip`
- Development build: `MemStat-1.0.1-5-g3a4b5c6.zip`
- Modified working directory: `MemStat-1.0.1-dirty.zip`