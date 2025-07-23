 Project Overview

This project is a macOS 13.0+ application that provides the user with a dynamic view of memory use and top 20 memory using processes. It is built using Xcode and Swift.

MemStat only reads system memory statistics and process information. It does not:
- Collect or transmit any data
- Modify system settings  
- Access personal files or data
- Require network access
- Read from or write to the filesystem (except for saving user preferences)

## Folder Structure

- `/MemStat`: Contains the source code for the application.
- `/MemStatTests`: Contains the unit tests for the application code.
- `/Scripts`: Contains scripts for building and testing the application.
- `justfile`: Contains many targets used for development and testing.

## Libraries and Frameworks

- macOS 13.0+ SDK for building the application.

## Coding Standards

- Use SwiftLint to enforce coding standards.
- Follow the Swift API Design Guidelines.

## UI guidelines

- A toggle is provided to switch between light and dark mode.
- A toggle is provided to switch between menubar and window mode.
- The application should have a modern and clean design.
- Use system colors and fonts to ensure consistency with macOS design.
