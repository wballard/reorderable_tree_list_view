import 'package:flutter/material.dart';
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

void main() {
  runApp(const MyApp());
}

/// Example application demonstrating ReorderableTreeListView.
class MyApp extends StatelessWidget {
  /// Creates the example app.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
      title: 'ReorderableTreeListView Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
}

/// Home page showing the tree view example.
class MyHomePage extends StatefulWidget {
  /// Creates the home page.
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Sample paths representing a file system structure
  late List<Uri> paths;
  String? _dragStatus;
  final List<String> _reorderHistory = [];

  @override
  void initState() {
    super.initState();
    paths = <Uri>[
      Uri.parse('file://home/user/documents/report.pdf'),
      Uri.parse('file://home/user/documents/presentation.pptx'),
      Uri.parse('file://home/user/pictures/vacation/beach.jpg'),
      Uri.parse('file://home/user/pictures/vacation/sunset.jpg'),
      Uri.parse('file://home/user/pictures/family.jpg'),
      Uri.parse('file://home/user/music/playlist.m3u'),
      Uri.parse('file://home/user/downloads/app.zip'),
      Uri.parse('file://etc/config.conf'),
      Uri.parse('file://var/log/system.log'),
    ];
  }

  bool _showConnectors = true;
  double _indentSize = 32.0;
  bool _showCustomTheme = false;
  bool _expandedByDefault = true;
  bool _animateExpansion = true;
  bool _enableDragAndDrop = true;

  TreeTheme get _currentTheme {
    if (!_showCustomTheme) {
      return TreeTheme(
        indentSize: _indentSize,
        showConnectors: _showConnectors,
      );
    }

    return TreeTheme(
      indentSize: _indentSize,
      showConnectors: _showConnectors,
      connectorColor: Colors.deepPurple.withValues(alpha: 0.6),
      connectorWidth: 2.0,
      itemPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
      hoverColor: Colors.deepPurple.withValues(alpha: 0.04),
      focusColor: Colors.deepPurple.withValues(alpha: 0.12),
      splashColor: Colors.deepPurple.withValues(alpha: 0.08),
      highlightColor: Colors.deepPurple.withValues(alpha: 0.04),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('ReorderableTreeListView Demo'),
      ),
      body: Column(
        children: [
          // Theme Controls
          Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme Controls',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: SwitchListTile(
                          title: const Text('Show Connectors'),
                          value: _showConnectors,
                          onChanged: (value) => setState(() => _showConnectors = value),
                          dense: true,
                        ),
                      ),
                      Expanded(
                        child: SwitchListTile(
                          title: const Text('Custom Theme'),
                          value: _showCustomTheme,
                          onChanged: (value) => setState(() => _showCustomTheme = value),
                          dense: true,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: SwitchListTile(
                          title: const Text('Expanded by Default'),
                          value: _expandedByDefault,
                          onChanged: (value) => setState(() => _expandedByDefault = value),
                          dense: true,
                        ),
                      ),
                      Expanded(
                        child: SwitchListTile(
                          title: const Text('Animate Expansion'),
                          value: _animateExpansion,
                          onChanged: (value) => setState(() => _animateExpansion = value),
                          dense: true,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Indent Size:'),
                      Expanded(
                        child: Slider(
                          value: _indentSize,
                          min: 16.0,
                          max: 64.0,
                          divisions: 12,
                          label: _indentSize.round().toString(),
                          onChanged: (value) => setState(() => _indentSize = value),
                        ),
                      ),
                    ],
                  ),
                  SwitchListTile(
                    title: const Text('Enable Drag and Drop'),
                    value: _enableDragAndDrop,
                    onChanged: (value) => setState(() => _enableDragAndDrop = value),
                    dense: true,
                  ),
                ],
              ),
            ),
          ),
          // Drag Status
          if (_dragStatus != null)
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_dragStatus!)),
                  ],
                ),
              ),
            ),
          // Reorder History
          if (_reorderHistory.isNotEmpty)
            Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Reorder History',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        TextButton(
                          onPressed: () => setState(() => _reorderHistory.clear()),
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                    ..._reorderHistory.take(5).map((entry) => Text(
                      entry,
                      style: Theme.of(context).textTheme.bodySmall,
                    )),
                  ],
                ),
              ),
            ),
          // Tree View
          Expanded(
            child: ReorderableTreeListView(
              paths: paths,
              theme: _currentTheme,
              padding: const EdgeInsets.all(8),
              expandedByDefault: _expandedByDefault,
              animateExpansion: _animateExpansion,
              onReorder: _enableDragAndDrop ? (oldPath, newPath) {
                setState(() {
                  // Update paths list
                  paths = List<Uri>.from(paths);
                  paths.remove(oldPath);
                  paths.add(newPath);
                  
                  // Add to history
                  final String shortOld = TreePath.getDisplayName(oldPath);
                  final String shortNew = TreePath.getDisplayName(newPath);
                  final String parent = newPath.pathSegments.isEmpty 
                      ? 'root' 
                      : TreePath.getDisplayName(TreePath.getParentPath(newPath) ?? newPath);
                  _reorderHistory.insert(0, 'Moved $shortOld to $parent as $shortNew');
                  
                  _dragStatus = null;
                });
              } : null,
              onDragStart: _enableDragAndDrop ? (path) {
                setState(() {
                  _dragStatus = 'Dragging: ${TreePath.getDisplayName(path)}';
                });
              } : null,
              onDragEnd: _enableDragAndDrop ? (path) {
                setState(() {
                  if (_dragStatus?.contains('Dragging') ?? false) {
                    _dragStatus = null;
                  }
                });
              } : null,
              onWillAcceptDrop: _enableDragAndDrop ? (draggedPath, targetPath) {
                // Example: Don't allow dropping into 'etc' folder
                if (targetPath.toString().contains('/etc/')) {
                  setState(() {
                    _dragStatus = 'Cannot drop into /etc/ folder';
                  });
                  return false;
                }
                return true;
              } : null,
              proxyDecorator: _enableDragAndDrop ? (child, index, animation) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return Material(
                      elevation: 8 * animation.value,
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.blue.withValues(alpha: 0.1),
                      child: child,
                    );
                  },
                  child: child,
                );
              } : null,
              itemBuilder: (BuildContext context, Uri path) {
                final String displayName = TreePath.getDisplayName(path);
                
                return Row(
                  children: [
                    Icon(
                      Icons.insert_drive_file,
                      color: _showCustomTheme ? Colors.deepPurple : Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(fontWeight: FontWeight.normal),
                          ),
                          Text(
                            path.toString(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              folderBuilder: (BuildContext context, Uri path) {
                final String displayName = TreePath.getDisplayName(path);
                
                return Row(
                  children: [
                    Icon(
                      Icons.folder,
                      color: _showCustomTheme ? Colors.deepPurple.shade300 : Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            path.toString(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
}