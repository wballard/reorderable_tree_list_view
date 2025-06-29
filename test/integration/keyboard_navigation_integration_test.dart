import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

import '../test_utils.dart';

void main() {
  group('Keyboard Navigation Integration', () {
    testWidgets('complete keyboard navigation flow', (WidgetTester tester) async {
      Set<Uri> selectedPaths = {};
      Uri? activatedPath;

      await tester.pumpWidget(TestUtils.createTestApp(
        paths: TestUtils.sampleFilePaths,
        selectionMode: SelectionMode.single,
        enableKeyboardNavigation: true,
        expandedByDefault: false,
        onSelectionChanged: (selection) => selectedPaths = selection,
        onItemActivated: (path) => activatedPath = path,
      ));

      // Focus the tree
      await tester.tap(find.byType(ReorderableTreeListView));
      await tester.pump();

      // Navigate down
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(selectedPaths.length, 1);

      // Navigate to folder
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      // Expand folder with right arrow
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await TestUtils.pumpAndSettle(tester);

      // Should see children
      expect(find.text('file1.txt'), findsOneWidget);

      // Navigate into folder
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      // Activate item with Enter
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(activatedPath?.toString(), contains('file1.txt'));

      // Navigate back up
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();

      // Collapse folder with left arrow
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await TestUtils.pumpAndSettle(tester);

      // Children should be hidden
      expect(find.text('file1.txt'), findsNothing);
    });

    testWidgets('keyboard shortcuts with modifiers', (WidgetTester tester) async {
      Set<Uri> selectedPaths = {};

      await tester.pumpWidget(TestUtils.createTestApp(
        paths: TestUtils.sampleFilePaths,
        selectionMode: SelectionMode.multiple,
        enableKeyboardNavigation: true,
        onSelectionChanged: (selection) => selectedPaths = selection,
      ));

      // Focus tree
      await tester.tap(find.byType(ReorderableTreeListView));
      await tester.pump();

      // Select first item
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(selectedPaths.length, 1);

      // Move down
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      // Add to selection with Ctrl+Space
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pump();
      
      expect(selectedPaths.length, 2);

      // Select all with Ctrl+A
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pump();

      // Should select all visible items
      expect(selectedPaths.length, greaterThan(2));
    });

    testWidgets('focus management', (WidgetTester tester) async {
      await tester.pumpWidget(Column(
        children: [
          ElevatedButton(
            onPressed: () {},
            child: const Text('Button Before'),
          ),
          Expanded(
            child: TestUtils.createTestApp(
              paths: TestUtils.sampleFilePaths,
              enableKeyboardNavigation: true,
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Button After'),
          ),
        ],
      ));

      // Tab to first button
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      // Tab to tree
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      // Navigate within tree
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      // Tab out of tree
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      // Should focus button after
      final buttonFocus = Focus.of(
        tester.element(find.text('Button After')),
      );
      expect(buttonFocus.hasFocus, isTrue);
    });

    testWidgets('keyboard navigation with filtering', (WidgetTester tester) async {
      List<Uri> allPaths = TestUtils.sampleFilePaths;
      List<Uri> filteredPaths = List.from(allPaths);
      String searchQuery = '';

      await tester.pumpWidget(StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                    if (value.isEmpty) {
                      filteredPaths = List.from(allPaths);
                    } else {
                      filteredPaths = allPaths
                          .where((p) => p.toString().contains(value))
                          .toList();
                    }
                  });
                },
              ),
              Expanded(
                child: ReorderableTreeListView(
                  paths: filteredPaths,
                  enableKeyboardNavigation: true,
                  itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
                ),
              ),
            ],
          );
        },
      ));

      // Type in search field
      await tester.tap(find.byType(TextField));
      await tester.enterText(find.byType(TextField), 'file1');
      await tester.pump();

      // Tab to tree
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      // Should only navigate filtered items
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      // Clear search
      await tester.tap(find.byType(TextField));
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      // All items should be navigable again
      expect(find.byType(ReorderableTreeListViewItem), findsWidgets);
    });

    testWidgets('keyboard interactions with drag and drop', (WidgetTester tester) async {
      List<Uri> paths = List.from(TestUtils.sampleFilePaths);
      Uri? selectedPath;

      await tester.pumpWidget(StatefulBuilder(
        builder: (context, setState) {
          return TestUtils.createTestApp(
            paths: paths,
            selectionMode: SelectionMode.single,
            enableKeyboardNavigation: true,
            onSelectionChanged: (selection) {
              selectedPath = selection.isEmpty ? null : selection.first;
            },
            onReorder: (oldPath, newPath) {
              setState(() {
                paths.remove(oldPath);
                paths.add(newPath);
              });
            },
          );
        },
      ));

      // Select an item with keyboard
      await tester.tap(find.byType(ReorderableTreeListView));
      await tester.pump();
      
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      
      expect(selectedPath, isNotNull);

      // Start drag with mouse on selected item
      final selectedItem = find.ancestor(
        of: find.text(TreePath.getDisplayName(selectedPath!)),
        matching: find.byType(ReorderableTreeListViewItem),
      );
      
      final target = find.byType(ReorderableTreeListViewItem).last;
      await TestUtils.dragItem(tester, selectedItem, target);

      // Continue keyboard navigation after drag
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
    });

    testWidgets('vim-style keyboard shortcuts', (WidgetTester tester) async {
      Uri? currentPath;
      
      await tester.pumpWidget(MaterialApp(
        home: Shortcuts(
          shortcuts: <LogicalKeySet, Intent>{
            // Vim-style navigation
            LogicalKeySet(LogicalKeyboardKey.keyJ): const _MoveDownIntent(),
            LogicalKeySet(LogicalKeyboardKey.keyK): const _MoveUpIntent(),
            LogicalKeySet(LogicalKeyboardKey.keyL): const _ExpandIntent(),
            LogicalKeySet(LogicalKeyboardKey.keyH): const _CollapseIntent(),
          },
          child: Actions(
            actions: <Type, Action<Intent>>{
              _MoveDownIntent: CallbackAction<_MoveDownIntent>(
                onInvoke: (_) {
                  // Move selection down
                  return null;
                },
              ),
              _MoveUpIntent: CallbackAction<_MoveUpIntent>(
                onInvoke: (_) {
                  // Move selection up
                  return null;
                },
              ),
              _ExpandIntent: CallbackAction<_ExpandIntent>(
                onInvoke: (_) {
                  // Expand node
                  return null;
                },
              ),
              _CollapseIntent: CallbackAction<_CollapseIntent>(
                onInvoke: (_) {
                  // Collapse node
                  return null;
                },
              ),
            },
            child: Scaffold(
              body: ReorderableTreeListView(
                paths: TestUtils.sampleFilePaths,
                enableKeyboardNavigation: true,
                selectionMode: SelectionMode.single,
                onSelectionChanged: (selection) {
                  currentPath = selection.isEmpty ? null : selection.first;
                },
                itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
              ),
            ),
          ),
        ),
      ));

      // Focus tree
      await tester.tap(find.byType(ReorderableTreeListView));
      await tester.pump();

      // Use vim keys
      await tester.sendKeyEvent(LogicalKeyboardKey.keyJ); // down
      await tester.pump();
      
      await tester.sendKeyEvent(LogicalKeyboardKey.keyK); // up
      await tester.pump();
      
      await tester.sendKeyEvent(LogicalKeyboardKey.keyL); // expand
      await tester.pump();
      
      await tester.sendKeyEvent(LogicalKeyboardKey.keyH); // collapse
      await tester.pump();
    });
  });
}

// Custom intents for vim-style navigation
class _MoveDownIntent extends Intent {
  const _MoveDownIntent();
}

class _MoveUpIntent extends Intent {
  const _MoveUpIntent();
}

class _ExpandIntent extends Intent {
  const _ExpandIntent();
}

class _CollapseIntent extends Intent {
  const _CollapseIntent();
}