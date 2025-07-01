# Selection

ReorderableTreeListView provides flexible selection capabilities that support none, single, or multiple selection modes with comprehensive keyboard and mouse interaction.

## Selection Modes

### No Selection (Default)

By default, no items can be selected:

```dart
ReorderableTreeListView(
  paths: paths,
  selectionMode: SelectionMode.none, // Default
  itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
)
```

### Single Selection

Only one item can be selected at a time:

```dart
class SingleSelectionExample extends StatefulWidget {
  @override
  State<SingleSelectionExample> createState() => _SingleSelectionExampleState();
}

class _SingleSelectionExampleState extends State<SingleSelectionExample> {
  List<Uri> paths = [
    Uri.parse('file:///documents/file1.txt'),
    Uri.parse('file:///documents/file2.txt'),
    Uri.parse('file:///downloads/app.zip'),
  ];
  
  Set<Uri> selectedPaths = {};

  @override
  Widget build(BuildContext context) {
    return ReorderableTreeListView(
      paths: paths,
      selectionMode: SelectionMode.single,
      initialSelection: selectedPaths,
      onSelectionChanged: (Set<Uri> selection) {
        setState(() {
          selectedPaths = selection;
        });
      },
      itemBuilder: (context, path) {
        final isSelected = selectedPaths.contains(path);
        return Container(
          color: isSelected ? Colors.blue.shade100 : null,
          padding: EdgeInsets.all(8),
          child: Text(TreePath.getDisplayName(path)),
        );
      },
    );
  }
}
```

### Multiple Selection

Multiple items can be selected simultaneously:

```dart
class MultipleSelectionExample extends StatefulWidget {
  @override
  State<MultipleSelectionExample> createState() => _MultipleSelectionExampleState();
}

class _MultipleSelectionExampleState extends State<MultipleSelectionExample> {
  List<Uri> paths = [
    Uri.parse('file:///documents/work/report.pdf'),
    Uri.parse('file:///documents/work/presentation.pptx'),
    Uri.parse('file:///documents/personal/photo.jpg'),
    Uri.parse('file:///downloads/app.zip'),
  ];
  
  Set<Uri> selectedPaths = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Selection summary
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.grey.shade100,
          child: Row(
            children: [
              Text('Selected: ${selectedPaths.length} items'),
              Spacer(),
              if (selectedPaths.isNotEmpty)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedPaths.clear();
                    });
                  },
                  child: Text('Clear Selection'),
                ),
            ],
          ),
        ),
        Expanded(
          child: ReorderableTreeListView(
            paths: paths,
            selectionMode: SelectionMode.multiple,
            initialSelection: selectedPaths,
            onSelectionChanged: (Set<Uri> selection) {
              setState(() {
                selectedPaths = selection;
              });
            },
            itemBuilder: (context, path) {
              final isSelected = selectedPaths.contains(path);
              final name = TreePath.getDisplayName(path);
              
              return Container(
                decoration: BoxDecoration(
                  color: isSelected 
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : null,
                  border: isSelected 
                    ? Border.all(color: Theme.of(context).primaryColor)
                    : null,
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: EdgeInsets.all(8),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                      size: 20,
                      color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.insert_drive_file, size: 20),
                    SizedBox(width: 8),
                    Text(name),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
```

## Keyboard Selection

### Single Selection Shortcuts

- **Click** - Select item
- **Arrow Keys** - Navigate and select
- **Enter/Space** - Select focused item

### Multiple Selection Shortcuts

- **Click** - Select item (clears previous selection)
- **Ctrl+Click** (Cmd+Click on Mac) - Toggle item selection
- **Shift+Click** - Range selection from last selected item
- **Ctrl+A** (Cmd+A on Mac) - Select all visible items
- **Escape** - Clear selection

```dart
ReorderableTreeListView(
  paths: paths,
  selectionMode: SelectionMode.multiple,
  enableKeyboardNavigation: true, // Enable keyboard shortcuts
  onSelectionChanged: (selection) {
    setState(() {
      selectedPaths = selection;
    });
  },
  itemBuilder: (context, path) {
    // ... item builder
  },
)
```

## Programmatic Selection

### Initial Selection

Set items to be selected when the widget first loads:

```dart
final initialSelection = {
  Uri.parse('file:///documents/important.pdf'),
  Uri.parse('file:///downloads/app.zip'),
};

ReorderableTreeListView(
  paths: paths,
  selectionMode: SelectionMode.multiple,
  initialSelection: initialSelection,
  onSelectionChanged: (selection) {
    setState(() {
      selectedPaths = selection;
    });
  },
  itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
)
```

