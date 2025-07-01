# Drag and Drop

ReorderableTreeListView provides powerful drag-and-drop capabilities that allow users to intuitively reorder tree items with visual feedback and comprehensive customization options.

## Basic Drag and Drop

Enable drag and drop by providing an `onReorder` callback:

```dart
ReorderableTreeListView(
  paths: paths,
  itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
  onReorder: (Uri oldPath, Uri newPath) {
    setState(() {
      // Remove the item from its old position
      paths.remove(oldPath);
      // Add it to the new position
      paths.add(newPath);
    });
  },
)
```

Without an `onReorder` callback, items cannot be dragged.

## Drag Lifecycle Events

Monitor the complete drag lifecycle with these callbacks:

```dart
ReorderableTreeListView(
  paths: paths,
  itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
  
  // Drag lifecycle events
  onDragStart: (Uri path) {
    print('Started dragging: ${TreePath.getDisplayName(path)}');
    // Optional: Show visual feedback, disable other interactions
  },
  
  onDragEnd: (Uri path) {
    print('Finished dragging: ${TreePath.getDisplayName(path)}');
    // Optional: Clean up, re-enable interactions
  },
  
  onReorder: (oldPath, newPath) {
    setState(() {
      paths.remove(oldPath);
      paths.add(newPath);
    });
    print('Moved ${TreePath.getDisplayName(oldPath)} to new location');
  },
)
```

## Drop Validation

Control which drops are allowed with validation callbacks:

### Synchronous Validation

```dart
ReorderableTreeListView(
  paths: paths,
  itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
  
  // Prevent dropping into certain folders
  onWillAcceptDrop: (Uri draggedPath, Uri targetPath) {
    // Don't allow dropping into the "system" folder
    if (targetPath.path.contains('/system/')) {
      return false;
    }
    
    // Don't allow dropping a folder into itself
    if (TreePath.isAncestorOf(draggedPath, targetPath)) {
      return false;
    }
    
    return true;
  },
  
  canDrop: (Uri draggedPath, Uri targetPath) {
    // Additional validation logic
    final draggedName = TreePath.getDisplayName(draggedPath);
    final targetName = TreePath.getDisplayName(targetPath);
    
    // Don't allow dropping files onto other files
    if (!targetPath.path.endsWith('/') && !draggedPath.path.endsWith('/')) {
      return false;
    }
    
    return true;
  },
  
  onReorder: (oldPath, newPath) {
    setState(() {
      paths.remove(oldPath);
      paths.add(newPath);
    });
  },
)
```

### Asynchronous Validation

For validation that requires network calls or other async operations:

```dart
ReorderableTreeListView(
  paths: paths,
  itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
  
  canDropAsync: (Uri draggedPath, Uri targetPath) async {
    // Example: Check server permissions
    final hasPermission = await checkDropPermission(draggedPath, targetPath);
    return hasPermission;
  },
  
  onReorder: (oldPath, newPath) {
    setState(() {
      paths.remove(oldPath);
      paths.add(newPath);
    });
  },
)
```

## Drag Restrictions

Control which items can be dragged:

```dart
ReorderableTreeListView(
  paths: paths,
  itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
  
  // Prevent dragging certain items
  canDrag: (Uri path) {
    // Don't allow dragging system files
    if (path.path.contains('/system/')) {
      return false;
    }
    
    // Don't allow dragging readonly files
    if (path.path.contains('.readonly')) {
      return false;
    }
    
    return true;
  },
  
  onReorder: (oldPath, newPath) {
    setState(() {
      paths.remove(oldPath);
      paths.add(newPath);
    });
  },
)
```

## Visual Feedback

### Custom Drag Proxy

Customize the appearance of items while being dragged:

```dart
ReorderableTreeListView(
  paths: paths,
  itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
  
  proxyDecorator: (Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.1 * animation.value,
          child: Card(
            elevation: 8.0 * animation.value,
            shadowColor: Colors.blue.withOpacity(0.5),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: child,
            ),
          ),
        );
      },
      child: child,
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

### Drop Indicators

Enable visual drop indicators:

```dart
ReorderableTreeListView(
  paths: paths,
  itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
  enableDropIndicators: true,
  
  onDropZoneEntered: (String type, Uri path) {
    print('Entered $type drop zone for: ${TreePath.getDisplayName(path)}');
    // Optional: Show additional visual feedback
  },
  
  onReorder: (oldPath, newPath) {
    setState(() {
      paths.remove(oldPath);
      paths.add(newPath);
    });
  },
)
```

## Drop Types

ReorderableTreeListView supports two types of drops:

### 1. Folder Drop
Dropping an item **into** a folder makes it a child of that folder:

```
Before:
├── documents/
├── downloads/
└── file.txt

