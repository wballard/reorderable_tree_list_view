# URI-Based Tree Structure

ReorderableTreeListView uses URIs (Uniform Resource Identifiers) as the foundation for representing hierarchical data. This approach provides a flexible, standard way to represent tree structures that works across different data sources.

## Why URIs?

URIs offer several advantages for tree structures:

1. **Universal Format** - Works for files, URLs, custom schemes
2. **Hierarchical by Nature** - Path segments naturally represent hierarchy
3. **Platform Agnostic** - Same format works everywhere
4. **Extensible** - Custom schemes for any data type
5. **Standard API** - Dart's Uri class provides parsing and manipulation

## Basic Concepts

### URI Structure

A URI consists of several parts:

```
scheme://authority/path/to/resource?query#fragment
```

For tree structures, we primarily use the scheme and path:

```dart
// File system
Uri.parse('file:///home/user/documents/report.pdf')

// Web resources  
Uri.parse('https://api.example.com/users/123/profile')

// Custom schemes
Uri.parse('app://settings/display/theme')
```

### Automatic Tree Generation

ReorderableTreeListView automatically generates intermediate folders from paths:

```dart
// Given these paths:
[
  Uri.parse('file:///documents/work/report.pdf'),
  Uri.parse('file:///downloads/app.zip'),
]

// The widget generates this tree:
// /
// ├── documents/
// │   └── work/
// │       └── report.pdf
// └── downloads/
//     └── app.zip
```

## Common URI Schemes

### File System (`file://`)

Most common for representing local files:

```dart
final paths = [
  Uri.parse('file:///Users/john/Documents/report.pdf'),
  Uri.parse('file:///Users/john/Documents/images/photo.jpg'),
  Uri.parse('file:///Users/john/Downloads/app.zip'),
];
```

### HTTP/HTTPS (`http://`, `https://`)

For web resources and APIs:

```dart
final paths = [
  Uri.parse('https://api.example.com/v1/users'),
  Uri.parse('https://api.example.com/v1/products'),
  Uri.parse('https://api.example.com/v2/orders'),
];
```

### Custom Schemes

Create domain-specific hierarchies:

```dart
// Settings tree
final settingsPaths = [
  Uri.parse('settings://appearance/theme'),
  Uri.parse('settings://appearance/font-size'),
  Uri.parse('settings://privacy/location'),
  Uri.parse('settings://privacy/camera'),
];

// Organization chart
final orgPaths = [
  Uri.parse('org://engineering/frontend/team-a'),
  Uri.parse('org://engineering/backend/team-b'),
  Uri.parse('org://sales/north-america'),
  Uri.parse('org://sales/europe'),
];
```

## Working with Paths

### Creating URIs

```dart
// From string
final uri1 = Uri.parse('file:///path/to/file.txt');

// Using constructor
final uri2 = Uri(
  scheme: 'file',
  path: '/path/to/file.txt',
);

// From file path
final uri3 = Uri.file('/path/to/file.txt');

// With special characters (automatically encoded)
final uri4 = Uri.parse('file:///My Documents/Report 2023.pdf');
```

### Path Manipulation

ReorderableTreeListView provides the `TreePath` utility class:

```dart
// Get display name (last segment)
final name = TreePath.getDisplayName(
  Uri.parse('file:///documents/report.pdf')
); // Returns: "report.pdf"

// Get parent path
final parent = TreePath.getParentPath(
  Uri.parse('file:///documents/work/report.pdf')
); // Returns: Uri.parse('file:///documents/work')

// Calculate depth
final depth = TreePath.calculateDepth(
  Uri.parse('file:///a/b/c/d.txt')
); // Returns: 4

// Check relationships
final isAncestor = TreePath.isAncestorOf(
  Uri.parse('file:///documents'),
  Uri.parse('file:///documents/work/report.pdf')
); // Returns: true
```

## Best Practices

### 1. Consistent Schemes

Use the same scheme for related data:

