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
	@echo "  just version - Generate Version.swift only"
	@echo "  just show-version - Display current version info"
	@echo "  just help    - Show this help message"