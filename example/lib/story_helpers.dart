import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

/// Collection of utilities for creating Storybook stories
class StoryHelpers {
  StoryHelpers._();
  
  /// Sample file system paths for demonstrations
  static List<Uri> get sampleFilePaths => [
    Uri.parse('file:///Documents/Projects/flutter_app/lib/main.dart'),
    Uri.parse('file:///Documents/Projects/flutter_app/lib/models/user.dart'),
    Uri.parse('file:///Documents/Projects/flutter_app/lib/widgets/tree_view.dart'),
    Uri.parse('file:///Documents/Projects/flutter_app/test/widget_test.dart'),
    Uri.parse('file:///Documents/Projects/flutter_app/pubspec.yaml'),
    Uri.parse('file:///Documents/Projects/react_app/src/index.js'),
    Uri.parse('file:///Documents/Projects/react_app/src/components/App.js'),
    Uri.parse('file:///Documents/Projects/react_app/package.json'),
    Uri.parse('file:///Downloads/document.pdf'),
    Uri.parse('file:///Downloads/archive.zip'),
    Uri.parse('file:///Pictures/vacation/beach.jpg'),
    Uri.parse('file:///Pictures/vacation/sunset.jpg'),
    Uri.parse('file:///Pictures/family/birthday.jpg'),
    Uri.parse('file:///Music/playlists/favorites.m3u'),
    Uri.parse('file:///Music/albums/rock/song1.mp3'),
    Uri.parse('file:///Music/albums/rock/song2.mp3'),
  ];
  
  /// Sample URL paths for web-like demonstrations
  static List<Uri> get sampleUrlPaths => [
    Uri.parse('https://example.com/'),
    Uri.parse('https://example.com/products/electronics/phones.html'),
    Uri.parse('https://example.com/products/electronics/laptops.html'),
    Uri.parse('https://example.com/products/books/fiction.html'),
    Uri.parse('https://example.com/products/books/non-fiction.html'),
    Uri.parse('https://example.com/about/'),
    Uri.parse('https://example.com/about/team.html'),
    Uri.parse('https://example.com/about/history.html'),
    Uri.parse('https://example.com/contact/'),
    Uri.parse('https://example.com/blog/2023/first-post.html'),
    Uri.parse('https://example.com/blog/2023/second-post.html'),
  ];
  
  /// Large dataset for performance testing
  static List<Uri> get largeSamplePaths {
    final List<Uri> paths = [];
    
    // Create a large hierarchical structure
    for (int i = 1; i <= 20; i++) {
      paths.add(Uri.parse('file:///folder$i/'));
      
      for (int j = 1; j <= 10; j++) {
        paths.add(Uri.parse('file:///folder$i/subfolder$j/'));
        
        for (int k = 1; k <= 5; k++) {
          paths.add(Uri.parse('file:///folder$i/subfolder$j/file$k.txt'));
        }
      }
      
      // Add some files at the folder level
      for (int j = 1; j <= 3; j++) {
        paths.add(Uri.parse('file:///folder$i/document$j.pdf'));
      }
    }
    
    return paths;
  }
  
  /// Minimal sample for simple demonstrations
  static List<Uri> get minimalSamplePaths => [
    Uri.parse('file:///README.md'),
    Uri.parse('file:///src/main.dart'),
    Uri.parse('file:///src/models/data.dart'),
    Uri.parse('file:///test/test.dart'),
  ];
  
  /// Creates a mock callback that logs to console
  static void Function(T) createLoggingCallback<T>(String name) {
    return (T value) {
      developer.log('$name: $value', name: 'Storybook');
    };
  }
  
  /// Creates a mock boolean callback that logs and returns true
  static bool Function(T) createLoggingBoolCallback<T>(String name, [bool returnValue = true]) {
    return (T value) {
      developer.log('$name: $value -> $returnValue', name: 'Storybook');
      return returnValue;
    };
  }
  
  /// Creates a mock callback for reorder operations
  static void Function(Uri, Uri) get mockReorderCallback {
    return (Uri oldPath, Uri newPath) {
      final String oldName = TreePath.getDisplayName(oldPath);
      final String newName = TreePath.getDisplayName(newPath);
      final String parentPath = TreePath.getParentPath(newPath)?.toString() ?? 'root';
      developer.log(
        'Reorder: $oldName -> $newName (parent: $parentPath)',
        name: 'Storybook',
      );
    };
  }
  
  /// Creates a mock callback for selection changes
  static void Function(Set<Uri>) get mockSelectionCallback {
    return (Set<Uri> selection) {
      final List<String> names = selection
          .map((uri) => TreePath.getDisplayName(uri))
          .toList();
      developer.log('Selection changed: [${names.join(", ")}]', name: 'Storybook');
    };
  }
  
  /// Creates a mock context menu callback
  static void Function(Uri, Offset) get mockContextMenuCallback {
    return (Uri path, Offset position) {
      final String name = TreePath.getDisplayName(path);
      developer.log(
        'Context menu: $name at (${position.dx.toInt()}, ${position.dy.toInt()})',
        name: 'Storybook',
      );
    };
  }
}

/// Common story wrapper that provides consistent styling
class StoryWrapper extends StatelessWidget {
  /// Creates a story wrapper
  const StoryWrapper({
    required this.title,
    required this.child,
    this.description,
    this.showPadding = true,
    super.key,
  });
  
  /// The title of the story
  final String title;
  
  /// Optional description
  final String? description;
  
  /// The story content
  final Widget child;
  
  /// Whether to add padding around the content
  final bool showPadding;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          if (description != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Text(
                description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
          Expanded(
            child: showPadding 
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: child,
                  )
                : child,
          ),
        ],
      ),
    );
  }
}

/// Builder for tree items with consistent styling
class StoryItemBuilder {
  /// Creates file item widget
  static Widget buildFileItem(BuildContext context, Uri path) {
    final String displayName = TreePath.getDisplayName(path);
    final String extension = displayName.split('.').last.toLowerCase();
    
    return Row(
      children: [
        Icon(
          _getFileIcon(extension),
          color: _getFileColor(extension),
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
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  /// Creates folder item widget
  static Widget buildFolderItem(BuildContext context, Uri path) {
    final String displayName = TreePath.getDisplayName(path);
    
    return Row(
      children: [
        Icon(
          Icons.folder,
          color: Colors.amber[700],
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
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  /// Creates simple text item widget
  static Widget buildSimpleItem(BuildContext context, Uri path) {
    return Text(TreePath.getDisplayName(path));
  }
  
  static IconData _getFileIcon(String extension) {
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
  
  static Color _getFileColor(String extension) {
    switch (extension) {
      case 'dart':
        return Colors.blue;
      case 'js':
      case 'ts':
      case 'jsx':
      case 'tsx':
        return Colors.yellow[700]!;
      case 'html':
      case 'htm':
        return Colors.orange;
      case 'css':
        return Colors.blue[300]!;
      case 'json':
      case 'yaml':
      case 'yml':
        return Colors.green;
      case 'md':
        return Colors.grey[700]!;
      case 'pdf':
        return Colors.red;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Colors.purple;
      case 'mp3':
      case 'wav':
      case 'flac':
        return Colors.pink;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Colors.indigo;
      case 'zip':
      case 'rar':
      case '7z':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }
}