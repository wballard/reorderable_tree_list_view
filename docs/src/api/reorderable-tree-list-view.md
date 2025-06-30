# ReorderableTreeListView API

The `ReorderableTreeListView` is the main widget that displays hierarchical tree data with drag-and-drop reordering capabilities. It automatically generates a complete tree structure from a sparse list of URI paths.

## Constructor

```dart
ReorderableTreeListView({
  required List<Uri> paths,
  required Widget Function(BuildContext, Uri) itemBuilder,
  Key? key,
  TreeTheme? theme,
  Widget Function(BuildContext, Uri)? folderBuilder,
  ScrollController? scrollController,
  Axis scrollDirection = Axis.vertical,
  bool shrinkWrap = false,
  EdgeInsetsGeometry? padding,
  ScrollPhysics? physics,
  bool expandedByDefault = true,
  Set<Uri>? initiallyExpanded,
  bool animateExpansion = true,
  void Function(Uri, Uri)? onReorder,
  void Function(Uri)? onDragStart,
  void Function(Uri)? onDragEnd,
  bool Function(Uri, Uri)? onWillAcceptDrop,
  Widget Function(Widget, int, Animation<double>)? proxyDecorator,
  bool enableDropIndicators = false,
  void Function(String, Uri)? onDropZoneEntered,
  bool enableKeyboardNavigation = true,
  SelectionMode selectionMode = SelectionMode.none,
  Set<Uri>? initialSelection,
  void Function(Set<Uri>)? onSelectionChanged,
  void Function(Uri)? onItemActivated,
  TreeExpandCallback? onExpandStart,
  TreeExpandCallback? onExpandEnd,
  TreeExpandCallback? onCollapseStart,
  TreeExpandCallback? onCollapseEnd,
  TreeItemTapCallback? onItemTap,
  TreeCanExpandCallback? canExpand,
  TreeCanDragCallback? canDrag,
  TreeCanDropCallback? canDrop,
  TreeContextMenuCallback? onContextMenu,
  TreeCanExpandAsyncCallback? canExpandAsync,
  TreeCanDragAsyncCallback? canDragAsync,
  TreeCanDropAsyncCallback? canDropAsync,
})
```

## Required Properties

### paths
**Type:** `List<Uri>`

The sparse list of URI paths to display in the tree. The widget automatically generates intermediate folder nodes from these paths.

```dart
final paths = [
  Uri.parse('file:///documents/work/report.pdf'),
  Uri.parse('file:///documents/personal/photo.jpg'),
  Uri.parse('file:///downloads/app.zip'),
];
```

### itemBuilder
**Type:** `Widget Function(BuildContext context, Uri path)`

Builds widgets for leaf nodes (files). This function is called for each file item in the tree.

```dart
itemBuilder: (context, path) {
  final name = TreePath.getDisplayName(path);
  return Row(
    children: [
      Icon(Icons.insert_drive_file, size: 20),
      SizedBox(width: 8),
      Text(name),
    ],
  );
}
```

## Optional Properties

### theme
**Type:** `TreeTheme?`
**Default:** `null`

Optional theme configuration for the tree view. If provided, this theme will be applied to all tree items. If not provided, items will use the default theme or inherit from an ancestor `TreeThemeData`.

```dart
theme: TreeTheme(
  indentSize: 32.0,
  expandIconSize: 20.0,
  itemPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  borderRadius: BorderRadius.circular(8),
  hoverColor: Colors.grey.shade100,
)
```

### folderBuilder
**Type:** `Widget Function(BuildContext context, Uri path)?`
**Default:** Uses `itemBuilder`

Builds widgets for folder nodes. If not provided, uses the `itemBuilder` function.

```dart
folderBuilder: (context, path) {
  final name = TreePath.getDisplayName(path);
  return Row(
    children: [
      Icon(Icons.folder, size: 20, color: Colors.amber),
      SizedBox(width: 8),
      Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
    ],
  );
}
```

## Scroll Properties

### scrollController
**Type:** `ScrollController?`
**Default:** `null`

An optional scroll controller for the list view. Useful for programmatic scrolling or listening to scroll events.

### scrollDirection
**Type:** `Axis`
**Default:** `Axis.vertical`

The axis along which the list view scrolls.

### shrinkWrap
**Type:** `bool`
**Default:** `false`

Whether the list view should shrink-wrap its contents.

