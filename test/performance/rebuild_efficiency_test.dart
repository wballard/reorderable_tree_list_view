import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

import '../test_utils.dart';

void main() {
  group('Rebuild Efficiency', () {
    testWidgets('should minimize rebuilds on state changes', (WidgetTester tester) async {
      final itemBuildCounts = <String, int>{};
      final folderBuildCounts = <String, int>{};

      await tester.pumpWidget(StatefulBuilder(
        builder: (context, setState) {
          return TestUtils.createTestApp(
            paths: TestUtils.sampleFilePaths,
            itemBuilder: (context, path) {
              final name = TreePath.getDisplayName(path);
              itemBuildCounts[name] = (itemBuildCounts[name] ?? 0) + 1;
              return Text(name);
            },
            folderBuilder: (context, path) {
              final name = TreePath.getDisplayName(path);
              folderBuildCounts[name] = (folderBuildCounts[name] ?? 0) + 1;
              return Text(name);
            },
          );
        },
      ));

      // Record initial build counts
      final initialItemBuilds = Map.from(itemBuildCounts);
      final initialFolderBuilds = Map.from(folderBuildCounts);

      // Expand a folder
      await tester.tap(TestUtils.findTreeItem('folder1'));
      await TestUtils.pumpAndSettle(tester);

      // Only affected items should rebuild
      for (final entry in itemBuildCounts.entries) {
        if (entry.key.contains('folder1')) {
          // Items in folder1 might rebuild
          expect(entry.value, greaterThanOrEqualTo(initialItemBuilds[entry.key] ?? 0));
        } else {
          // Other items should not rebuild
          expect(entry.value, equals(initialItemBuilds[entry.key] ?? 0));
        }
      }
    });

    testWidgets('should not rebuild on scroll', (WidgetTester tester) async {
      int buildCount = 0;
      final paths = TestUtils.generateLargePaths(100);

      await tester.pumpWidget(TestUtils.createTestApp(
        paths: paths,
        itemBuilder: (context, path) {
          buildCount++;
          return Text(TreePath.getDisplayName(path));
        },
      ));

      final beforeScroll = buildCount;
      buildCount = 0;

      // Scroll
      await tester.fling(
        find.byType(ReorderableTreeListView),
        const Offset(0, -200),
        1000,
      );
      await tester.pumpAndSettle();

      // Only newly visible items should build
      expect(buildCount, lessThan(beforeScroll));
    });

    testWidgets('should efficiently handle selection changes', (WidgetTester tester) async {
      final buildCounts = <String, int>{};
      Set<Uri> selectedPaths = {};

      await tester.pumpWidget(StatefulBuilder(
        builder: (context, setState) {
          return TestUtils.createTestApp(
            paths: TestUtils.sampleFilePaths,
            selectionMode: SelectionMode.multiple,
            initialSelection: selectedPaths,
            onSelectionChanged: (selection) {
              setState(() {
                selectedPaths = selection;
              });
            },
            itemBuilder: (context, path) {
              final name = TreePath.getDisplayName(path);
              buildCounts[name] = (buildCounts[name] ?? 0) + 1;
              
              final isSelected = selectedPaths.contains(path);
              return Container(
                color: isSelected ? Colors.blue.withOpacity(0.2) : null,
                child: Text(name),
              );
            },
          );
        },
      ));

      // Reset counts after initial build
      buildCounts.clear();

      // Select an item
      await tester.tap(find.byType(ReorderableTreeListViewItem).first);
      await tester.pump();

      // Only selected item should rebuild
      expect(buildCounts.length, 1);
    });

    testWidgets('should cache expensive computations', (WidgetTester tester) async {
      int expensiveComputationCount = 0;

      String expensiveComputation(Uri path) {
        expensiveComputationCount++;
        // Simulate expensive operation
        return path.toString().split('/').reversed.join('-');
      }

      await tester.pumpWidget(TestUtils.createTestApp(
        paths: TestUtils.sampleFilePaths,
        itemBuilder: (context, path) {
          final result = expensiveComputation(path);
          return Text(result);
        },
      ));

      final initialCount = expensiveComputationCount;

      // Trigger rebuild by scrolling
      await tester.fling(
        find.byType(ReorderableTreeListView),
        const Offset(0, -100),
        500,
      );
      await tester.pumpAndSettle();

      // Computation should not be repeated for visible items
      expect(expensiveComputationCount, lessThanOrEqualTo(initialCount + 5));
    });

    testWidgets('should handle theme changes efficiently', (WidgetTester tester) async {
      int buildCount = 0;
      TreeTheme theme = const TreeTheme();

      await tester.pumpWidget(StatefulBuilder(
        builder: (context, setState) {
          return TestUtils.createTestApp(
            paths: TestUtils.sampleFilePaths,
            theme: theme,
            itemBuilder: (context, path) {
              buildCount++;
              return Text(TreePath.getDisplayName(path));
            },
          );
        },
      ));

      buildCount = 0;

      // Change theme
      await tester.pumpWidget(StatefulBuilder(
        builder: (context, setState) {
          return TestUtils.createTestApp(
            paths: TestUtils.sampleFilePaths,
            theme: const TreeTheme(indentSize: 40),
            itemBuilder: (context, path) {
              buildCount++;
              return Text(TreePath.getDisplayName(path));
            },
          );
        },
      ));

      // All visible items need to rebuild for theme change
      expect(buildCount, greaterThan(0));
      expect(buildCount, lessThan(TestUtils.sampleFilePaths.length * 2));
    });

    testWidgets('should dispose resources properly', (WidgetTester tester) async {
      final disposedControllers = <String>[];

      await tester.pumpWidget(TestUtils.createTestApp(
        paths: TestUtils.sampleFilePaths,
        itemBuilder: (context, path) {
          return _DisposableItem(
            path: path,
            onDispose: () => disposedControllers.add(path.toString()),
          );
        },
      ));

      // Navigate away
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: Text('New Page')),
      ));

      // All items should be disposed
      expect(disposedControllers.length, greaterThan(0));
    });

    testWidgets('should batch updates efficiently', (WidgetTester tester) async {
      int buildCount = 0;
      List<Uri> paths = List.from(TestUtils.sampleFilePaths);

      await tester.pumpWidget(StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    // Add multiple items at once
                    paths.addAll([
                      Uri.parse('file:///new1.txt'),
                      Uri.parse('file:///new2.txt'),
                      Uri.parse('file:///new3.txt'),
                    ]);
                  });
                },
                child: const Text('Add Items'),
              ),
              Expanded(
                child: ReorderableTreeListView(
                  paths: paths,
                  itemBuilder: (context, path) {
                    buildCount++;
                    return Text(TreePath.getDisplayName(path));
                  },
                ),
              ),
            ],
          );
        },
      ));

      buildCount = 0;

      // Add multiple items
      await tester.tap(find.text('Add Items'));
      await tester.pump();

      // Should batch the updates
      expect(buildCount, equals(3)); // Only new items
    });
  });
}

class _DisposableItem extends StatefulWidget {
  final Uri path;
  final VoidCallback onDispose;

  const _DisposableItem({
    required this.path,
    required this.onDispose,
  });

  @override
  State<_DisposableItem> createState() => _DisposableItemState();
}

class _DisposableItemState extends State<_DisposableItem> {
  @override
  void dispose() {
    widget.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(TreePath.getDisplayName(widget.path));
  }
}