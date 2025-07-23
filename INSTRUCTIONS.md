# Project Context

This project is a macOS app that runs both in the macOS menu bar and as a regular window.

## Features
- Displayes a window showing memory statistics

## Build Instructions
- Use debug builds by default
- Only do release builds when specifically instructed

## Code Comments Policy
- Only add comments to source code which explain non-obvious or complex logic
- Never add comments which state the obvious or 'marker' style comments that have no practical value
- Code should be self-documenting through clear naming and structure
- Allowed comment types:
  - MARK comments for code organization and navigation
  - API documentation comments (///, /** */)
  - Complex logic explanations that are not obvious from the code
- Comment cleanup is performed as needed but is not worth mentioning in changelogs (it's routine maintenance)

## Steering
- All new files created must be added to the Xcode project in order that xcodebuild works, including test files and other artifacts, as required
- prefer to use 'just' as a runner, the justfile contains a number of useful targets
- use just as task runner for local development
- always use just and the just test target to run tests. Individual tests can use this target as well

## Git Commit Policy
- NEVER do git commit, even if asked for a commit message. I require signing of commits and commit signing does not currently work when claude attempts a git commit.

## Changelog Management
- Update the changelog whenever code is about to be committed (changelog will be requested before commit)