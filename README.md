# MemStat

A lightweight macOS menu bar application that provides real-time memory statistics and process monitoring.

## Features

- **Menu Bar Integration**: Runs discreetly in your macOS menu bar
- **Real-Time Memory Monitoring**: View current memory usage including:
  - Physical memory (Total, Used, Free)
  - Virtual memory (Active, Inactive, Wired, Compressed)
  - Swap memory usage and activity
  - Memory pressure status
- **Process Monitoring**: See the top 20 memory-consuming processes with:
  - Process ID (PID)
  - Memory usage (percentage and absolute)
  - Virtual memory usage
  - CPU usage percentage
  - Process name/command
- **Smart Window Management**: Click the menu bar icon to show stats, click again or anywhere else to dismiss
- **Automatic Updates**: Stats refresh every second while the window is open
- **Dark Mode Support**: Automatically adapts to your system appearance
- **Efficient Performance**: Optimized to use minimal system resources

## Requirements

- macOS 14.0 (Sonoma) or later
- Apple Silicon or Intel Mac

## Installation

1. Download the latest release from the Releases page
2. Move MemStat.app to your Applications folder
3. Launch MemStat from Applications or Spotlight
4. Grant necessary permissions when prompted

## Usage

- Click the MemStat icon in your menu bar to view current statistics
- Click column headers in the process table to sort by that column
- Click again to reverse sort order
- Right-click the menu bar icon for additional options:
  - Toggle "Launch at Login"
  - Change appearance settings
  - Quit the application

## Building from Source

Prerequisites:
- Xcode 15.0 or later
- macOS 14.0 SDK or later

```bash
# Clone the repository
git clone https://github.com/yourusername/memstat.git
cd memstat

# Build using Xcode
open MemStat.xcodeproj

# Or build from command line
xcodebuild -project MemStat.xcodeproj -scheme MemStat -configuration Release build

# To run unit tests against the debug build
xcodebuild test -scheme MemStat -destination 'platform=macOS,arch=arm64' -configuration Debug
```

For development builds without code signing:
```bash
./build_unsigned.sh
```

## Privacy

MemStat only reads system memory statistics and process information. It does not:
- Collect or transmit any data
- Modify system settings
- Access personal files or data
- Require network access

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
