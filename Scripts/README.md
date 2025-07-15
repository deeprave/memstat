# Version Management Scripts

## Setting up automatic version generation

To automatically generate version information from git tags on each build, add a Run Script Build Phase to your Xcode project:

### Steps to add the Run Script Phase:

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
8. Uncheck "Based on dependency analysis" (to ensure it runs every build)

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