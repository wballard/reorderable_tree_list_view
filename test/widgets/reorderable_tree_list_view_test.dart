import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

void main() {
  group('ReorderableTreeListView', () {
    late List<Uri> samplePaths;
    
    setUp(() {
      samplePaths = <Uri>[
        Uri.parse('file://var/data/readme.txt'),
        Uri.parse('file://var/data/info.txt'),
        Uri.parse('file://var/config.json'),
        Uri.parse('file://usr/bin/app'),
      ];
    });
    
    testWidgets('creates widget with sample paths', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableTreeListView(
              paths: samplePaths,
              itemBuilder: (BuildContext context, Uri path) {
                return ListTile(
                  title: Text(path.toString()),
                );
              },
            ),
          ),
        ),
      );
      
      // Widget should build without errors
      expect(find.byType(ReorderableTreeListView), findsOneWidget);
      
      // Should show text with node count
      // Expected nodes: file://, file://var, file://var/data, 
      // file://var/data/readme.txt, file://var/data/info.txt,
      // file://var/config.json, file://usr, file://usr/bin,
      // file://usr/bin/app = 9 nodes
      expect(find.text('Tree with 9 nodes'), findsOneWidget);
    });
    
    testWidgets('shows all paths in temporary ListView', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableTreeListView(
              paths: samplePaths,
              itemBuilder: (BuildContext context, Uri path) {
                return ListTile(
                  key: ValueKey<String>(path.toString()),
                  title: Text(path.toString()),
                );
              },
            ),
          ),
        ),
      );
      
      // Should show all nodes (including generated intermediate ones)
      // The ListView has 10 items: 1 header + 9 tree nodes
      expect(find.byType(ListTile), findsNWidgets(9));
    });
    
    testWidgets('uses custom folder builder when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableTreeListView(
              paths: samplePaths,
              itemBuilder: (BuildContext context, Uri path) {
                return ListTile(
                  title: Text('Leaf: ${path.toString()}'),
                );
              },
              folderBuilder: (BuildContext context, Uri path) {
                return ListTile(
                  title: Text('Folder: ${path.toString()}'),
                );
              },
            ),
          ),
        ),
      );
      
      // Should have both folder and leaf items
      expect(find.textContaining('Folder:'), findsWidgets);
      expect(find.textContaining('Leaf:'), findsWidgets);
    });
    
    testWidgets('handles empty path list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableTreeListView(
              paths: <Uri>[],
              itemBuilder: (BuildContext context, Uri path) {
                return ListTile(
                  title: Text(path.toString()),
                );
              },
            ),
          ),
        ),
      );
      
      expect(find.byType(ReorderableTreeListView), findsOneWidget);
      expect(find.text('Tree with 0 nodes'), findsOneWidget);
    });
    
    testWidgets('rebuilds when paths change', (WidgetTester tester) async {
      List<Uri> paths = <Uri>[
        Uri.parse('file://var/test.txt'),
      ];
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  children: <Widget>[
                    Expanded(
                      child: ReorderableTreeListView(
                        paths: paths,
                        itemBuilder: (BuildContext context, Uri path) {
                          return ListTile(
                            title: Text(path.toString()),
                          );
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          paths = <Uri>[
                            Uri.parse('file://var/test.txt'),
                            Uri.parse('file://usr/new.txt'),
                          ];
                        });
                      },
                      child: const Text('Add Path'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
      
      // Initially should have 3 nodes (file://, file://var, file://var/test.txt)
      expect(find.text('Tree with 3 nodes'), findsOneWidget);
      
      // Add a new path
      await tester.tap(find.text('Add Path'));
      await tester.pump();
      
      // Now should have 5 nodes (file://, file://var, file://var/test.txt,
      // file://usr, file://usr/new.txt)
      expect(find.text('Tree with 5 nodes'), findsOneWidget);
    });
    
    testWidgets('accepts scroll controller', (WidgetTester tester) async {
      final ScrollController scrollController = ScrollController();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableTreeListView(
              paths: samplePaths,
              scrollController: scrollController,
              itemBuilder: (BuildContext context, Uri path) {
                return ListTile(
                  title: Text(path.toString()),
                );
              },
            ),
          ),
        ),
      );
      
      expect(find.byType(ReorderableTreeListView), findsOneWidget);
      
      // Clean up
      scrollController.dispose();
    });
    
    testWidgets('applies padding', (WidgetTester tester) async {
      const EdgeInsets padding = EdgeInsets.all(16.0);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableTreeListView(
              paths: samplePaths,
              padding: padding,
              itemBuilder: (BuildContext context, Uri path) {
                return ListTile(
                  title: Text(path.toString()),
                );
              },
            ),
          ),
        ),
      );
      
      // Find the ListView and check its padding
      final Finder listViewFinder = find.byType(ListView);
      expect(listViewFinder, findsOneWidget);
      
      final ListView listView = tester.widget<ListView>(listViewFinder);
      expect(listView.padding, equals(padding));
    });
  });
}