### padding
**Type:** `EdgeInsetsGeometry?`
**Default:** `null`

The amount of space by which to inset the list view.

### physics
**Type:** `ScrollPhysics?`
**Default:** `null`

How the list view should respond to user input.

## Expansion Properties

### expandedByDefault
**Type:** `bool`
**Default:** `true`

Whether folders should be expanded by default. If `true`, all folder nodes start in the expanded state. If `false`, all folder nodes start collapsed.

### initiallyExpanded
**Type:** `Set<Uri>?`
**Default:** `null`

A set of paths that should be initially expanded, regardless of `expandedByDefault`. If provided, the specified paths will be expanded while others follow `expandedByDefault`.

```dart
initiallyExpanded: {
  Uri.parse('file:///documents'),
  Uri.parse('file:///documents/work'),
}
```

### animateExpansion
**Type:** `bool`
**Default:** `true`

Whether to animate expansion and collapse operations. If `true`, expanding and collapsing folders will be animated. If `false`, changes will be immediate.

## Drag and Drop Properties

### onReorder
**Type:** `void Function(Uri oldPath, Uri newPath)?`
**Default:** `null`

Called when an item is reordered via drag and drop. Provides the old path and new path of the moved item.

```dart
onReorder: (oldPath, newPath) {
  setState(() {
    paths.remove(oldPath);
    paths.add(newPath);
  });
}
```

### onDragStart
**Type:** `void Function(Uri path)?`
**Default:** `null`

Called when a drag operation starts. Provides the path of the item being dragged.

### onDragEnd
**Type:** `void Function(Uri path)?`
**Default:** `null`

Called when a drag operation ends. Provides the path of the item that was being dragged.

### onWillAcceptDrop
**Type:** `bool Function(Uri draggedPath, Uri targetPath)?`
**Default:** `null`

Called to determine if a drop is allowed. Return `false` to prevent the drop operation.

```dart
onWillAcceptDrop: (draggedPath, targetPath) {
  // Don't allow dropping into certain folders
  return !targetPath.path.contains('locked');
}
```

### proxyDecorator
**Type:** `Widget Function(Widget child, int index, Animation<double> animation)?`
**Default:** `null`

Custom decoration for the item being dragged. If not provided, uses the default Material elevation.

### enableDropIndicators
**Type:** `bool`
**Default:** `false`

Whether to show drop indicators during drag operations.

### onDropZoneEntered
**Type:** `void Function(String type, Uri path)?`
**Default:** `null`

Called when the drag enters a drop zone. Provides the type of drop zone ('folder' or 'sibling') and target path.

## Selection Properties

### enableKeyboardNavigation
**Type:** `bool`
**Default:** `true`

Whether to enable keyboard navigation for the tree view.

### selectionMode
**Type:** `SelectionMode`
**Default:** `SelectionMode.none`

The selection mode for the tree view. Can be:
- `SelectionMode.none` - No selection allowed
- `SelectionMode.single` - Only one item can be selected
- `SelectionMode.multiple` - Multiple items can be selected

### initialSelection
**Type:** `Set<Uri>?`
**Default:** `null`

The initial selection when the tree view is first displayed.

### onSelectionChanged
**Type:** `void Function(Set<Uri> selection)?`
**Default:** `null`

Called when the selection changes.

```dart
onSelectionChanged: (selection) {
  print('Selected ${selection.length} items');
}
```

## Interaction Callbacks

### onItemActivated
**Type:** `void Function(Uri path)?`
**Default:** `null`

Called when an item is activated (e.g., double-clicked or Enter pressed).

```dart
onItemActivated: (path) {
  print('Activated: ${TreePath.getDisplayName(path)}');
}
```

### onItemTap
**Type:** `TreeItemTapCallback?`
**Default:** `null`

Called when an item is tapped.

### onContextMenu
**Type:** `TreeContextMenuCallback?`
**Default:** `null`

Called when right-click context menu is requested.

```dart
onContextMenu: (path, position) {
  showMenu(
    context: context,
    position: RelativeRect.fromLTRB(
      position.dx, position.dy, position.dx, position.dy,
    ),
    items: [
      PopupMenuItem(child: Text('Open'), value: 'open'),
      PopupMenuItem(child: Text('Delete'), value: 'delete'),
    ],
  );
}
```

## Expansion Callbacks

### onExpandStart
**Type:** `TreeExpandCallback?`
**Default:** `null`

