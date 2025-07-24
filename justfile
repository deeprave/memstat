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
	xcodebuild -scheme MemStat -configuration Debug -derivedDataPath build build

# Build debug version explicitly
debug: version
	@echo "Building MemStat (Debug)..."
	xcodebuild -scheme MemStat -configuration Debug -derivedDataPath build build

# Build release version
release: version
	@echo "Building MemStat (Release)..."
	xcodebuild -scheme MemStat -configuration Release -derivedDataPath build build

# Run tests (optionally specify test to run)
test TEST_ID="": version
	@echo "Running tests..."
	@if [ "{{TEST_ID}}" = "" ]; then \
		xcodebuild test -scheme MemStat -destination 'platform=macOS'; \
	else \
		echo "Running specific test: {{TEST_ID}}"; \
		xcodebuild test -scheme MemStat -destination 'platform=macOS' -only-testing:{{TEST_ID}}; \
	fi

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

# Run the app (uses saved preference or default window mode)
run:
	@echo "Running MemStat (Debug) in default mode..."
	@./build/Build/Products/Debug/MemStat.app/Contents/MacOS/MemStat &

run-release:
	@echo "Running MemStat (Release) in default mode..."
	@./build/Build/Products/Release/MemStat.app/Contents/MacOS/MemStat &

# Run the app in window mode
run-window:
	@echo "Running MemStat (Debug) in window mode..."
	@./build/Build/Products/Debug/MemStat.app/Contents/MacOS/MemStat --window &

# Run the app in menubar mode
run-menubar:
	@echo "Running MemStat (Debug) in menubar mode..."
	@./build/Build/Products/Debug/MemStat.app/Contents/MacOS/MemStat --menubar &

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
	@echo "  just              - Build debug version (default)"
	@echo "  just debug        - Build debug version"
	@echo "  just release      - Build release version"
	@echo "  just run          - Run debug app (uses saved preference)"
	@echo "  just run-window   - Run debug app in window mode"
	@echo "  just run-menubar  - Run debug app in menubar mode"
	@echo "  just test         - Run all tests"
	@echo "  just test TEST_ID - Run specific test (e.g., just test MemStatTests/TableFieldFactoryTests/testCreateMetricFieldAlignment)"
	@echo "  just clean        - Clean build artifacts"
	@echo "  just archive      - Create release archive"
	@echo "  just zip          - Create ZIP distribution"
	@echo "  just dmg          - Create DMG distribution"
	@echo "  just dist         - Create both ZIP and DMG distributions"
	@echo "  just version      - Generate Version.swift only"
	@echo "  just show-version - Display current version info"
	@echo "  just help         - Show this help message"