import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

import 'package:example/story_helpers.dart';

/// Basic stories showcasing simple ReorderableTreeListView usage
final List<Story> basicStories = [
  Story(
    name: 'Basic/Simple Tree',
    description: 'A basic tree with minimal configuration',
    builder: (context) => const _SimpleTreeStory(),
  ),
  Story(
    name: 'Basic/File System',
    description: 'Tree displaying file system structure',
    builder: (context) => const _FileSystemStory(),
  ),
  Story(
    name: 'Basic/Custom Item Builder',
    description: 'Tree with custom item and folder builders',
    builder: (context) => const _CustomBuildersStory(),
  ),
  Story(
    name: 'Basic/Minimal Example',
    description: 'Minimal tree for quick start',
    builder: (context) => const _MinimalStory(),
  ),
];

/// Simple tree story with basic configuration
class _SimpleTreeStory extends StatefulWidget {
  const _SimpleTreeStory();

  @override
  State<_SimpleTreeStory> createState() => _SimpleTreeStoryState();
}

class _SimpleTreeStoryState extends State<_SimpleTreeStory> {
  late List<Uri> paths;

  @override
  void initState() {
    super.initState();
    paths = List.from(StoryHelpers.sampleFilePaths);
  }

  @override
  Widget build(BuildContext context) {
    final bool showConnectors = context.knobs.boolean(
      label: 'Show Connectors',
      initial: true,
    );
    
    final double indentSize = context.knobs.slider(
      label: 'Indent Size',
      initial: 32.0,
      min: 16.0,
      max: 64.0,
    );
    
    final bool expandedByDefault = context.knobs.boolean(
      label: 'Expanded by Default',
      initial: true,
    );

    return StoryWrapper(
      title: 'Simple Tree',
      description: 'Basic tree configuration with customizable options',
      child: ReorderableTreeListView(
        paths: paths,
        theme: TreeTheme(
          indentSize: indentSize,
          showConnectors: showConnectors,
        ),
        expandedByDefault: expandedByDefault,
        itemBuilder: (context, path) => Text(
          TreePath.getDisplayName(path),
        ),
        onReorder: (oldPath, newPath) {
          setState(() {
            paths.remove(oldPath);
            paths.add(newPath);
          });
          StoryHelpers.mockReorderCallback(oldPath, newPath);
        },
      ),
    );
  }
}

/// File system story with detailed file/folder display
class _FileSystemStory extends StatefulWidget {
  const _FileSystemStory();

  @override
  State<_FileSystemStory> createState() => _FileSystemStoryState();
}

class _FileSystemStoryState extends State<_FileSystemStory> {
  late List<Uri> paths;

  @override
  void initState() {
    super.initState();
    paths = List.from(StoryHelpers.sampleFilePaths);
  }

  @override
  Widget build(BuildContext context) {
    final bool animateExpansion = context.knobs.boolean(
      label: 'Animate Expansion',
      initial: true,
    );
    
    final bool enableDragAndDrop = context.knobs.boolean(
      label: 'Enable Drag & Drop',
      initial: true,
    );

    return StoryWrapper(
      title: 'File System Tree',
      description: 'Tree mimicking a file system with custom file and folder icons',
      child: ReorderableTreeListView(
        paths: paths,
        animateExpansion: animateExpansion,
        itemBuilder: (context, path) => StoryItemBuilder.buildFileItem(context, path),
        folderBuilder: (context, path) => StoryItemBuilder.buildFolderItem(context, path),
        onReorder: enableDragAndDrop ? (oldPath, newPath) {
          setState(() {
            paths.remove(oldPath);
            paths.add(newPath);
          });
          StoryHelpers.mockReorderCallback(oldPath, newPath);
        } : null,
        onExpandStart: StoryHelpers.createLoggingCallback('Expand Start'),
        onExpandEnd: StoryHelpers.createLoggingCallback('Expand End'),
        onCollapseStart: StoryHelpers.createLoggingCallback('Collapse Start'),
        onCollapseEnd: StoryHelpers.createLoggingCallback('Collapse End'),
      ),
    );
  }
}

/// Custom builders story showing different styling options
class _CustomBuildersStory extends StatefulWidget {
  const _CustomBuildersStory();

  @override
  State<_CustomBuildersStory> createState() => _CustomBuildersStoryState();
}

class _CustomBuildersStoryState extends State<_CustomBuildersStory> {
  late List<Uri> paths;

  @override
  void initState() {
    super.initState();
    paths = List.from(StoryHelpers.sampleUrlPaths);
  }

  @override
  Widget build(BuildContext context) {
    final String builderStyle = context.knobs.options(
      label: 'Builder Style',
      initial: 'card',
      options: [
        const Option(label: 'Card', value: 'card'),
        const Option(label: 'List Tile', value: 'tile'),
        const Option(label: 'Simple', value: 'simple'),
      ],
    );

    return StoryWrapper(
      title: 'Custom Builders',
      description: 'Different item builder styles for various UI needs',
      child: ReorderableTreeListView(
        paths: paths,
        itemBuilder: (context, path) => _buildCustomItem(context, path, builderStyle),
        folderBuilder: (context, path) => _buildCustomFolder(context, path, builderStyle),
        onReorder: (oldPath, newPath) {
          setState(() {
            paths.remove(oldPath);
            paths.add(newPath);
          });
          StoryHelpers.mockReorderCallback(oldPath, newPath);
        },
      ),
    );
  }

  Widget _buildCustomItem(BuildContext context, Uri path, String style) {
    final String displayName = TreePath.getDisplayName(path);
    
    switch (style) {
      case 'card':
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 2),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                const Icon(Icons.insert_drive_file, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(displayName)),
              ],
            ),
          ),
        );
      case 'tile':
        return ListTile(
          dense: true,
          leading: const Icon(Icons.insert_drive_file),
          title: Text(displayName),
          subtitle: Text(path.toString()),
        );
      case 'simple':
      default:
        return Text(displayName);
    }
  }

  Widget _buildCustomFolder(BuildContext context, Uri path, String style) {
    final String displayName = TreePath.getDisplayName(path);
    
    switch (style) {
      case 'card':
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 2),
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                const Icon(Icons.folder, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    displayName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      case 'tile':
        return ListTile(
          dense: true,
          leading: const Icon(Icons.folder),
          title: Text(
            displayName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(path.toString()),
        );
      case 'simple':
      default:
        return Text(
          displayName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        );
    }
  }
}

/// Minimal story for quick demonstrations
class _MinimalStory extends StatefulWidget {
  const _MinimalStory();

  @override
  State<_MinimalStory> createState() => _MinimalStoryState();
}

class _MinimalStoryState extends State<_MinimalStory> {
  late List<Uri> paths;

  @override
  void initState() {
    super.initState();
    paths = List.from(StoryHelpers.minimalSamplePaths);
  }

  @override
  Widget build(BuildContext context) {
    return StoryWrapper(
      title: 'Minimal Example',
      description: 'Simplest possible tree configuration',
      child: ReorderableTreeListView(
        paths: paths,
        itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
        onReorder: (oldPath, newPath) {
          setState(() {
            paths.remove(oldPath);
            paths.add(newPath);
          });
        },
      ),
    );
  }
}