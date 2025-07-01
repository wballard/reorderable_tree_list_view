# Tree Data Model

ReorderableTreeListView uses a unique approach to representing hierarchical data by building complete tree structures from sparse URI path lists. This design simplifies data management while providing powerful tree functionality.

## Core Concept

Instead of manually creating parent-child relationships, you provide a flat list of URI paths, and the widget automatically:

1. **Generates intermediate folders** for missing path segments
2. **Builds the complete tree structure** with proper hierarchy
3. **Manages parent-child relationships** transparently
4. **Updates the tree** when paths are added or removed

## Path-to-Tree Transformation

### Input: Sparse Path List

```dart
final paths = [
  Uri.parse('file:///documents/work/reports/annual.pdf'),
  Uri.parse('file:///documents/work/presentations/q3.pptx'),
  Uri.parse('file:///documents/personal/photos/vacation.jpg'),
  Uri.parse('file:///downloads/app.zip'),
];
```

### Output: Complete Tree Structure

```
file:///
├── documents/
│   ├── work/
│   │   ├── reports/
│   │   │   └── annual.pdf
│   │   └── presentations/
│   │       └── q3.pptx
│   └── personal/
│       └── photos/
│           └── vacation.jpg
└── downloads/
    └── app.zip
```

### Generated Intermediate Paths

The widget automatically creates these intermediate folder paths:

```dart
// Original paths (what you provide)
[
  'file:///documents/work/reports/annual.pdf',
  'file:///documents/work/presentations/q3.pptx',
  'file:///documents/personal/photos/vacation.jpg',
  'file:///downloads/app.zip',
]

// Generated intermediate paths (created automatically)
[
  'file:///',                              // Root
  'file:///documents/',                    // Level 1 folder
  'file:///documents/work/',              // Level 2 folder
  'file:///documents/work/reports/',      // Level 3 folder
  'file:///documents/work/presentations/', // Level 3 folder
  'file:///documents/personal/',         // Level 2 folder
  'file:///documents/personal/photos/',  // Level 3 folder
  'file:///downloads/',                   // Level 1 folder
]
```

## TreeNode Internal Structure

Internally, the widget creates `TreeNode` objects to represent the hierarchy:

```dart
class TreeNode {
  final Uri path;
  final int depth;
  final bool isLeaf;
  final List<TreeNode> children;
  bool isExpanded;
  
  // ... additional properties
}
```

### Node Types

#### Leaf Nodes (Files)
- Represent actual files or end-point items
- Have no children
- Built using `itemBuilder`
- Cannot be expanded

```dart
// Leaf node example
TreeNode(
  path: Uri.parse('file:///documents/report.pdf'),
  depth: 2,
  isLeaf: true,
  children: [],
  isExpanded: false,
)
```

#### Branch Nodes (Folders)
- Represent directories or containers
- Have one or more children
- Built using `folderBuilder` (or `itemBuilder` if not provided)
- Can be expanded/collapsed

```dart
// Branch node example
TreeNode(
  path: Uri.parse('file:///documents/'),
  depth: 1,
  isLeaf: false,
  children: [/* child nodes */],
  isExpanded: true,
)
```

## Path Depth Calculation

Depth is calculated based on URI path segments:

```dart
// Examples of depth calculation
Uri.parse('file:///')                     // Depth: 0 (root)
Uri.parse('file:///documents/')           // Depth: 1
Uri.parse('file:///documents/work/')      // Depth: 2
Uri.parse('file:///documents/work/file.txt') // Depth: 3
```

Use `TreePath.calculateDepth()` to get the depth of any path:

```dart
final depth = TreePath.calculateDepth(Uri.parse('file:///documents/work/file.txt'));
print(depth); // Output: 3
```

## Tree Building Process

### 1. Path Collection
The widget starts with your provided paths:

```dart
final userPaths = [
  Uri.parse('file:///a/b/c/file1.txt'),
  Uri.parse('file:///a/d/file2.txt'),
];
```

### 2. Intermediate Path Generation
For each user path, generate all intermediate paths:

```dart
// For 'file:///a/b/c/file1.txt', generate:
[
  'file:///',
  'file:///a/',
  'file:///a/b/',
  'file:///a/b/c/',
]

// For 'file:///a/d/file2.txt', generate:
[
  'file:///',
  'file:///a/',
  'file:///a/d/',
]
```

### 3. Path Deduplication
Combine and deduplicate all paths:

```dart
final allPaths = [
  'file:///',                 // Root
  'file:///a/',              // Shared parent
  'file:///a/b/',            // Branch 1
  'file:///a/b/c/',          // Branch 1 subfolder
  'file:///a/b/c/file1.txt', // Leaf 1
  'file:///a/d/',            // Branch 2
  'file:///a/d/file2.txt',   // Leaf 2
];
```

### 4. Tree Node Creation
Create `TreeNode` objects and establish parent-child relationships:

```dart
// Pseudo-code for tree building
final nodes = allPaths.map((path) => TreeNode.fromPath(path));
for (final node in nodes) {
  final parent = findParent(node.path);
  if (parent != null) {
    parent.children.add(node);
  }
}
```

## Working with the Data Model

### Adding Paths

When you add new paths to your list, the tree automatically updates:

```dart
setState(() {
  paths.add(Uri.parse('file:///documents/new-folder/new-file.txt'));
});
// Tree automatically includes new intermediate folder: file:///documents/new-folder/
```

### Removing Paths

