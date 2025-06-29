# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.1] - 2024-01-15

### Initial Release

#### Features
- 🌳 **Automatic Tree Generation** - Automatically builds tree structure from URI paths
- 🔄 **Drag & Drop Reordering** - Intuitive drag-and-drop functionality with visual feedback
- 📂 **Expand/Collapse** - Animated folder expansion with customizable behavior
- 🎯 **Selection Modes** - Support for none, single, and multiple selection
- ⌨️ **Keyboard Navigation** - Full keyboard support with arrow keys and shortcuts
- ♿ **Accessibility** - Screen reader support and semantic labels
- 🎨 **Theming** - Extensive customization through TreeTheme
- ⚡ **Performance** - Optimized for large datasets with virtualization
- 🔌 **Actions & Intents** - Integration with Flutter's Actions system

#### Core Components
- `ReorderableTreeListView` - Main widget for displaying tree structure
- `TreeTheme` - Customization options for visual appearance
- `TreePath` - Utility class for path operations
- `TreeNode` - Data model for tree nodes
- `TreeState` - State management for tree operations

#### Callbacks
- Drag and drop callbacks (onReorder, onDragStart, onDragEnd)
- Selection callbacks (onSelectionChanged, onItemTap, onItemActivated)
- Expansion callbacks (onExpandStart/End, onCollapseStart/End)
- Validation callbacks (canExpand, canDrag, canDrop)
- Context menu support (onContextMenu)

#### Platform Support
- ✅ iOS
- ✅ Android  
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

#### Examples
- Basic usage example
- Interactive Storybook with all features
- Advanced integration examples
- Performance optimization examples

#### Documentation
- Comprehensive README with quick start guide
- API documentation with examples
- Performance optimization guide
- Contributing guidelines

[0.0.1]: https://github.com/yourusername/reorderable_tree_list_view/releases/tag/v0.0.1