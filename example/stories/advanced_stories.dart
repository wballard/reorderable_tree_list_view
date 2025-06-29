import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storybook_flutter/storybook_flutter.dart';
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

import 'package:example/story_helpers.dart';

/// Advanced stories showcasing complex integration scenarios
final List<Story> advancedStories = [
  Story(
    name: 'Advanced/File Explorer',
    description: 'Complete file explorer implementation',
    builder: (context) => const _FileExplorerStory(),
  ),
  Story(
    name: 'Advanced/Project Navigator',
    description: 'VS Code-style project navigator',
    builder: (context) => const _ProjectNavigatorStory(),
  ),
  Story(
    name: 'Advanced/Persistent State',
    description: 'Save and restore expansion state',
    builder: (context) => const _PersistentStateStory(),
  ),
  Story(
    name: 'Advanced/Undo/Redo',
    description: 'Undo/redo functionality for tree operations',
    builder: (context) => const _UndoRedoStory(),
  ),
  Story(
    name: 'Advanced/Custom Shortcuts',
    description: 'Custom keyboard shortcuts and actions',
    builder: (context) => const _CustomShortcutsStory(),
  ),
];

/// File explorer implementation story
class _FileExplorerStory extends StatefulWidget {
  const _FileExplorerStory();

  @override
  State<_FileExplorerStory> createState() => _FileExplorerStoryState();
}

class _FileExplorerStoryState extends State<_FileExplorerStory> {
  late List<Uri> paths;
  Set<Uri> selectedPaths = {};
  String? lastAction;

  @override
  void initState() {
    super.initState();
    paths = List.from(StoryHelpers.sampleFilePaths);
  }

