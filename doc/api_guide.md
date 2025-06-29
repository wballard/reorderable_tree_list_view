# API Guide

This guide provides detailed information about the ReorderableTreeListView API.

## Table of Contents

- [Core Widget](#core-widget)
- [Properties](#properties)
- [Callbacks](#callbacks)
- [Theme Configuration](#theme-configuration)
- [Selection Management](#selection-management)
- [Keyboard Navigation](#keyboard-navigation)
- [Actions and Intents](#actions-and-intents)
- [Utility Classes](#utility-classes)

## Core Widget

### ReorderableTreeListView

The main widget that displays a hierarchical tree structure with drag-and-drop capabilities.

```dart
ReorderableTreeListView({
  required List<Uri> paths,
  required Widget Function(BuildContext, Uri) itemBuilder,
  Widget Function(BuildContext, Uri)? folderBuilder,
  void Function(Uri, Uri)? onReorder,
  TreeTheme? theme,
  SelectionMode selectionMode = SelectionMode.none,
  bool expandedByDefault = true,
  Set<Uri>? initiallyExpanded,
  bool animateExpansion = true,
  bool enableKeyboardNavigation = true,
  // ... more properties
})
```

## Properties

### Required Properties

#### paths
- **Type**: `List<Uri>`
- **Description**: The list of URI paths to display in the tree
- **Example**:
  ```dart
  paths: [
    Uri.parse('file:///documents/report.pdf'),
    Uri.parse('file:///documents/images/photo.jpg'),
  ]
  ```

#### itemBuilder
- **Type**: `Widget Function(BuildContext context, Uri path)`
- **Description**: Builder function for leaf nodes (files)
- **Example**:
  ```dart
  itemBuilder: (context, path) => Row(
    children: [
      Icon(Icons.insert_drive_file),
      Text(TreePath.getDisplayName(path)),
    ],
  )
  ```

### Optional Properties

#### folderBuilder
- **Type**: `Widget Function(BuildContext context, Uri path)?`
- **Description**: Builder function for folder nodes. If not provided, uses itemBuilder
- **Example**:
  ```dart
  folderBuilder: (context, path) => Row(
    children: [
      Icon(Icons.folder, color: Colors.amber),
      Text(TreePath.getDisplayName(path)),
    ],
  )
  ```

#### theme
- **Type**: `TreeTheme?`
- **Description**: Visual configuration for the tree
- **Default**: Uses default theme or inherits from TreeThemeData

#### selectionMode
- **Type**: `SelectionMode`
- **Description**: Selection behavior for tree items
- **Values**: `SelectionMode.none`, `SelectionMode.single`, `SelectionMode.multiple`
- **Default**: `SelectionMode.none`

#### expandedByDefault
- **Type**: `bool`
- **Description**: Whether folders should be expanded by default
- **Default**: `true`

#### initiallyExpanded
- **Type**: `Set<Uri>?`
- **Description**: Specific paths that should be initially expanded
- **Default**: `null` (uses expandedByDefault)

#### animateExpansion
- **Type**: `bool`
- **Description**: Whether to animate expand/collapse operations
- **Default**: `true`

#### enableKeyboardNavigation
- **Type**: `bool`
- **Description**: Whether to enable keyboard navigation
- **Default**: `true`

#### initialSelection
- **Type**: `Set<Uri>?`
- **Description**: Initially selected paths
- **Default**: `null` (no selection)

#### scrollController
- **Type**: `ScrollController?`
- **Description**: Optional scroll controller for the list view
- **Default**: `null`

#### padding
- **Type**: `EdgeInsetsGeometry?`
- **Description**: Padding around the tree view
- **Default**: `null`

#### physics
- **Type**: `ScrollPhysics?`
- **Description**: Scroll physics for the list view
- **Default**: Platform default

## Callbacks

### Drag and Drop Callbacks

#### onReorder
- **Type**: `void Function(Uri oldPath, Uri newPath)?`
- **Description**: Called when an item is reordered
- **Example**:
  ```dart
  onReorder: (oldPath, newPath) {
    setState(() {
      paths.remove(oldPath);
      paths.add(newPath);
    });
  }
  ```

#### onDragStart
- **Type**: `void Function(Uri path)?`
- **Description**: Called when a drag operation starts
- **Example**:
  ```dart
  onDragStart: (path) {
    print('Started dragging: $path');
  }
  ```

#### onDragEnd
- **Type**: `void Function(Uri path)?`
- **Description**: Called when a drag operation ends
- **Example**:
  ```dart
  onDragEnd: (path) {
    print('Stopped dragging: $path');
  }
  ```

#### onWillAcceptDrop
- **Type**: `bool Function(Uri draggedPath, Uri targetPath)?`
- **Description**: Called to determine if a drop is allowed
- **Example**:
  ```dart
  onWillAcceptDrop: (draggedPath, targetPath) {
    // Don't allow dropping into system folders
    return !targetPath.toString().contains('/system/');
  }
  ```

### Selection Callbacks

#### onSelectionChanged
- **Type**: `void Function(Set<Uri> selection)?`
- **Description**: Called when selection changes
- **Example**:
  ```dart
  onSelectionChanged: (selection) {
    print('Selected ${selection.length} items');
  }
  ```

#### onItemTap
- **Type**: `void Function(Uri path)?`
- **Description**: Called when an item is tapped
- **Example**:
  ```dart
  onItemTap: (path) {
    print('Tapped: $path');
  }
  ```

#### onItemActivated
- **Type**: `void Function(Uri path)?`
- **Description**: Called when an item is activated (double-click or Enter)
- **Example**:
  ```dart
  onItemActivated: (path) {
    openFile(path);
  }
  ```

### Expansion Callbacks

#### onExpandStart
- **Type**: `void Function(Uri path)?`
- **Description**: Called when node expansion starts

#### onExpandEnd
- **Type**: `void Function(Uri path)?`
- **Description**: Called when node expansion completes

#### onCollapseStart
- **Type**: `void Function(Uri path)?`
- **Description**: Called when node collapse starts

#### onCollapseEnd
- **Type**: `void Function(Uri path)?`
- **Description**: Called when node collapse completes

### Validation Callbacks

#### canExpand
- **Type**: `bool Function(Uri path)?`
- **Description**: Determines if a node can be expanded
- **Example**:
  ```dart
  canExpand: (path) => !path.toString().contains('locked'),
  ```

#### canDrag
- **Type**: `bool Function(Uri path)?`
- **Description**: Determines if a node can be dragged
- **Example**:
  ```dart
  canDrag: (path) => !isSystemPath(path),
  ```

#### canDrop
- **Type**: `bool Function(Uri draggedPath, Uri targetPath)?`
- **Description**: Determines if a drop operation is allowed
- **Example**:
  ```dart
  canDrop: (draggedPath, targetPath) {
    // Don't allow dropping folders into their own children
    return !draggedPath.toString().startsWith(targetPath.toString());
  }
  ```

### Context Menu

#### onContextMenu
- **Type**: `void Function(Uri path, Offset globalPosition)?`
- **Description**: Called when right-click context menu is requested
- **Example**:
  ```dart
  onContextMenu: (path, position) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx, position.dy, 
        position.dx, position.dy,
      ),
      items: [
        PopupMenuItem(child: Text('Open')),
        PopupMenuItem(child: Text('Delete')),
      ],
    );
  }
  ```

## Theme Configuration

### TreeTheme

Customize the visual appearance of the tree:

```dart
TreeTheme({
  double indentSize = 32.0,
  bool showConnectors = false,
  Color? connectorColor,
  double connectorWidth = 1.0,
  EdgeInsetsGeometry itemPadding = const EdgeInsets.symmetric(
    horizontal: 12.0, 
    vertical: 8.0,
  ),
  BorderRadius borderRadius = const BorderRadius.all(Radius.circular(4.0)),
  Color? hoverColor,
  Color? focusColor,
  Color? splashColor,
  Color? highlightColor,
})
```

#### Properties

- **indentSize**: Indentation width for each tree level
- **showConnectors**: Whether to show connecting lines
- **connectorColor**: Color of the connecting lines
- **connectorWidth**: Width of the connecting lines
- **itemPadding**: Padding around each item
- **borderRadius**: Border radius for item containers
- **hoverColor**: Color when hovering (desktop)
- **focusColor**: Color when focused
- **splashColor**: Ripple effect color
- **highlightColor**: Highlight color

### TreeThemeData

Inherited widget for providing theme to descendant tree views:

```dart
TreeThemeData(
  theme: TreeTheme(
    indentSize: 40,
    showConnectors: true,
  ),
  child: MyWidget(),
)
```

## Selection Management

### SelectionMode

Enum defining selection behavior:

```dart
enum SelectionMode {
  /// No selection allowed
  none,
  
  /// Single item selection
  single,
  
  /// Multiple item selection
  multiple,
}
```

### Selection Example

```dart
class MyTreeView extends StatefulWidget {
  @override
  State<MyTreeView> createState() => _MyTreeViewState();
}

class _MyTreeViewState extends State<MyTreeView> {
  Set<Uri> selectedPaths = {};

  @override
  Widget build(BuildContext context) {
    return ReorderableTreeListView(
      paths: paths,
      selectionMode: SelectionMode.multiple,
      initialSelection: selectedPaths,
      onSelectionChanged: (selection) {
        setState(() {
          selectedPaths = selection;
        });
      },
      itemBuilder: (context, path) {
        final isSelected = selectedPaths.contains(path);
        return Container(
          color: isSelected ? Colors.blue.withOpacity(0.2) : null,
          child: Text(TreePath.getDisplayName(path)),
        );
      },
    );
  }
}
```

## Keyboard Navigation

### Default Shortcuts

- **Arrow Up/Down**: Navigate between items
- **Arrow Left**: Collapse folder or move to parent
- **Arrow Right**: Expand folder or move to first child
- **Enter**: Activate item (triggers onItemActivated)
- **Space**: Select item (when selection enabled)
- **Ctrl+A**: Select all (when multiple selection enabled)

### Custom Keyboard Shortcuts

```dart
Shortcuts(
  shortcuts: <LogicalKeySet, Intent>{
    LogicalKeySet(LogicalKeyboardKey.delete): DeleteIntent(),
    LogicalKeySet(LogicalKeyboardKey.f2): RenameIntent(),
  },
  child: Actions(
    actions: <Type, Action<Intent>>{
      DeleteIntent: CallbackAction<DeleteIntent>(
        onInvoke: (_) => deleteSelectedItems(),
      ),
      RenameIntent: CallbackAction<RenameIntent>(
        onInvoke: (_) => renameSelectedItem(),
      ),
    },
    child: ReorderableTreeListView(
      paths: paths,
      enableKeyboardNavigation: true,
      itemBuilder: (context, path) => Text(path.toString()),
    ),
  ),
)
```

## Actions and Intents

### Built-in Intents

The widget provides several built-in intents:

- **ExpandNodeIntent**: Expand a tree node
- **CollapseNodeIntent**: Collapse a tree node
- **SelectNodeIntent**: Select a tree node
- **ActivateNodeIntent**: Activate a tree node

### Custom Actions Example

```dart
Actions(
  actions: <Type, Action<Intent>>{
    ExpandNodeIntent: CallbackAction<ExpandNodeIntent>(
      onInvoke: (intent) {
        print('Expanding: ${intent.path}');
        // Custom expansion logic
        return null;
      },
    ),
  },
  child: ReorderableTreeListView(
    paths: paths,
    itemBuilder: (context, path) => Text(path.toString()),
  ),
)
```

## Utility Classes

### TreePath

Static utility methods for working with URI paths:

```dart
class TreePath {
  /// Gets the display name from a URI path
  static String getDisplayName(Uri path);
  
  /// Gets the parent path of a URI
  static Uri? getParentPath(Uri path);
  
  /// Checks if a path is a folder
  static bool isFolder(Uri path);
  
  /// Gets the depth of a path
  static int getDepth(Uri path);
  
  /// Normalizes a path
  static Uri normalize(Uri path);
}
```

### TreeNode

Data model representing a node in the tree:

```dart
class TreeNode {
  final Uri path;
  final int depth;
  final bool isFolder;
  final List<TreeNode> children;
  final Key key;
  
  // Getters
  String get displayName;
  bool get hasChildren;
  Uri? get parentPath;
}
```

### TreeState

Manages the tree's state:

```dart
class TreeState extends ChangeNotifier {
  /// All nodes in the tree
  List<TreeNode> get allNodes;
  
  /// Visible nodes (considering expansion state)
  List<TreeNode> get visibleNodes;
  
  /// Expanded paths
  Set<Uri> get expandedPaths;
  
  /// Selected paths
  Set<Uri> get selectedPaths;
  
  /// Expand a node
  void expand(Uri path);
  
  /// Collapse a node
  void collapse(Uri path);
  
  /// Toggle expansion
  void toggleExpansion(Uri path);
  
  /// Select paths
  void select(Set<Uri> paths);
}
```

## Best Practices

### Performance Optimization

1. **Large Datasets**: Use `expandedByDefault: false` for better initial performance
2. **Custom Keys**: Provide stable keys for items if paths might change
3. **Memoization**: Cache expensive computations in item builders

### Accessibility

1. **Semantic Labels**: Add semantic labels to custom item widgets
2. **Focus Management**: Ensure focusable elements are properly marked
3. **Announcements**: Use `SemanticsService.announce` for dynamic updates

### State Management

1. **Immutable Updates**: Always create new lists when updating paths
2. **Controlled State**: Manage selection and expansion externally
3. **Persistence**: Save expansion/selection state for user convenience

## Examples

### File Explorer

```dart
class FileExplorer extends StatefulWidget {
  @override
  State<FileExplorer> createState() => _FileExplorerState();
}

class _FileExplorerState extends State<FileExplorer> {
  List<Uri> paths = [];
  Set<Uri> selectedPaths = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('File Explorer'),
        actions: [
          IconButton(
            icon: Icon(Icons.create_new_folder),
            onPressed: createNewFolder,
          ),
        ],
      ),
      body: ReorderableTreeListView(
        paths: paths,
        selectionMode: SelectionMode.multiple,
        initialSelection: selectedPaths,
        theme: TreeTheme(
          indentSize: 24,
          showConnectors: false,
        ),
        itemBuilder: (context, path) => FileItem(
          path: path,
          isSelected: selectedPaths.contains(path),
        ),
        folderBuilder: (context, path) => FolderItem(
          path: path,
          isSelected: selectedPaths.contains(path),
        ),
        onReorder: handleReorder,
        onSelectionChanged: (selection) {
          setState(() {
            selectedPaths = selection;
          });
        },
        onItemActivated: openFile,
        onContextMenu: showContextMenu,
      ),
    );
  }
}
```