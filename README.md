# MemStat

A lightweight macOS application that provides real-time memory statistics and process monitoring. MemStat can run in two modes: as a traditional menu bar app or as a regular windowed application.

## Features

### Dual Mode Support
- **Menu Bar Mode**: Runs discreetly in your macOS menu bar with on-demand floating stats window
- **Regular Window Mode**: Standard macOS app with always-visible window and dock icon (default)
- **Mode Switching**: Switch between modes via menu options with automatic restart
- **Persistent Preferences**: App remembers your selected mode between launches

### Real-Time Memory Monitoring
- **Physical Memory**: Total, Used, Free memory with visual indicators
- **Virtual Memory**: Active, Inactive, Wired, Compressed memory breakdown
- **Swap Memory**: Usage, utilization percentage, and swap activity (ins/outs)
- **Memory Pressure**: Real-time pressure status with color-coded indicators

### Process Monitoring
- **Top 20 Processes**: Memory-consuming processes with sortable columns
- **Process Details**: PID, Memory % and absolute usage, Virtual memory, CPU %, Command name
- **Interactive Sorting**: Click column headers to sort, click again to reverse order
- **Real-time Updates**: Process list refreshes every second

### User Experience
- **Smart Window Management**: Click to show/hide stats, click anywhere else to dismiss
- **Appearance Support**: Auto/Light/Dark mode with visual menu indicators
- **Launch at Login**: Optional system startup integration
- **Command Line Support**: Force startup mode with `--menubar`, `--window`, or `--help` flags
- **Efficient Performance**: Optimized for minimal system resource usage

## Requirements

- macOS 13.0 (Ventura) or later
- Apple Silicon or Intel Mac

## Installation

1. Download the latest release from the Releases page
2. Move MemStat.app to your Applications folder
3. Launch MemStat from Applications or Spotlight
4. Grant necessary permissions when prompted
5. Choose your preferred mode on first launch (Regular Window is default)

## Usage

### Regular Window Mode (Default)
- App appears in dock with always-visible window
- Use "Mode" menu in application menu bar to switch to Menu Bar mode
- Standard macOS window controls (minimize, close, etc.)

### Menu Bar Mode
- Click the MemStat icon in your menu bar to view current statistics
- Right-click the menu bar icon for options including mode switching
- Click outside the stats window to dismiss

### Universal Features
- Click column headers in the process table to sort by that column
- Access appearance settings and launch preferences via menus
- Use command line flags to override saved mode preference

## Command Line Options

```bash
# Force startup in menu bar mode
./MemStat.app/Contents/MacOS/MemStat --menubar

# Force startup in regular window mode  
./MemStat.app/Contents/MacOS/MemStat --window

# Display usage information
./MemStat.app/Contents/MacOS/MemStat --help
```

## Building from Source

### Prerequisites
- Xcode 15.0 or later
- macOS 13.0 SDK or later

### Using Just (Recommended)
```bash
# Clone the repository
git clone https://github.com/yourusername/memstat.git
cd memstat

# Build debug version (default)
just build

# Build release version
just release

# Run tests
just test

# Run specific test
just test MemStatTests/AppModeTests/testModeToggling

# Run in different modes for development
just run          # Uses saved preference or default
just run-window   # Force window mode
just run-menubar  # Force menu bar mode

# Create distribution packages
just zip          # Create ZIP distribution
just dmg          # Create DMG distribution
just dist         # Create both ZIP and DMG

# View all available commands
just help
```

### Using Xcode Directly
```bash
# Build using Xcode
open MemStat.xcodeproj

# Or build from command line
xcodebuild -project MemStat.xcodeproj -scheme MemStat -configuration Release build

# Run comprehensive test suite (125 tests)
xcodebuild test -scheme MemStat -destination 'platform=macOS'
```

### Development
The project includes a comprehensive test suite with 125 tests covering:
- Mode switching and preference persistence
- Command line argument parsing
- UI component functionality
- Memory monitoring and data services
- Theme management and appearance handling

All tests must pass before submitting changes. Use `just test` to run the full suite.

## Privacy

MemStat only reads system memory statistics and process information. It does not:
- Collect or transmit any data
- Modify system settings  
- Access personal files or data
- Require network access
- Read from or write to the filesystem (except for saving user preferences)

The app operates entirely locally, requiring no network connectivity and performing no filesystem operations beyond standard macOS preference storage.

## Contributing

Contributions are welcome! Please:
1. Ensure all tests pass with `just test`
2. Follow the existing code style and architecture
3. Add tests for new functionality
4. Update documentation as needed
5. Submit a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.