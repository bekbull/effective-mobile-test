# To-Do List iOS App

A modern iOS To-Do List app built with **VIPER architecture**, **Tuist**, **SnapKit**, and **Core Data**.

## Features

- ✅ Display list of tasks on main screen
- ✅ Task contains: title, description, creation date, completion status
- ✅ Add new tasks
- ✅ Edit existing tasks
- ✅ Delete tasks
- ✅ Search through tasks
- ✅ Initial data seeding from DummyJSON API

## Architecture

This project follows **VIPER (View, Interactor, Presenter, Entity, Router)** architecture for clean separation of concerns:

```
Features/
├── TasksList/          # Main tasks list module
│   ├── TasksListViewController.swift
│   ├── TasksListPresenter.swift
│   ├── TasksListInteractor.swift
│   ├── TasksListRouter.swift
│   ├── TasksListProtocols.swift
│   └── TaskTableViewCell.swift
└── TaskEditor/         # Add/Edit task module
    ├── TaskEditorViewController.swift
    ├── TaskEditorPresenter.swift
    ├── TaskEditorInteractor.swift
    ├── TaskEditorRouter.swift
    └── TaskEditorProtocols.swift

Shared/
├── Core/              # Shared utilities
├── Networking/        # API services
│   └── NetworkService.swift
└── Persistence/       # Data layer
    ├── CoreDataStack.swift
    └── TasksRepository.swift
```

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

2. **Install dependencies**:
   ```bash
   tuist install
   ```

3. **Generate the Xcode project**:
   ```bash
   tuist generate
   ```

4. **Open the workspace**:
   ```bash
   open ToDoList.xcworkspace
   ```

## Dependencies

- **SnapKit** - Auto Layout DSL for programmatic UI
- **Core Data** - Local data persistence
- **DummyJSON API** - Initial data seeding

## Project Structure

```
├── Sources/           # App entry points (AppDelegate, SceneDelegate)
├── Features/          # VIPER modules
├── Shared/           # Shared services and utilities
├── Resources/        # Assets, Core Data models
├── Project.swift     # Tuist project manifest
├── Tuist.swift      # Tuist configuration
├── Package.swift    # Swift Package Manager dependencies
└── mise.toml        # Tool versions
```

## Tuist Commands

- `tuist generate` - Generate Xcode project and workspace
- `tuist clean` - Clean generated artifacts
- `tuist edit` - Edit project manifests in Xcode
- `tuist install` - Install dependencies
- `tuist graph` - Visualize project dependencies

## Adding Dependencies

1. Add the dependency to `Package.swift`:
   ```swift
   dependencies: [
       .package(url: "https://github.com/RealmSwift/RealmSwift.git", from: "10.0.0")
   ]
   ```

2. Reference it in `Project.swift`:
   ```swift
   dependencies: [
       .external(name: "RealmSwift")
   ]
   ```

3. Run `tuist generate` to update the project

## Development Workflow

1. Make changes to your Swift files in the appropriate modules
2. Add resources to the `Resources/` directory
3. Run `tuist generate` if you modify manifests or dependencies
4. Use the generated `ToDoList.xcworkspace` for development

## VIPER Flow

1. **View** - UI components (ViewControllers, Cells)
2. **Interactor** - Business logic and data operations
3. **Presenter** - Mediates between View and Interactor
4. **Entity** - Data models (Core Data entities)
5. **Router** - Navigation logic
