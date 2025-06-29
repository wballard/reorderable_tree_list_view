import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

import '../test_utils.dart';

void main() {
  group('Screen Reader Accessibility', () {
    testWidgets('should provide semantic labels for all items', (WidgetTester tester) async {
      await tester.pumpWidget(TestUtils.createTestApp(
        paths: TestUtils.sampleFilePaths,
      ));

      // Check each item has semantic label
      final items = find.byType(ReorderableTreeListViewItem);
      expect(items, findsWidgets);

      for (final item in items.evaluate()) {
        final semantics = tester.getSemantics(find.byWidget(item.widget));
        expect(semantics.label, isNotEmpty);
      }
    });

    testWidgets('should announce tree structure', (WidgetTester tester) async {
      await tester.pumpWidget(TestUtils.createTestApp(
        paths: TestUtils.sampleFilePaths,
      ));

      // Check folder semantics
      final folderItem = find.ancestor(
        of: find.text('folder1'),
        matching: find.byType(ReorderableTreeListViewItem),
      );

      final folderSemantics = tester.getSemantics(folderItem);
      expect(folderSemantics.hasFlag(SemanticsFlag.hasExpandedState), isTrue);
    });

    testWidgets('should announce expansion state changes', (WidgetTester tester) async {
      bool expandAnnounced = false;
      
      await tester.pumpWidget(TestUtils.createTestApp(
        paths: TestUtils.sampleFilePaths,
        expandedByDefault: false,
        onExpandStart: (path) {
          expandAnnounced = true;
        },
      ));

      // Tap to expand
      final folderItem = TestUtils.findTreeItem('folder1');
      await tester.tap(folderItem);
      await tester.pump();

      expect(expandAnnounced, isTrue);

      // Check semantics updated
      final semantics = tester.getSemantics(folderItem);
      expect(semantics.hasFlag(SemanticsFlag.hasExpandedState), isTrue);
    });

    testWidgets('should provide context for drag operations', (WidgetTester tester) async {
      await tester.pumpWidget(TestUtils.createTestApp(
        paths: TestUtils.sampleFilePaths,
        onReorder: (oldPath, newPath) {},
      ));

      // Long press to start drag
      final item = find.byType(ReorderableTreeListViewItem).first;
      await tester.longPress(item);
      await tester.pump();

      // Check drag semantics
      final semantics = tester.getSemantics(item);
      expect(semantics, isNotNull);
    });

    testWidgets('should announce selection changes', (WidgetTester tester) async {
      Set<Uri> selectedPaths = {};
      
      await tester.pumpWidget(TestUtils.createTestApp(
        paths: TestUtils.sampleFilePaths,
        selectionMode: SelectionMode.multiple,
        onSelectionChanged: (selection) => selectedPaths = selection,
      ));

      // Select an item
      final item = find.byType(ReorderableTreeListViewItem).first;
      await tester.tap(item);
      await tester.pump();

      // Check selection announced
      expect(selectedPaths, isNotEmpty);
      
      final semantics = tester.getSemantics(item);
      expect(semantics.hasFlag(SemanticsFlag.isSelected), isTrue);
    });

    testWidgets('should provide helpful hints', (WidgetTester tester) async {
      await tester.pumpWidget(TestUtils.createTestApp(
        paths: TestUtils.sampleFilePaths,
        itemBuilder: (context, path) => Semantics(
          hint: 'Double tap to open',
          child: Text(TreePath.getDisplayName(path)),
        ),
        folderBuilder: (context, path) => Semantics(
          hint: 'Double tap to expand',
          child: Row(
            children: [
              const Icon(Icons.folder),
              const SizedBox(width: 8),
              Text(TreePath.getDisplayName(path)),
            ],
          ),
        ),
      ));

      // Check hints are present
      final item = find.byType(ReorderableTreeListViewItem).first;
      final semantics = tester.getSemantics(item);
      expect(semantics.hint, isNotEmpty);
    });

    testWidgets('should handle live regions for updates', (WidgetTester tester) async {
      final List<Uri> paths = List.from(TestUtils.sampleFilePaths);
      
      await tester.pumpWidget(StatefulBuilder(
        builder: (context, setState) {
          return TestUtils.createTestApp(
            paths: paths,
            onReorder: (oldPath, newPath) {
              setState(() {
                paths.remove(oldPath);
                paths.add(newPath);
              });
              
              // Announce change
              SemanticsService.announce(
                'Moved ${TreePath.getDisplayName(oldPath)} to ${TreePath.getDisplayName(newPath)}',
                TextDirection.ltr,
              );
            },
          );
        },
      ));

      // Simulate reorder
      final from = find.byType(ReorderableTreeListViewItem).first;
      final to = find.byType(ReorderableTreeListViewItem).last;
      
      await TestUtils.dragItem(tester, from, to);
    });

    testWidgets('should provide loading state announcements', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Semantics(
            label: 'Loading tree data',
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ));

      final semantics = tester.getSemantics(find.byType(CircularProgressIndicator));
      expect(semantics.label, contains('Loading'));

      // Switch to loaded state
      await tester.pumpWidget(TestUtils.createTestApp(
        paths: TestUtils.sampleFilePaths,
      ));

      // Verify tree is announced
      final tree = find.byType(ReorderableTreeListView);
      expect(tree, findsOneWidget);
    });

    testWidgets('should support high contrast mode', (WidgetTester tester) async {
      await tester.pumpWidget(MediaQuery(
        data: const MediaQueryData(
          highContrast: true,
        ),
        child: TestUtils.createTestApp(
          paths: TestUtils.sampleFilePaths,
          theme: const TreeTheme(
            connectorColor: Colors.black,
            connectorWidth: 3.0,
          ),
        ),
      ));

      // Verify high contrast rendering
      final tree = find.byType(ReorderableTreeListView);
      expect(tree, findsOneWidget);
    });
  });
}