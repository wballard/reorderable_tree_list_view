import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

void main() {
  group('Multiple Selection Tests', () {
    testWidgets('Shift+click should enable multiple selection when selectionMode is multiple', (
      WidgetTester tester,
    ) async {
      Set<Uri> selectedPaths = {};
      
      final paths = [
        Uri.parse('file://file1.txt'),
        Uri.parse('file://file2.txt'),
        Uri.parse('file://file3.txt'),
      ];

      Widget testWidget = MaterialApp(
        home: Scaffold(
          body: ReorderableTreeListView(
            paths: paths,
            selectionMode: SelectionMode.multiple,
            initiallyExpanded: {Uri.parse('file://')}, // Expand root to show files
            itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
            onSelectionChanged: (newSelection) {
              selectedPaths = newSelection;
            },
          ),
        ),
      );

      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // First, click on file1.txt to select it
      await tester.tap(find.text('file1.txt'));
      await tester.pumpAndSettle();
      
      // Should have one item selected
      expect(selectedPaths.length, 1);
      expect(selectedPaths.contains(Uri.parse('file://file1.txt')), true);

      // Now shift+click on file3.txt - should select range from file1.txt to file3.txt (including file2.txt)
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.tap(find.text('file3.txt'));
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pumpAndSettle();

      // Should now have file1.txt, file2.txt, and file3.txt selected (range selection)
      expect(selectedPaths.length, 3, reason: 'Shift+click should enable range selection');
      expect(selectedPaths.contains(Uri.parse('file://file1.txt')), true);
      expect(selectedPaths.contains(Uri.parse('file://file2.txt')), true);
      expect(selectedPaths.contains(Uri.parse('file://file3.txt')), true);
    });

    testWidgets('Multiple selection mode should allow selecting multiple items individually', (
      WidgetTester tester,
    ) async {
      Set<Uri> selectedPaths = {};
      
      final paths = [
        Uri.parse('file://file1.txt'),
        Uri.parse('file://file2.txt'),
        Uri.parse('file://file3.txt'),
      ];

      Widget testWidget = MaterialApp(
        home: Scaffold(
          body: ReorderableTreeListView(
            paths: paths,
            selectionMode: SelectionMode.multiple,
            initiallyExpanded: {Uri.parse('file://')}, // Expand root to show files
            itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
            onSelectionChanged: (newSelection) {
              selectedPaths = newSelection;
            },
          ),
        ),
      );

      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Click on file1.txt
      await tester.tap(find.text('file1.txt'));
      await tester.pumpAndSettle();
      
      // Should have one item selected
      expect(selectedPaths.length, 1);
      expect(selectedPaths.contains(Uri.parse('file://file1.txt')), true);

      // Ctrl+click on file2.txt to add it to selection
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.tap(find.text('file2.txt'));
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();

      // Should now have both file1.txt and file2.txt selected
      expect(selectedPaths.length, 2, reason: 'Ctrl+click should add to selection in multiple mode');
      expect(selectedPaths.contains(Uri.parse('file://file1.txt')), true);
      expect(selectedPaths.contains(Uri.parse('file://file2.txt')), true);
    });

    testWidgets('Single selection mode should replace selection on click', (
      WidgetTester tester,
    ) async {
      Set<Uri> selectedPaths = {};
      
      final paths = [
        Uri.parse('file://file1.txt'),
        Uri.parse('file://file2.txt'),
      ];

      Widget testWidget = MaterialApp(
        home: Scaffold(
          body: ReorderableTreeListView(
            paths: paths,
            selectionMode: SelectionMode.single,
            initiallyExpanded: {Uri.parse('file://')}, // Expand root to show files
            itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
            onSelectionChanged: (newSelection) {
              selectedPaths = newSelection;
            },
          ),
        ),
      );

      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Click on file1.txt
      await tester.tap(find.text('file1.txt'));
      await tester.pumpAndSettle();
      
      // Should have one item selected
      expect(selectedPaths.length, 1);
      expect(selectedPaths.contains(Uri.parse('file://file1.txt')), true);

      // Click on file2.txt - should replace selection
      await tester.tap(find.text('file2.txt'));
      await tester.pumpAndSettle();

      // Should now have only file2.txt selected
      expect(selectedPaths.length, 1, reason: 'Single selection should replace previous selection');
      expect(selectedPaths.contains(Uri.parse('file://file1.txt')), false);
      expect(selectedPaths.contains(Uri.parse('file://file2.txt')), true);
    });
  });
}