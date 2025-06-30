# Basic Example

This step-by-step tutorial will walk you through creating your first ReorderableTreeListView from scratch.

## Project Setup

Create a new Flutter project:

```bash
flutter create tree_example
cd tree_example
```

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  reorderable_tree_list_view: ^0.0.1
```

Run `flutter pub get` to install the package.

## Step 1: Simple Tree Structure

Replace the contents of `lib/main.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tree Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: BasicTreeExample(),
    );
  }
}

class BasicTreeExample extends StatefulWidget {
  @override
  State<BasicTreeExample> createState() => _BasicTreeExampleState();
}

class _BasicTreeExampleState extends State<BasicTreeExample> {
  // Define your file structure using URI paths
  List<Uri> paths = [
    Uri.parse('file:///project/README.md'),
    Uri.parse('file:///project/pubspec.yaml'),
    Uri.parse('file:///project/lib/main.dart'),
    Uri.parse('file:///project/lib/widgets/button.dart'),
    Uri.parse('file:///project/lib/widgets/card.dart'),
    Uri.parse('file:///project/test/widget_test.dart'),
    Uri.parse('file:///project/assets/images/logo.png'),
    Uri.parse('file:///project/assets/fonts/custom.ttf'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Basic Tree Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ReorderableTreeListView(
        paths: paths,
        itemBuilder: (context, path) {
          final name = TreePath.getDisplayName(path);
          return Row(
            children: [
              Icon(_getFileIcon(name), size: 20, color: _getFileColor(name)),
              SizedBox(width: 8),
              Text(name),
            ],
          );
        },
        folderBuilder: (context, path) {
          final name = TreePath.getDisplayName(path);
          return Row(
            children: [
              Icon(Icons.folder, size: 20, color: Colors.amber),
              SizedBox(width: 8),
              Text(
                name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _getFileIcon(String name) {
    if (name.endsWith('.dart')) return Icons.code;
    if (name.endsWith('.yaml') || name.endsWith('.yml')) return Icons.settings;
    if (name.endsWith('.md')) return Icons.description;
    if (name.endsWith('.png') || name.endsWith('.jpg')) return Icons.image;
    if (name.endsWith('.ttf') || name.endsWith('.otf')) return Icons.font_download;
    return Icons.insert_drive_file;
  }

  Color _getFileColor(String name) {
    if (name.endsWith('.dart')) return Colors.blue;
    if (name.endsWith('.yaml') || name.endsWith('.yml')) return Colors.orange;
    if (name.endsWith('.md')) return Colors.green;
    if (name.endsWith('.png') || name.endsWith('.jpg')) return Colors.purple;
    if (name.endsWith('.ttf') || name.endsWith('.otf')) return Colors.brown;
    return Colors.grey;
  }
}
```

Run the app:

```bash
flutter run
```

You should see a file tree with folders and files organized automatically!

## Step 2: Adding Drag and Drop

Let's add reordering functionality. Update the `ReorderableTreeListView` widget:

```dart
ReorderableTreeListView(
  paths: paths,
  itemBuilder: (context, path) {
    // ... existing itemBuilder code
  },
  folderBuilder: (context, path) {
    // ... existing folderBuilder code
  },
  onReorder: (Uri oldPath, Uri newPath) {
    setState(() {
      // Remove the item from its old position
      paths.remove(oldPath);
      // Add it to the new position  
      paths.add(newPath);
    });
    
    // Optional: Show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Moved ${TreePath.getDisplayName(oldPath)}'),
        duration: Duration(seconds: 2),
      ),
    );
  },
)
```

Now you can drag and drop items to reorder them!

## Step 3: Adding Visual Polish

Let's improve the appearance with custom styling:

```dart
ReorderableTreeListView(
  paths: paths,
  theme: TreeTheme(
    indentSize: 32.0,                    // Indentation per level
    expandIconSize: 20.0,                // Size of expand/collapse icons
    itemPadding: EdgeInsets.symmetric(   // Padding for each item
      horizontal: 12.0,
      vertical: 6.0,
    ),
    borderRadius: BorderRadius.circular(8.0), // Rounded corners
    hoverColor: Colors.grey.shade100,          // Hover effect
  ),
  itemBuilder: (context, path) {
    final name = TreePath.getDisplayName(path);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.0),
        color: Colors.transparent,
      ),
      child: Row(
        children: [
          Icon(_getFileIcon(name), size: 18, color: _getFileColor(name)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  },
  folderBuilder: (context, path) {
    final name = TreePath.getDisplayName(path);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.0),
        color: Colors.transparent,
      ),
      child: Row(
        children: [
          Icon(Icons.folder, size: 18, color: Colors.amber.shade700),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  },
  onReorder: (oldPath, newPath) {
    setState(() {
      paths.remove(oldPath);
      paths.add(newPath);
    });
  },
)
```

## Step 4: Adding Interaction

Let's add tap handling to open files:

```dart
class _BasicTreeExampleState extends State<BasicTreeExample> {
  List<Uri> paths = [...]; // Your existing paths
  String? lastOpenedFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Basic Tree Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          if (lastOpenedFile != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              color: Colors.blue.shade50,
              child: Text(
                'Last opened: $lastOpenedFile',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          Expanded(
            child: ReorderableTreeListView(
              paths: paths,
              // ... your existing theme and builders
              onItemActivated: (Uri path) {
                // Called when user double-taps or presses Enter
                final name = TreePath.getDisplayName(path);
                setState(() {
                  lastOpenedFile = name;
                });
              },
              onReorder: (oldPath, newPath) {
                setState(() {
                  paths.remove(oldPath);
                  paths.add(newPath);
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

## Step 5: Adding Context Menus

Finally, let's add right-click context menus:

```dart
ReorderableTreeListView(
  paths: paths,
  // ... your existing configuration
  onContextMenu: (Uri path, Offset position) {
    _showContextMenu(context, path, position);
  },
)

// Add this method to your _BasicTreeExampleState class:
void _showContextMenu(BuildContext context, Uri path, Offset position) {
  final name = TreePath.getDisplayName(path);
  
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
        value: 'open',
        child: Row(
          children: [
            Icon(Icons.open_in_new, size: 18),
            SizedBox(width: 8),
            Text('Open'),
          ],
        ),
      ),
      PopupMenuItem(
        value: 'rename',
        child: Row(
          children: [
            Icon(Icons.edit, size: 18),
            SizedBox(width: 8),
            Text('Rename'),
          ],
        ),
      ),
      PopupMenuDivider(),
      PopupMenuItem(
        value: 'delete',
        child: Row(
          children: [
            Icon(Icons.delete, size: 18, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    ],
  ).then((value) {
    if (value != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$value: $name'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  });
}
```

## Complete Example

Here's the complete code with all features:

```dart
import 'package:flutter/material.dart';
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tree Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: BasicTreeExample(),
    );
  }
}

class BasicTreeExample extends StatefulWidget {
  @override
  State<BasicTreeExample> createState() => _BasicTreeExampleState();
}

class _BasicTreeExampleState extends State<BasicTreeExample> {
  List<Uri> paths = [
    Uri.parse('file:///project/README.md'),
    Uri.parse('file:///project/pubspec.yaml'),
    Uri.parse('file:///project/lib/main.dart'),
    Uri.parse('file:///project/lib/widgets/button.dart'),
    Uri.parse('file:///project/lib/widgets/card.dart'),
    Uri.parse('file:///project/test/widget_test.dart'),
    Uri.parse('file:///project/assets/images/logo.png'),
    Uri.parse('file:///project/assets/fonts/custom.ttf'),
  ];

  String? lastOpenedFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Basic Tree Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          if (lastOpenedFile != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              color: Colors.blue.shade50,
              child: Text(
                'Last opened: $lastOpenedFile',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          Expanded(
            child: ReorderableTreeListView(
              paths: paths,
              theme: TreeTheme(
                indentSize: 32.0,
                expandIconSize: 20.0,
                itemPadding: EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 6.0,
                ),
                borderRadius: BorderRadius.circular(8.0),
                hoverColor: Colors.grey.shade100,
              ),
              itemBuilder: (context, path) {
                final name = TreePath.getDisplayName(path);
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.0),
                    color: Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Icon(_getFileIcon(name), size: 18, color: _getFileColor(name)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          name,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                );
              },
              folderBuilder: (context, path) {
                final name = TreePath.getDisplayName(path);
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.0),
                    color: Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.folder, size: 18, color: Colors.amber.shade700),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          name,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              onItemActivated: (Uri path) {
                final name = TreePath.getDisplayName(path);
                setState(() {
                  lastOpenedFile = name;
                });
              },
              onContextMenu: (Uri path, Offset position) {
                _showContextMenu(context, path, position);
              },
              onReorder: (oldPath, newPath) {
                setState(() {
                  paths.remove(oldPath);
                  paths.add(newPath);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String name) {
    if (name.endsWith('.dart')) return Icons.code;
    if (name.endsWith('.yaml') || name.endsWith('.yml')) return Icons.settings;
    if (name.endsWith('.md')) return Icons.description;
    if (name.endsWith('.png') || name.endsWith('.jpg')) return Icons.image;
    if (name.endsWith('.ttf') || name.endsWith('.otf')) return Icons.font_download;
    return Icons.insert_drive_file;
  }

  Color _getFileColor(String name) {
    if (name.endsWith('.dart')) return Colors.blue;
    if (name.endsWith('.yaml') || name.endsWith('.yml')) return Colors.orange;
    if (name.endsWith('.md')) return Colors.green;
    if (name.endsWith('.png') || name.endsWith('.jpg')) return Colors.purple;
    if (name.endsWith('.ttf') || name.endsWith('.otf')) return Colors.brown;
    return Colors.grey;
  }

  void _showContextMenu(BuildContext context, Uri path, Offset position) {
    final name = TreePath.getDisplayName(path);
    
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
          value: 'open',
          child: Row(
            children: [
              Icon(Icons.open_in_new, size: 18),
              SizedBox(width: 8),
              Text('Open'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'rename',
          child: Row(
            children: [
              Icon(Icons.edit, size: 18),
              SizedBox(width: 8),
              Text('Rename'),
            ],
          ),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 18, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$value: $name'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }
}
```

## Next Steps

Now that you have a working tree view, you can:

1. **Add more data** - Expand your URI list with more files and folders
2. **Customize styling** - Explore [Theming](../customization/theming.md) options
3. **Add keyboard navigation** - Enable [Keyboard Navigation](../features/keyboard-navigation.md)
4. **Implement selection** - Add [Selection Modes](../features/selection.md)
5. **Learn advanced features** - Explore [Actions and Intents](../features/actions-intents.md)

## Troubleshooting

**Tree not showing**: Make sure your URIs have a valid scheme (like `file://`)

**Items not reordering**: Ensure you're calling `setState()` in your `onReorder` callback

**Icons not showing**: Check that you're importing `package:flutter/material.dart`

Continue to the [Drag and Drop](../features/drag-and-drop.md) guide to learn more about reordering features.