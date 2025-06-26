import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

import 'package:example/story_helpers.dart';

/// Stories showcasing accessibility and keyboard navigation features
final List<Story> accessibilityStories = [
  Story(
    name: 'Accessibility/Keyboard Navigation',
    description: 'Navigate the tree using keyboard shortcuts',
    builder: (context) => const _KeyboardNavigationStory(),
  ),
  Story(
    name: 'Accessibility/Screen Reader',
    description: 'Screen reader support and semantic labels',
    builder: (context) => const _ScreenReaderStory(),
  ),
  Story(
    name: 'Accessibility/Focus Management',
    description: 'Focus management and visual indicators',
    builder: (context) => const _FocusManagementStory(),
  ),
  Story(
    name: 'Accessibility/High Contrast',
    description: 'High contrast themes for accessibility',
    builder: (context) => const _HighContrastStory(),
  ),
  Story(
    name: 'Accessibility/Voice Control',
    description: 'Voice control and spoken feedback',
    builder: (context) => const _VoiceControlStory(),
  ),
];

/// Keyboard navigation story
class _KeyboardNavigationStory extends StatefulWidget {
  const _KeyboardNavigationStory();

  @override
  State<_KeyboardNavigationStory> createState() => _KeyboardNavigationStoryState();
}

class _KeyboardNavigationStoryState extends State<_KeyboardNavigationStory> {
  late List<Uri> paths;
  final List<String> _actionLog = [];

  @override
  void initState() {
    super.initState();
    paths = List.from(StoryHelpers.sampleFilePaths.take(8));
  }