### Controlling Selection Programmatically

You can control selection by updating the selection set:

```dart
class ProgrammaticSelectionExample extends StatefulWidget {
  @override
  State<ProgrammaticSelectionExample> createState() => _ProgrammaticSelectionExampleState();
}

class _ProgrammaticSelectionExampleState extends State<ProgrammaticSelectionExample> {
  List<Uri> paths = [
    Uri.parse('file:///documents/file1.txt'),
    Uri.parse('file:///documents/file2.txt'),
    Uri.parse('file:///documents/file3.txt'),
    Uri.parse('file:///downloads/app.zip'),
  ];
  
  Set<Uri> selectedPaths = {};

  void selectAll() {
    setState(() {
      selectedPaths = Set.from(paths);
    });
  }
  
  void selectNone() {
    setState(() {
      selectedPaths.clear();
    });
  }
  
  void selectDocuments() {
    setState(() {
      selectedPaths = paths
          .where((path) => path.path.contains('/documents/'))
          .toSet();
    });
  }
  
  void invertSelection() {
    setState(() {
      final newSelection = <Uri>{};
      for (final path in paths) {
        if (!selectedPaths.contains(path)) {
          newSelection.add(path);
        }
      }
      selectedPaths = newSelection;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Control buttons
        Wrap(
          spacing: 8,
          children: [
            ElevatedButton(
              onPressed: selectAll,
              child: Text('Select All'),
            ),
            ElevatedButton(
              onPressed: selectNone,
              child: Text('Clear Selection'),
            ),
            ElevatedButton(
              onPressed: selectDocuments,
              child: Text('Select Documents'),
            ),
            ElevatedButton(
              onPressed: invertSelection,
              child: Text('Invert Selection'),
            ),
          ],
        ),
        Expanded(
          child: ReorderableTreeListView(
            paths: paths,
            selectionMode: SelectionMode.multiple,
            initialSelection: selectedPaths,
            onSelectionChanged: (Set<Uri> selection) {
              setState(() {
                selectedPaths = selection;
              });
            },
            itemBuilder: (context, path) {
              final isSelected = selectedPaths.contains(path);
              return ListTile(
                selected: isSelected,
                leading: Icon(Icons.insert_drive_file),
                title: Text(TreePath.getDisplayName(path)),
                onTap: () {
                  // Custom tap handling
                  setState(() {
                    if (selectedPaths.contains(path)) {
                      selectedPaths.remove(path);
                    } else {
                      selectedPaths.add(path);
                    }
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
```

## Custom Selection Indicators

### Checkbox Style

```dart
itemBuilder: (context, path) {
  final isSelected = selectedPaths.contains(path);
  final name = TreePath.getDisplayName(path);
  
  return Row(
    children: [
      Checkbox(
        value: isSelected,
        onChanged: (bool? value) {
          setState(() {
            if (value == true) {
              selectedPaths.add(path);
            } else {
              selectedPaths.remove(path);
            }
          });
        },
      ),
      Icon(Icons.insert_drive_file, size: 20),
      SizedBox(width: 8),
      Text(name),
    ],
  );
}
```

### Badge Style

```dart
itemBuilder: (context, path) {
  final isSelected = selectedPaths.contains(path);
  final name = TreePath.getDisplayName(path);
  
  return Stack(
    children: [
      Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.insert_drive_file, size: 20),
            SizedBox(width: 8),
            Text(name),
          ],
        ),
      ),
      if (isSelected)
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              size: 12,
              color: Colors.white,
            ),
          ),
        ),
    ],
  );
}
```

### Highlight Style

```dart
itemBuilder: (context, path) {
  final isSelected = selectedPaths.contains(path);
  final name = TreePath.getDisplayName(path);
  
  return AnimatedContainer(
    duration: Duration(milliseconds: 200),
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: isSelected 
        ? Theme.of(context).primaryColor.withOpacity(0.1)
        : null,
      borderRadius: BorderRadius.circular(8),
      border: isSelected 
        ? Border.all(
            color: Theme.of(context).primaryColor,
            width: 2,
          )
        : null,
    ),
    child: Row(
      children: [
        Icon(
          Icons.insert_drive_file,
          size: 20,
          color: isSelected 
            ? Theme.of(context).primaryColor
            : null,
        ),
        SizedBox(width: 8),
        Text(
          name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : null,
            color: isSelected 
              ? Theme.of(context).primaryColor
              : null,
          ),
        ),
      ],
    ),
  );
}
```

