# ReorderableTreeListView

A Flutter widget that provides a tree view with drag-and-drop reordering capabilities, built on top of Flutter's ReorderableListView.

## Features

- 🌳 **Tree Structure**: Display hierarchical data using URI-based paths
- 🔄 **Drag & Drop**: Reorder items within the tree with intuitive drag-and-drop
- 📱 **Material Design**: Follows Material Design guidelines with Material 3 support
- ⚡ **Performance**: Efficient rendering for large datasets
- 🎨 **Customizable**: Flexible builder pattern for custom node widgets
- ♿ **Accessible**: Full keyboard navigation and screen reader support

## How It Works

ReorderableTreeListView uses a unique approach where you provide a list of URI paths, and the widget automatically:
- Generates the tree structure
- Creates intermediate folder nodes for sparse paths
- Handles indentation and visual hierarchy
- Manages expand/collapse state
- Enables drag-and-drop reordering

## Getting Started

```dart
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

// Example usage coming soon
```

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  reorderable_tree_list_view: ^0.0.1
```

## Example

See the `example` directory for a complete sample application.

## License

This project is licensed under the MIT License - see the LICENSE file for details.