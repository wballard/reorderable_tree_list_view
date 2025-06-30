import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

import 'package:example/story_helpers.dart';

/// Stories showcasing user interaction features
final List<Story> interactionStories = [
  Story(
    name: 'Interaction/Drag and Drop',
    description: 'Drag and drop reordering with visual feedback',
    builder: (context) => const _DragDropStory(),
  ),
  Story(
    name: 'Interaction/Selection Modes',
    description: 'Different selection modes (single, multiple, none)',
    builder: (context) => const _SelectionStory(),
  ),
  Story(
    name: 'Interaction/Context Menu',
    description: 'Right-click context menu support',
    builder: (context) => const _ContextMenuStory(),
  ),
  Story(
    name: 'Interaction/Validation',
    description: 'Validation callbacks to control user actions',
    builder: (context) => const _ValidationStory(),
  ),
  Story(
    name: 'Interaction/Event Handling',
    description: 'Comprehensive event handling with callbacks',
    builder: (context) => const _EventHandlingStory(),
  ),
];

/// Drag and drop story with visual feedback
class _DragDropStory extends StatefulWidget {
  const _DragDropStory();

  @override
  State<_DragDropStory> createState() => _DragDropStoryState();
}

class _DragDropStoryState extends State<_DragDropStory> {
  late List<Uri> paths;
  String? _dragStatus;
  final List<String> _reorderHistory = [];

  @override
  void initState() {
    super.initState();
    paths = List.from(StoryHelpers.sampleFilePaths.take(8));
  }