```dart
// Good - consistent scheme
[
  Uri.parse('file:///docs/report1.pdf'),
  Uri.parse('file:///docs/report2.pdf'),
]

// Avoid - mixed schemes for same data type
[
  Uri.parse('file:///docs/report1.pdf'),
  Uri.parse('/docs/report2.pdf'), // Missing scheme
]
```

### 2. Normalized Paths

Keep paths normalized to avoid duplicates:

```dart
// Good - normalized paths
Uri.parse('file:///documents/work/report.pdf')

// Avoid - non-normalized
Uri.parse('file:///documents//work/./report.pdf')
```

### 3. Encoding Special Characters

Let Uri handle encoding:

```dart
// Good - Uri handles encoding
Uri.parse('file:///My Documents/Report 2023.pdf')

// The Uri class automatically encodes to:
// file:///My%20Documents/Report%202023.pdf
```

### 4. Platform-Specific Paths

Use Uri.file() for platform compatibility:

```dart
// Cross-platform file URI
final uri = Uri.file(
  '/Users/john/document.txt',
  windows: Platform.isWindows,
);

// Results in:
// macOS/Linux: file:///Users/john/document.txt
// Windows: file:///C:/Users/john/document.txt
```

## Advanced Usage

### Dynamic Path Generation

Generate paths programmatically:

```dart
List<Uri> generateProjectStructure(String projectName) {
  final base = 'project://$projectName';
  return [
    Uri.parse('$base/src/main.dart'),
    Uri.parse('$base/src/widgets/button.dart'),
    Uri.parse('$base/src/widgets/card.dart'),
    Uri.parse('$base/test/widget_test.dart'),
    Uri.parse('$base/pubspec.yaml'),
    Uri.parse('$base/README.md'),
  ];
}
```

### Mixed Schemes

Display different types of resources:

```dart
final mixedPaths = [
  // Local files
  Uri.parse('file:///downloads/image.jpg'),
  
  // Remote resources
  Uri.parse('https://cdn.example.com/assets/logo.png'),
  
  // Application routes
  Uri.parse('app://settings/profile'),
  
  // Custom data
  Uri.parse('db://users/123/preferences'),
];
```

### Path Filtering

Filter paths by criteria:

```dart
// Show only images
final imagePaths = paths.where((uri) {
  final path = uri.path.toLowerCase();
  return path.endsWith('.jpg') || 
         path.endsWith('.png') || 
         path.endsWith('.gif');
}).toList();

// Show only specific folder
final folderPaths = paths.where((uri) {
  return uri.path.startsWith('/documents/work/');
}).toList();
```

## Examples

### File Explorer

```dart
final fileExplorerPaths = [
  Uri.file('/Users/john/Documents/Work/Report.pdf'),
  Uri.file('/Users/john/Documents/Work/Presentation.pptx'),
  Uri.file('/Users/john/Documents/Personal/Resume.docx'),
  Uri.file('/Users/john/Downloads/app-installer.dmg'),
  Uri.file('/Users/john/Pictures/vacation/beach.jpg'),
];
```

### API Endpoint Browser

```dart
final apiPaths = [
  Uri.parse('https://api.myapp.com/v1/users/list'),
  Uri.parse('https://api.myapp.com/v1/users/{id}'),
  Uri.parse('https://api.myapp.com/v1/products/categories'),
  Uri.parse('https://api.myapp.com/v1/products/search'),
  Uri.parse('https://api.myapp.com/v2/orders/create'),
];
```

### Settings Tree

```dart
final settingsPaths = [
  Uri.parse('settings://general/language'),
  Uri.parse('settings://general/timezone'),
  Uri.parse('settings://appearance/theme/dark-mode'),
  Uri.parse('settings://appearance/theme/accent-color'),
  Uri.parse('settings://privacy/data-collection'),
  Uri.parse('settings://privacy/cookies'),
];
```

## Next Steps

- Learn about the [Tree Data Model](./tree-data-model.md)
- Understand [Widget Architecture](./widget-architecture.md)
- Explore [Custom Item Builders](../customization/item-builders.md)