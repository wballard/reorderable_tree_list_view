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
    // Note: Do not use const here - it prevents knob changes from rebuilding
    builder: (context) => _DarkModeStory(),
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
    final double indentSize = context.knobs.slider(
      label: 'Indent Size',
      initial: 32.0,
      min: 16.0,
      max: 64.0,
    );

    return StoryWrapper(
      title: 'Basic Theming',
      description: 'Customize basic visual properties of the tree',
      child: ReorderableTreeListView(
        paths: paths,
        theme: TreeTheme(
          indentSize: indentSize,
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
    final bool useCustomDarkTheme = context.knobs.boolean(
      label: 'Use Custom Dark Theme',
      initial: true,
    );

    TreeTheme theme;
    if (useCustomDarkTheme) {
      // Apply custom theme when knob is enabled, regardless of light/dark mode
      theme = TreeTheme(
        indentSize: 48.0,  // More noticeable indent
        itemPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),  // Larger padding
        borderRadius: const BorderRadius.all(Radius.circular(16.0)),  // More rounded
        hoverColor: Colors.cyan.withValues(alpha: 0.3),  // More visible hover
        focusColor: Colors.cyan.withValues(alpha: 0.4),  // More visible focus
        splashColor: Colors.cyan.withValues(alpha: 0.3),
        highlightColor: Colors.cyan.withValues(alpha: 0.2),
      );
    } else {
      theme = TreeTheme(
        indentSize: 24.0,  // Smaller indent for contrast
        itemPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),  // Smaller padding
        borderRadius: BorderRadius.zero,  // No rounding
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
              useCustomDarkTheme
                  ? 'Using custom dark theme with cyan accents on dark background'
                  : 'Using default light theme',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 16),
          
          // Tree view
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: useCustomDarkTheme ? Colors.grey.shade900 : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Theme(
                data: useCustomDarkTheme 
                    ? ThemeData.dark().copyWith(
                        // Dark theme overrides
                        scaffoldBackgroundColor: Colors.grey.shade900,
                        colorScheme: const ColorScheme.dark(
                          primary: Colors.cyan,
                          secondary: Colors.cyanAccent,
                          surface: Colors.black87,
                        ),
                        listTileTheme: const ListTileThemeData(
                          textColor: Colors.white,
                          iconColor: Colors.white70,
                        ),
                      )
                    : Theme.of(context),
                child: ReorderableTreeListView(
                  paths: paths,
                  theme: theme,
                  itemBuilder: (context, path) => useCustomDarkTheme
                      ? _buildDarkThemeItem(context, path)
                      : StoryItemBuilder.buildFileItem(context, path),
                  folderBuilder: (context, path) => useCustomDarkTheme
                      ? _buildDarkThemeFolder(context, path)
                      : StoryItemBuilder.buildFolderItem(context, path),
                  onReorder: (oldPath, newPath) {
                    setState(() {
                      paths.remove(oldPath);
                      paths.add(newPath);
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkThemeItem(BuildContext context, Uri path) {
    final String displayName = TreePath.getDisplayName(path);
    final String extension = displayName.split('.').last.toLowerCase();
    final IconData icon = _getFileIcon(extension);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          icon,
          size: 20,
          color: Colors.cyanAccent,
        ),
        title: Text(
          displayName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  Widget _buildDarkThemeFolder(BuildContext context, Uri path) {
    final String displayName = TreePath.getDisplayName(path);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.cyan.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        leading: const Icon(
          Icons.folder,
          size: 20,
          color: Colors.cyan,
        ),
        title: Text(
          displayName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  IconData _getFileIcon(String extension) {
    switch (extension) {
      case 'dart':
        return Icons.code;
      case 'js':
      case 'ts':
      case 'jsx':
      case 'tsx':
        return Icons.javascript;
      case 'html':
      case 'htm':
        return Icons.html;
      case 'css':
        return Icons.css;
      case 'json':
      case 'yaml':
      case 'yml':
        return Icons.data_object;
      case 'md':
        return Icons.description;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'mp3':
      case 'wav':
      case 'flac':
        return Icons.music_note;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icons.video_file;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
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