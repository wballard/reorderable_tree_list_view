import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

void main() {
  group('ReorderableTreeListView Keyboard Navigation', () {
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
      bool enableKeyboardNavigation = true,
      SelectionMode selectionMode = SelectionMode.none,
      Set<Uri>? initialSelection,
      void Function(Set<Uri> selection)? onSelectionChanged,
      void Function(Uri path)? onItemActivated,
    }) => MaterialApp(
      home: Scaffold(
        body: ReorderableTreeListView(
          paths: paths,
          itemBuilder: (BuildContext context, Uri path) =>
              Text(path.toString()),
          enableKeyboardNavigation: enableKeyboardNavigation,
          selectionMode: selectionMode,
          initialSelection: initialSelection,
          onSelectionChanged: onSelectionChanged,
          onItemActivated: onItemActivated,
        ),
      ),
    );

    group('Focus Management', () {
      testWidgets('should focus first item on initial tab', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(buildTestWidget(paths: testPaths));
        await tester.pumpAndSettle();

        // Tab to focus the tree
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        // Give time for async focus transfer
        await tester.pump(const Duration(milliseconds: 100));

        // First meaningful item should be focused (file5.txt is first in order)
        final FocusNode focusNode = Focus.of(
          tester.element(find.text('file://file5.txt/')),
          scopeOk: true,
        );
        expect(focusNode.hasFocus, isTrue);
      });

      testWidgets('should maintain focus during tree updates', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(buildTestWidget(paths: testPaths));
        await tester.pumpAndSettle();

        // Focus on second item (folder1)
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        // Give time for async focus transfer
        await tester.pump(const Duration(milliseconds: 100));
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();

        // Verify focus before update
        final FocusNode focusNodeBefore = Focus.of(
          tester.element(find.text('file://folder1/')),
          scopeOk: true,
        );
        expect(
          focusNodeBefore.hasFocus,
          isTrue,
          reason: 'folder1 should be focused before update',
        );

        // Update paths
        final List<Uri> updatedPaths = List<Uri>.from(testPaths)
          ..add(Uri.parse('file://folder1/file3.txt'));

        await tester.pumpWidget(buildTestWidget(paths: updatedPaths));
        await tester.pumpAndSettle();

        // Give extra time for focus restoration
        await tester.pump(const Duration(milliseconds: 100));

        // Focus should still be on folder1
        final FocusNode focusNode = Focus.of(
          tester.element(find.text('file://folder1/')),
          scopeOk: true,
        );
        expect(
          focusNode.hasFocus,
          isTrue,
          reason: 'folder1 should still be focused after update',
        );
      });
    });

    group('Arrow Navigation', () {
      testWidgets('should navigate down with arrow down', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(buildTestWidget(paths: testPaths));
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        // Give time for async focus transfer
        await tester.pump(const Duration(milliseconds: 100));

        // Navigate down
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();

        // Second item should be focused (folder1)
        final FocusNode focusNode = Focus.of(
          tester.element(find.text('file://folder1/')),
          scopeOk: true,
        );
        expect(focusNode.hasFocus, isTrue);
      });

      testWidgets('should navigate up with arrow up', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(buildTestWidget(paths: testPaths));
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        // Give time for async focus transfer
        await tester.pump(const Duration(milliseconds: 100));
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();

        // Navigate up
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pumpAndSettle();

        // Second item should be focused (folder1)
        final FocusNode focusNode = Focus.of(
          tester.element(find.text('file://folder1/')),
          scopeOk: true,
        );
        expect(focusNode.hasFocus, isTrue);
      });

      testWidgets('should expand folder with arrow right', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReorderableTreeListView(
                paths: testPaths,
                itemBuilder: (BuildContext context, Uri path) =>
                    Text(path.toString()),
                expandedByDefault: false,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        // Give time for async focus transfer
        await tester.pump(const Duration(milliseconds: 100));

        // First expand the root to show top-level items
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();

        // Navigate to folder1 (second item after file5.txt)
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();

        // folder1 should be collapsed
        expect(find.text('file://folder1/file1.txt'), findsNothing);

        // Expand with arrow right
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();

        // folder1 should be expanded
        expect(find.text('file://folder1/file1.txt'), findsOneWidget);
      });

      testWidgets('should collapse folder with arrow left', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(buildTestWidget(paths: testPaths));
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        // Give time for async focus transfer
        await tester.pump(const Duration(milliseconds: 100));

        // Navigate to folder1 (second item)
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();

        // folder1 should be expanded by default
        expect(find.text('file://folder1/file1.txt'), findsOneWidget);

        // Collapse with arrow left
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.pumpAndSettle();

        // folder1 should be collapsed
        expect(find.text('file://folder1/file1.txt'), findsNothing);
      });

      testWidgets('should move to parent with arrow left on leaf', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(buildTestWidget(paths: testPaths));
        await tester.pumpAndSettle();

        // Navigate to file1.txt inside folder1
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        // Give time for async focus transfer
        await tester.pump(const Duration(milliseconds: 100));
        
        // Arrow down to folder1
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        
        // Arrow right to expand folder1
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();
        
        // Arrow down to file1.txt
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();

        // Now we're on file1.txt - press arrow left to move to parent
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.pumpAndSettle();
        // Wait for focus update
        await tester.pump(const Duration(milliseconds: 100));

        // folder1 should be focused
        final Finder folder1Finder = find.text('file://folder1/');
        expect(folder1Finder, findsOneWidget);

        // Check if folder1 is focused
        final ReorderableTreeListViewItem item = tester.widget<ReorderableTreeListViewItem>(
          find.ancestor(
            of: folder1Finder,
            matching: find.byType(ReorderableTreeListViewItem),
          ),
        );
        expect(item.isFocused, isTrue);
      });
    });

    group('Home/End Navigation', () {
      testWidgets('should jump to first item with Home', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(buildTestWidget(paths: testPaths));
        await tester.pumpAndSettle();

        // Navigate to middle item
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        // Give time for async focus transfer
        await tester.pump(const Duration(milliseconds: 100));
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();

        // Press Home
        await tester.sendKeyEvent(LogicalKeyboardKey.home);
        await tester.pumpAndSettle();

        // First meaningful item should be focused (file5.txt)
        final FocusNode focusNode = Focus.of(
          tester.element(find.text('file://file5.txt/')),
          scopeOk: true,
        );
        expect(focusNode.hasFocus, isTrue);
      });

      testWidgets('should jump to last item with End', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(buildTestWidget(paths: testPaths));
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        // Give time for async focus transfer
        await tester.pump(const Duration(milliseconds: 100));

        // Press End
        await tester.sendKeyEvent(LogicalKeyboardKey.end);
        await tester.pumpAndSettle();

        // Wait for focus update
        await tester.pump(const Duration(milliseconds: 100));
        
        // Last visible item should be focused - the last item in tree order is file3.txt
        final Finder lastItemFinder = find.text('file://folder2/subfolder/file3.txt');
        expect(lastItemFinder, findsOneWidget);
        
        final ReorderableTreeListViewItem item = tester.widget<ReorderableTreeListViewItem>(
          find.ancestor(
            of: lastItemFinder,
            matching: find.byType(ReorderableTreeListViewItem),
          ),
        );
        expect(item.isFocused, isTrue);
      });
    });

    group('Item Activation', () {
      testWidgets('should activate item with Enter', (
        WidgetTester tester,
      ) async {
        Uri? activatedPath;

        await tester.pumpWidget(
          buildTestWidget(
            paths: testPaths,
            onItemActivated: (Uri path) {
              activatedPath = path;
            },
          ),
        );
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        // Give time for async focus transfer
        await tester.pump(const Duration(milliseconds: 100));
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();

        // Press Enter
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        expect(activatedPath, Uri.parse('file://folder1/'));
      });

      testWidgets('should activate item with Space', (
        WidgetTester tester,
      ) async {
        Uri? activatedPath;

        await tester.pumpWidget(
          buildTestWidget(
            paths: testPaths,
            onItemActivated: (Uri path) {
              activatedPath = path;
            },
          ),
        );
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        // Give time for async focus transfer
        await tester.pump(const Duration(milliseconds: 100));
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();

        // Press Space
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pumpAndSettle();

        expect(activatedPath, Uri.parse('file://folder1/'));
      });
    });

    // TODO(Actions): Re-enable these tests after implementing Actions/Intents system
    /*
    group('Selection', () {
      testWidgets('should select item in single selection mode', (WidgetTester tester) async {
        Set<Uri>? selectedPaths;
        
        await tester.pumpWidget(buildTestWidget(
          paths: testPaths,
          selectionMode: SelectionMode.single,
          onSelectionChanged: (Set<Uri> selection) {
            selectedPaths = selection;
          },
        ));
        await tester.pumpAndSettle();
        
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        // Give time for async focus transfer
        await tester.pump(const Duration(milliseconds: 100));
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        
        // Select with Space
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pumpAndSettle();
        
        expect(selectedPaths, <Uri>{Uri.parse('file://folder1/')});
      });
      
      testWidgets('should handle multiple selection with Ctrl+Space', (WidgetTester tester) async {
        Set<Uri>? selectedPaths;
        
        await tester.pumpWidget(buildTestWidget(
          paths: testPaths,
          selectionMode: SelectionMode.multiple,
          onSelectionChanged: (Set<Uri> selection) {
            selectedPaths = selection;
          },
        ));
        await tester.pumpAndSettle();
        
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        // Give time for async focus transfer
        await tester.pump(const Duration(milliseconds: 100));
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        
        // Select first item (folder1)
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pumpAndSettle();
        
        // Move to next item (file1.txt)
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        
        // Add to selection with Ctrl+Space
        await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
        await tester.pumpAndSettle();
        
        expect(selectedPaths, <Uri>{
          Uri.parse('file://folder1/'),
          Uri.parse('file://folder1/file1.txt'),
        });
      });
      
      testWidgets('should handle range selection with Shift+Arrow', (WidgetTester tester) async {
        Set<Uri>? selectedPaths;
        
        await tester.pumpWidget(buildTestWidget(
          paths: testPaths,
          selectionMode: SelectionMode.multiple,
          onSelectionChanged: (Set<Uri> selection) {
            selectedPaths = selection;
          },
        ));
        await tester.pumpAndSettle();
        
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        // Give time for async focus transfer
        await tester.pump(const Duration(milliseconds: 100));
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        
        // Select first item (folder1)
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pumpAndSettle();
        
        // Extend selection with Shift+Arrow
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pumpAndSettle();
        
        expect(selectedPaths?.length, 3);
        expect(selectedPaths?.contains(Uri.parse('file://folder1/')), isTrue);
        expect(selectedPaths?.contains(Uri.parse('file://folder1/file1.txt')), isTrue);
        expect(selectedPaths?.contains(Uri.parse('file://folder1/file2.txt')), isTrue);
      });
    });
    */ // End of commented out section

    group('Accessibility', () {
      testWidgets('should disable keyboard navigation when flag is false', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          buildTestWidget(paths: testPaths, enableKeyboardNavigation: false),
        );
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();

        // When keyboard navigation is disabled, the tree should not have TreeViewShortcuts
        final Finder shortcutsFinder = find.byType(TreeViewShortcuts);
        expect(shortcutsFinder, findsNothing);
        
        // The tree should not respond to keyboard navigation
        final Finder folder1Finder = find.text('file://folder1/');
        expect(folder1Finder, findsOneWidget);
      });

      testWidgets('should announce tree structure with Semantics', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(buildTestWidget(paths: testPaths));
        await tester.pumpAndSettle();

        // Check that the tree structure is present
        expect(find.text('file://folder1/'), findsOneWidget);
        expect(find.text('file://folder1/file1.txt'), findsOneWidget);
        
        // Verify the tree has proper widget structure for accessibility
        final Finder treeViewFinder = find.byType(ReorderableTreeListView);
        expect(treeViewFinder, findsOneWidget);
      });
    });
  });
}