Removing paths may also remove empty intermediate folders:

```dart
setState(() {
  paths.remove(Uri.parse('file:///documents/work/reports/annual.pdf'));
});
// If this was the only file in reports/, the reports/ folder is automatically removed
```

### Path Validation

The widget handles various URI formats:

```dart
// Valid path formats
Uri.parse('file:///absolute/path/file.txt')        // Absolute file path
Uri.parse('https://api.com/v1/resource')           // Web API endpoint
Uri.parse('custom://app/settings/theme')           // Custom scheme
Uri.file('/absolute/path/file.txt')                // Using Uri.file()

// The widget normalizes these automatically
```

## TreePath Utilities

The `TreePath` class provides utilities for working with paths:

### Display Names

```dart
final path = Uri.parse('file:///documents/work/report.pdf');
final name = TreePath.getDisplayName(path);
print(name); // Output: "report.pdf"
```

### Parent Paths

```dart
final path = Uri.parse('file:///documents/work/report.pdf');
final parent = TreePath.getParentPath(path);
print(parent); // Output: file:///documents/work/
```

### Ancestor Checking

```dart
final ancestor = Uri.parse('file:///documents/');
final descendant = Uri.parse('file:///documents/work/report.pdf');
final isAncestor = TreePath.isAncestorOf(ancestor, descendant);
print(isAncestor); // Output: true
```

### Path Relationships

```dart
final path1 = Uri.parse('file:///documents/work/');
final path2 = Uri.parse('file:///documents/work/report.pdf');

// Check if path2 is a direct child of path1
final isDirectChild = TreePath.isDirectChildOf(path1, path2);

// Get all ancestors of a path
final ancestors = TreePath.getAncestors(path2);
```

## Data Model Best Practices

### 1. Consistent Schemes

Use the same URI scheme for related data:

```dart
// ✅ Good: Consistent scheme
final paths = [
  Uri.parse('file:///documents/file1.txt'),
  Uri.parse('file:///documents/file2.txt'),
];

// ❌ Avoid: Mixed schemes
final paths = [
  Uri.parse('file:///documents/file1.txt'),
  Uri.parse('/documents/file2.txt'), // Missing scheme
];
```

### 2. Normalized Paths

Ensure paths are normalized:

```dart
// ✅ Good: Normalized path
Uri.parse('file:///documents/work/report.pdf')

// ❌ Avoid: Non-normalized path
Uri.parse('file:///documents//work/./report.pdf')
```

### 3. Proper File vs Folder Distinction

Use trailing slashes for folders when creating custom paths:

```dart
// ✅ Good: Clear distinction
Uri.parse('file:///documents/')        // Folder
Uri.parse('file:///documents/file.txt') // File

// ⚠️ Ambiguous: Is this a file or folder?
Uri.parse('file:///documents/something')
```

### 4. Efficient Updates

Batch path updates when possible:

```dart
// ✅ Good: Batch update
setState(() {
  paths.addAll([
    Uri.parse('file:///new/file1.txt'),
    Uri.parse('file:///new/file2.txt'),
    Uri.parse('file:///new/file3.txt'),
  ]);
});

// ❌ Inefficient: Multiple updates
paths.add(Uri.parse('file:///new/file1.txt'));
setState(() {});
paths.add(Uri.parse('file:///new/file2.txt'));
setState(() {});
paths.add(Uri.parse('file:///new/file3.txt'));
setState(() {});
```

## Advanced Data Patterns

### Virtual File System

```dart
class VirtualFileSystem {
  List<Uri> _paths = [];
  
  void createFile(String path) {
    _paths.add(Uri.parse('vfs://$path'));
  }
  
  void createFolder(String path) {
    _paths.add(Uri.parse('vfs://$path/'));
  }
  
  void moveFile(String oldPath, String newPath) {
    final oldUri = Uri.parse('vfs://$oldPath');
    final newUri = Uri.parse('vfs://$newPath');
    
    final index = _paths.indexOf(oldUri);
    if (index != -1) {
      _paths[index] = newUri;
    }
  }
  
  List<Uri> get paths => List.unmodifiable(_paths);
}
```

### API Endpoint Tree

```dart
class APIEndpointTree {
  final List<Uri> endpoints = [
    Uri.parse('https://api.myapp.com/v1/users/'),
    Uri.parse('https://api.myapp.com/v1/users/profile'),
    Uri.parse('https://api.myapp.com/v1/users/settings'),
    Uri.parse('https://api.myapp.com/v1/products/'),
    Uri.parse('https://api.myapp.com/v1/products/categories'),
    Uri.parse('https://api.myapp.com/v2/orders/'),
  ];
}
```

### Multi-Schema Tree

```dart
class ProjectExplorer {
  final List<Uri> items = [
    // Local files
    Uri.parse('file:///project/src/main.dart'),
    Uri.parse('file:///project/test/test.dart'),
    
    // Remote resources
    Uri.parse('https://github.com/user/repo/blob/main/README.md'),
    
    // Custom application data
    Uri.parse('app://bookmarks/folder1/bookmark1'),
    Uri.parse('app://bookmarks/folder2/bookmark2'),
  ];
}
```

## See Also

- [URI-Based Trees](./uri-based-trees.md) - Understanding URI path structures
- [Widget Architecture](./widget-architecture.md) - How the widget processes data
- [TreePath API](../api/tree-path.md) - Path manipulation utilities
- [Basic Example](../getting-started/basic-example.md) - Practical usage examples