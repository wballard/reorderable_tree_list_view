import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

void main() {
  group('Drag and Drop Knob Consistency Tests', () {
    testWidgets('When enableDragAndDrop is false, drag should be completely disabled', (
      WidgetTester tester,
    ) async {
      // Track if callbacks are invoked 
      bool onReorderCalled = false;
      bool onDragStartCalled = false;
      bool onDragEndCalled = false;

      const bool enableDragAndDrop = false;
      
      final paths = [
        Uri.parse('file://file1.txt'),
        Uri.parse('file://file2.txt'),
      ];

      // Create a widget that simulates the FIXED behavior
      Widget fixedImplementation = MaterialApp(
        home: Scaffold(
          body: ReorderableTreeListView(
            paths: paths,
            // Expand the root so we can see the files
            initiallyExpanded: {Uri.parse('file://')},
            enableDragAndDrop: enableDragAndDrop,
            itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
            
            // FIXED: Drag functionality is now controlled by enableDragAndDrop parameter
            onReorder: (oldPath, newPath) => onReorderCalled = true,
            onDragStart: (path) => onDragStartCalled = true,
            onDragEnd: (path) => onDragEndCalled = true,
          ),
        ),
      );

      await tester.pumpWidget(fixedImplementation);
      await tester.pumpAndSettle();

      // Now we should find the file
      final finder = find.text('file1.txt');
      expect(finder, findsOneWidget);

      // Simulate drag start
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(finder),
      );
      await tester.pump(const Duration(milliseconds: 500)); // Long press timeout

      // Move and release
      await gesture.moveBy(const Offset(0, 50));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      // When enableDragAndDrop is false, drag should be completely prevented
      // NONE of the callbacks should be called because drag doesn't start
      expect(onReorderCalled, false, reason: 'onReorder should not be called when enableDragAndDrop is false');
      expect(onDragStartCalled, false, reason: 'onDragStart should not be called when enableDragAndDrop is false');
      expect(onDragEndCalled, false, reason: 'onDragEnd should not be called when enableDragAndDrop is false');
    });

    testWidgets('When enableDragAndDrop is true, all drag callbacks should work', (
      WidgetTester tester,
    ) async {
      bool onDragStartCalled = false;
      bool onDragEndCalled = false;

      const bool enableDragAndDrop = true;
      
      final paths = [
        Uri.parse('file://file1.txt'),
        Uri.parse('file://file2.txt'),
      ];

      // Create the correct implementation with all callbacks enabled
      Widget correctImplementation = MaterialApp(
        home: Scaffold(
          body: ReorderableTreeListView(
            paths: paths,
            initiallyExpanded: {Uri.parse('file://')},
            enableDragAndDrop: enableDragAndDrop,
            itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
            
            // All callbacks are always provided, enableDragAndDrop controls behavior
            onReorder: (oldPath, newPath) {
              // onReorder callback - not testing this particular callback in this test
            },
            onDragStart: (path) => onDragStartCalled = true,
            onDragEnd: (path) => onDragEndCalled = true,
          ),
        ),
      );

      await tester.pumpWidget(correctImplementation);
      await tester.pumpAndSettle();

      // Try to trigger a drag operation
      final finder = find.text('file1.txt');
      expect(finder, findsOneWidget);

      // Simulate drag
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(finder),
      );
      await tester.pump(const Duration(milliseconds: 500));

      await gesture.moveBy(const Offset(0, 50));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      // When enableDragAndDrop is true, all callbacks should be triggered
      expect(onDragStartCalled, true, reason: 'onDragStart should be called when enableDragAndDrop is true');
      expect(onDragEndCalled, true, reason: 'onDragEnd should be called when enableDragAndDrop is true');
      // Note: onReorder might not be called if the drop position doesn't result in an actual reorder
    });

    testWidgets('Demonstrates the original bug (story callbacks without enableDragAndDrop)', (
      WidgetTester tester,
    ) async {
      // This test demonstrates what the bug was before the enableDragAndDrop parameter existed
      // Stories would set callbacks to null to try to disable drag, but drag handles still appeared
      
      const bool enableDragAndDrop = false;
      
      final paths = [
        Uri.parse('file://file1.txt'),
        Uri.parse('file://file2.txt'),
      ];

      // This simulates the OLD (buggy) behavior where stories tried to disable drag
      // by setting callbacks to null, but drag handles still appeared
      Widget buggyImplementation = MaterialApp(
        home: Scaffold(
          body: ReorderableTreeListView(
            paths: paths,
            initiallyExpanded: {Uri.parse('file://')},
            // No enableDragAndDrop parameter existed - drag handles always shown
            itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
            
            // Stories tried to disable drag by setting callbacks to null
            onReorder: enableDragAndDrop
                ? (oldPath, newPath) {
                    // Would have done something here
                  }
                : null,
                
            // BUG: Even with null callbacks, drag handles were still visible
            // and drag gestures would still trigger internal ReorderableListView logic
            onDragStart: enableDragAndDrop
                ? (path) {
                    // Would have done something here
                  }
                : null,
            onDragEnd: enableDragAndDrop
                ? (path) {
                    // Would have done something here
                  }
                : null,
          ),
        ),
      );

      await tester.pumpWidget(buggyImplementation);
      await tester.pumpAndSettle();

      final finder = find.text('file1.txt');
      expect(finder, findsOneWidget);

      // Simulate drag
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(finder),
      );
      await tester.pump(const Duration(milliseconds: 500));

      await gesture.moveBy(const Offset(0, 50));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      // In the old buggy behavior, even with null callbacks:
      // - Callbacks wouldn't be called (they were null)
      // - But drag handles were still visible and drag gestures still worked internally
      // - The main issue was the UI showing drag handles when it shouldn't
      
      // The BUG was that drag handles were still visible! 
      // This test demonstrates the approach that didn't work properly.
      // The actual UI bug (drag handles visible) isn't easily testable here,
      // but that was the main user-visible issue: knob had no effect on drag handle visibility
    });
  });
}