After dropping file.txt into documents/:
├── documents/
│   └── file.txt
└── downloads/
```

### 2. Sibling Drop
Dropping an item **between** other items makes it a sibling:

```
Before:
├── file1.txt
├── file2.txt
└── file3.txt

After dropping file3.txt between file1.txt and file2.txt:
├── file1.txt
├── file3.txt
└── file2.txt
```

## Advanced Examples

### File Manager with Permissions

```dart
class FileManagerTree extends StatefulWidget {
  @override
  State<FileManagerTree> createState() => _FileManagerTreeState();
}

class _FileManagerTreeState extends State<FileManagerTree> {
  List<Uri> paths = [
    Uri.parse('file:///documents/work/report.pdf'),
    Uri.parse('file:///documents/personal/photo.jpg'),
    Uri.parse('file:///downloads/app.zip'),
    Uri.parse('file:///system/config.sys'),
  ];
  
  Set<Uri> readOnlyPaths = {
    Uri.parse('file:///system/config.sys'),
  };

  @override
  Widget build(BuildContext context) {
    return ReorderableTreeListView(
      paths: paths,
      enableDropIndicators: true,
      
      itemBuilder: (context, path) {
        final name = TreePath.getDisplayName(path);
        final isReadOnly = readOnlyPaths.contains(path);
        
        return Row(
          children: [
            Icon(
              isReadOnly ? Icons.lock : Icons.insert_drive_file,
              size: 20,
              color: isReadOnly ? Colors.red : Colors.blue,
            ),
            SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(
                color: isReadOnly ? Colors.grey : null,
              ),
            ),
          ],
        );
      },
      
      folderBuilder: (context, path) {
        final name = TreePath.getDisplayName(path);
        return Row(
          children: [
            Icon(Icons.folder, size: 20, color: Colors.amber),
            SizedBox(width: 8),
            Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        );
      },
      
      canDrag: (Uri path) {
        // Don't allow dragging readonly files
        return !readOnlyPaths.contains(path);
      },
      
      canDrop: (Uri draggedPath, Uri targetPath) {
        // Don't allow dropping into system folders
        if (targetPath.path.contains('/system/')) {
          return false;
        }
        
        // Don't allow dropping a folder into itself
        if (TreePath.isAncestorOf(draggedPath, targetPath)) {
          return false;
        }
        
        return true;
      },
      
      onDragStart: (Uri path) {
        // Show visual feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dragging ${TreePath.getDisplayName(path)}'),
            duration: Duration(seconds: 1),
          ),
        );
      },
      
      onReorder: (oldPath, newPath) {
        setState(() {
          paths.remove(oldPath);
          paths.add(newPath);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Moved ${TreePath.getDisplayName(oldPath)}'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                setState(() {
                  paths.remove(newPath);
                  paths.add(oldPath);
                });
              },
            ),
          ),
        );
      },
    );
  }
}
```

### Project Navigator with Validation

```dart
class ProjectNavigator extends StatefulWidget {
  @override
  State<ProjectNavigator> createState() => _ProjectNavigatorState();
}

class _ProjectNavigatorState extends State<ProjectNavigator> {
  List<Uri> projectFiles = [
    Uri.parse('project://myapp/src/main.dart'),
    Uri.parse('project://myapp/src/widgets/button.dart'),
    Uri.parse('project://myapp/src/utils/helpers.dart'),
    Uri.parse('project://myapp/test/widget_test.dart'),
    Uri.parse('project://myapp/assets/images/logo.png'),
    Uri.parse('project://myapp/pubspec.yaml'),
  ];

