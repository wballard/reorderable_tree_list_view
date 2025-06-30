import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

import 'package:example/story_helpers.dart';

/// Stories showcasing theming and visual customization
final List<Story> themeStories = [
  Story(
    name: 'Theme/Basic Theming',
    description: 'Basic tree theme customization options',
    builder: (context) => const _BasicThemingStory(),
  ),
  Story(
    name: 'Theme/Advanced Styling',
    description: 'Advanced styling with custom colors and effects',
    builder: (context) => const _AdvancedStylingStory(),
  ),
  Story(
    name: 'Theme/Dark Mode',
    description: 'Dark mode theming showcase',
    builder: (context) => const _DarkModeStory(),
  ),
  Story(
    name: 'Theme/Material Design',
    description: 'Material Design 3 integration',
    builder: (context) => const _MaterialDesignStory(),
  ),
  Story(
    name: 'Theme/Custom Indicators',
    description: 'Custom expand/collapse indicators',
    builder: (context) => const _CustomIndicatorsStory(),
  ),
];

/// Basic theming story
class _BasicThemingStory extends StatefulWidget {
  const _BasicThemingStory();

  @override
  State<_BasicThemingStory> createState() => _BasicThemingStoryState();
}

class _BasicThemingStoryState extends State<_BasicThemingStory> {
  late List<Uri> paths;

