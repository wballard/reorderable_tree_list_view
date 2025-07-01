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

    testWidgets('creates widget with sample paths', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableTreeListView(
              paths: samplePaths,
              initiallyExpanded: <Uri>{
                Uri.parse('file://'),
                Uri.parse('file://var'),
                Uri.parse('file://var/data'),
                Uri.parse('file://usr'),
                Uri.parse('file://usr/bin'),
              },
              itemBuilder: (BuildContext context, Uri path) =>
                  ListTile(title: Text(path.toString())),
            ),
          ),
        ),
      );

      // Widget should build without errors
      expect(find.byType(ReorderableTreeListView), findsOneWidget);

      // Should show all tree items
      // Expected nodes: file://, file://var, file://var/data,
      // file://var/data/readme.txt, file://var/data/info.txt,
      // file://var/config.json, file://usr, file://usr/bin,
      // file://usr/bin/app = 9 nodes
      expect(find.byType(ReorderableTreeListViewItem), findsNWidgets(9));
    });

    testWidgets('shows all paths in temporary ListView', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableTreeListView(
              paths: samplePaths,
              initiallyExpanded: <Uri>{
                Uri.parse('file://'),
                Uri.parse('file://var'),
                Uri.parse('file://var/data'),
                Uri.parse('file://usr'),
                Uri.parse('file://usr/bin'),
              },
              itemBuilder: (BuildContext context, Uri path) => ListTile(
                key: ValueKey<String>(path.toString()),
                title: Text(path.toString()),
              ),
            ),
          ),
        ),
      );

      // Should show all nodes (including generated intermediate ones)
      // The ListView has 10 items: 1 header + 9 tree nodes
      expect(find.byType(ListTile), findsNWidgets(9));
    });

    testWidgets('uses custom folder builder when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableTreeListView(
              paths: samplePaths,
              initiallyExpanded: <Uri>{
                Uri.parse('file://'),
                Uri.parse('file://var'),
                Uri.parse('file://var/data'),
                Uri.parse('file://usr'),
                Uri.parse('file://usr/bin'),
              },
              itemBuilder: (BuildContext context, Uri path) =>
                  ListTile(title: Text('Leaf: $path')),
              folderBuilder: (BuildContext context, Uri path) =>
                  ListTile(title: Text('Folder: $path')),
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
              paths: const <Uri>[],
              initiallyExpanded: <Uri>{
                Uri.parse('file://'),
                Uri.parse('file://var'),
                Uri.parse('file://var/data'),
                Uri.parse('file://usr'),
                Uri.parse('file://usr/bin'),
              },
              itemBuilder: (BuildContext context, Uri path) =>
                  ListTile(title: Text(path.toString())),
            ),
          ),
        ),
      );

      expect(find.byType(ReorderableTreeListView), findsOneWidget);
      expect(find.byType(ReorderableTreeListViewItem), findsNothing);
    });

    testWidgets('rebuilds when paths change', (WidgetTester tester) async {
      List<Uri> paths = <Uri>[Uri.parse('file://var/test.txt')];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) => Column(
                children: <Widget>[
                  Expanded(
                    child: ReorderableTreeListView(
                      paths: paths,
                      initiallyExpanded: <Uri>{
                Uri.parse('file://'),
                Uri.parse('file://var'),
                Uri.parse('file://var/data'),
                Uri.parse('file://usr'),
                Uri.parse('file://usr/bin'),
              },
                      itemBuilder: (BuildContext context, Uri path) =>
                          ListTile(title: Text(path.toString())),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(
                        () => paths = <Uri>[
                          Uri.parse('file://var/test.txt'),
                          Uri.parse('file://usr/new.txt'),
                        ],
                      );
                    },
                    child: const Text('Add Path'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Initially should have 3 nodes (file://, file://var, file://var/test.txt)
      expect(find.byType(ReorderableTreeListViewItem), findsNWidgets(3));

      // Add a new path
      await tester.tap(find.text('Add Path'));
      await tester.pump();

      // Now should have 5 nodes (file://, file://var, file://var/test.txt,
      // file://usr, file://usr/new.txt)
      expect(find.byType(ReorderableTreeListViewItem), findsNWidgets(5));
    });

    testWidgets('accepts scroll controller', (WidgetTester tester) async {
      final ScrollController scrollController = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableTreeListView(
              paths: samplePaths,
              initiallyExpanded: <Uri>{
                Uri.parse('file://'),
                Uri.parse('file://var'),
                Uri.parse('file://var/data'),
                Uri.parse('file://usr'),
                Uri.parse('file://usr/bin'),
              },
              scrollController: scrollController,
              itemBuilder: (BuildContext context, Uri path) =>
                  ListTile(title: Text(path.toString())),
            ),
          ),
        ),
      );

      expect(find.byType(ReorderableTreeListView), findsOneWidget);

      // Clean up
      scrollController.dispose();
    });

    testWidgets('applies padding', (WidgetTester tester) async {
      const EdgeInsets padding = EdgeInsets.all(16);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableTreeListView(
              paths: samplePaths,
              initiallyExpanded: <Uri>{
                Uri.parse('file://'),
                Uri.parse('file://var'),
                Uri.parse('file://var/data'),
                Uri.parse('file://usr'),
                Uri.parse('file://usr/bin'),
              },
              padding: padding,
              itemBuilder: (BuildContext context, Uri path) =>
                  ListTile(title: Text(path.toString())),
            ),
          ),
        ),
      );

      // Find the ReorderableListView and check its padding
      final Finder reorderableListViewFinder = find.byType(ReorderableListView);
      expect(reorderableListViewFinder, findsOneWidget);

      final ReorderableListView reorderableListView = tester
          .widget<ReorderableListView>(reorderableListViewFinder);
      expect(reorderableListView.padding, equals(padding));
    });
  });
}
