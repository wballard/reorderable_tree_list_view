import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

void main() {
  group('ReorderableTreeListView Expansion Integration', () {
    late List<Uri> testPaths;

    setUp(() {
      testPaths = <Uri>[
        Uri.parse('file://root/folder1/file1.txt'),
        Uri.parse('file://root/folder1/file2.txt'),
        Uri.parse('file://root/folder2/file3.txt'),
        Uri.parse('file://root/file4.txt'),
      ];
    });

    group('initialization', () {
      testWidgets('should expand all folders by default', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReorderableTreeListView(
                paths: testPaths,
                itemBuilder: (BuildContext context, Uri path) => Text(
                  path.pathSegments.isNotEmpty
                      ? path.pathSegments.last
                      : path.toString(),
                ),
              ),
            ),
          ),
        );

        // Should show all nodes when expanded by default
        expect(find.text('file:///'), findsOneWidget);
        expect(find.text('file://root/'), findsOneWidget);
        expect(find.text('folder1'), findsOneWidget);
        expect(find.text('folder2'), findsOneWidget);
        expect(find.text('file1.txt'), findsOneWidget);
        expect(find.text('file2.txt'), findsOneWidget);
        expect(find.text('file3.txt'), findsOneWidget);
        expect(find.text('file4.txt'), findsOneWidget);
      });

      testWidgets(
        'should collapse all folders when expandedByDefault is false',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: ReorderableTreeListView(
                  paths: testPaths,
                  expandedByDefault: false,
                  itemBuilder: (BuildContext context, Uri path) => Text(
                    path.pathSegments.isNotEmpty
                        ? path.pathSegments.last
                        : path.toString(),
                  ),
                ),
              ),
            ),
          );

          // Should show only root node when collapsed by default
          expect(find.text('file:///'), findsOneWidget);
          expect(find.text('file://root/'), findsNothing);
          expect(find.text('folder1'), findsNothing);
          expect(find.text('file1.txt'), findsNothing);
        },
      );

      testWidgets('should respect initiallyExpanded parameter', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReorderableTreeListView(
                paths: testPaths,
                expandedByDefault: false,
                initiallyExpanded: <Uri>{
                  Uri.parse('file://'),
                  Uri.parse('file://root'),
                },
                itemBuilder: (BuildContext context, Uri path) => Text(
                  path.pathSegments.isNotEmpty
                      ? path.pathSegments.last
                      : path.toString(),
                ),
              ),
            ),
          ),
        );

        // Should show root and its immediate children
        expect(find.text('file:///'), findsOneWidget);
        expect(find.text('file://root/'), findsOneWidget);
        expect(find.text('folder1'), findsOneWidget);
        expect(find.text('folder2'), findsOneWidget);
        expect(find.text('file4.txt'), findsOneWidget);

        // But not the contents of folders
        expect(find.text('file1.txt'), findsNothing);
        expect(find.text('file2.txt'), findsNothing);
        expect(find.text('file3.txt'), findsNothing);
      });
    });

    group('interaction', () {
      testWidgets('should toggle expansion when icon is tapped', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReorderableTreeListView(
                paths: testPaths,
                itemBuilder: (BuildContext context, Uri path) => Text(
                  path.pathSegments.isNotEmpty
                      ? path.pathSegments.last
                      : path.toString(),
                ),
              ),
            ),
          ),
        );

        // Verify folder1 contents are initially visible
        expect(find.text('file1.txt'), findsOneWidget);
        expect(find.text('file2.txt'), findsOneWidget);

        // Find and tap the collapse icon for folder1
        // First, find the folder1 row, then find the arrow down icon in that row
        final Finder folder1Finder = find.ancestor(
          of: find.text('folder1'),
          matching: find.byType(ReorderableTreeListViewItem),
        );

        final Finder arrowIconFinder = find.descendant(
          of: folder1Finder,
          matching: find.byIcon(Icons.keyboard_arrow_down),
        );

        expect(arrowIconFinder, findsOneWidget);
        await tester.tap(arrowIconFinder);
        await tester.pump();

        // Verify folder1 contents are now hidden
        expect(find.text('file1.txt'), findsNothing);
        expect(find.text('file2.txt'), findsNothing);

        // But folder1 itself should still be visible with right arrow
        expect(find.text('folder1'), findsOneWidget);
        final Finder arrowRightFinder = find.descendant(
          of: folder1Finder,
          matching: find.byIcon(Icons.keyboard_arrow_right),
        );
        expect(arrowRightFinder, findsOneWidget);
      });

      testWidgets('should expand collapsed folder when icon is tapped', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReorderableTreeListView(
                paths: testPaths,
                expandedByDefault: false,
                initiallyExpanded: <Uri>{
                  Uri.parse('file://'),
                  Uri.parse('file://root'),
                },
                itemBuilder: (BuildContext context, Uri path) => Text(
                  path.pathSegments.isNotEmpty
                      ? path.pathSegments.last
                      : path.toString(),
                ),
              ),
            ),
          ),
        );

        // Verify folder1 contents are initially hidden
        expect(find.text('file1.txt'), findsNothing);
        expect(find.text('file2.txt'), findsNothing);

        // Find and tap the expand icon for folder1
        final Finder folder1Finder = find.ancestor(
          of: find.text('folder1'),
          matching: find.byType(ReorderableTreeListViewItem),
        );

        final Finder arrowRightFinder = find.descendant(
          of: folder1Finder,
          matching: find.byIcon(Icons.keyboard_arrow_right),
        );

        expect(arrowRightFinder, findsOneWidget);
        await tester.tap(arrowRightFinder);
        await tester.pump();

        // Verify folder1 contents are now visible
        expect(find.text('file1.txt'), findsOneWidget);
        expect(find.text('file2.txt'), findsOneWidget);

        // Arrow should now point down
        final Finder arrowDownFinder = find.descendant(
          of: folder1Finder,
          matching: find.byIcon(Icons.keyboard_arrow_down),
        );
        expect(arrowDownFinder, findsOneWidget);
      });
    });

    group('edge cases', () {
      testWidgets('should handle empty paths list', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReorderableTreeListView(
                paths: const <Uri>[],
                itemBuilder: (BuildContext context, Uri path) =>
                    Text(path.toString()),
              ),
            ),
          ),
        );

        // Should not crash and should show no items
        expect(find.byType(ReorderableTreeListViewItem), findsNothing);
      });

      testWidgets('should handle paths with no common parent', (
        WidgetTester tester,
      ) async {
        final List<Uri> diversePaths = <Uri>[
          Uri.parse('file://path1/file1.txt'),
          Uri.parse('http://example.com/file2.txt'),
          Uri.parse('https://example.org/file3.txt'),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReorderableTreeListView(
                paths: diversePaths,
                itemBuilder: (BuildContext context, Uri path) => Text(
                  path.pathSegments.isNotEmpty
                      ? path.pathSegments.last
                      : path.toString(),
                ),
              ),
            ),
          ),
        );

        // Should handle different schemes properly
        expect(find.text('file:///'), findsOneWidget);
        expect(find.text('http://example.com'), findsOneWidget);
        expect(find.text('https://example.org'), findsOneWidget);
      });
    });
  });
}
