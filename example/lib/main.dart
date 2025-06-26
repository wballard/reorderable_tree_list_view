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
  final List<Uri> paths = <Uri>[
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

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('ReorderableTreeListView Demo'),
      ),
      body: ReorderableTreeListView(
        paths: paths,
        padding: const EdgeInsets.all(8),
        itemBuilder: (BuildContext context, Uri path) {
          final String displayName = TreePath.getDisplayName(path);
          
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
            child: ListTile(
              leading: const Icon(Icons.insert_drive_file, color: Colors.blue),
              title: Text(
                displayName,
                style: const TextStyle(fontWeight: FontWeight.normal),
              ),
              subtitle: Text(
                path.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              dense: true,
            ),
          );
        },
        folderBuilder: (BuildContext context, Uri path) {
          final String displayName = TreePath.getDisplayName(path);
          final int depth = TreePath.calculateDepth(path);
          
          return Card(
            margin: EdgeInsets.only(
              left: depth * 16,
              right: 8,
              top: 4,
              bottom: 4,
            ),
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: ListTile(
              leading: const Icon(Icons.folder),
              title: Text(
                displayName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                path.toString(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              dense: true,
            ),
          );
        },
      ),
    );
}