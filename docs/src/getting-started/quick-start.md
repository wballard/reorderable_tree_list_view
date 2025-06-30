# Quick Start

This guide will help you create your first ReorderableTreeListView in just a few minutes.

## Basic Tree View

Let's start with a simple tree view displaying a file structure:

```dart
import 'package:flutter/material.dart';
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

class SimpleTreeExample extends StatefulWidget {
  @override
  State<SimpleTreeExample> createState() => _SimpleTreeExampleState();
}

class _SimpleTreeExampleState extends State<SimpleTreeExample> {
  // Define your tree structure using URI paths
  List<Uri> paths = [
    Uri.parse('file:///project/README.md'),
    Uri.parse('file:///project/pubspec.yaml'),
    Uri.parse('file:///project/lib/main.dart'),
    Uri.parse('file:///project/lib/widgets/button.dart'),
    Uri.parse('file:///project/lib/widgets/card.dart'),
    Uri.parse('file:///project/test/widget_test.dart'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Simple Tree View'),
      ),
      body: ReorderableTreeListView(
        paths: paths,
        itemBuilder: (context, path) {
          // Build widgets for file items
          final name = TreePath.getDisplayName(path);
          return Row(
            children: [
              Icon(Icons.insert_drive_file, size: 20),
              SizedBox(width: 8),
              Text(name),
            ],
          );
        },
        folderBuilder: (context, path) {
          // Build widgets for folder items
          final name = TreePath.getDisplayName(path);
          return Row(
            children: [
              Icon(Icons.folder, size: 20, color: Colors.amber),
              SizedBox(width: 8),
              Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          );
        },
      ),
    );
  }
}
```

## Adding Drag and Drop

Enable reordering by adding an `onReorder` callback:

```dart
ReorderableTreeListView(
  paths: paths,
  itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
  onReorder: (oldPath, newPath) {
    setState(() {
      // Remove the item from its old position
      paths.remove(oldPath);
      // Add it to the new position
      paths.add(newPath);
    });
  },
)
```

## Customizing Appearance

Add visual customization with TreeTheme:

```dart
ReorderableTreeListView(
  paths: paths,
  theme: TreeTheme(
    indentSize: 40,                    // Indentation per level
    expandIconSize: 24,                // Size of expand/collapse icons
    itemPadding: EdgeInsets.symmetric( // Padding for each item
      horizontal: 16,
      vertical: 8,
    ),
    borderRadius: BorderRadius.circular(8), // Rounded corners
    hoverColor: Colors.grey.shade200,       // Hover effect color
  ),
  itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
)
```

## Managing Expansion State

Control which folders are expanded:

```dart
class ExpandableTreeExample extends StatefulWidget {
  @override
  State<ExpandableTreeExample> createState() => _ExpandableTreeExampleState();
}

class _ExpandableTreeExampleState extends State<ExpandableTreeExample> {
  List<Uri> paths = [...]; // Your paths
  Set<Uri> expandedPaths = {};

  @override
  Widget build(BuildContext context) {
    return ReorderableTreeListView(
      paths: paths,
      expandedByDefault: false, // Start with all folders collapsed
      initiallyExpanded: expandedPaths,
      onExpandStart: (path) {
        setState(() {
          expandedPaths.add(path);
        });
      },
      onCollapseStart: (path) {
        setState(() {
          expandedPaths.remove(path);
        });
      },
      itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
    );
  }
}
```

## Adding Selection

Enable item selection with different modes:

```dart
class SelectableTreeExample extends StatefulWidget {
  @override
  State<SelectableTreeExample> createState() => _SelectableTreeExampleState();
}

class _SelectableTreeExampleState extends State<SelectableTreeExample> {
  List<Uri> paths = [...]; // Your paths
  Set<Uri> selectedPaths = {};

  @override
  Widget build(BuildContext context) {
    return ReorderableTreeListView(
      paths: paths,
      selectionMode: SelectionMode.multiple, // or .single, .none
      initialSelection: selectedPaths,
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
    );
  }
}
```

## Complete Example

Here's a complete example combining all features:

```dart
import 'package:flutter/material.dart';
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

class CompleteTreeExample extends StatefulWidget {
  @override
  State<CompleteTreeExample> createState() => _CompleteTreeExampleState();
}

class _CompleteTreeExampleState extends State<CompleteTreeExample> {
  List<Uri> paths = [
    Uri.parse('file:///documents/work/report.pdf'),
    Uri.parse('file:///documents/work/presentation.pptx'),
    Uri.parse('file:///documents/personal/photos/vacation.jpg'),
    Uri.parse('file:///documents/personal/photos/family.jpg'),
    Uri.parse('file:///downloads/app.zip'),
    Uri.parse('file:///downloads/music/song.mp3'),
  ];
  
  Set<Uri> selectedPaths = {};
  String? lastAction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complete Tree Example'),
        actions: [
          if (selectedPaths.isNotEmpty)
            Chip(
              label: Text('${selectedPaths.length} selected'),
              onDeleted: () {
                setState(() {
                  selectedPaths.clear();
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          if (lastAction != null)
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.blue.shade100,
              child: Text('Last action: $lastAction'),
            ),
          Expanded(
            child: ReorderableTreeListView(
              paths: paths,
              theme: TreeTheme(
                indentSize: 32,
                expandIconSize: 20,
                itemPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
              ),
              selectionMode: SelectionMode.multiple,
              initialSelection: selectedPaths,
              enableKeyboardNavigation: true,
              
              // Builders
              itemBuilder: (context, path) {
                final name = TreePath.getDisplayName(path);
                final isSelected = selectedPaths.contains(path);
                
                return Container(
                  decoration: BoxDecoration(
                    color: isSelected 
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : null,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getFileIcon(name),
                        size: 16,
                        color: _getFileColor(name),
                      ),
                      SizedBox(width: 8),
                      Expanded(child: Text(name)),
                    ],
                  ),
                );
              },
              
              folderBuilder: (context, path) {
                final name = TreePath.getDisplayName(path);
                final isSelected = selectedPaths.contains(path);
                
                return Container(
                  decoration: BoxDecoration(
                    color: isSelected 
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : null,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.folder, size: 16, color: Colors.amber),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              },
              
              // Callbacks
              onReorder: (oldPath, newPath) {
                setState(() {
                  paths.remove(oldPath);
                  paths.add(newPath);
                  lastAction = 'Moved ${TreePath.getDisplayName(oldPath)}';
                });
              },
              
              onSelectionChanged: (selection) {
                setState(() {
                  selectedPaths = selection;
                });
              },
              
              onItemActivated: (path) {
                setState(() {
                  lastAction = 'Activated ${TreePath.getDisplayName(path)}';
                });
              },
              
              onContextMenu: (path, position) {
                // Show context menu
                _showContextMenu(context, path, position);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getFileIcon(String name) {
    if (name.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (name.endsWith('.jpg') || name.endsWith('.png')) return Icons.image;
    if (name.endsWith('.mp3')) return Icons.music_note;
    if (name.endsWith('.zip')) return Icons.archive;
    return Icons.insert_drive_file;
  }
  
  Color _getFileColor(String name) {
    if (name.endsWith('.pdf')) return Colors.red;
    if (name.endsWith('.jpg') || name.endsWith('.png')) return Colors.green;
    if (name.endsWith('.mp3')) return Colors.purple;
    if (name.endsWith('.zip')) return Colors.orange;
    return Colors.grey;
  }
  
  void _showContextMenu(BuildContext context, Uri path, Offset position) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: [
        PopupMenuItem(
          child: Text('Open'),
          value: 'open',
        ),
        PopupMenuItem(
          child: Text('Rename'),
          value: 'rename',
        ),
        PopupMenuItem(
          child: Text('Delete'),
          value: 'delete',
        ),
      ],
    ).then((value) {
      if (value != null) {
        setState(() {
          lastAction = '$value ${TreePath.getDisplayName(path)}';
        });
      }
    });
  }
}
```

## Next Steps

Now you have a fully functional tree view! Here's what to explore next:

- [Basic Example](./basic-example.md) - Step-by-step tutorial
- [Drag and Drop](../features/drag-and-drop.md) - Advanced drag and drop features
- [Keyboard Navigation](../features/keyboard-navigation.md) - Keyboard shortcuts
- [Theming](../customization/theming.md) - Visual customization options

## Tips

1. **Performance**: For large datasets (1000+ items), consider using `expandedByDefault: false`
2. **URIs**: Use consistent URI schemes for better organization
3. **State Management**: Consider using a state management solution for complex apps
4. **Accessibility**: Always provide meaningful labels for screen readers