Called when node expansion starts.

### onExpandEnd
**Type:** `TreeExpandCallback?`
**Default:** `null`

Called when node expansion completes.

### onCollapseStart
**Type:** `TreeExpandCallback?`
**Default:** `null`

Called when node collapse starts.

### onCollapseEnd
**Type:** `TreeExpandCallback?`
**Default:** `null`

Called when node collapse completes.

## Validation Callbacks

### canExpand
**Type:** `TreeCanExpandCallback?`
**Default:** `null`

Callback to determine if a node can be expanded. Return `false` to prevent expansion.

```dart
canExpand: (path) {
  // Don't allow expansion of empty folders
  return hasChildren(path);
}
```

### canDrag
**Type:** `TreeCanDragCallback?`
**Default:** `null`

Callback to determine if a node can be dragged. Return `false` to prevent dragging.

```dart
canDrag: (path) {
  // Don't allow dragging system files
  return !path.path.contains('system');
}
```

### canDrop
**Type:** `TreeCanDropCallback?`
**Default:** `null`

Callback to determine if a drop is allowed. Return `false` to prevent the drop.

## Async Validation Callbacks

### canExpandAsync
**Type:** `TreeCanExpandAsyncCallback?`
**Default:** `null`

Async callback to determine if a node can be expanded. Useful for validation that requires async operations.

### canDragAsync
**Type:** `TreeCanDragAsyncCallback?`
**Default:** `null`

Async callback to determine if a node can be dragged. Useful for validation that requires async operations.

### canDropAsync
**Type:** `TreeCanDropAsyncCallback?`
**Default:** `null`

Async callback to determine if a drop is allowed. Useful for validation that requires async operations.

## Typedef Definitions

The following typedefs are used throughout the API:

```dart
/// Callback for expansion-related events
typedef TreeExpandCallback = void Function(Uri path);

/// Callback for item tap events
typedef TreeItemTapCallback = void Function(Uri path);

/// Callback to determine if a node can be expanded
typedef TreeCanExpandCallback = bool Function(Uri path);

/// Callback to determine if a node can be dragged
typedef TreeCanDragCallback = bool Function(Uri path);

/// Callback to determine if a drop is allowed
typedef TreeCanDropCallback = bool Function(Uri draggedPath, Uri targetPath);

/// Callback for context menu events
typedef TreeContextMenuCallback = void Function(Uri path, Offset globalPosition);

/// Async callback to determine if a node can be expanded
typedef TreeCanExpandAsyncCallback = Future<bool> Function(Uri path);

/// Async callback to determine if a node can be dragged
typedef TreeCanDragAsyncCallback = Future<bool> Function(Uri path);

/// Async callback to determine if a drop is allowed
typedef TreeCanDropAsyncCallback = Future<bool> Function(Uri draggedPath, Uri targetPath);
```

## Usage Examples

### Basic Usage

```dart
ReorderableTreeListView(
  paths: [
    Uri.parse('file:///documents/report.pdf'),
    Uri.parse('file:///documents/images/photo.jpg'),
  ],
  itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
)
```

### With Drag and Drop

```dart
ReorderableTreeListView(
  paths: paths,
  itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
  onReorder: (oldPath, newPath) {
    setState(() {
      paths.remove(oldPath);
      paths.add(newPath);
    });
  },
)
```

### With Selection

```dart
ReorderableTreeListView(
  paths: paths,
  selectionMode: SelectionMode.multiple,
  onSelectionChanged: (selection) {
    setState(() {
      selectedPaths = selection;
    });
  },
  itemBuilder: (context, path) {
    final isSelected = selectedPaths.contains(path);
    return Container(
      color: isSelected ? Colors.blue.shade100 : null,
      child: Text(TreePath.getDisplayName(path)),
    );
  },
)
```

### With Custom Theme

```dart
ReorderableTreeListView(
  paths: paths,
  theme: TreeTheme(
    indentSize: 40,
    expandIconSize: 24,
    itemPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    borderRadius: BorderRadius.circular(8),
    hoverColor: Colors.grey.shade100,
  ),
  itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
)
```

## See Also

- [TreeTheme](./tree-theme.md) - Theme configuration options
- [TreePath](./tree-path.md) - Path utilities
- [Selection](../features/selection.md) - Selection modes and handling
- [Drag and Drop](../features/drag-and-drop.md) - Drag and drop features