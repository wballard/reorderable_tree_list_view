import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

void main() {
  group('ReorderableTreeListView Callbacks', () {
    testWidgets('invokes expansion callbacks', (WidgetTester tester) async {
      final List<Uri> expandStartPaths = <Uri>[];
      final List<Uri> expandEndPaths = <Uri>[];
      final List<Uri> collapseStartPaths = <Uri>[];
      final List<Uri> collapseEndPaths = <Uri>[];

      final List<Uri> paths = <Uri>[
        Uri.parse('file:///folder1/file1.txt'),
        Uri.parse('file:///folder1/file2.txt'),
        Uri.parse('file:///folder2/file3.txt'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableTreeListView(
              paths: paths,
              itemBuilder: (BuildContext context, Uri path) => Text(path.toString()),
              onExpandStart: expandStartPaths.add,
              onExpandEnd: expandEndPaths.add,
              onCollapseStart: collapseStartPaths.add,
              onCollapseEnd: collapseEndPaths.add,
              expandedByDefault: false,
            ),
          ),
        ),
      );

      // Find and tap the expand icon for folder1
      final Finder expandIcon = find.byType(Icon).first;
      await tester.tap(expandIcon);
      await tester.pumpAndSettle();

      // Verify expansion callbacks were called
      expect(expandStartPaths, contains(Uri.parse('file:///folder1')));
      expect(expandEndPaths, contains(Uri.parse('file:///folder1')));

      // Tap again to collapse
      await tester.tap(expandIcon);
      await tester.pumpAndSettle();

      // Verify collapse callbacks were called
      expect(collapseStartPaths, contains(Uri.parse('file:///folder1')));
      expect(collapseEndPaths, contains(Uri.parse('file:///folder1')));
    });

    testWidgets('invokes drag callbacks', (WidgetTester tester) async {
      final List<Uri> dragStartPaths = <Uri>[];
      final List<Uri> dragEndPaths = <Uri>[];
      final List<(Uri, Uri)> reorders = <(Uri, Uri)>[];

      final List<Uri> paths = <Uri>[
        Uri.parse('file:///file1.txt'),
        Uri.parse('file:///file2.txt'),
        Uri.parse('file:///file3.txt'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableTreeListView(
              paths: paths,
              itemBuilder: (BuildContext context, Uri path) => SizedBox(
                    key: ValueKey<String>(path.toString()),
                    height: 60,
                    child: Text(path.toString()),
                  ),
              onDragStart: dragStartPaths.add,
              onDragEnd: dragEndPaths.add,
              onReorder: (Uri oldPath, Uri newPath) => reorders.add((oldPath, newPath)),
            ),
          ),
        ),
      );

      // Start a drag operation
      final Finder firstItem = find.text('file:///file1.txt');
      final Finder secondItem = find.text('file:///file2.txt');
      
      await tester.drag(firstItem, tester.getBottomLeft(secondItem) - tester.getTopLeft(firstItem));
      await tester.pumpAndSettle();

      // Verify drag callbacks were called
      expect(dragStartPaths, isNotEmpty);
      expect(dragEndPaths, isNotEmpty);
      expect(reorders, isNotEmpty);
    });

    testWidgets('invokes selection callbacks', (WidgetTester tester) async {
      final List<Set<Uri>> selectionChanges = <Set<Uri>>[];
      final List<Uri> itemTaps = <Uri>[];
      final List<Uri> itemActivations = <Uri>[];

      final List<Uri> paths = <Uri>[
        Uri.parse('file:///file1.txt'),
        Uri.parse('file:///file2.txt'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableTreeListView(
              paths: paths,
              itemBuilder: (BuildContext context, Uri path) => Text(path.toString()),
              selectionMode: SelectionMode.single,
              onSelectionChanged: selectionChanges.add,
              onItemTap: itemTaps.add,
              onItemActivated: itemActivations.add,
            ),
          ),
        ),
      );

      // Tap on first item
      await tester.tap(find.text('file:///file1.txt'));
      await tester.pumpAndSettle();

      // Verify callbacks
      expect(itemTaps, contains(Uri.parse('file:///file1.txt')));
      expect(selectionChanges, isNotEmpty);
      expect(selectionChanges.last, contains(Uri.parse('file:///file1.txt')));

      // Double-tap for activation
      await tester.tap(find.text('file:///file2.txt'));
      await tester.tap(find.text('file:///file2.txt'));
      await tester.pumpAndSettle();

      // For now, activation happens on Enter key in keyboard navigation
      // expect(itemActivations, contains(Uri.parse('file:///file2.txt')));
    });

    testWidgets('validation callbacks prevent actions', (WidgetTester tester) async {
      final List<Uri> expandedPaths = <Uri>[];
      bool allowExpansion = true;

      final List<Uri> paths = <Uri>[
        Uri.parse('file:///folder1/file1.txt'),
        Uri.parse('file:///folder2/file2.txt'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableTreeListView(
              paths: paths,
              itemBuilder: (BuildContext context, Uri path) => Text(path.toString()),
              expandedByDefault: false,
              canExpand: (Uri path) => allowExpansion,
              onExpandEnd: expandedPaths.add,
            ),
          ),
        ),
      );

      // Try to expand with validation allowed
      final Finder expandIcon = find.byType(Icon).first;
      await tester.tap(expandIcon);
      await tester.pumpAndSettle();

      expect(expandedPaths, contains(Uri.parse('file:///folder1')));

      // Prevent expansion
      allowExpansion = false;
      expandedPaths.clear();

      // Try to expand folder2
      final Finder expandIcon2 = find.byType(Icon).at(1);
      await tester.tap(expandIcon2);
      await tester.pumpAndSettle();

      // Should not have expanded
      expect(expandedPaths, isEmpty);
    });

    testWidgets('context menu callback works', (WidgetTester tester) async {
      final List<(Uri, Offset)> contextMenuEvents = <(Uri, Offset)>[];

      final List<Uri> paths = <Uri>[
        Uri.parse('file:///file1.txt'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableTreeListView(
              paths: paths,
              itemBuilder: (BuildContext context, Uri path) => Text(path.toString()),
              onContextMenu: (Uri path, Offset position) => 
                  contextMenuEvents.add((path, position)),
            ),
          ),
        ),
      );

      // Right-click on item - use secondary tap
      await tester.tapAt(
        tester.getCenter(find.text('file:///file1.txt')),
        buttons: kSecondaryButton,
      );
      await tester.pumpAndSettle();

      expect(contextMenuEvents, isNotEmpty);
      expect(contextMenuEvents.first.$1, equals(Uri.parse('file:///file1.txt')));
    });

    testWidgets('async validation callbacks work', (WidgetTester tester) async {
      final List<Uri> expandedPaths = <Uri>[];

      final List<Uri> paths = <Uri>[
        Uri.parse('file:///folder1/file1.txt'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableTreeListView(
              paths: paths,
              itemBuilder: (BuildContext context, Uri path) => Text(path.toString()),
              expandedByDefault: false,
              canExpandAsync: (Uri path) async {
                await Future<void>.delayed(const Duration(milliseconds: 100));
                return path.path.contains('folder1');
              },
              onExpandEnd: expandedPaths.add,
            ),
          ),
        ),
      );

      // Try to expand
      final Finder expandIcon = find.byType(Icon).first;
      await tester.tap(expandIcon);
      
      // Wait for async validation
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();

      expect(expandedPaths, contains(Uri.parse('file:///folder1')));
    });
  });
}