  void _logAction(String action) {
    setState(() {
      _actionLog.insert(0, '${DateTime.now().toLocal().toString().split(' ')[1].split('.')[0]} - $action');
      if (_actionLog.length > 10) {
        _actionLog.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool enableKeyboardShortcuts = context.knobs.boolean(
      label: 'Enable Keyboard Shortcuts',
      initial: true,
    );

    return StoryWrapper(
      title: 'Keyboard Navigation',
      description: 'Navigate and interact with the tree using keyboard',
      child: Row(
        children: [
          // Tree view
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // Instructions
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
                      const Text(
                        'Keyboard Shortcuts:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text('• Arrow keys: Navigate'),
                      const Text('• Enter/Space: Activate item'),
                      const Text('• Tab: Focus next'),
                      const Text('• Shift+Tab: Focus previous'),
                      if (enableKeyboardShortcuts) ...[
                        const Text('• Ctrl+A: Select all'),
                        const Text('• Delete: Delete selected'),
                        const Text('• F2: Rename'),
                        const Text('• Ctrl+C: Copy'),
                        const Text('• Ctrl+V: Paste'),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Tree
                Expanded(
                  child: Focus(
                    autofocus: true,
                    child: enableKeyboardShortcuts
                        ? _buildTree()
                        : _buildTree(),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Action log
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Action Log',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: _actionLog.isEmpty
                        ? const Center(child: Text('No actions yet...'))
                        : ListView.builder(
                            itemCount: _actionLog.length,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                _actionLog[index],
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

  Widget _buildTree() {
    return ReorderableTreeListView(
      paths: paths,
      selectionMode: SelectionMode.multiple,
      itemBuilder: (context, path) => StoryItemBuilder.buildFileItem(context, path),
      folderBuilder: (context, path) => StoryItemBuilder.buildFolderItem(context, path),
      onReorder: (oldPath, newPath) {
        setState(() {
          paths.remove(oldPath);
          paths.add(newPath);
        });
        _logAction('Reorder: ${TreePath.getDisplayName(oldPath)} → ${TreePath.getDisplayName(newPath)}');
      },
      onItemTap: (path) => _logAction('Tap: ${TreePath.getDisplayName(path)}'),
      onItemActivated: (path) => _logAction('Activate: ${TreePath.getDisplayName(path)}'),
      onSelectionChanged: (selection) => _logAction('Selection: ${selection.length} items'),
    );
  }
}

// Note: Custom keyboard shortcuts could be implemented here with proper Intent classes

/// Screen reader story
class _ScreenReaderStory extends StatefulWidget {
  const _ScreenReaderStory();

  @override
  State<_ScreenReaderStory> createState() => _ScreenReaderStoryState();
}

class _ScreenReaderStoryState extends State<_ScreenReaderStory> {
  late List<Uri> paths;

  @override
  void initState() {
    super.initState();
    paths = List.from(StoryHelpers.minimalSamplePaths);
  }

  @override
  Widget build(BuildContext context) {
    final bool verboseLabels = context.knobs.boolean(
      label: 'Verbose Labels',
      initial: true,
    );
    
    final bool includeHints = context.knobs.boolean(
      label: 'Include Hints',
      initial: true,
    );

    return StoryWrapper(
      title: 'Screen Reader Support',
      description: 'Semantic labels and screen reader accessibility',
      child: Column(
        children: [
          // Accessibility info
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
                  'Screen Reader Features:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text('• Semantic labels for all interactive elements'),
                const Text('• ARIA live regions for dynamic updates'),
                const Text('• Proper focus management'),
                const Text('• Descriptive hints and instructions'),
                if (verboseLabels)
                  const Text('• Verbose mode: Detailed descriptions'),
                if (includeHints)
                  const Text('• Hints: Action guidance'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Tree view
          Expanded(
            child: ReorderableTreeListView(
              paths: paths,
              itemBuilder: (context, path) => _buildAccessibleItem(context, path, verboseLabels, includeHints),
              folderBuilder: (context, path) => _buildAccessibleFolder(context, path, verboseLabels, includeHints),
              onReorder: (oldPath, newPath) {
                setState(() {
                  paths.remove(oldPath);
                  paths.add(newPath);
                });
                
                // Announce the reorder to screen readers
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Moved ${TreePath.getDisplayName(oldPath)} to ${TreePath.getDisplayName(newPath)}',
                    ),
                    duration: const Duration(milliseconds: 1500),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessibleItem(BuildContext context, Uri path, bool verboseLabels, bool includeHints) {
    final String displayName = TreePath.getDisplayName(path);
    final String semanticLabel = verboseLabels
        ? 'File: $displayName, Path: ${path.toString()}'
        : 'File: $displayName';
    final String hint = includeHints
        ? 'Double tap to open, swipe for options'
        : '';

    return Semantics(
      label: semanticLabel,
      hint: hint,
      button: true,
      child: StoryItemBuilder.buildFileItem(context, path),
    );
  }

  Widget _buildAccessibleFolder(BuildContext context, Uri path, bool verboseLabels, bool includeHints) {
    final String displayName = TreePath.getDisplayName(path);
    final String semanticLabel = verboseLabels
        ? 'Folder: $displayName, Path: ${path.toString()}'
        : 'Folder: $displayName';
    final String hint = includeHints
        ? 'Double tap to expand, swipe for options'
        : '';

    return Semantics(
      label: semanticLabel,
      hint: hint,
      button: true,
      child: StoryItemBuilder.buildFolderItem(context, path),
    );
  }
}

/// Focus management story
class _FocusManagementStory extends StatefulWidget {
  const _FocusManagementStory();

  @override
  State<_FocusManagementStory> createState() => _FocusManagementStoryState();
}

class _FocusManagementStoryState extends State<_FocusManagementStory> {
  late List<Uri> paths;
  final FocusNode _treeFocusNode = FocusNode();
  Uri? _focusedPath;

  @override
  void initState() {
    super.initState();
    paths = List.from(StoryHelpers.minimalSamplePaths);
  }

  @override
  void dispose() {
    _treeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool showFocusIndicator = context.knobs.boolean(
      label: 'Show Focus Indicator',
      initial: true,
    );
    
    final bool autofocus = context.knobs.boolean(
      label: 'Autofocus Tree',
      initial: true,
    );

    return StoryWrapper(
      title: 'Focus Management',
      description: 'Visual focus indicators and focus management',
      child: Column(
        children: [
          // Focus controls
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () => _treeFocusNode.requestFocus(),
                  child: const Text('Focus Tree'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _treeFocusNode.unfocus(),
                  child: const Text('Unfocus'),
                ),
                const Spacer(),
                if (_focusedPath != null)
                  Text('Focused: ${TreePath.getDisplayName(_focusedPath!)}')
                else
                  const Text('No item focused'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Tree view
          Expanded(
            child: Focus(
              focusNode: _treeFocusNode,
              autofocus: autofocus,
              child: ReorderableTreeListView(
                paths: paths,
                theme: TreeTheme(
                  focusColor: showFocusIndicator
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                      : Colors.transparent,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                itemBuilder: (context, path) => _buildFocusableItem(context, path),
                folderBuilder: (context, path) => _buildFocusableFolder(context, path),
                onItemTap: (path) {
                  setState(() {
                    _focusedPath = path;
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
          ),
        ],
      ),
    );
  }

  Widget _buildFocusableItem(BuildContext context, Uri path) {
    final bool isFocused = _focusedPath == path;
    
    return Container(
      decoration: isFocused
          ? BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: StoryItemBuilder.buildFileItem(context, path),
    );
  }

  Widget _buildFocusableFolder(BuildContext context, Uri path) {
    final bool isFocused = _focusedPath == path;
    
    return Container(
      decoration: isFocused
          ? BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: StoryItemBuilder.buildFolderItem(context, path),
    );
  }
}

/// High contrast story
class _HighContrastStory extends StatefulWidget {
  const _HighContrastStory();

  @override
  State<_HighContrastStory> createState() => _HighContrastStoryState();
}

class _HighContrastStoryState extends State<_HighContrastStory> {
  late List<Uri> paths;

  @override
  void initState() {
    super.initState();
    paths = List.from(StoryHelpers.sampleFilePaths.take(6));
  }

  @override
  Widget build(BuildContext context) {
    final bool useHighContrast = context.knobs.boolean(
      label: 'High Contrast Mode',
      initial: false,
    );
    
    final bool largeFonts = context.knobs.boolean(
      label: 'Large Fonts',
      initial: false,
    );

    final TreeTheme theme = useHighContrast
        ? TreeTheme(
            indentSize: 40.0,
            showConnectors: true,
            connectorColor: Colors.black,
            connectorWidth: 3.0,
            itemPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            borderRadius: const BorderRadius.all(Radius.circular(4.0)),
            hoverColor: Colors.yellow.withValues(alpha: 0.3),
            focusColor: Colors.blue.withValues(alpha: 0.5),
            splashColor: Colors.grey.withValues(alpha: 0.5),
            highlightColor: Colors.yellow.withValues(alpha: 0.2),
          )
        : TreeTheme(
            indentSize: largeFonts ? 40.0 : 32.0,
            itemPadding: largeFonts
                ? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0)
                : const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          );

    return StoryWrapper(
      title: 'High Contrast',
      description: 'High contrast themes for better accessibility',
      child: Column(
        children: [
          // Accessibility settings
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: useHighContrast ? Colors.yellow.shade100 : Theme.of(context).colorScheme.surfaceContainerHighest,
              border: useHighContrast ? Border.all(color: Colors.black, width: 2) : null,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Accessibility Settings:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: largeFonts ? 18 : 14,
                    color: useHighContrast ? Colors.black : null,
                  ),
                ),
                Text(
                  useHighContrast ? '• High contrast colors enabled' : '• Normal contrast',
                  style: TextStyle(
                    fontSize: largeFonts ? 16 : 14,
                    color: useHighContrast ? Colors.black : null,
                  ),
                ),
                Text(
                  largeFonts ? '• Large fonts enabled' : '• Normal font size',
                  style: TextStyle(
                    fontSize: largeFonts ? 16 : 14,
                    color: useHighContrast ? Colors.black : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Tree view
          Expanded(
            child: Container(
              decoration: useHighContrast
                  ? BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 2),
                    )
                  : null,
              child: ReorderableTreeListView(
                paths: paths,
                theme: theme,
                itemBuilder: (context, path) => _buildHighContrastItem(context, path, useHighContrast, largeFonts),
                folderBuilder: (context, path) => _buildHighContrastFolder(context, path, useHighContrast, largeFonts),
                onReorder: (oldPath, newPath) {
                  setState(() {
                    paths.remove(oldPath);
                    paths.add(newPath);
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighContrastItem(BuildContext context, Uri path, bool highContrast, bool largeFonts) {
    final String displayName = TreePath.getDisplayName(path);
    
    return Row(
      children: [
        Icon(
          Icons.insert_drive_file,
          size: largeFonts ? 24 : 20,
          color: highContrast ? Colors.black : Colors.blue,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            displayName,
            style: TextStyle(
              fontSize: largeFonts ? 18 : 14,
              color: highContrast ? Colors.black : null,
              fontWeight: highContrast ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHighContrastFolder(BuildContext context, Uri path, bool highContrast, bool largeFonts) {
    final String displayName = TreePath.getDisplayName(path);
    
    return Row(
      children: [
        Icon(
          Icons.folder,
          size: largeFonts ? 24 : 20,
          color: highContrast ? Colors.black : Colors.amber[700],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            displayName,
            style: TextStyle(
              fontSize: largeFonts ? 18 : 14,
              color: highContrast ? Colors.black : null,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

/// Voice control story
class _VoiceControlStory extends StatefulWidget {
  const _VoiceControlStory();

  @override
  State<_VoiceControlStory> createState() => _VoiceControlStoryState();
}

class _VoiceControlStoryState extends State<_VoiceControlStory> {
  late List<Uri> paths;
  final List<String> _voiceCommands = [];
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    paths = List.from(StoryHelpers.minimalSamplePaths);
  }

  void _simulateVoiceCommand(String command) {
    setState(() {
      _voiceCommands.insert(0, command);
      if (_voiceCommands.length > 10) {
        _voiceCommands.removeLast();
      }
    });

    // Provide spoken feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Voice command: $command'),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
    });
    
    if (_isListening) {
      _simulateVoiceCommand('Started listening...');
    } else {
      _simulateVoiceCommand('Stopped listening');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool enableVoiceFeedback = context.knobs.boolean(
      label: 'Enable Voice Feedback',
      initial: true,
    );

    return StoryWrapper(
      title: 'Voice Control',
      description: 'Voice control simulation and spoken feedback',
      child: Row(
        children: [
          // Tree view
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // Voice controls
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isListening
                        ? Colors.red.withValues(alpha: 0.1)
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    border: _isListening
                        ? Border.all(color: Colors.red, width: 2)
                        : null,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isListening ? Icons.mic : Icons.mic_off,
                        color: _isListening ? Colors.red : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isListening ? 'Listening...' : 'Voice control off',
                        style: TextStyle(
                          color: _isListening ? Colors.red : null,
                          fontWeight: _isListening ? FontWeight.bold : null,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: _toggleListening,
                        icon: Icon(_isListening ? Icons.stop : Icons.mic),
                        label: Text(_isListening ? 'Stop' : 'Start'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                
                // Sample voice commands
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    'Open file',
                    'Expand folder',
                    'Select all',
                    'Move up',
                    'Move down',
                    'Delete item',
                  ].map((command) => ActionChip(
                    label: Text(command),
                    onPressed: _isListening
                        ? () => _simulateVoiceCommand(command)
                        : null,
                  )).toList(),
                ),
                const SizedBox(height: 16),
                
                // Tree
                Expanded(
                  child: ReorderableTreeListView(
                    paths: paths,
                    itemBuilder: (context, path) => StoryItemBuilder.buildFileItem(context, path),
                    folderBuilder: (context, path) => StoryItemBuilder.buildFolderItem(context, path),
                    onReorder: (oldPath, newPath) {
                      setState(() {
                        paths.remove(oldPath);
                        paths.add(newPath);
                      });
                      
                      if (enableVoiceFeedback) {
                        _simulateVoiceCommand(
                          'Moved ${TreePath.getDisplayName(oldPath)} to ${TreePath.getDisplayName(newPath)}'
                        );
                      }
                    },
                    onItemTap: (path) {
                      if (enableVoiceFeedback) {
                        _simulateVoiceCommand('Tapped ${TreePath.getDisplayName(path)}');
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Voice command log
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Voice Commands',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: _voiceCommands.isEmpty
                        ? const Center(child: Text('No voice commands yet...'))
                        : ListView.builder(
                            itemCount: _voiceCommands.length,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.volume_up, size: 12),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      _voiceCommands[index],
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ),
                                ],
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