## Selection with Actions

### Context-Sensitive Actions

```dart
class SelectionWithActionsExample extends StatefulWidget {
  @override
  State<SelectionWithActionsExample> createState() => _SelectionWithActionsExampleState();
}

class _SelectionWithActionsExampleState extends State<SelectionWithActionsExample> {
  List<Uri> paths = [
    Uri.parse('file:///documents/report.pdf'),
    Uri.parse('file:///documents/image.jpg'),
    Uri.parse('file:///downloads/app.zip'),
  ];
  
  Set<Uri> selectedPaths = {};

  void deleteSelected() {
    setState(() {
      paths.removeWhere((path) => selectedPaths.contains(path));
      selectedPaths.clear();
    });
  }
  
  void copySelected() {
    // Implement copy logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied ${selectedPaths.length} items')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (selectedPaths.isNotEmpty)
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Text('${selectedPaths.length} selected'),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.copy),
                  onPressed: copySelected,
                  tooltip: 'Copy',
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: deleteSelected,
                  tooltip: 'Delete',
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      selectedPaths.clear();
                    });
                  },
                  tooltip: 'Clear Selection',
                ),
              ],
            ),
          ),
        Expanded(
          child: ReorderableTreeListView(
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
              return ListTile(
                selected: isSelected,
                leading: Icon(Icons.insert_drive_file),
                title: Text(TreePath.getDisplayName(path)),
              );
            },
          ),
        ),
      ],
    );
  }
}
```

## Selection Persistence

### Saving Selection State

```dart
class PersistentSelectionExample extends StatefulWidget {
  @override
  State<PersistentSelectionExample> createState() => _PersistentSelectionExampleState();
}

class _PersistentSelectionExampleState extends State<PersistentSelectionExample> {
  List<Uri> paths = [...];
  Set<Uri> selectedPaths = {};
  
  @override
  void initState() {
    super.initState();
    loadSelection();
  }
  
  void loadSelection() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedStrings = prefs.getStringList('selected_paths') ?? [];
    setState(() {
      selectedPaths = selectedStrings.map((s) => Uri.parse(s)).toSet();
    });
  }
  
  void saveSelection() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedStrings = selectedPaths.map((uri) => uri.toString()).toList();
    await prefs.setStringList('selected_paths', selectedStrings);
  }
  
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
        saveSelection(); // Auto-save selection
      },
      itemBuilder: (context, path) {
        final isSelected = selectedPaths.contains(path);
        return ListTile(
          selected: isSelected,
          title: Text(TreePath.getDisplayName(path)),
        );
      },
    );
  }
}
```

## Best Practices

### 1. Visual Feedback

Always provide clear visual feedback for selection:

```dart
// ✅ Good: Clear visual distinction
Container(
  color: isSelected ? Colors.blue.shade100 : null,
  child: Text(name),
)

// ❌ Poor: No visual feedback
Text(name) // User can't tell what's selected
```

### 2. Keyboard Support

Enable keyboard navigation for accessibility:

```dart
ReorderableTreeListView(
  enableKeyboardNavigation: true,
  selectionMode: SelectionMode.multiple,
  // ...
)
```

### 3. Performance with Large Sets

For large datasets, optimize selection checking:

```dart
class _OptimizedSelectionState extends State<OptimizedSelectionExample> {
  Set<Uri> selectedPaths = {};
  
  // Cache selection status to avoid repeated Set.contains() calls
  Map<Uri, bool> selectionCache = {};
  
  void updateSelection(Set<Uri> newSelection) {
    setState(() {
      selectedPaths = newSelection;
      // Update cache
      selectionCache.clear();
      for (final path in paths) {
        selectionCache[path] = selectedPaths.contains(path);
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return ReorderableTreeListView(
      paths: paths,
      selectionMode: SelectionMode.multiple,
      onSelectionChanged: updateSelection,
      itemBuilder: (context, path) {
        final isSelected = selectionCache[path] ?? false;
        return Container(
          color: isSelected ? Colors.blue.shade100 : null,
          child: Text(TreePath.getDisplayName(path)),
        );
      },
    );
  }
}
```

## See Also

- [Keyboard Navigation](./keyboard-navigation.md) - Keyboard shortcuts and accessibility
- [Basic Example](../getting-started/basic-example.md) - Simple selection examples
- [API Reference](../api/reorderable-tree-list-view.md) - Complete selection API
- [Actions and Intents](./actions-intents.md) - Advanced action handling