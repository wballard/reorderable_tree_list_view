import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

import '../test_utils.dart';

void main() {
  group('Drag and Drop Integration', () {
    testWidgets('complete drag and drop flow', (WidgetTester tester) async {
      List<Uri> paths = List.from(TestUtils.sampleFilePaths);
      Uri? draggedPath;
      Uri? droppedPath;

      await tester.pumpWidget(StatefulBuilder(
        builder: (context, setState) {
          return TestUtils.createTestApp(
            paths: paths,
            onReorder: (oldPath, newPath) {
              setState(() {
                paths.remove(oldPath);
                paths.add(newPath);
                draggedPath = oldPath;
                droppedPath = newPath;
              });
            },
          );
        },
      ));

      // Find source and target
      final source = TestUtils.findTreeItem('file5.txt');
      final target = TestUtils.findTreeItem('folder1');

      // Perform drag
      await TestUtils.dragItem(tester, source, target);

      // Verify reorder happened
      expect(draggedPath.toString(), contains('file5.txt'));
      expect(droppedPath.toString(), contains('folder1/file5.txt'));

      // Verify UI updated
      expect(TestUtils.findTreeItem('file5.txt'), findsOneWidget);
      
      // File should now be inside folder1
      final folder1 = TestUtils.findTreeItem('folder1');
      final expandIcon = TestUtils.findExpandIcon('folder1');
      await tester.tap(expandIcon);
      await TestUtils.pumpAndSettle(tester);
      
      // Should see file5.txt inside folder1
      expect(find.text('file5.txt'), findsOneWidget);
    });

    testWidgets('visual feedback during drag', (WidgetTester tester) async {
      bool isDragging = false;
      Uri? draggingPath;

      await tester.pumpWidget(TestUtils.createTestApp(
        paths: TestUtils.sampleFilePaths,
        onReorder: (oldPath, newPath) {},
        onDragStart: (path) {
          isDragging = true;
          draggingPath = path;
        },
        onDragEnd: (path) {
          isDragging = false;
        },
        proxyDecorator: (child, index, animation) {
          return Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: child,
          );
        },
      ));

      // Start drag
      final item = find.byType(ReorderableTreeListViewItem).first;
      final gesture = await tester.startGesture(tester.getCenter(item));
      await tester.pump(const Duration(milliseconds: 100));

      // Check drag started
      expect(isDragging, isTrue);
      expect(draggingPath, isNotNull);

      // Move to show feedback
      await gesture.moveBy(const Offset(0, 50));
      await tester.pump();

      // Look for elevated material (proxy)
      final elevatedMaterial = find.byWidgetPredicate(
        (widget) => widget is Material && widget.elevation! > 0,
      );
      expect(elevatedMaterial, findsOneWidget);

      // End drag
      await gesture.up();
      await tester.pump();

      expect(isDragging, isFalse);
    });

    testWidgets('drop validation', (WidgetTester tester) async {
      int dropValidationCount = 0;
      bool allowDrop = true;

      await tester.pumpWidget(TestUtils.createTestApp(
        paths: TestUtils.sampleFilePaths,
        onReorder: (oldPath, newPath) {},
        onWillAcceptDrop: (draggedPath, targetPath) {
          dropValidationCount++;
          return allowDrop;
        },
      ));

      // Try to drag
      final source = find.byType(ReorderableTreeListViewItem).first;
      final target = find.byType(ReorderableTreeListViewItem).last;

      // First drag - allowed
      await TestUtils.dragItem(tester, source, target);
      expect(dropValidationCount, greaterThan(0));

      // Second drag - disallowed
      dropValidationCount = 0;
      allowDrop = false;
      
      await TestUtils.dragItem(tester, source, target);
      expect(dropValidationCount, greaterThan(0));
    });

    testWidgets('reordering within same level', (WidgetTester tester) async {
      List<Uri> paths = [
        Uri.parse('file:///a.txt'),
        Uri.parse('file:///b.txt'),
        Uri.parse('file:///c.txt'),
        Uri.parse('file:///d.txt'),
      ];

      await tester.pumpWidget(StatefulBuilder(
        builder: (context, setState) {
          return TestUtils.createTestApp(
            paths: paths,
            onReorder: (oldPath, newPath) {
              setState(() {
                paths.remove(oldPath);
                // Insert at correct position
                final targetIndex = paths.indexWhere((p) => p.toString() > newPath.toString());
                if (targetIndex >= 0) {
                  paths.insert(targetIndex, newPath);
                } else {
                  paths.add(newPath);
                }
              });
            },
          );
        },
      ));

      // Drag c.txt to position before a.txt
      final source = TestUtils.findTreeItem('c.txt');
      final target = TestUtils.findTreeItem('a.txt');
      
      await TestUtils.dragItem(tester, source, target);

      // Verify new order
      final items = find.byType(ReorderableTreeListViewItem).evaluate().toList();
      expect(items.length, 4);
      
      // c should now be before a
      final texts = items.map((e) => 
        find.descendant(of: find.byWidget(e.widget), matching: find.byType(Text))
          .evaluate().first.widget as Text
      ).map((t) => t.data).toList();
      
      expect(texts.indexOf('c.txt'), lessThan(texts.indexOf('a.txt')));
    });

    testWidgets('complex reordering scenarios', (WidgetTester tester) async {
      List<Uri> paths = [
        Uri.parse('file:///root1.txt'),
        Uri.parse('file:///folder1/file1.txt'),
        Uri.parse('file:///folder1/subfolder/deep.txt'),
        Uri.parse('file:///folder2/file2.txt'),
        Uri.parse('file:///root2.txt'),
      ];

      await tester.pumpWidget(StatefulBuilder(
        builder: (context, setState) {
          return TestUtils.createTestApp(
            paths: paths,
            expandedByDefault: true,
            onReorder: (oldPath, newPath) {
              setState(() {
                paths.remove(oldPath);
                paths.add(newPath);
              });
            },
          );
        },
      ));

      // Move deep file to root
      final deepFile = TestUtils.findTreeItem('deep.txt');
      final rootArea = find.byType(ReorderableTreeListView);
      
      final gesture = await tester.startGesture(tester.getCenter(deepFile));
      await tester.pump(const Duration(milliseconds: 100));
      
      // Drag to top of list
      await gesture.moveTo(tester.getTopLeft(rootArea) + const Offset(50, 50));
      await tester.pump();
      
      await gesture.up();
      await TestUtils.pumpAndSettle(tester);

      // deep.txt should now be at root level
      expect(paths.any((p) => p.toString() == 'file:///deep.txt'), isTrue);
    });

    testWidgets('drag and drop with animations', (WidgetTester tester) async {
      await tester.pumpWidget(TestUtils.createTestApp(
        paths: TestUtils.sampleFilePaths,
        animateExpansion: true,
        onReorder: (oldPath, newPath) {},
      ));

      // Start drag
      final item = find.byType(ReorderableTreeListViewItem).first;
      final gesture = await tester.startGesture(tester.getCenter(item));
      
      // Trigger lift animation
      await tester.pump(const Duration(milliseconds: 100));
      
      // Move item
      await gesture.moveBy(const Offset(0, 100));
      
      // Animation frames
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 16));
      
      // Drop
      await gesture.up();
      
      // Settle animation
      await TestUtils.pumpAndSettle(tester);
    });

    testWidgets('multi-level drag and drop', (WidgetTester tester) async {
      final paths = [
        Uri.parse('file:///level1/'),
        Uri.parse('file:///level1/level2/'),
        Uri.parse('file:///level1/level2/level3/'),
        Uri.parse('file:///level1/level2/level3/deep_file.txt'),
        Uri.parse('file:///target_folder/'),
      ];

      await tester.pumpWidget(StatefulBuilder(
        builder: (context, setState) {
          return TestUtils.createTestApp(
            paths: paths,
            expandedByDefault: true,
            onReorder: (oldPath, newPath) {
              setState(() {
                paths.remove(oldPath);
                paths.add(newPath);
              });
            },
          );
        },
      ));

      // Move deeply nested file to different folder
      final deepFile = TestUtils.findTreeItem('deep_file.txt');
      final targetFolder = TestUtils.findTreeItem('target_folder');
      
      await TestUtils.dragItem(tester, deepFile, targetFolder);

      // Verify file moved
      expect(
        paths.any((p) => p.toString().contains('target_folder/deep_file.txt')),
        isTrue,
      );
    });
  });
}