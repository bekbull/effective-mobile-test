# To-Do List iOS App

This project is configured to use [Tuist](https://tuist.dev) for project generation and dependency management.

## Prerequisites

- Xcode 15.0+
- iOS 16.0+ deployment target
- [mise](https://mise.jdx.dev) for tool management

## Getting Started

1. **Install Tuist** (if not already installed):
   ```bash
   mise install tuist
   mise use tuist
   ```

2. **Generate the Xcode project**:
   ```bash
   tuist generate
   ```

3. **Open the workspace**:
   ```bash
   open ToDoList.xcworkspace
   ```

## Project Structure

```
├── Sources/           # Swift source files
├── Resources/         # Assets, storyboards, Core Data models
├── Project.swift      # Tuist project manifest
├── Tuist.swift       # Tuist configuration
├── Package.swift     # Swift Package Manager dependencies
└── mise.toml         # Tool versions
```

## Tuist Commands

- `tuist generate` - Generate Xcode project and workspace
- `tuist clean` - Clean generated artifacts
- `tuist edit` - Edit project manifests in Xcode
- `tuist graph` - Visualize project dependencies

## Adding Dependencies

To add external dependencies, edit `Package.swift` and add them to the `dependencies` array, then reference them in `Project.swift` under the target's `dependencies`.

## Development Workflow

1. Make changes to your Swift files in the `Sources/` directory
2. Add resources to the `Resources/` directory
3. Run `tuist generate` to regenerate the project if you modify manifests
4. Use the generated `ToDoList.xcworkspace` for development
