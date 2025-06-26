import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

void main() {
  group('ReorderableTreeListView Basic Callbacks', () {
    testWidgets('invokes onItemTap callback', (WidgetTester tester) async {
      final List<Uri> tappedPaths = <Uri>[];

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
              onItemTap: tappedPaths.add,
            ),
          ),
        ),
      );

      // Tap on first item
      await tester.tap(find.text('file:///file1.txt'));
      await tester.pumpAndSettle();

      expect(tappedPaths, contains(Uri.parse('file:///file1.txt')));
    });

    testWidgets('invokes onSelectionChanged callback', (WidgetTester tester) async {
      final List<Set<Uri>> selectionChanges = <Set<Uri>>[];

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
            ),
          ),
        ),
      );

      // Tap on first item
      await tester.tap(find.text('file:///file1.txt'));
      await tester.pumpAndSettle();

      expect(selectionChanges, isNotEmpty);
      expect(selectionChanges.last, contains(Uri.parse('file:///file1.txt')));
    });

    testWidgets('basic drag and drop works', (WidgetTester tester) async {
      final List<(Uri, Uri)> reorders = <(Uri, Uri)>[];

      final List<Uri> paths = <Uri>[
        Uri.parse('file:///file1.txt'),
        Uri.parse('file:///file2.txt'),
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
              onReorder: (Uri oldPath, Uri newPath) => reorders.add((oldPath, newPath)),
            ),
          ),
        ),
      );

      // Perform drag
      await tester.drag(
        find.text('file:///file1.txt'),
        const Offset(0, 80),
      );
      await tester.pumpAndSettle();

      expect(reorders, isNotEmpty);
    });
  });
}