  @override
  Widget build(BuildContext context) {
    final bool enableDragDrop = context.knobs.boolean(
      label: 'Enable Drag & Drop',
      initial: true,
    );
    
    final bool showDragFeedback = context.knobs.boolean(
      label: 'Show Drag Feedback',
      initial: true,
    );

    return StoryWrapper(
      title: 'Drag and Drop',
      description: 'Interactive drag and drop with status feedback',
      child: Column(
        children: [
          // Status and history
          if (_dragStatus != null || _reorderHistory.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_dragStatus != null)
                    Text(
                      'Status: $_dragStatus',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  if (_reorderHistory.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text('Recent reorders:'),
                    ..._reorderHistory.take(3).map((entry) => Text(
                      '• $entry',
                      style: Theme.of(context).textTheme.bodySmall,
                    )),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Tree view
          Expanded(
            child: ReorderableTreeListView(
              paths: paths,
              itemBuilder: (context, path) => StoryItemBuilder.buildFileItem(context, path),
              folderBuilder: (context, path) => StoryItemBuilder.buildFolderItem(context, path),
              onReorder: enableDragDrop ? (oldPath, newPath) {
                setState(() {
                  paths.remove(oldPath);
                  paths.add(newPath);
                  
                  final String oldName = TreePath.getDisplayName(oldPath);
                  final String newName = TreePath.getDisplayName(newPath);
                  _reorderHistory.insert(0, '$oldName → $newName');
                  if (_reorderHistory.length > 10) {
                    _reorderHistory.removeLast();
                  }
                  _dragStatus = null;
                });
              } : null,
              onDragStart: enableDragDrop ? (path) {
                setState(() {
                  _dragStatus = 'Dragging: ${TreePath.getDisplayName(path)}';
                });
              } : null,
              onDragEnd: enableDragDrop ? (path) {
                setState(() {
                  if (_dragStatus?.contains('Dragging') ?? false) {
                    _dragStatus = 'Drag completed';
                  }
                });
              } : null,
              proxyDecorator: showDragFeedback ? (child, index, animation) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return Material(
                      elevation: 8 * animation.value,
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: child,
                    );
                  },
                  child: child,
                );
              } : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// Selection modes story
class _SelectionStory extends StatefulWidget {
  const _SelectionStory();

  @override
  State<_SelectionStory> createState() => _SelectionStoryState();
}

class _SelectionStoryState extends State<_SelectionStory> {
  late List<Uri> paths;
  Set<Uri> selectedPaths = {};

  @override
  void initState() {
    super.initState();
    paths = List.from(StoryHelpers.minimalSamplePaths);
  }

  @override
  Widget build(BuildContext context) {
    final String selectionMode = context.knobs.options(
      label: 'Selection Mode',
      initial: 'single',
      options: [
        const Option(label: 'Single', value: 'single'),
        const Option(label: 'Multiple', value: 'multiple'),
        const Option(label: 'None', value: 'none'),
      ],
    );

    SelectionMode mode;
    switch (selectionMode) {
      case 'multiple':
        mode = SelectionMode.multiple;
        break;
      case 'none':
        mode = SelectionMode.none;
        break;
      case 'single':
      default:
        mode = SelectionMode.single;
        break;
    }

    return StoryWrapper(
      title: 'Selection Modes',
      description: 'Different selection behaviors for tree items',
      child: Column(
        children: [
          // Selection info
          if (selectedPaths.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected (${selectedPaths.length}):',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...selectedPaths.map((path) => Text(
                    '• ${TreePath.getDisplayName(path)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  )),
                ],
              ),
            ),
          if (selectedPaths.isNotEmpty) const SizedBox(height: 16),
          
          // Tree view
          Expanded(
            child: ReorderableTreeListView(
              paths: paths,
              selectionMode: mode,
              initialSelection: selectedPaths,
              itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
              onSelectionChanged: (newSelection) {
                setState(() {
                  selectedPaths = newSelection;
                });
                StoryHelpers.mockSelectionCallback(newSelection);
              },
              onItemTap: StoryHelpers.createLoggingCallback('Item Tap'),
              onItemActivated: StoryHelpers.createLoggingCallback('Item Activated'),
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

/// Context menu story
class _ContextMenuStory extends StatefulWidget {
  const _ContextMenuStory();

  @override
  State<_ContextMenuStory> createState() => _ContextMenuStoryState();
}

class _ContextMenuStoryState extends State<_ContextMenuStory> {
  late List<Uri> paths;
  String? _lastContextMenuAction;

  @override
  void initState() {
    super.initState();
    paths = List.from(StoryHelpers.minimalSamplePaths);
  }

  @override
  Widget build(BuildContext context) {
    return StoryWrapper(
      title: 'Context Menu',
      description: 'Right-click context menu functionality',
      child: Column(
        children: [
          // Instructions
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Instructions:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text('• Right-click on any item to show context menu'),
                const Text('• Context menu actions will be logged'),
                if (_lastContextMenuAction != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Last action: $_lastContextMenuAction',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Tree view
          Expanded(
            child: ReorderableTreeListView(
              paths: paths,
              itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
              onContextMenu: (path, position) {
                _showContextMenu(context, path, position);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showContextMenu(BuildContext context, Uri path, Offset position) {
    final String displayName = TreePath.getDisplayName(path);
    
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy),
      items: <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'copy',
          child: Row(
            children: [
              Icon(Icons.copy, size: 16),
              SizedBox(width: 8),
              Text('Copy'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'rename',
          child: Row(
            children: [
              Icon(Icons.edit, size: 16),
              SizedBox(width: 8),
              Text('Rename'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 16),
              SizedBox(width: 8),
              Text('Delete'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'properties',
          child: Row(
            children: [
              Icon(Icons.info, size: 16),
              SizedBox(width: 8),
              Text('Properties'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value != null) {
        setState(() {
          _lastContextMenuAction = '$value on $displayName';
        });
      }
    });
  }
}

/// Validation story showing how to control user actions
class _ValidationStory extends StatefulWidget {
  const _ValidationStory();

  @override
  State<_ValidationStory> createState() => _ValidationStoryState();
}

class _ValidationStoryState extends State<_ValidationStory> {
  late List<Uri> paths;
  final Set<String> _lockedFolders = {'Documents', 'Pictures'};

  @override
  void initState() {
    super.initState();
    paths = List.from(StoryHelpers.sampleFilePaths.take(6));
  }

  @override
  Widget build(BuildContext context) {
    final bool enableValidation = context.knobs.boolean(
      label: 'Enable Validation',
      initial: true,
    );

    return StoryWrapper(
      title: 'Validation',
      description: 'Control user actions with validation callbacks',
      child: Column(
        children: [
          // Validation rules
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Validation Rules:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                if (enableValidation) ...[
                  const Text('• Cannot expand Documents or Pictures folders'),
                  const Text('• Cannot drag files with .pdf extension'),
                  const Text('• Cannot drop into Music folder'),
                ] else
                  const Text('• No validation (all actions allowed)'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Tree view
          Expanded(
            child: ReorderableTreeListView(
              paths: paths,
              itemBuilder: (context, path) => StoryItemBuilder.buildFileItem(context, path),
              folderBuilder: (context, path) => StoryItemBuilder.buildFolderItem(context, path),
              canExpand: enableValidation ? (path) {
                final String folderName = TreePath.getDisplayName(path);
                final bool canExpand = !_lockedFolders.contains(folderName);
                if (!canExpand) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Cannot expand $folderName folder')),
                  );
                }
                return canExpand;
              } : null,
              canDrag: enableValidation ? (path) {
                final String fileName = TreePath.getDisplayName(path);
                final bool canDrag = !fileName.endsWith('.pdf');
                if (!canDrag) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cannot drag PDF files')),
                  );
                }
                return canDrag;
              } : null,
              canDrop: enableValidation ? (draggedPath, targetPath) {
                final String targetName = TreePath.getDisplayName(targetPath);
                final bool canDrop = targetName != 'Music';
                if (!canDrop) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cannot drop into Music folder')),
                  );
                }
                return canDrop;
              } : null,
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

/// Comprehensive event handling story
class _EventHandlingStory extends StatefulWidget {
  const _EventHandlingStory();

  @override
  State<_EventHandlingStory> createState() => _EventHandlingStoryState();
}

class _EventHandlingStoryState extends State<_EventHandlingStory> {
  late List<Uri> paths;
  final List<String> _eventLog = [];

  @override
  void initState() {
    super.initState();
    paths = List.from(StoryHelpers.minimalSamplePaths);
  }

  void _logEvent(String event) {
    setState(() {
      _eventLog.insert(0, '${DateTime.now().toLocal().toString().split(' ')[1].split('.')[0]} - $event');
      if (_eventLog.length > 20) {
        _eventLog.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoryWrapper(
      title: 'Event Handling',
      description: 'Comprehensive event logging and handling',
      child: Row(
        children: [
          // Tree view
          Expanded(
            flex: 2,
            child: ReorderableTreeListView(
              paths: paths,
              itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
              onReorder: (oldPath, newPath) {
                setState(() {
                  paths.remove(oldPath);
                  paths.add(newPath);
                });
                _logEvent('Reorder: ${TreePath.getDisplayName(oldPath)} → ${TreePath.getDisplayName(newPath)}');
              },
              onExpandStart: (path) => _logEvent('Expand Start: ${TreePath.getDisplayName(path)}'),
              onExpandEnd: (path) => _logEvent('Expand End: ${TreePath.getDisplayName(path)}'),
              onCollapseStart: (path) => _logEvent('Collapse Start: ${TreePath.getDisplayName(path)}'),
              onCollapseEnd: (path) => _logEvent('Collapse End: ${TreePath.getDisplayName(path)}'),
              onDragStart: (path) => _logEvent('Drag Start: ${TreePath.getDisplayName(path)}'),
              onDragEnd: (path) => _logEvent('Drag End: ${TreePath.getDisplayName(path)}'),
              onItemTap: (path) => _logEvent('Item Tap: ${TreePath.getDisplayName(path)}'),
              onItemActivated: (path) => _logEvent('Item Activated: ${TreePath.getDisplayName(path)}'),
              onSelectionChanged: (selection) => _logEvent('Selection: ${selection.length} items'),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Event log
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Event Log',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _eventLog.clear()),
                      icon: const Icon(Icons.clear, size: 20),
                      tooltip: 'Clear log',
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: _eventLog.isEmpty
                        ? const Center(child: Text('No events yet...'))
                        : ListView.builder(
                            itemCount: _eventLog.length,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                _eventLog[index],
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}