  void _handleContextMenu(Uri path, Offset globalPosition) {
    setState(() {
      lastAction = 'Context menu at ${TreePath.getDisplayName(path)}';
    });

    // Show a custom context menu
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        globalPosition.dx,
        globalPosition.dy,
        globalPosition.dx,
        globalPosition.dy,
      ),
      items: [
        const PopupMenuItem<String>(
          value: 'open',
          child: ListTile(
            leading: Icon(Icons.open_in_new),
            title: Text('Open'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'rename',
          child: ListTile(
            leading: Icon(Icons.edit),
            title: Text('Rename'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete),
            title: Text('Delete'),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'properties',
          child: ListTile(
            leading: Icon(Icons.info),
            title: Text('Properties'),
          ),
        ),
      ],
    ).then((String? value) {
      if (value != null) {
        setState(() {
          lastAction = '$value: ${TreePath.getDisplayName(path)}';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoryWrapper(
      title: 'File Explorer',
      description: 'Full-featured file explorer with context menus and selection',
      child: Column(
        children: [
          // Toolbar
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => setState(() => lastAction = 'Navigate back'),
                  tooltip: 'Back',
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () => setState(() => lastAction = 'Navigate forward'),
                  tooltip: 'Forward',
                ),
                const VerticalDivider(),
                IconButton(
                  icon: const Icon(Icons.create_new_folder),
                  onPressed: () => setState(() => lastAction = 'New folder'),
                  tooltip: 'New Folder',
                ),
                IconButton(
                  icon: const Icon(Icons.upload_file),
                  onPressed: () => setState(() => lastAction = 'Upload file'),
                  tooltip: 'Upload',
                ),
                const Spacer(),
                if (selectedPaths.isNotEmpty)
                  Text('${selectedPaths.length} selected'),
                if (lastAction != null) ...[
                  const SizedBox(width: 16),
                  Chip(
                    label: Text(lastAction!),
                    onDeleted: () => setState(() => lastAction = null),
                  ),
                ],
              ],
            ),
          ),
          
          // File tree
          Expanded(
            child: ReorderableTreeListView(
              paths: paths,
              theme: const TreeTheme(
                indentSize: 24,
                showConnectors: false,
              ),
              selectionMode: SelectionMode.multiple,
              initialSelection: selectedPaths,
              itemBuilder: (context, path) => _buildFileItem(context, path),
              folderBuilder: (context, path) => _buildFolderItem(context, path),
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
                  lastAction = 'Opened ${TreePath.getDisplayName(path)}';
                });
              },
              onContextMenu: _handleContextMenu,
            ),
          ),
          
          // Status bar
          Container(
            height: 24,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  '${paths.length} items',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                Text(
                  'File Explorer Demo',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileItem(BuildContext context, Uri path) {
    final String displayName = TreePath.getDisplayName(path);
    final bool isSelected = selectedPaths.contains(path);
    
    return Container(
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
          : null,
      child: StoryItemBuilder.buildFileItem(context, path),
    );
  }

  Widget _buildFolderItem(BuildContext context, Uri path) {
    final String displayName = TreePath.getDisplayName(path);
    final bool isSelected = selectedPaths.contains(path);
    
    return Container(
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
          : null,
      child: StoryItemBuilder.buildFolderItem(context, path),
    );
  }
}

/// Project navigator story (VS Code style)
class _ProjectNavigatorStory extends StatefulWidget {
  const _ProjectNavigatorStory();

  @override
  State<_ProjectNavigatorStory> createState() => _ProjectNavigatorStoryState();
}

class _ProjectNavigatorStoryState extends State<_ProjectNavigatorStory> {
  late List<Uri> paths;
  Uri? activeFile;
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    paths = _generateProjectStructure();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Uri> _generateProjectStructure() {
    return [
      Uri.parse('file:///project/.gitignore'),
      Uri.parse('file:///project/README.md'),
      Uri.parse('file:///project/pubspec.yaml'),
      Uri.parse('file:///project/analysis_options.yaml'),
      Uri.parse('file:///project/lib/main.dart'),
      Uri.parse('file:///project/lib/src/widgets/tree_view.dart'),
      Uri.parse('file:///project/lib/src/widgets/tree_item.dart'),
      Uri.parse('file:///project/lib/src/models/tree_node.dart'),
      Uri.parse('file:///project/lib/src/models/tree_path.dart'),
      Uri.parse('file:///project/lib/src/controllers/tree_controller.dart'),
      Uri.parse('file:///project/lib/src/theme/tree_theme.dart'),
      Uri.parse('file:///project/test/widget_test.dart'),
      Uri.parse('file:///project/test/unit_test.dart'),
      Uri.parse('file:///project/example/main.dart'),
      Uri.parse('file:///project/example/stories/basic_stories.dart'),
      Uri.parse('file:///project/example/stories/advanced_stories.dart'),
    ];
  }

  List<Uri> get filteredPaths {
    if (searchQuery.isEmpty) return paths;
    
    return paths.where((path) {
      final String pathStr = path.toString().toLowerCase();
      return pathStr.contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool showOnlyModified = context.knobs.boolean(
      label: 'Show Only Modified',
      initial: false,
    );

    return StoryWrapper(
      title: 'Project Navigator',
      description: 'VS Code-style project file navigator with search',
      showPadding: false,
      child: Row(
        children: [
          // Sidebar
          Container(
            width: 300,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: Column(
              children: [
                // Explorer header
                Container(
                  height: 35,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Text(
                        'EXPLORER',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 16),
                        onPressed: () => setState(() {
                          paths = _generateProjectStructure();
                        }),
                      ),
                    ],
                  ),
                ),
                
                // Search box
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search files...',
                      prefixIcon: Icon(Icons.search, size: 16),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => searchQuery = value),
                  ),
                ),
                
                // File tree
                Expanded(
                  child: ReorderableTreeListView(
                    paths: filteredPaths,
                    theme: const TreeTheme(
                      indentSize: 20,
                      showConnectors: false,
                      itemPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    ),
                    expandedByDefault: true,
                    itemBuilder: (context, path) => _buildProjectItem(context, path),
                    folderBuilder: (context, path) => _buildProjectFolder(context, path),
                    onItemActivated: (path) {
                      setState(() {
                        activeFile = path;
                      });
                    },
                    onReorder: null, // Disable reordering for project navigator
                  ),
                ),
              ],
            ),
          ),
          
          // Editor area
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: activeFile != null
                  ? Column(
                      children: [
                        // Tab bar
                        Container(
                          height: 35,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            border: Border(
                              bottom: BorderSide(
                                color: Theme.of(context).dividerColor,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  border: Border(
                                    right: BorderSide(
                                      color: Theme.of(context).dividerColor,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.code, size: 16),
                                    const SizedBox(width: 8),
                                    Text(TreePath.getDisplayName(activeFile!)),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () => setState(() => activeFile = null),
                                      child: const Icon(Icons.close, size: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Editor content
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              _getFileContent(activeFile!),
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Center(
                      child: Text(
                        'Select a file to open',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectItem(BuildContext context, Uri path) {
    final String displayName = TreePath.getDisplayName(path);
    final bool isActive = path == activeFile;
    
    return Container(
      color: isActive
          ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
          : null,
      child: Row(
        children: [
          Icon(
            _getFileIcon(displayName),
            size: 16,
            color: _getFileIconColor(displayName),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              displayName,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectFolder(BuildContext context, Uri path) {
    final String displayName = TreePath.getDisplayName(path);
    
    return Row(
      children: [
        Icon(
          Icons.folder,
          size: 16,
          color: Colors.amber[700],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            displayName,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getFileIcon(String fileName) {
    if (fileName.endsWith('.dart')) return Icons.code;
    if (fileName.endsWith('.yaml') || fileName.endsWith('.yml')) return Icons.settings;
    if (fileName.endsWith('.md')) return Icons.description;
    if (fileName.endsWith('.gitignore')) return Icons.block;
    return Icons.insert_drive_file;
  }

  Color _getFileIconColor(String fileName) {
    if (fileName.endsWith('.dart')) return Colors.blue;
    if (fileName.endsWith('.yaml') || fileName.endsWith('.yml')) return Colors.green;
    if (fileName.endsWith('.md')) return Colors.grey;
    if (fileName.endsWith('.gitignore')) return Colors.red;
    return Colors.grey;
  }

  String _getFileContent(Uri path) {
    final String fileName = TreePath.getDisplayName(path);
    
    if (fileName.endsWith('.dart')) {
      return '''import 'package:flutter/material.dart';

class ${_getClassName(fileName)} extends StatelessWidget {
  const ${_getClassName(fileName)}({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('${fileName}'),
    );
  }
}''';
    }
    
    if (fileName == 'pubspec.yaml') {
      return '''name: reorderable_tree_list_view
description: A Flutter widget for displaying hierarchical data
version: 1.0.0

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0''';
    }
    
    if (fileName == 'README.md') {
      return '''# ReorderableTreeListView

A Flutter widget for displaying hierarchical data with drag-and-drop reordering.

## Features

- Automatic tree structure generation
- Drag and drop reordering
- Expand/collapse animations
- Keyboard navigation
- Accessibility support

## Usage

```dart
ReorderableTreeListView(
  paths: myPaths,
  itemBuilder: (context, path) => Text(path.toString()),
  onReorder: (oldPath, newPath) {
    // Handle reordering
  },
)
```''';
    }
    
    return '// Content of $fileName';
  }

  String _getClassName(String fileName) {
    return fileName
        .replaceAll('.dart', '')
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join();
  }
}

/// Persistent state story
class _PersistentStateStory extends StatefulWidget {
  const _PersistentStateStory();

  @override
  State<_PersistentStateStory> createState() => _PersistentStateStoryState();
}

class _PersistentStateStoryState extends State<_PersistentStateStory> {
  late List<Uri> paths;
  Set<Uri> expandedPaths = {};
  Set<Uri> savedExpandedPaths = {};

  @override
  void initState() {
    super.initState();
    paths = List.from(StoryHelpers.sampleFilePaths);
  }

  void _saveState() {
    setState(() {
      savedExpandedPaths = Set.from(expandedPaths);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Expansion state saved'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _restoreState() {
    setState(() {
      expandedPaths = Set.from(savedExpandedPaths);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Expansion state restored'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _clearState() {
    setState(() {
      expandedPaths.clear();
      savedExpandedPaths.clear();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('State cleared'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StoryWrapper(
      title: 'Persistent State',
      description: 'Save and restore tree expansion state',
      child: Column(
        children: [
          // Control buttons
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'State Management',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _saveState,
                        icon: const Icon(Icons.save),
                        label: const Text('Save State'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _restoreState,
                        icon: const Icon(Icons.restore),
                        label: const Text('Restore State'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _clearState,
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear State'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Expanded nodes: ${expandedPaths.length}'),
                  Text('Saved nodes: ${savedExpandedPaths.length}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Tree view
          Expanded(
            child: ReorderableTreeListView(
              paths: paths,
              expandedByDefault: false,
              initiallyExpanded: expandedPaths,
              itemBuilder: (context, path) => StoryItemBuilder.buildFileItem(context, path),
              folderBuilder: (context, path) => StoryItemBuilder.buildFolderItem(context, path),
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

/// Undo/Redo story
class _UndoRedoStory extends StatefulWidget {
  const _UndoRedoStory();

  @override
  State<_UndoRedoStory> createState() => _UndoRedoStoryState();
}

class _UndoRedoAction {
  final Uri oldPath;
  final Uri newPath;
  final DateTime timestamp;

  _UndoRedoAction({
    required this.oldPath,
    required this.newPath,
    required this.timestamp,
  });
}

class _UndoRedoStoryState extends State<_UndoRedoStory> {
  late List<Uri> paths;
  final List<_UndoRedoAction> undoStack = [];
  final List<_UndoRedoAction> redoStack = [];

  @override
  void initState() {
    super.initState();
    paths = List.from(StoryHelpers.minimalSamplePaths);
  }

  bool get canUndo => undoStack.isNotEmpty;
  bool get canRedo => redoStack.isNotEmpty;

  void _undo() {
    if (!canUndo) return;

    setState(() {
      final action = undoStack.removeLast();
      
      // Revert the action
      paths.remove(action.newPath);
      paths.add(action.oldPath);
      
      // Add to redo stack
      redoStack.add(action);
    });
  }

  void _redo() {
    if (!canRedo) return;

    setState(() {
      final action = redoStack.removeLast();
      
      // Replay the action
      paths.remove(action.oldPath);
      paths.add(action.newPath);
      
      // Add back to undo stack
      undoStack.add(action);
    });
  }

  void _clearHistory() {
    setState(() {
      undoStack.clear();
      redoStack.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoryWrapper(
      title: 'Undo/Redo',
      description: 'Undo and redo tree operations',
      child: Column(
        children: [
          // Toolbar
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: canUndo ? _undo : null,
                    icon: const Icon(Icons.undo),
                    tooltip: 'Undo (${undoStack.length} actions)',
                  ),
                  IconButton(
                    onPressed: canRedo ? _redo : null,
                    icon: const Icon(Icons.redo),
                    tooltip: 'Redo (${redoStack.length} actions)',
                  ),
                  const VerticalDivider(),
                  TextButton.icon(
                    onPressed: undoStack.isEmpty && redoStack.isEmpty
                        ? null
                        : _clearHistory,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear History'),
                  ),
                  const Spacer(),
                  Text('History: ${undoStack.length} actions'),
                ],
              ),
            ),
          ),
          
          // History view
          if (undoStack.isNotEmpty || redoStack.isNotEmpty)
            Card(
              child: Container(
                height: 100,
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    // Undo history
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Undo History',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Expanded(
                            child: ListView.builder(
                              itemCount: undoStack.length,
                              itemBuilder: (context, index) {
                                final action = undoStack[undoStack.length - 1 - index];
                                return Text(
                                  '${TreePath.getDisplayName(action.oldPath)} → ${TreePath.getDisplayName(action.newPath)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const VerticalDivider(),
                    // Redo history
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Redo History',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Expanded(
                            child: ListView.builder(
                              itemCount: redoStack.length,
                              itemBuilder: (context, index) {
                                final action = redoStack[redoStack.length - 1 - index];
                                return Text(
                                  '${TreePath.getDisplayName(action.oldPath)} → ${TreePath.getDisplayName(action.newPath)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Tree view
          Expanded(
            child: ReorderableTreeListView(
              paths: paths,
              itemBuilder: (context, path) => StoryItemBuilder.buildFileItem(context, path),
              folderBuilder: (context, path) => StoryItemBuilder.buildFolderItem(context, path),
              onReorder: (oldPath, newPath) {
                setState(() {
                  // Perform the action
                  paths.remove(oldPath);
                  paths.add(newPath);
                  
                  // Add to undo stack
                  undoStack.add(_UndoRedoAction(
                    oldPath: oldPath,
                    newPath: newPath,
                    timestamp: DateTime.now(),
                  ));
                  
                  // Clear redo stack when new action is performed
                  redoStack.clear();
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom shortcuts story
class _CustomShortcutsStory extends StatefulWidget {
  const _CustomShortcutsStory();

  @override
  State<_CustomShortcutsStory> createState() => _CustomShortcutsStoryState();
}

class _CustomShortcutsStoryState extends State<_CustomShortcutsStory> {
  late List<Uri> paths;
  final List<String> actionLog = [];
  Uri? selectedPath;

  @override
  void initState() {
    super.initState();
    paths = List.from(StoryHelpers.minimalSamplePaths);
  }

  void _logAction(String action) {
    setState(() {
      actionLog.insert(0, '${DateTime.now().toLocal().toString().split(' ')[1].split('.')[0]} - $action');
      if (actionLog.length > 20) {
        actionLog.removeLast();
      }
    });
  }

  void _duplicateItem() {
    if (selectedPath == null) return;
    
    setState(() {
      final String baseName = TreePath.getDisplayName(selectedPath!);
      final String newName = '${baseName}_copy';
      final Uri? parentPath = TreePath.getParentPath(selectedPath!);
      final Uri newPath = parentPath != null
          ? parentPath.resolve(newName)
          : Uri.parse('file:///$newName');
      
      paths.add(newPath);
      _logAction('Duplicated: $baseName → $newName');
    });
  }

  void _deleteItem() {
    if (selectedPath == null) return;
    
    setState(() {
      final String name = TreePath.getDisplayName(selectedPath!);
      paths.remove(selectedPath!);
      _logAction('Deleted: $name');
      selectedPath = null;
    });
  }

  void _renameItem() {
    if (selectedPath == null) return;
    
    final String currentName = TreePath.getDisplayName(selectedPath!);
    _logAction('Rename: $currentName (not implemented in demo)');
  }

  @override
  Widget build(BuildContext context) {
    return StoryWrapper(
      title: 'Custom Shortcuts',
      description: 'Custom keyboard shortcuts and actions',
      child: Row(
        children: [
          // Tree and shortcuts
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // Shortcut reference
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Custom Shortcuts',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text('Ctrl+D - Duplicate item'),
                                  Text('Delete - Delete item'),
                                  Text('F2 - Rename item'),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text('Ctrl+X - Cut'),
                                  Text('Ctrl+C - Copy'),
                                  Text('Ctrl+V - Paste'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Tree view with shortcuts
                Expanded(
                  child: Shortcuts(
                    shortcuts: <LogicalKeySet, Intent>{
                      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyD):
                          const _DuplicateIntent(),
                      LogicalKeySet(LogicalKeyboardKey.delete):
                          const _DeleteIntent(),
                      LogicalKeySet(LogicalKeyboardKey.f2):
                          const _RenameIntent(),
                    },
                    child: Actions(
                      actions: <Type, Action<Intent>>{
                        _DuplicateIntent: CallbackAction<_DuplicateIntent>(
                          onInvoke: (_) => _duplicateItem(),
                        ),
                        _DeleteIntent: CallbackAction<_DeleteIntent>(
                          onInvoke: (_) => _deleteItem(),
                        ),
                        _RenameIntent: CallbackAction<_RenameIntent>(
                          onInvoke: (_) => _renameItem(),
                        ),
                      },
                      child: Focus(
                        autofocus: true,
                        child: ReorderableTreeListView(
                          paths: paths,
                          selectionMode: SelectionMode.single,
                          itemBuilder: (context, path) => StoryItemBuilder.buildFileItem(context, path),
                          folderBuilder: (context, path) => StoryItemBuilder.buildFolderItem(context, path),
                          onReorder: (oldPath, newPath) {
                            setState(() {
                              paths.remove(oldPath);
                              paths.add(newPath);
                              _logAction('Moved: ${TreePath.getDisplayName(oldPath)}');
                            });
                          },
                          onSelectionChanged: (selection) {
                            setState(() {
                              selectedPath = selection.isEmpty ? null : selection.first;
                              if (selectedPath != null) {
                                _logAction('Selected: ${TreePath.getDisplayName(selectedPath!)}');
                              }
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Action log
          SizedBox(
            width: 300,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Action Log',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => setState(() => actionLog.clear()),
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                    const Divider(),
                    Expanded(
                      child: actionLog.isEmpty
                          ? const Center(
                              child: Text(
                                'No actions yet...',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: actionLog.length,
                              itemBuilder: (context, index) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  actionLog[index],
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom intents for shortcuts
class _DuplicateIntent extends Intent {
  const _DuplicateIntent();
}

class _DeleteIntent extends Intent {
  const _DeleteIntent();
}

class _RenameIntent extends Intent {
  const _RenameIntent();
}