  @override
  Widget build(BuildContext context) {
    return ReorderableTreeListView(
      paths: projectFiles,
      enableDropIndicators: true,
      
      itemBuilder: (context, path) {
        final name = TreePath.getDisplayName(path);
        return Row(
          children: [
            Icon(_getFileIcon(name), size: 18, color: _getFileColor(name)),
            SizedBox(width: 8),
            Text(name),
          ],
        );
      },
      
      folderBuilder: (context, path) {
        final name = TreePath.getDisplayName(path);
        return Row(
          children: [
            Icon(Icons.folder_open, size: 18, color: Colors.blue),
            SizedBox(width: 8),
            Text(name, style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        );
      },
      
      canDrop: (Uri draggedPath, Uri targetPath) {
        // Don't allow Dart files in assets folder
        if (targetPath.path.contains('/assets/') && 
            draggedPath.path.endsWith('.dart')) {
          return false;
        }
        
        // Don't allow test files outside test folder
        if (draggedPath.path.contains('_test.dart') && 
            !targetPath.path.contains('/test/')) {
          return false;
        }
        
        return true;
      },
      
      onWillAcceptDrop: (Uri draggedPath, Uri targetPath) {
        // Additional validation with user feedback
        if (targetPath.path.contains('/assets/') && 
            draggedPath.path.endsWith('.dart')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Dart files cannot be placed in assets folder'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
        
        return true;
      },
      
      onReorder: (oldPath, newPath) {
        setState(() {
          projectFiles.remove(oldPath);
          projectFiles.add(newPath);
        });
      },
      
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.05,
              child: Card(
                elevation: 8,
                shadowColor: Theme.of(context).primaryColor.withOpacity(0.3),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: child,
                ),
              ),
            );
          },
          child: child,
        );
      },
    );
  }
  
  IconData _getFileIcon(String name) {
    if (name.endsWith('.dart')) return Icons.code;
    if (name.endsWith('.yaml')) return Icons.settings;
    if (name.endsWith('.png') || name.endsWith('.jpg')) return Icons.image;
    return Icons.insert_drive_file;
  }
  
  Color _getFileColor(String name) {
    if (name.endsWith('.dart')) return Colors.blue;
    if (name.endsWith('.yaml')) return Colors.orange;
    if (name.endsWith('.png') || name.endsWith('.jpg')) return Colors.green;
    return Colors.grey;
  }
}
```

## Best Practices

### 1. Always Update State
```dart
// ✅ Good: Update state in onReorder
onReorder: (oldPath, newPath) {
  setState(() {
    paths.remove(oldPath);
    paths.add(newPath);
  });
}

// ❌ Bad: Forgetting to update state
onReorder: (oldPath, newPath) {
  // Missing setState - UI won't update
  paths.remove(oldPath);
  paths.add(newPath);
}
```

### 2. Provide User Feedback
```dart
onReorder: (oldPath, newPath) {
  setState(() {
    paths.remove(oldPath);
    paths.add(newPath);
  });
  
  // Show confirmation to user
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Moved ${TreePath.getDisplayName(oldPath)}'),
    ),
  );
}
```

### 3. Validate Drops Appropriately
```dart
canDrop: (draggedPath, targetPath) {
  // Prevent circular references
  if (TreePath.isAncestorOf(draggedPath, targetPath)) {
    return false;
  }
  
  // Add business logic validation
  return isValidFileLocation(draggedPath, targetPath);
}
```

### 4. Handle Async Operations
```dart
canDropAsync: (draggedPath, targetPath) async {
  try {
    return await validateMovePermission(draggedPath, targetPath);
  } catch (e) {
    // Handle errors gracefully
    return false;
  }
}
```

## Troubleshooting

### Items Not Dragging
- Check that `onReorder` callback is provided
- Verify `canDrag` callback returns `true`
- Ensure items are not disabled

### Drops Not Working
- Check `canDrop` and `onWillAcceptDrop` callbacks
- Verify target areas are accepting drops
- Check for validation errors

### Visual Issues
- Use `proxyDecorator` for custom drag appearance
- Enable `enableDropIndicators` for better feedback
- Check theme configuration

### Performance Issues
- Optimize validation callbacks
- Use async validation sparingly
- Consider debouncing drag events for large datasets

## See Also

- [Basic Example](../getting-started/basic-example.md) - Simple drag and drop setup
- [API Reference](../api/reorderable-tree-list-view.md) - Complete API documentation
- [TreePath Utilities](../api/tree-path.md) - Path manipulation helpers
- [Selection](./selection.md) - Combining drag and drop with selection