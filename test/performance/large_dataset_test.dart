import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

import '../test_utils.dart';

void main() {
  group('Large Dataset Performance', () {
    testWidgets('should render 1000+ items efficiently', (WidgetTester tester) async {
      final largePaths = TestUtils.generateLargePaths(1000);
      
      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(TestUtils.createTestApp(
        paths: largePaths,
        expandedByDefault: false,
      ));
      
      stopwatch.stop();
      
      // Initial render should be fast
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      expect(find.byType(ReorderableTreeListViewItem), findsWidgets);
    });

    testWidgets('should scroll smoothly with large dataset', (WidgetTester tester) async {
      final largePaths = TestUtils.generateLargePaths(500);
      
      await tester.pumpWidget(TestUtils.createTestApp(
        paths: largePaths,
        expandedByDefault: false,
      ));

      // Measure scroll performance
      final stopwatch = Stopwatch()..start();
      
      // Scroll down
      await tester.fling(
        find.byType(ReorderableTreeListView),
        const Offset(0, -300),
        1000,
      );
      await tester.pumpAndSettle();
      
      // Scroll up
      await tester.fling(
        find.byType(ReorderableTreeListView),
        const Offset(0, 300),
        1000,
      );
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // Scrolling should be responsive
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });

    testWidgets('should handle expansion of large folders', (WidgetTester tester) async {
      final largePaths = TestUtils.generateLargePaths(200);
      
      await tester.pumpWidget(TestUtils.createTestApp(
        paths: largePaths,
        expandedByDefault: false,
      ));

      // Find first folder
      final folder = TestUtils.findTreeItem('folder0');
      
      final stopwatch = Stopwatch()..start();
      
      // Expand folder
      await tester.tap(folder);
      await TestUtils.pumpAndSettle(tester);
      
      stopwatch.stop();
      
      // Expansion should be fast
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
      
      // Children should be visible
      expect(TestUtils.findTreeItem('file0.txt'), findsOneWidget);
    });

    testWidgets('should efficiently update when data changes', (WidgetTester tester) async {
      List<Uri> paths = TestUtils.generateLargePaths(300);
      
      await tester.pumpWidget(StatefulBuilder(
        builder: (context, setState) {
          return TestUtils.createTestApp(
            paths: paths,
            onReorder: (oldPath, newPath) {
              setState(() {
                paths.remove(oldPath);
                paths.add(newPath);
              });
            },
          );
        },
      ));

      final stopwatch = Stopwatch()..start();
      
      // Perform reorder
      final from = find.byType(ReorderableTreeListViewItem).first;
      final to = find.byType(ReorderableTreeListViewItem).at(10);
      
      await TestUtils.dragItem(tester, from, to);
      
      stopwatch.stop();
      
      // Update should be fast
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    testWidgets('should not rebuild unnecessary widgets', (WidgetTester tester) async {
      int buildCount = 0;
      final paths = TestUtils.generateLargePaths(100);
      
      await tester.pumpWidget(TestUtils.createTestApp(
        paths: paths,
        expandedByDefault: false,
        itemBuilder: (context, path) {
          buildCount++;
          return Text(TreePath.getDisplayName(path));
        },
      ));

      final initialBuildCount = buildCount;
      
      // Expand one folder
      buildCount = 0;
      await tester.tap(TestUtils.findTreeItem('folder0'));
      await TestUtils.pumpAndSettle(tester);
      
      // Only the newly visible items should be built
      expect(buildCount, lessThan(20)); // folder0 has 10 children
    });

    testWidgets('should handle memory efficiently', (WidgetTester tester) async {
      // This test would ideally measure memory usage, but Flutter test
      // doesn't provide direct memory profiling. Instead, we ensure
      // widgets are properly disposed.
      
      final paths = TestUtils.generateLargePaths(500);
      
      await tester.pumpWidget(TestUtils.createTestApp(
        paths: paths,
      ));

      // Navigate away to dispose
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Disposed'),
          ),
        ),
      ));

      // Widgets should be disposed
      expect(find.byType(ReorderableTreeListView), findsNothing);
    });

    testWidgets('should use viewport optimization', (WidgetTester tester) async {
      final paths = TestUtils.generateLargePaths(1000);
      
      await tester.pumpWidget(TestUtils.createTestApp(
        paths: paths,
        expandedByDefault: false,
      ));

      // Count visible items
      final visibleItems = find.byType(ReorderableTreeListViewItem).evaluate().length;
      
      // Should only render visible items plus buffer
      expect(visibleItems, lessThan(100)); // Much less than 1000
    });

    testWidgets('should handle deep nesting efficiently', (WidgetTester tester) async {
      final deepPaths = <Uri>[];
      
      // Create very deep hierarchy
      String path = 'file://';
      for (int i = 0; i < 20; i++) {
        path += '/level$i';
        deepPaths.add(Uri.parse(path + '/'));
      }
      deepPaths.add(Uri.parse(path + '/deep_file.txt'));
      
      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(TestUtils.createTestApp(
        paths: deepPaths,
        expandedByDefault: true,
      ));
      
      stopwatch.stop();
      
      // Should handle deep nesting
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      expect(find.text('deep_file.txt'), findsOneWidget);
    });
  });
}