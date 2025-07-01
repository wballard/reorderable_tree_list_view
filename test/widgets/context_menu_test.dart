import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

void main() {
  group('Context Menu Tests', () {
    testWidgets('Right-click should trigger onContextMenu callback', (
      WidgetTester tester,
    ) async {
      bool contextMenuCalled = false;
      Offset? contextMenuPosition;
      Uri? contextMenuPath;
      
      final paths = [
        Uri.parse('file://file1.txt'),
        Uri.parse('file://file2.txt'),
      ];

      Widget testWidget = MaterialApp(
        home: Scaffold(
          body: ReorderableTreeListView(
            paths: paths,
            initiallyExpanded: {Uri.parse('file://')}, // Expand root to show files
            itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
            onContextMenu: (path, position) {
              contextMenuCalled = true;
              contextMenuPath = path;
              contextMenuPosition = position;
            },
          ),
        ),
      );

      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Find the first file and right-click on it
      final firstFile = find.text('file1.txt');
      expect(firstFile, findsOneWidget);

      // Simulate right-click (secondary tap)
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(firstFile),
        kind: PointerDeviceKind.mouse,
        buttons: kSecondaryButton,
      );
      await gesture.up();
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify context menu callback was triggered
      expect(contextMenuCalled, true, reason: 'onContextMenu should be called on right-click');
      expect(contextMenuPath, Uri.parse('file://file1.txt'));
      expect(contextMenuPosition, isNotNull);
    });

    testWidgets('Context menu should work without interfering with normal tap', (
      WidgetTester tester,
    ) async {
      bool contextMenuCalled = false;
      bool normalTapCalled = false;
      
      final paths = [
        Uri.parse('file://file1.txt'),
      ];

      Widget testWidget = MaterialApp(
        home: Scaffold(
          body: ReorderableTreeListView(
            paths: paths,
            initiallyExpanded: {Uri.parse('file://')},
            itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
            onContextMenu: (path, position) {
              contextMenuCalled = true;
            },
            onItemTap: (path) {
              normalTapCalled = true;
            },
          ),
        ),
      );

      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      final firstFile = find.text('file1.txt');

      // Test normal tap
      await tester.tap(firstFile);
      await tester.pumpAndSettle();
      
      expect(normalTapCalled, true, reason: 'Normal tap should trigger onItemTap');
      expect(contextMenuCalled, false, reason: 'Normal tap should not trigger context menu');

      // Reset flags
      normalTapCalled = false;
      contextMenuCalled = false;

      // Test right-click  
      final TestGesture rightClickGesture = await tester.startGesture(
        tester.getCenter(firstFile),
        kind: PointerDeviceKind.mouse,
        buttons: kSecondaryButton,
      );
      await rightClickGesture.up();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(contextMenuCalled, true, reason: 'Right-click should trigger context menu');
      expect(normalTapCalled, false, reason: 'Right-click should not trigger normal tap');
    });

    testWidgets('Context menu should use onSecondaryTap instead of onSecondaryTapDown for web compatibility', (
      WidgetTester tester,
    ) async {
      // This test verifies that we use the proper secondary tap handler
      // that can prevent default browser context menu behavior on web
      bool contextMenuCalled = false;
      
      final paths = [
        Uri.parse('file://file1.txt'),
      ];

      Widget testWidget = MaterialApp(
        home: Scaffold(
          body: ReorderableTreeListView(
            paths: paths,
            initiallyExpanded: {Uri.parse('file://')},
            itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
            onContextMenu: (path, position) {
              contextMenuCalled = true;
            },
          ),
        ),
      );

      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      final firstFile = find.text('file1.txt');

      // Test with onSecondaryTap gesture (better for web)
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(firstFile),
        kind: PointerDeviceKind.mouse,
        buttons: kSecondaryButton,
      );
      await gesture.up();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(contextMenuCalled, true, reason: 'Context menu should be triggered by secondary tap');
    });
  });
}