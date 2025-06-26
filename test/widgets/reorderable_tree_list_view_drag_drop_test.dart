import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

const Duration kLongPressTimeout = Duration(milliseconds: 500);

void main() {
  group('ReorderableTreeListView Drag and Drop', () {
    late List<Uri> testPaths;
    
    setUp(() {
      testPaths = <Uri>[
        Uri.parse('file://folder1/file1.txt'),
        Uri.parse('file://folder1/file2.txt'),
        Uri.parse('file://folder2/subfolder/file3.txt'),
        Uri.parse('file://folder3/file4.txt'),
        Uri.parse('file://file5.txt'),
      ];
    });
    
    Widget buildTestWidget({
      required List<Uri> paths,
      void Function(Uri oldPath, Uri newPath)? onReorder,
      void Function(Uri path)? onDragStart,
      void Function(Uri path)? onDragEnd,
      bool Function(Uri draggedPath, Uri targetPath)? onWillAcceptDrop,
      Widget Function(Widget child, int index, Animation<double> animation)? proxyDecorator,
    }) =>
        MaterialApp(
          home: Scaffold(
            body: ReorderableTreeListView(
              paths: paths,
              itemBuilder: (BuildContext context, Uri path) => Text(path.toString()),
              onReorder: onReorder,
              onDragStart: onDragStart,
              onDragEnd: onDragEnd,
              onWillAcceptDrop: onWillAcceptDrop,
              proxyDecorator: proxyDecorator,
            ),
          ),
        );
    
    testWidgets('should call onReorder when item is moved', (WidgetTester tester) async {
      Uri? reorderedOldPath;
      Uri? reorderedNewPath;
      
      await tester.pumpWidget(buildTestWidget(
        paths: testPaths,
        onReorder: (Uri oldPath, Uri newPath) {
          reorderedOldPath = oldPath;
          reorderedNewPath = newPath;
        },
      ));
      
      // Wait for tree to build
      await tester.pumpAndSettle();
      
      // Find and drag file1.txt
      final Finder file1Finder = find.text('file://folder1/file1.txt');
      expect(file1Finder, findsOneWidget);
      
      // Drag to a new position
      final TestGesture gesture = await tester.startGesture(tester.getCenter(file1Finder));
      await tester.pump(kLongPressTimeout);
      
      // Move down past file2.txt
      await gesture.moveBy(const Offset(0, 100));
      await tester.pump();
      
      // Release
      await gesture.up();
      await tester.pumpAndSettle();
      
      // Verify onReorder was called
      expect(reorderedOldPath, Uri.parse('file://folder1/file1.txt'));
      expect(reorderedNewPath, isNotNull);
    });
    
    testWidgets('should call onDragStart when drag begins', (WidgetTester tester) async {
      Uri? dragStartPath;
      
      await tester.pumpWidget(buildTestWidget(
        paths: testPaths,
        onDragStart: (Uri path) {
          dragStartPath = path;
        },
      ));
      
      await tester.pumpAndSettle();
      
      // Start dragging file1.txt
      final Finder file1Finder = find.text('file://folder1/file1.txt');
      final TestGesture gesture = await tester.startGesture(tester.getCenter(file1Finder));
      await tester.pump(kLongPressTimeout);
      
      // Verify onDragStart was called
      expect(dragStartPath, Uri.parse('file://folder1/file1.txt'));
      
      await gesture.up();
      await tester.pumpAndSettle();
    });
    
    testWidgets('should call onDragEnd when drag ends', (WidgetTester tester) async {
      Uri? dragEndPath;
      
      await tester.pumpWidget(buildTestWidget(
        paths: testPaths,
        onDragEnd: (Uri path) {
          dragEndPath = path;
        },
      ));
      
      await tester.pumpAndSettle();
      
      // Start and end drag
      final Finder file1Finder = find.text('file://folder1/file1.txt');
      final TestGesture gesture = await tester.startGesture(tester.getCenter(file1Finder));
      await tester.pump(kLongPressTimeout);
      await gesture.up();
      await tester.pumpAndSettle();
      
      // Verify onDragEnd was called
      expect(dragEndPath, Uri.parse('file://folder1/file1.txt'));
    });
    
    testWidgets('should respect onWillAcceptDrop validation', (WidgetTester tester) async {
      bool reorderCalled = false;
      
      await tester.pumpWidget(buildTestWidget(
        paths: testPaths,
        onReorder: (Uri oldPath, Uri newPath) {
          reorderCalled = true;
        },
        onWillAcceptDrop: (Uri draggedPath, Uri targetPath) =>
            // Prevent moving into folder2
            !targetPath.toString().contains('folder2'),
      ));
      
      await tester.pumpAndSettle();
      
      // Try to drag file1.txt to a position that would put it in folder2
      final Finder file1Finder = find.text('file://folder1/file1.txt');
      
      // Find folder2 first
      final Finder folder2Finder = find.text('file://folder2/');
      
      final TestGesture gesture = await tester.startGesture(tester.getCenter(file1Finder));
      await tester.pump(kLongPressTimeout);
      
      // Move just below folder2 to drop into it
      final Offset folder2Position = tester.getCenter(folder2Finder);
      await gesture.moveTo(Offset(folder2Position.dx, folder2Position.dy + 30));
      await tester.pump();
      
      await gesture.up();
      await tester.pumpAndSettle();
      
      // Verify onReorder was NOT called due to validation failure
      expect(reorderCalled, false);
    });
    
    testWidgets('should apply custom proxyDecorator during drag', (WidgetTester tester) async {
      bool decoratorApplied = false;
      
      await tester.pumpWidget(buildTestWidget(
        paths: testPaths,
        proxyDecorator: (Widget child, int index, Animation<double> animation) {
          decoratorApplied = true;
          return Material(
            elevation: 8,
            color: Colors.blue.withValues(alpha: 0.5),
            child: child,
          );
        },
      ));
      
      await tester.pumpAndSettle();
      
      // Start dragging
      final Finder file1Finder = find.text('file://folder1/file1.txt');
      final TestGesture gesture = await tester.startGesture(tester.getCenter(file1Finder));
      await tester.pump(kLongPressTimeout);
      
      // Move a bit to trigger proxy
      await gesture.moveBy(const Offset(0, 10));
      await tester.pump();
      
      // Verify decorator was applied
      expect(decoratorApplied, true);
      
      // Check for elevated material (proxy)
      expect(find.byType(Material).evaluate().where((Element element) {
        final Material material = element.widget as Material;
        return material.elevation == 8;
      }), isNotEmpty);
      
      await gesture.up();
      await tester.pumpAndSettle();
    });
    
    
    testWidgets('should handle complex tree reorganization', (WidgetTester tester) async {
      final List<Uri> complexPaths = <Uri>[
        Uri.parse('file://projectA/src/main.dart'),
        Uri.parse('file://projectA/src/utils/helpers.dart'),
        Uri.parse('file://projectA/tests/main_test.dart'),
        Uri.parse('file://projectB/lib/app.dart'),
        Uri.parse('file://projectB/lib/widgets/button.dart'),
        Uri.parse('file://shared/config.yaml'),
      ];
      
      Uri? movedFrom;
      Uri? movedTo;
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ReorderableTreeListView(
            paths: complexPaths,
            itemBuilder: (BuildContext context, Uri path) => Text(path.toString()),
            onReorder: (Uri oldPath, Uri newPath) {
              movedFrom = oldPath;
              movedTo = newPath;
            }
          ),
        ),
      ));
      
      await tester.pumpAndSettle();
      
      // Move helpers.dart from projectA to projectB/lib
      final Finder helpersFinder = find.text('file://projecta/src/utils/helpers.dart');
      final TestGesture gesture = await tester.startGesture(tester.getCenter(helpersFinder));
      await tester.pump(kLongPressTimeout);
      
      // Move to projectB area
      await gesture.moveBy(const Offset(0, 200));
      await tester.pump();
      
      await gesture.up();
      await tester.pumpAndSettle();
      
      // Verify the move
      expect(movedFrom, Uri.parse('file://projectA/src/utils/helpers.dart'));
      expect(movedTo?.toString(), contains('projectb'));
    });
  });
}