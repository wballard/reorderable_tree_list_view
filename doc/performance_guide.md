# Performance Optimization Guide

This guide covers best practices and techniques for optimizing ReorderableTreeListView performance, especially when dealing with large datasets.

## Table of Contents

- [General Principles](#general-principles)
- [Widget Optimization](#widget-optimization)
- [State Management](#state-management)
- [Large Dataset Handling](#large-dataset-handling)
- [Memory Management](#memory-management)
- [Profiling and Debugging](#profiling-and-debugging)
- [Platform-Specific Optimizations](#platform-specific-optimizations)

## General Principles

### 1. Use Const Constructors

Always use `const` constructors where possible to prevent unnecessary rebuilds:

```dart
// Good
itemBuilder: (context, path) => const Icon(Icons.file_present),

// Better - if the widget doesn't change
itemBuilder: (context, path) => _buildStaticItem(),

Widget _buildStaticItem() {
  return const Row(
    children: [
      Icon(Icons.insert_drive_file, size: 20),
      SizedBox(width: 8),
      Text('Static Content'),
    ],
  );
}
```

### 2. Minimize Widget Rebuilds

Use `const` widgets and extract static widgets:

```dart
class OptimizedTreeItem extends StatelessWidget {
  final Uri path;
  final bool isSelected;
  
  const OptimizedTreeItem({
    super.key,
    required this.path,
    required this.isSelected,
  });
  
  // Static widgets extracted as const
  static const _icon = Icon(Icons.insert_drive_file, size: 20);
  static const _spacing = SizedBox(width: 8);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: isSelected ? Colors.blue.withOpacity(0.2) : null,
      child: Row(
        children: [
          _icon,
          _spacing,
          Text(TreePath.getDisplayName(path)),
        ],
      ),
    );
  }
}
```

### 3. Key Usage

Use proper keys for optimal reconciliation:

```dart
ReorderableTreeListView(
  paths: paths,
  itemBuilder: (context, path) => OptimizedTreeItem(
    key: ValueKey(path.toString()), // Stable key based on path
    path: path,
    isSelected: selectedPaths.contains(path),
  ),
)
```

## Widget Optimization

### 1. Lazy Building

The tree automatically uses lazy building, but ensure your builders are efficient:

```dart
// Avoid expensive computations in builders
itemBuilder: (context, path) {
  // Bad - computing on every build
  final metadata = expensiveMetadataLookup(path);
  
  // Good - use cached data
  final metadata = _metadataCache[path] ??= expensiveMetadataLookup(path);
  
  return ListTile(
    title: Text(metadata.name),
    subtitle: Text(metadata.description),
  );
}
```

### 2. Image Optimization

For trees with images, use proper caching:

```dart
itemBuilder: (context, path) {
  return Row(
    children: [
      // Use cached network images
      CachedNetworkImage(
        imageUrl: getImageUrl(path),
        width: 40,
        height: 40,
        placeholder: (context, url) => const CircularProgressIndicator(),
      ),
      const SizedBox(width: 8),
      Text(TreePath.getDisplayName(path)),
    ],
  );
}
```

### 3. Complex Layouts

For complex item layouts, consider using LayoutBuilder efficiently:

```dart
class ComplexTreeItem extends StatelessWidget {
  final Uri path;
  
  const ComplexTreeItem({super.key, required this.path});
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Adjust layout based on available space
        if (constraints.maxWidth > 400) {
          return _buildWideLayout();
        } else {
          return _buildCompactLayout();
        }
      },
    );
  }
}
```

## State Management

### 1. Efficient State Updates

Update state efficiently to minimize rebuilds:

```dart
class EfficientTreeState extends State<MyTree> {
  List<Uri> _paths = [];
  Set<Uri> _selectedPaths = {};
  
  void _updatePaths(List<Uri> newPaths) {
    // Only update if actually changed
    if (!listEquals(_paths, newPaths)) {
      setState(() {
        _paths = newPaths;
      });
    }
  }
  
  void _toggleSelection(Uri path) {
    setState(() {
      // Efficient set operations
      if (_selectedPaths.contains(path)) {
        _selectedPaths = Set.from(_selectedPaths)..remove(path);
      } else {
        _selectedPaths = Set.from(_selectedPaths)..add(path);
      }
    });
  }
}
```

### 2. Separate Stateful Logic

Isolate stateful widgets to minimize rebuild scope:

```dart
// Instead of rebuilding entire tree
class TreeWithSelection extends StatefulWidget {
  @override
  State<TreeWithSelection> createState() => _TreeWithSelectionState();
}

class _TreeWithSelectionState extends State<TreeWithSelection> {
  Set<Uri> selectedPaths = {};
  
  @override
  Widget build(BuildContext context) {
    return ReorderableTreeListView(
      paths: paths,
      itemBuilder: (context, path) => SelectableItem(
        path: path,
        isSelected: selectedPaths.contains(path),
        onSelectionChanged: (selected) {
          setState(() {
            if (selected) {
              selectedPaths.add(path);
            } else {
              selectedPaths.remove(path);
            }
          });
        },
      ),
    );
  }
}

// Stateless item that doesn't cause tree rebuild
class SelectableItem extends StatelessWidget {
  final Uri path;
  final bool isSelected;
  final ValueChanged<bool> onSelectionChanged;
  
  const SelectableItem({
    super.key,
    required this.path,
    required this.isSelected,
    required this.onSelectionChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onSelectionChanged(!isSelected),
      child: Container(
        color: isSelected ? Colors.blue.withOpacity(0.2) : null,
        child: Text(TreePath.getDisplayName(path)),
      ),
    );
  }
}
```

## Large Dataset Handling

### 1. Initial Expansion State

For large datasets, start with folders collapsed:

```dart
ReorderableTreeListView(
  paths: largePaths, // 1000+ items
  expandedByDefault: false, // Important for performance
  initiallyExpanded: {
    // Only expand specific paths if needed
    Uri.parse('file:///important/folder/'),
  },
)
```

### 2. Virtualization

The widget automatically virtualizes the list, but you can optimize further:

```dart
ReorderableTreeListView(
  paths: paths,
  // Provide extent hints for better performance
  itemBuilder: (context, path) => SizedBox(
    height: 48, // Fixed height improves scrolling
    child: TreeItem(path: path),
  ),
)
```

### 3. Pagination

For extremely large datasets, implement pagination:

```dart
class PaginatedTree extends StatefulWidget {
  final List<Uri> allPaths;
  
  @override
  State<PaginatedTree> createState() => _PaginatedTreeState();
}

class _PaginatedTreeState extends State<PaginatedTree> {
  static const _pageSize = 100;
  int _currentPage = 0;
  
  List<Uri> get _visiblePaths {
    final start = _currentPage * _pageSize;
    final end = min(start + _pageSize, widget.allPaths.length);
    return widget.allPaths.sublist(start, end);
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ReorderableTreeListView(
          paths: _visiblePaths,
          itemBuilder: (context, path) => Text(path.toString()),
        ),
        PaginationControls(
          currentPage: _currentPage,
          totalPages: (widget.allPaths.length / _pageSize).ceil(),
          onPageChanged: (page) {
            setState(() {
              _currentPage = page;
            });
          },
        ),
      ],
    );
  }
}
```

### 4. Search and Filter Optimization

Implement efficient search with debouncing:

```dart
class SearchableTree extends StatefulWidget {
  @override
  State<SearchableTree> createState() => _SearchableTreeState();
}

class _SearchableTreeState extends State<SearchableTree> {
  List<Uri> _allPaths = [];
  List<Uri> _filteredPaths = [];
  Timer? _debounceTimer;
  
  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        if (query.isEmpty) {
          _filteredPaths = _allPaths;
        } else {
          // Efficient filtering
          final lowerQuery = query.toLowerCase();
          _filteredPaths = _allPaths.where((path) {
            return path.toString().toLowerCase().contains(lowerQuery);
          }).toList();
        }
      });
    });
  }
  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          onChanged: _onSearchChanged,
          decoration: const InputDecoration(
            hintText: 'Search...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        Expanded(
          child: ReorderableTreeListView(
            paths: _filteredPaths,
            itemBuilder: (context, path) => Text(path.toString()),
          ),
        ),
      ],
    );
  }
}
```

## Memory Management

### 1. Dispose Resources

Always dispose of resources properly:

```dart
class TreeWithResources extends StatefulWidget {
  @override
  State<TreeWithResources> createState() => _TreeWithResourcesState();
}

class _TreeWithResourcesState extends State<TreeWithResources> {
  late final ScrollController _scrollController;
  late final StreamSubscription _pathSubscription;
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _pathSubscription = pathStream.listen(_onPathsUpdated);
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    _pathSubscription.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return ReorderableTreeListView(
      scrollController: _scrollController,
      paths: paths,
      itemBuilder: (context, path) => Text(path.toString()),
    );
  }
}
```

### 2. Image Memory Management

For trees with many images:

```dart
class ImageTreeItem extends StatefulWidget {
  final Uri path;
  
  @override
  State<ImageTreeItem> createState() => _ImageTreeItemState();
}

class _ImageTreeItemState extends State<ImageTreeItem> 
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => false; // Don't keep all images in memory
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Row(
      children: [
        Image.network(
          getImageUrl(widget.path),
          width: 40,
          height: 40,
          cacheWidth: 40, // Limit cache size
          cacheHeight: 40,
        ),
        const SizedBox(width: 8),
        Text(TreePath.getDisplayName(widget.path)),
      ],
    );
  }
}
```

## Profiling and Debugging

### 1. Performance Overlay

Enable the performance overlay to identify issues:

```dart
void main() {
  runApp(MaterialApp(
    showPerformanceOverlay: true, // Enable in debug
    home: MyApp(),
  ));
}
```

### 2. Widget Inspector

Use the Widget Inspector to analyze rebuilds:

```dart
// Add debug prints to identify rebuilds
itemBuilder: (context, path) {
  debugPrint('Building item: $path');
  return TreeItem(path: path);
}
```

### 3. Timeline Profiling

Use Flutter DevTools Timeline to profile:

```dart
Timeline.startSync('TreeBuild');
final tree = ReorderableTreeListView(
  paths: paths,
  itemBuilder: itemBuilder,
);
Timeline.finishSync();
```

### 4. Memory Profiling

Monitor memory usage with DevTools:

```dart
// Add memory monitoring
class MemoryMonitor extends StatefulWidget {
  @override
  State<MemoryMonitor> createState() => _MemoryMonitorState();
}

class _MemoryMonitorState extends State<MemoryMonitor> {
  Timer? _memoryTimer;
  
  @override
  void initState() {
    super.initState();
    _memoryTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      debugPrint('Memory: ${ProcessInfo.currentRss ~/ 1024 ~/ 1024} MB');
    });
  }
  
  @override
  void dispose() {
    _memoryTimer?.cancel();
    super.dispose();
  }
}
```

## Platform-Specific Optimizations

### Web

```dart
// Optimize for web
if (kIsWeb) {
  return ReorderableTreeListView(
    paths: paths,
    // Use smaller indent on web
    theme: const TreeTheme(indentSize: 24),
    // Disable hover effects on mobile web
    itemBuilder: (context, path) => MouseRegion(
      cursor: SystemMouseCursors.click,
      child: TreeItem(path: path),
    ),
  );
}
```

### Mobile

```dart
// Optimize for mobile
if (Platform.isIOS || Platform.isAndroid) {
  return ReorderableTreeListView(
    paths: paths,
    // Larger touch targets on mobile
    theme: const TreeTheme(
      itemPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    // Disable hover effects
    proxyDecorator: (child, index, animation) => Material(
      elevation: 8,
      child: child,
    ),
  );
}
```

### Desktop

```dart
// Optimize for desktop
if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
  return ReorderableTreeListView(
    paths: paths,
    // Enable all desktop features
    enableKeyboardNavigation: true,
    theme: TreeTheme(
      hoverColor: Colors.grey.withOpacity(0.1),
      focusColor: Colors.blue.withOpacity(0.2),
    ),
  );
}
```

## Best Practices Summary

1. **Start Collapsed**: Use `expandedByDefault: false` for large datasets
2. **Fixed Heights**: Provide fixed item heights when possible
3. **Const Widgets**: Use const constructors liberally
4. **Efficient Builders**: Keep builder methods lightweight
5. **Proper Keys**: Use stable, unique keys
6. **Dispose Resources**: Clean up controllers and subscriptions
7. **Profile Regularly**: Use DevTools to identify bottlenecks
8. **Platform Awareness**: Optimize for target platforms

## Benchmarking

Example benchmark setup:

```dart
void runBenchmark() async {
  final stopwatch = Stopwatch()..start();
  
  // Generate large dataset
  final paths = List.generate(
    10000,
    (i) => Uri.parse('file:///folder${i % 100}/file$i.txt'),
  );
  
  print('Data generation: ${stopwatch.elapsedMilliseconds}ms');
  stopwatch.reset();
  
  // Build tree
  final tree = ReorderableTreeListView(
    paths: paths,
    expandedByDefault: false,
    itemBuilder: (context, path) => Text(path.toString()),
  );
  
  print('Tree creation: ${stopwatch.elapsedMilliseconds}ms');
}
```