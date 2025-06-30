# ReorderableTreeListView

Welcome to the official documentation for ReorderableTreeListView - a high-performance Flutter widget that displays hierarchical data in a tree structure with drag-and-drop reordering capabilities.

## What is ReorderableTreeListView?

ReorderableTreeListView is a Flutter package that combines the power of tree data structures with the intuitive drag-and-drop functionality of Flutter's ReorderableListView. It's designed to handle complex hierarchical data while maintaining excellent performance and user experience.

## Key Features

### 🌳 Automatic Tree Generation
Simply provide URI paths, and the widget automatically builds the complete tree structure, including intermediate folders.

### 🔄 Drag & Drop Reordering
Intuitive drag-and-drop interface with visual feedback, automatic validation, and smooth animations.

### 📂 Expand/Collapse Functionality
Animated folder expansion with customizable animations and persistent state management.

### 🎯 Flexible Selection Modes
Support for none, single, and multiple selection modes with keyboard modifiers.

### ⌨️ Comprehensive Keyboard Navigation
Full keyboard support including arrow navigation, expand/collapse shortcuts, and customizable key bindings.

### ♿ Accessibility First
Built with accessibility in mind, featuring screen reader support and semantic labels.

### 🎨 Highly Customizable
Extensive theming options, custom item builders, and flexible visual customization.

### ⚡ Performance Optimized
Efficient rendering engine optimized for large datasets with thousands of nodes.

### 🔌 Modern Architecture
Integration with Flutter's Actions and Intents system for advanced customization.

### 📱 Cross-Platform
Works seamlessly on iOS, Android, Web, and Desktop platforms.

## When to Use ReorderableTreeListView

This widget is perfect for:

- **File Explorers** - Display and manage file system hierarchies
- **Project Navigators** - IDE-style project file trees
- **Settings Pages** - Hierarchical configuration interfaces
- **Organization Charts** - Display company or team structures
- **Category Trees** - E-commerce product categorization
- **Menu Systems** - Multi-level navigation menus
- **Any Hierarchical Data** - Wherever you need to display tree-structured information

## Design Philosophy

ReorderableTreeListView is built on several core principles:

1. **Simplicity First** - Easy to use with sensible defaults
2. **Flexibility When Needed** - Extensive customization options available
3. **Performance at Scale** - Optimized for large datasets
4. **Accessibility by Default** - Inclusive design for all users
5. **Modern Flutter Patterns** - Uses latest Flutter best practices

## Quick Example

Here's a simple example to get you started:

```dart
ReorderableTreeListView(
  paths: [
    Uri.parse('file:///documents/report.pdf'),
    Uri.parse('file:///documents/images/photo.jpg'),
    Uri.parse('file:///downloads/app.zip'),
  ],
  itemBuilder: (context, path) => Text(
    TreePath.getDisplayName(path),
  ),
  onReorder: (oldPath, newPath) {
    // Handle reordering
  },
)
```

## Getting Help

- 📖 **This Documentation** - Comprehensive guides and API reference
- 💡 **Example App** - Interactive examples with source code
- 🐛 **Issue Tracker** - Report bugs and request features
- 💬 **Discussions** - Ask questions and share ideas

## Next Steps

Ready to get started? Head to the [Installation](./getting-started/installation.md) guide to add ReorderableTreeListView to your project.

For a hands-on introduction, check out our [Quick Start](./getting-started/quick-start.md) tutorial.