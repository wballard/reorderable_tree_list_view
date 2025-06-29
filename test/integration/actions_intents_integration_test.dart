import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

import '../test_utils.dart';

void main() {
  group('Actions and Intents Integration', () {
    testWidgets('intent invocation through widget', (WidgetTester tester) async {
      bool expandInvoked = false;
      bool collapseInvoked = false;
      bool selectInvoked = false;

      await tester.pumpWidget(MaterialApp(
        home: Actions(
          actions: <Type, Action<Intent>>{
            ExpandNodeIntent: CallbackAction<ExpandNodeIntent>(
              onInvoke: (intent) {
                expandInvoked = true;
                return null;
              },
            ),
            CollapseNodeIntent: CallbackAction<CollapseNodeIntent>(
              onInvoke: (intent) {
                collapseInvoked = true;
                return null;
              },
            ),
            SelectNodeIntent: CallbackAction<SelectNodeIntent>(
              onInvoke: (intent) {
                selectInvoked = true;
                return null;
              },
            ),
          },
          child: Scaffold(
            body: ReorderableTreeListView(
              paths: TestUtils.sampleFilePaths,
              expandedByDefault: false,
              selectionMode: SelectionMode.single,
              itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
            ),
          ),
        ),
      ));

      // Tap on folder to expand
      final folder = TestUtils.findTreeItem('folder1');
      await tester.tap(folder);
      await tester.pump();

      // Should invoke expand intent
      expect(expandInvoked, isTrue);

      // Tap again to collapse
      collapseInvoked = false;
      await tester.tap(folder);
      await tester.pump();

      expect(collapseInvoked, isTrue);

      // Select an item
      final item = TestUtils.findTreeItem('file5.txt');
      await tester.tap(item);
      await tester.pump();

      expect(selectInvoked, isTrue);
    });

    testWidgets('action override behavior', (WidgetTester tester) async {
      String? expandedPath;
      String? customActionPath;

      await tester.pumpWidget(MaterialApp(
        home: Actions(
          actions: <Type, Action<Intent>>{
            // Override expand action
            ExpandNodeIntent: CallbackAction<ExpandNodeIntent>(
              onInvoke: (intent) {
                expandedPath = intent.path.toString();
                customActionPath = 'custom_expand';
                // Return non-null to indicate handled
                return true;
              },
            ),
          },
          child: Scaffold(
            body: ReorderableTreeListView(
              paths: TestUtils.sampleFilePaths,
              expandedByDefault: false,
              itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
            ),
          ),
        ),
      ));

      // Tap folder
      await tester.tap(TestUtils.findTreeItem('folder1'));
      await tester.pump();

      // Custom action should be invoked
      expect(customActionPath, equals('custom_expand'));
      expect(expandedPath, contains('folder1'));
    });

    testWidgets('intent propagation through widget tree', (WidgetTester tester) async {
      final actionLog = <String>[];

      await tester.pumpWidget(MaterialApp(
        home: Actions(
          // Top-level actions
          actions: <Type, Action<Intent>>{
            ExpandNodeIntent: CallbackAction<ExpandNodeIntent>(
              onInvoke: (intent) {
                actionLog.add('top_expand');
                return null; // Let it propagate
              },
            ),
          },
          child: Scaffold(
            body: Actions(
              // Mid-level actions
              actions: <Type, Action<Intent>>{
                SelectNodeIntent: CallbackAction<SelectNodeIntent>(
                  onInvoke: (intent) {
                    actionLog.add('mid_select');
                    return null;
                  },
                ),
              },
              child: ReorderableTreeListView(
                paths: TestUtils.sampleFilePaths,
                expandedByDefault: false,
                selectionMode: SelectionMode.single,
                itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
              ),
            ),
          ),
        ),
      ));

      // Expand action
      await tester.tap(TestUtils.findTreeItem('folder1'));
      await tester.pump();

      // Select action
      await tester.tap(TestUtils.findTreeItem('file5.txt'));
      await tester.pump();

      // Both actions should be logged
      expect(actionLog, contains('top_expand'));
      expect(actionLog, contains('mid_select'));
    });

    testWidgets('custom intents with tree view', (WidgetTester tester) async {
      String? deletedPath;
      String? renamedPath;

      await tester.pumpWidget(MaterialApp(
        home: Shortcuts(
          shortcuts: <LogicalKeySet, Intent>{
            LogicalKeySet(LogicalKeyboardKey.delete): const _DeleteNodeIntent(),
            LogicalKeySet(LogicalKeyboardKey.f2): const _RenameNodeIntent(),
          },
          child: Actions(
            actions: <Type, Action<Intent>>{
              _DeleteNodeIntent: CallbackAction<_DeleteNodeIntent>(
                onInvoke: (_) {
                  deletedPath = 'deleted';
                  return null;
                },
              ),
              _RenameNodeIntent: CallbackAction<_RenameNodeIntent>(
                onInvoke: (_) {
                  renamedPath = 'renamed';
                  return null;
                },
              ),
            },
            child: Scaffold(
              body: ReorderableTreeListView(
                paths: TestUtils.sampleFilePaths,
                enableKeyboardNavigation: true,
                selectionMode: SelectionMode.single,
                itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
              ),
            ),
          ),
        ),
      ));

      // Focus and select
      await tester.tap(find.byType(ReorderableTreeListView));
      await tester.pump();

      // Delete key
      await tester.sendKeyEvent(LogicalKeyboardKey.delete);
      await tester.pump();
      expect(deletedPath, equals('deleted'));

      // F2 key
      await tester.sendKeyEvent(LogicalKeyboardKey.f2);
      await tester.pump();
      expect(renamedPath, equals('renamed'));
    });

    testWidgets('intent context and data passing', (WidgetTester tester) async {
      Uri? receivedPath;
      BuildContext? receivedContext;

      await tester.pumpWidget(MaterialApp(
        home: Actions(
          actions: <Type, Action<Intent>>{
            ActivateNodeIntent: CallbackAction<ActivateNodeIntent>(
              onInvoke: (intent) {
                receivedPath = intent.path;
                receivedContext = intent.context;
                return null;
              },
            ),
          },
          child: Scaffold(
            body: ReorderableTreeListView(
              paths: TestUtils.sampleFilePaths,
              selectionMode: SelectionMode.single,
              onItemActivated: (path) {
                // This should trigger the intent
              },
              itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
            ),
          ),
        ),
      ));

      // Double-tap to activate
      final item = TestUtils.findTreeItem('file5.txt');
      await tester.tap(item);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(item);
      await tester.pump();

      // Intent should carry the path
      expect(receivedPath?.toString(), contains('file5.txt'));
      expect(receivedContext, isNotNull);
    });

    testWidgets('action composition and chaining', (WidgetTester tester) async {
      final actionSequence = <String>[];

      await tester.pumpWidget(MaterialApp(
        home: Actions(
          actions: <Type, Action<Intent>>{
            ExpandNodeIntent: CallbackAction<ExpandNodeIntent>(
              onInvoke: (intent) {
                actionSequence.add('expand_start');
                // Simulate async operation
                return Future.delayed(
                  const Duration(milliseconds: 100),
                  () {
                    actionSequence.add('expand_end');
                    return null;
                  },
                );
              },
            ),
            SelectNodeIntent: CallbackAction<SelectNodeIntent>(
              onInvoke: (intent) {
                actionSequence.add('select');
                return null;
              },
            ),
          },
          child: Scaffold(
            body: ReorderableTreeListView(
              paths: TestUtils.sampleFilePaths,
              expandedByDefault: false,
              selectionMode: SelectionMode.single,
              itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
            ),
          ),
        ),
      ));

      // Expand then select
      await tester.tap(TestUtils.findTreeItem('folder1'));
      await TestUtils.pumpAndSettle(tester);

      await tester.tap(TestUtils.findTreeItem('file5.txt'));
      await tester.pump();

      // Check sequence
      expect(actionSequence, ['expand_start', 'expand_end', 'select']);
    });

    testWidgets('action availability and enablement', (WidgetTester tester) async {
      bool canExpand = true;
      bool expandCalled = false;

      await tester.pumpWidget(StatefulBuilder(
        builder: (context, setState) {
          return MaterialApp(
            home: Column(
              children: [
                Switch(
                  value: canExpand,
                  onChanged: (value) => setState(() => canExpand = value),
                ),
                Expanded(
                  child: Actions(
                    actions: <Type, Action<Intent>>{
                      ExpandNodeIntent: CallbackAction<ExpandNodeIntent>(
                        onInvoke: canExpand
                            ? (intent) {
                                expandCalled = true;
                                return null;
                              }
                            : null,
                      ),
                    },
                    child: Scaffold(
                      body: ReorderableTreeListView(
                        paths: TestUtils.sampleFilePaths,
                        expandedByDefault: false,
                        itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ));

      // Try to expand when enabled
      await tester.tap(TestUtils.findTreeItem('folder1'));
      await tester.pump();
      expect(expandCalled, isTrue);

      // Disable expansion
      expandCalled = false;
      await tester.tap(find.byType(Switch));
      await tester.pump();

      // Try to expand when disabled
      await tester.tap(TestUtils.findTreeItem('folder2'));
      await tester.pump();
      expect(expandCalled, isFalse);
    });
  });
}

// Custom intents for testing
class _DeleteNodeIntent extends Intent {
  const _DeleteNodeIntent();
}

class _RenameNodeIntent extends Intent {
  const _RenameNodeIntent();
}