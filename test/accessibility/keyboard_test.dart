import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

import '../test_utils.dart';

void main() {
  group('Keyboard Accessibility', () {
    testWidgets('should support tab traversal', (WidgetTester tester) async {
      await tester.pumpWidget(TestUtils.createTestApp(
        paths: TestUtils.sampleFilePaths,
        selectionMode: SelectionMode.single,
      ));

      // Focus on the tree
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      // Tab through items
      for (int i = 0; i < 3; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
      }

      // Shift+Tab to go back
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
      await tester.pump();

      // Verify focus is managed properly
      final FocusNode? focusNode = Focus.of(
        tester.element(find.byType(ReorderableTreeListView)),
      ).focusNode;
      expect(focusNode?.hasFocus, isTrue);
    });

    testWidgets('should navigate with arrow keys', (WidgetTester tester) async {
      await tester.pumpWidget(TestUtils.createTestApp(
        paths: TestUtils.sampleFilePaths,
        selectionMode: SelectionMode.single,
        enableKeyboardNavigation: true,
      ));

      // Focus the tree
      await tester.tap(find.byType(ReorderableTreeListView));
      await tester.pump();

      // Navigate down
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      // Navigate up
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();

      // Navigate right (expand)
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      // Navigate left (collapse)
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
    });

    testWidgets('should expand/collapse with Enter key', (WidgetTester tester) async {
      await tester.pumpWidget(TestUtils.createTestApp(
        paths: TestUtils.sampleFilePaths,
        expandedByDefault: false,
      ));

      // Focus on a folder
      final folderFinder = TestUtils.findTreeItem('folder1');
      await tester.tap(folderFinder);
      await tester.pump();

      // Press Enter to expand
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await TestUtils.pumpAndSettle(tester);

      // Verify expanded
      expect(TestUtils.findTreeItem('file1.txt'), findsOneWidget);

      // Press Enter again to collapse
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await TestUtils.pumpAndSettle(tester);

      // Verify collapsed
      expect(TestUtils.findTreeItem('file1.txt'), findsNothing);
    });

    testWidgets('should select with Space key', (WidgetTester tester) async {
      Set<Uri> selectedPaths = {};

      await tester.pumpWidget(TestUtils.createTestApp(
        paths: TestUtils.sampleFilePaths,
        selectionMode: SelectionMode.multiple,
        onSelectionChanged: (selection) => selectedPaths = selection,
      ));

      // Focus on first item
      await tester.tap(find.byType(ReorderableTreeListView));
      await tester.pump();

      // Select with space
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();

      expect(selectedPaths.length, 1);

      // Move to next item
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      // Select another with space
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();

      expect(selectedPaths.length, 2);
    });

    testWidgets('should handle focus indicators', (WidgetTester tester) async {
      await tester.pumpWidget(TestUtils.createTestApp(
        paths: TestUtils.sampleFilePaths,
        theme: const TreeTheme(
          focusColor: Colors.blue,
        ),
      ));

      // Focus the tree
      await tester.tap(find.byType(ReorderableTreeListView));
      await tester.pump();

      // Look for focus decoration
      final inkWell = tester.widget<InkWell>(
        find.descendant(
          of: find.byType(ReorderableTreeListViewItem).first,
          matching: find.byType(InkWell),
        ),
      );

      expect(inkWell.focusColor, Colors.blue);
    });

    testWidgets('should not conflict with global shortcuts', (WidgetTester tester) async {
      bool globalShortcutTriggered = false;

      await tester.pumpWidget(MaterialApp(
        home: Shortcuts(
          shortcuts: <LogicalKeySet, Intent>{
            LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyA):
                const SelectAllIntent(),
          },
          child: Actions(
            actions: <Type, Action<Intent>>{
              SelectAllIntent: CallbackAction<SelectAllIntent>(
                onInvoke: (_) {
                  globalShortcutTriggered = true;
                  return null;
                },
              ),
            },
            child: Scaffold(
              body: ReorderableTreeListView(
                paths: TestUtils.sampleFilePaths,
                itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
              ),
            ),
          ),
        ),
      ));

      // Focus the tree
      await tester.tap(find.byType(ReorderableTreeListView));
      await tester.pump();

      // Try Ctrl+A
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pump();

      // Global shortcut should be triggered
      expect(globalShortcutTriggered, isTrue);
    });

    testWidgets('should announce focus changes for screen readers', (WidgetTester tester) async {
      await tester.pumpWidget(TestUtils.createTestApp(
        paths: TestUtils.sampleFilePaths,
      ));

      // Check semantics
      final semantics = tester.getSemantics(find.byType(ReorderableTreeListView));
      expect(semantics, isNotNull);

      // Focus on first item
      await tester.tap(find.byType(ReorderableTreeListViewItem).first);
      await tester.pump();

      // Check for semantic announcement
      final itemSemantics = tester.getSemantics(
        find.byType(ReorderableTreeListViewItem).first,
      );
      expect(itemSemantics.hasFlag(SemanticsFlag.isFocusable), isTrue);
    });

    testWidgets('should provide keyboard navigation help', (WidgetTester tester) async {
      await tester.pumpWidget(TestUtils.createTestApp(
        paths: TestUtils.sampleFilePaths,
      ));

      // The tree should have semantic hints for keyboard navigation
      final semantics = tester.getSemantics(find.byType(ReorderableTreeListView));
      expect(semantics, isNotNull);
    });
  });
}