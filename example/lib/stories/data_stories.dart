import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

import 'package:example/story_helpers.dart';

/// Stories showcasing different data scenarios and use cases
final List<Story> dataStories = [
  Story(
    name: 'Data/Large Dataset',
    description: 'Performance with large hierarchical datasets',
    builder: (context) => const _LargeDatasetStory(),
  ),
  Story(
    name: 'Data/Dynamic Data',
    description: 'Dynamically adding and removing tree items',
    builder: (context) => const _DynamicDataStory(),
  ),
  Story(
    name: 'Data/Different URI Schemes',
    description: 'Various URI schemes (file://, https://, custom://)',
    builder: (context) => const _UriSchemesStory(),
  ),
  Story(
    name: 'Data/Empty States',
    description: 'Handling empty data and loading states',
    builder: (context) => const _EmptyStatesStory(),
  ),
  Story(
    name: 'Data/Deep Hierarchy',
    description: 'Very deep tree structures',
    builder: (context) => const _DeepHierarchyStory(),
  ),
];

/// Large dataset story for performance testing
class _LargeDatasetStory extends StatefulWidget {
  const _LargeDatasetStory();

  @override
  State<_LargeDatasetStory> createState() => _LargeDatasetStoryState();
}

class _LargeDatasetStoryState extends State<_LargeDatasetStory> {
  late List<Uri> paths;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    paths = List.from(StoryHelpers.sampleFilePaths);
  }

  void _generateLargeDataset() {
    setState(() {
      _isLoading = true;
    });

    // Simulate some delay for large dataset generation
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        paths = List.from(StoryHelpers.largeSamplePaths);
        _isLoading = false;
      });
    });
  }

  void _resetToSmallDataset() {
    setState(() {
      paths = List.from(StoryHelpers.sampleFilePaths);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool expandedByDefault = context.knobs.boolean(
      label: 'Expanded by Default',
      initial: false,
    );
    
    final bool animateExpansion = context.knobs.boolean(
      label: 'Animate Expansion',
      initial: true,
    );

    return StoryWrapper(
      title: 'Large Dataset',
      description: 'Performance testing with large hierarchical data',
      child: Column(
        children: [
          // Controls
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Text('Items: ${paths.length}'),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _generateLargeDataset,
                  icon: _isLoading 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.dataset, size: 16),
                  label: Text(_isLoading ? 'Generating...' : 'Large Dataset'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _resetToSmallDataset,
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Reset'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Tree view
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Generating large dataset...'),
                      ],
                    ),
                  )
                : ReorderableTreeListView(
                    paths: paths,
                    expandedByDefault: expandedByDefault,
                    animateExpansion: animateExpansion,
                    itemBuilder: (context, path) => StoryItemBuilder.buildSimpleItem(context, path),
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

/// Dynamic data story
class _DynamicDataStory extends StatefulWidget {
  const _DynamicDataStory();

  @override
  State<_DynamicDataStory> createState() => _DynamicDataStoryState();
}

class _DynamicDataStoryState extends State<_DynamicDataStory> {
  List<Uri> paths = [];
  int _counter = 1;

  void _addFile() {
    setState(() {
      paths.add(Uri.parse('file:///new_file_$_counter.txt'));
      _counter++;
    });
  }

  void _addFolder() {
    setState(() {
      paths.add(Uri.parse('file:///new_folder_$_counter/'));
      _counter++;
    });
  }

  void _removeRandomItem() {
    if (paths.isNotEmpty) {
      setState(() {
        paths.removeAt(0);
      });
    }
  }

  void _addSampleData() {
    setState(() {
      paths.addAll(StoryHelpers.minimalSamplePaths);
    });
  }

  void _clearAll() {
    setState(() {
      paths.clear();
      _counter = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoryWrapper(
      title: 'Dynamic Data',
      description: 'Add and remove tree items dynamically',
      child: Column(
        children: [
          // Controls
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _addFile,
                  icon: const Icon(Icons.insert_drive_file, size: 16),
                  label: const Text('Add File'),
                ),
                ElevatedButton.icon(
                  onPressed: _addFolder,
                  icon: const Icon(Icons.folder, size: 16),
                  label: const Text('Add Folder'),
                ),
                ElevatedButton.icon(
                  onPressed: paths.isNotEmpty ? _removeRandomItem : null,
                  icon: const Icon(Icons.remove, size: 16),
                  label: const Text('Remove First'),
                ),
                ElevatedButton.icon(
                  onPressed: _addSampleData,
                  icon: const Icon(Icons.add_box, size: 16),
                  label: const Text('Add Sample'),
                ),
                ElevatedButton.icon(
                  onPressed: paths.isNotEmpty ? _clearAll : null,
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text('Clear All'),
                ),
                Text('Items: ${paths.length}'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Tree view
          Expanded(
            child: paths.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No items yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Use the buttons above to add some items',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ReorderableTreeListView(
                    paths: paths,
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

/// URI schemes story
class _UriSchemesStory extends StatefulWidget {
  const _UriSchemesStory();

  @override
  State<_UriSchemesStory> createState() => _UriSchemesStoryState();
}

class _UriSchemesStoryState extends State<_UriSchemesStory> {
  late List<Uri> paths;

  @override
  void initState() {
    super.initState();
    paths = _generateMixedUriPaths();
  }

  List<Uri> _generateMixedUriPaths() {
    return [
      // File system paths
      Uri.parse('file:///home/user/documents/file1.txt'),
      Uri.parse('file:///home/user/documents/file2.pdf'),
      Uri.parse('file:///home/user/pictures/photo.jpg'),
      
      // HTTP URLs
      Uri.parse('https://example.com/'),
      Uri.parse('https://example.com/products/item1.html'),
      Uri.parse('https://example.com/products/item2.html'),
      Uri.parse('https://example.com/about.html'),
      
      // FTP URLs
      Uri.parse('ftp://ftp.example.com/'),
      Uri.parse('ftp://ftp.example.com/uploads/data.zip'),
      Uri.parse('ftp://ftp.example.com/public/readme.txt'),
      
      // Custom schemes
      Uri.parse('app://navigation/'),
      Uri.parse('app://navigation/home'),
      Uri.parse('app://navigation/settings'),
      Uri.parse('db://table/users'),
      Uri.parse('db://table/products'),
      Uri.parse('memory://cache/item1'),
      Uri.parse('memory://cache/item2'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final String filterScheme = context.knobs.options(
      label: 'Filter by Scheme',
      initial: 'all',
      options: [
        const Option(label: 'All', value: 'all'),
        const Option(label: 'File', value: 'file'),
        const Option(label: 'HTTPS', value: 'https'),
        const Option(label: 'FTP', value: 'ftp'),
        const Option(label: 'Custom (app://)', value: 'app'),
        const Option(label: 'Custom (db://)', value: 'db'),
        const Option(label: 'Custom (memory://)', value: 'memory'),
      ],
    );

    final List<Uri> filteredPaths = filterScheme == 'all'
        ? paths
        : paths.where((uri) => uri.scheme == filterScheme).toList();

    return StoryWrapper(
      title: 'Different URI Schemes',
      description: 'Tree with various URI schemes and protocols',
      child: Column(
        children: [
          // Scheme info
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
                Text(
                  'Showing ${filteredPaths.length} items',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (filterScheme != 'all')
                  Text('Filtered by scheme: $filterScheme://'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Tree view
          Expanded(
            child: ReorderableTreeListView(
              paths: filteredPaths,
              itemBuilder: (context, path) => _buildSchemeItem(context, path),
              folderBuilder: (context, path) => _buildSchemeFolder(context, path),
              onReorder: (oldPath, newPath) {
                setState(() {
                  final oldIndex = paths.indexOf(oldPath);
                  if (oldIndex != -1) {
                    paths[oldIndex] = newPath;
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchemeItem(BuildContext context, Uri path) {
    final String displayName = TreePath.getDisplayName(path);
    final Color schemeColor = _getSchemeColor(path.scheme);
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: schemeColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            path.scheme,
            style: TextStyle(
              fontSize: 10,
              color: schemeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          _getSchemeIcon(path.scheme),
          size: 16,
          color: schemeColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(displayName),
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

  Widget _buildSchemeFolder(BuildContext context, Uri path) {
    final String displayName = TreePath.getDisplayName(path);
    final Color schemeColor = _getSchemeColor(path.scheme);
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: schemeColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            path.scheme,
            style: TextStyle(
              fontSize: 10,
              color: schemeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.folder,
          size: 16,
          color: schemeColor,
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

  Color _getSchemeColor(String scheme) {
    switch (scheme) {
      case 'file':
        return Colors.blue;
      case 'https':
      case 'http':
        return Colors.green;
      case 'ftp':
        return Colors.orange;
      case 'app':
        return Colors.purple;
      case 'db':
        return Colors.red;
      case 'memory':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getSchemeIcon(String scheme) {
    switch (scheme) {
      case 'file':
        return Icons.folder;
      case 'https':
      case 'http':
        return Icons.language;
      case 'ftp':
        return Icons.cloud;
      case 'app':
        return Icons.apps;
      case 'db':
        return Icons.storage;
      case 'memory':
        return Icons.memory;
      default:
        return Icons.link;
    }
  }
}

/// Empty states story
class _EmptyStatesStory extends StatefulWidget {
  const _EmptyStatesStory();

  @override
  State<_EmptyStatesStory> createState() => _EmptyStatesStoryState();
}

class _EmptyStatesStoryState extends State<_EmptyStatesStory> {
  List<Uri> paths = [];
  bool _isLoading = false;

  void _simulateLoading() {
    setState(() {
      _isLoading = true;
      paths.clear();
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
        paths = List.from(StoryHelpers.minimalSamplePaths);
      });
    });
  }

  void _clearData() {
    setState(() {
      paths.clear();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoryWrapper(
      title: 'Empty States',
      description: 'Handling empty data and loading states',
      child: Column(
        children: [
          // Controls
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _simulateLoading,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Simulate Loading'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _clearData,
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear Data'),
                ),
                const Spacer(),
                Text('State: ${_getStateDescription()}'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Tree view or state indicators
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  String _getStateDescription() {
    if (_isLoading) return 'Loading';
    if (paths.isEmpty) return 'Empty';
    return 'Data (${paths.length} items)';
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(strokeWidth: 3),
            SizedBox(height: 24),
            Text(
              'Loading data...',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Please wait while we fetch your files',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (paths.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No files found',
              style: TextStyle(
                fontSize: 24,
                color: Colors.grey[600],
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There are no files to display',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _simulateLoading,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return ReorderableTreeListView(
      paths: paths,
      itemBuilder: (context, path) => StoryItemBuilder.buildFileItem(context, path),
      folderBuilder: (context, path) => StoryItemBuilder.buildFolderItem(context, path),
      onReorder: (oldPath, newPath) {
        setState(() {
          paths.remove(oldPath);
          paths.add(newPath);
        });
      },
    );
  }
}

/// Deep hierarchy story
class _DeepHierarchyStory extends StatefulWidget {
  const _DeepHierarchyStory();

  @override
  State<_DeepHierarchyStory> createState() => _DeepHierarchyStoryState();
}

class _DeepHierarchyStoryState extends State<_DeepHierarchyStory> {
  late List<Uri> paths;

  @override
  void initState() {
    super.initState();
    paths = _generateDeepHierarchy();
  }

  List<Uri> _generateDeepHierarchy() {
    final List<Uri> result = [];
    
    // Create a very deep hierarchy
    for (int level1 = 1; level1 <= 3; level1++) {
      result.add(Uri.parse('file:///level1_folder$level1/'));
      
      for (int level2 = 1; level2 <= 3; level2++) {
        result.add(Uri.parse('file:///level1_folder$level1/level2_folder$level2/'));
        
        for (int level3 = 1; level3 <= 3; level3++) {
          result.add(Uri.parse('file:///level1_folder$level1/level2_folder$level2/level3_folder$level3/'));
          
          for (int level4 = 1; level4 <= 2; level4++) {
            result.add(Uri.parse('file:///level1_folder$level1/level2_folder$level2/level3_folder$level3/level4_folder$level4/'));
            
            for (int level5 = 1; level5 <= 2; level5++) {
              result.add(Uri.parse('file:///level1_folder$level1/level2_folder$level2/level3_folder$level3/level4_folder$level4/level5_folder$level5/'));
              
              // Add some files at the deepest level
              result.add(Uri.parse('file:///level1_folder$level1/level2_folder$level2/level3_folder$level3/level4_folder$level4/level5_folder$level5/deep_file$level5.txt'));
            }
            
            // Add some files at level 4
            result.add(Uri.parse('file:///level1_folder$level1/level2_folder$level2/level3_folder$level3/level4_folder$level4/file$level4.txt'));
          }
          
          // Add some files at level 3
          result.add(Uri.parse('file:///level1_folder$level1/level2_folder$level2/level3_folder$level3/file$level3.txt'));
        }
        
        // Add some files at level 2
        result.add(Uri.parse('file:///level1_folder$level1/level2_folder$level2/file$level2.txt'));
      }
      
      // Add some files at level 1
      result.add(Uri.parse('file:///level1_folder$level1/file$level1.txt'));
    }
    
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final bool expandedByDefault = context.knobs.boolean(
      label: 'Expanded by Default',
      initial: false,
    );
    
    final bool showDepthIndicator = context.knobs.boolean(
      label: 'Show Depth Indicator',
      initial: true,
    );

    return StoryWrapper(
      title: 'Deep Hierarchy',
      description: 'Very deep tree structures (5+ levels)',
      child: Column(
        children: [
          // Hierarchy info
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
                Text(
                  'Deep Hierarchy Stats:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Total items: ${paths.length}'),
                Text('Max depth: ${_getMaxDepth()} levels'),
                const Text('Tip: Use "Expanded by Default: false" for better performance'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Tree view
          Expanded(
            child: ReorderableTreeListView(
              paths: paths,
              expandedByDefault: expandedByDefault,
              itemBuilder: (context, path) => showDepthIndicator
                  ? _buildDepthItem(context, path)
                  : StoryItemBuilder.buildFileItem(context, path),
              folderBuilder: (context, path) => showDepthIndicator
                  ? _buildDepthFolder(context, path)
                  : StoryItemBuilder.buildFolderItem(context, path),
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

  int _getMaxDepth() {
    return paths
        .map((uri) => uri.pathSegments.where((segment) => segment.isNotEmpty).length)
        .fold(0, (max, depth) => depth > max ? depth : max);
  }

  Widget _buildDepthItem(BuildContext context, Uri path) {
    final int depth = path.pathSegments.where((segment) => segment.isNotEmpty).length;
    final String displayName = TreePath.getDisplayName(path);
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: _getDepthColor(depth).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            'L$depth',
            style: TextStyle(
              fontSize: 10,
              color: _getDepthColor(depth),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.insert_drive_file, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(displayName)),
      ],
    );
  }

  Widget _buildDepthFolder(BuildContext context, Uri path) {
    final int depth = path.pathSegments.where((segment) => segment.isNotEmpty).length;
    final String displayName = TreePath.getDisplayName(path);
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: _getDepthColor(depth).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            'L$depth',
            style: TextStyle(
              fontSize: 10,
              color: _getDepthColor(depth),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.folder, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            displayName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Color _getDepthColor(int depth) {
    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.brown,
    ];
    
    return colors[depth % colors.length];
  }
}