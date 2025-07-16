# justfile for MemStat
# This provides an alternative build method that ensures Version.swift is always updated

# Default recipe
default: build

# Generate version file before building
version:
	@echo "Generating Version.swift..."
	@./Scripts/generate_version.sh

# Build debug version (default)
build: version
	@echo "Building MemStat (Debug)..."
	xcodebuild -scheme MemStat -configuration Debug build

# Build debug version explicitly
debug: version
	@echo "Building MemStat (Debug)..."
	xcodebuild -scheme MemStat -configuration Debug build

# Build release version
release: version
	@echo "Building MemStat (Release)..."
	xcodebuild -scheme MemStat -configuration Release -derivedDataPath build build

# Run tests
test: version
	@echo "Running tests..."
	xcodebuild test -scheme MemStat -destination 'platform=macOS'

# Clean build artifacts
clean:
	@echo "Cleaning..."
	xcodebuild clean -scheme MemStat
	rm -rf ~/Library/Developer/Xcode/DerivedData/MemStat-*

# Archive for distribution
archive: version
	@echo "Creating archive..."
	xcodebuild -scheme MemStat -configuration Release -derivedDataPath build archive

# Create ZIP distribution
zip: release
	@echo "Creating ZIP distribution..."
	@./Scripts/package_zip.sh

# Create DMG distribution
dmg: release
	@echo "Creating DMG distribution..."
	@./Scripts/package_dmg_styled.sh

# Create both ZIP and DMG distributions
dist: zip dmg
	@echo "All distribution packages created!"

# Show current version
show-version:
	@echo "Current version info:"
	@echo "Git version: `git describe --tags --always --dirty`"
	@echo "Build number: `git rev-list --count HEAD`"
	@echo "Commit hash: `git rev-parse --short HEAD`"

# Help
help:
	@echo "MemStat justfile"
	@echo ""
	@echo "Available recipes:"
	@echo "  just         - Build debug version (default)"
	@echo "  just debug   - Build debug version"
	@echo "  just release - Build release version"
	@echo "  just test    - Run tests"
	@echo "  just clean   - Clean build artifacts"
	@echo "  just archive - Create release archive"
	@echo "  just zip     - Create ZIP distribution"
	@echo "  just dmg     - Create DMG distribution"
	@echo "  just dist    - Create both ZIP and DMG distributions"
	@echo "  just version - Generate Version.swift only"
	@echo "  just show-version - Display current version info"
	@echo "  just help    - Show this help message"