  @override
  void initState() {
    super.initState();
    paths = List.from(StoryHelpers.sampleFilePaths.take(8));
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
    
    final double connectorWidth = context.knobs.slider(
      label: 'Connector Width',
      initial: 1.0,
      min: 0.5,
      max: 4.0,
    );

    final Color connectorColor = context.knobs.options(
      label: 'Connector Color',
      initial: Colors.grey,
      options: [
        const Option(label: 'Grey', value: Colors.grey),
        const Option(label: 'Blue', value: Colors.blue),
        const Option(label: 'Green', value: Colors.green),
        const Option(label: 'Purple', value: Colors.purple),
      ],
    );

    return StoryWrapper(
      title: 'Basic Theming',
      description: 'Customize basic visual properties of the tree',
      child: ReorderableTreeListView(
        paths: paths,
        theme: TreeTheme(
          indentSize: indentSize,
          showConnectors: showConnectors,
          connectorWidth: connectorWidth,
          connectorColor: connectorColor.withValues(alpha: 0.6),
        ),
        itemBuilder: (context, path) => StoryItemBuilder.buildFileItem(context, path),
        folderBuilder: (context, path) => StoryItemBuilder.buildFolderItem(context, path),
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

/// Advanced styling story
class _AdvancedStylingStory extends StatefulWidget {
  const _AdvancedStylingStory();

  @override
  State<_AdvancedStylingStory> createState() => _AdvancedStylingStoryState();
}

class _AdvancedStylingStoryState extends State<_AdvancedStylingStory> {
  late List<Uri> paths;

  @override
  void initState() {
    super.initState();
    paths = List.from(StoryHelpers.sampleFilePaths.take(6));
  }

  @override
  Widget build(BuildContext context) {
    final String themePreset = context.knobs.options(
      label: 'Theme Preset',
      initial: 'default',
      options: [
        const Option(label: 'Default', value: 'default'),
        const Option(label: 'Rounded', value: 'rounded'),
        const Option(label: 'Minimal', value: 'minimal'),
        const Option(label: 'Colorful', value: 'colorful'),
      ],
    );

    final double borderRadius = context.knobs.slider(
      label: 'Border Radius',
      initial: 4.0,
      min: 0.0,
      max: 16.0,
    );

    return StoryWrapper(
      title: 'Advanced Styling',
      description: 'Advanced styling options with different presets',
      child: ReorderableTreeListView(
        paths: paths,
        theme: _getThemePreset(themePreset, borderRadius),
        itemBuilder: (context, path) => StoryItemBuilder.buildFileItem(context, path),
        folderBuilder: (context, path) => StoryItemBuilder.buildFolderItem(context, path),
        onReorder: (oldPath, newPath) {
          setState(() {
            paths.remove(oldPath);
            paths.add(newPath);
          });
        },
      ),
    );
  }

  TreeTheme _getThemePreset(String preset, double borderRadius) {
    switch (preset) {
      case 'rounded':
        return TreeTheme(
          indentSize: 32.0,
          showConnectors: true,
          connectorColor: Colors.blue.withValues(alpha: 0.4),
          connectorWidth: 2.0,
          itemPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          borderRadius: BorderRadius.circular(borderRadius),
          hoverColor: Colors.blue.withValues(alpha: 0.08),
          focusColor: Colors.blue.withValues(alpha: 0.16),
          splashColor: Colors.blue.withValues(alpha: 0.12),
          highlightColor: Colors.blue.withValues(alpha: 0.06),
        );
      case 'minimal':
        return TreeTheme(
          indentSize: 24.0,
          showConnectors: false,
          itemPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          borderRadius: BorderRadius.circular(borderRadius),
          hoverColor: Colors.grey.withValues(alpha: 0.04),
          focusColor: Colors.grey.withValues(alpha: 0.08),
          splashColor: Colors.grey.withValues(alpha: 0.06),
          highlightColor: Colors.grey.withValues(alpha: 0.02),
        );
      case 'colorful':
        return TreeTheme(
          indentSize: 40.0,
          showConnectors: true,
          connectorColor: const Color(0xFF9C27B0), // Purple color instead of rainbow
          connectorWidth: 3.0,
          itemPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          borderRadius: BorderRadius.circular(borderRadius),
          hoverColor: Colors.purple.withValues(alpha: 0.08),
          focusColor: Colors.purple.withValues(alpha: 0.16),
          splashColor: Colors.purple.withValues(alpha: 0.12),
          highlightColor: Colors.purple.withValues(alpha: 0.06),
        );
      case 'default':
      default:
        return TreeTheme(
          indentSize: 32.0,
          showConnectors: true,
          borderRadius: BorderRadius.circular(borderRadius),
        );
    }
  }
}

/// Dark mode theming story
class _DarkModeStory extends StatefulWidget {
  const _DarkModeStory();

  @override
  State<_DarkModeStory> createState() => _DarkModeStoryState();
}

class _DarkModeStoryState extends State<_DarkModeStory> {
  late List<Uri> paths;

  @override
  void initState() {
    super.initState();
    paths = List.from(StoryHelpers.sampleFilePaths.take(6));
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    final bool useCustomDarkTheme = context.knobs.boolean(
      label: 'Use Custom Dark Theme',
      initial: true,
    );

    TreeTheme theme;
    if (useCustomDarkTheme && isDark) {
      theme = TreeTheme(
        indentSize: 32.0,
        showConnectors: true,
        connectorColor: Colors.cyan.withValues(alpha: 0.6),
        connectorWidth: 2.0,
        itemPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        hoverColor: Colors.cyan.withValues(alpha: 0.08),
        focusColor: Colors.cyan.withValues(alpha: 0.16),
        splashColor: Colors.cyan.withValues(alpha: 0.12),
        highlightColor: Colors.cyan.withValues(alpha: 0.06),
      );
    } else {
      theme = TreeTheme(
        indentSize: 32.0,
        showConnectors: true,
      );
    }

    return StoryWrapper(
      title: 'Dark Mode',
      description: 'Dark mode optimized theming',
      child: Column(
        children: [
          // Theme info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isDark
                  ? 'Dark mode detected - ${useCustomDarkTheme ? "using custom theme" : "using default theme"}'
                  : 'Light mode - switch to dark mode in device frame settings to see dark theme',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 16),
          
          // Tree view
          Expanded(
            child: ReorderableTreeListView(
              paths: paths,
              theme: theme,
              itemBuilder: (context, path) => StoryItemBuilder.buildFileItem(context, path),
              folderBuilder: (context, path) => StoryItemBuilder.buildFolderItem(context, path),
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

/// Material Design integration story
class _MaterialDesignStory extends StatefulWidget {
  const _MaterialDesignStory();

  @override
  State<_MaterialDesignStory> createState() => _MaterialDesignStoryState();
}

class _MaterialDesignStoryState extends State<_MaterialDesignStory> {
  late List<Uri> paths;

  @override
  void initState() {
    super.initState();
    paths = List.from(StoryHelpers.sampleFilePaths.take(6));
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    
    final String colorSource = context.knobs.options(
      label: 'Color Source',
      initial: 'primary',
      options: [
        const Option(label: 'Primary', value: 'primary'),
        const Option(label: 'Secondary', value: 'secondary'),
        const Option(label: 'Tertiary', value: 'tertiary'),
        const Option(label: 'Error', value: 'error'),
      ],
    );

    Color accentColor;
    switch (colorSource) {
      case 'secondary':
        accentColor = colorScheme.secondary;
        break;
      case 'tertiary':
        accentColor = colorScheme.tertiary;
        break;
      case 'error':
        accentColor = colorScheme.error;
        break;
      case 'primary':
      default:
        accentColor = colorScheme.primary;
        break;
    }

    return StoryWrapper(
      title: 'Material Design',
      description: 'Material Design 3 color scheme integration',
      child: ReorderableTreeListView(
        paths: paths,
        theme: TreeTheme(
          indentSize: 32.0,
          showConnectors: true,
          connectorColor: accentColor.withValues(alpha: 0.6),
          connectorWidth: 2.0,
          itemPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
          hoverColor: accentColor.withValues(alpha: 0.08),
          focusColor: accentColor.withValues(alpha: 0.16),
          splashColor: accentColor.withValues(alpha: 0.12),
          highlightColor: accentColor.withValues(alpha: 0.06),
        ),
        itemBuilder: (context, path) => _buildMaterialItem(context, path, accentColor),
        folderBuilder: (context, path) => _buildMaterialFolder(context, path, accentColor),
        onReorder: (oldPath, newPath) {
          setState(() {
            paths.remove(oldPath);
            paths.add(newPath);
          });
        },
      ),
    );
  }

  Widget _buildMaterialItem(BuildContext context, Uri path, Color accentColor) {
    final String displayName = TreePath.getDisplayName(path);
    
    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 12,
        backgroundColor: accentColor.withValues(alpha: 0.1),
        child: Icon(
          Icons.insert_drive_file,
          size: 16,
          color: accentColor,
        ),
      ),
      title: Text(displayName),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildMaterialFolder(BuildContext context, Uri path, Color accentColor) {
    final String displayName = TreePath.getDisplayName(path);
    
    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 12,
        backgroundColor: accentColor.withValues(alpha: 0.1),
        child: Icon(
          Icons.folder,
          size: 16,
          color: accentColor,
        ),
      ),
      title: Text(
        displayName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}

/// Custom indicators story
class _CustomIndicatorsStory extends StatefulWidget {
  const _CustomIndicatorsStory();

  @override
  State<_CustomIndicatorsStory> createState() => _CustomIndicatorsStoryState();
}

class _CustomIndicatorsStoryState extends State<_CustomIndicatorsStory> {
  late List<Uri> paths;

  @override
  void initState() {
    super.initState();
    paths = List.from(StoryHelpers.sampleFilePaths.take(6));
  }

  @override
  Widget build(BuildContext context) {
    // Note: Custom indicators are not currently supported in this version

    return StoryWrapper(
      title: 'Custom Indicators',
      description: 'Different expand/collapse indicator styles',
      child: ReorderableTreeListView(
        paths: paths,
        theme: TreeTheme(
          indentSize: 32.0,
          showConnectors: true,
          connectorColor: Colors.blue.withValues(alpha: 0.6),
        ),
        // Custom icons not currently supported - using default
        itemBuilder: (context, path) => StoryItemBuilder.buildFileItem(context, path),
        folderBuilder: (context, path) => StoryItemBuilder.buildFolderItem(context, path),
        onReorder: (oldPath, newPath) {
          setState(() {
            paths.remove(oldPath);
            paths.add(newPath);
          });
        },
      ),
    );
  }

  // Note: Custom icon methods removed as feature is not currently supported
}