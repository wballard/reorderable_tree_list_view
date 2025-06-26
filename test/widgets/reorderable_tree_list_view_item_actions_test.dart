import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

void main() {
  group('ReorderableTreeListViewItem Actions Integration', () {
    late TreeNode testNode;

    setUp(() {
      testNode = TreeNode(path: Uri.parse('file://folder1/'), isLeaf: false);
    });

    group('Intent Invocation', () {
      testWidgets('should invoke ExpandNodeIntent when expand button is tapped', (
        WidgetTester tester,
      ) async {
        ExpandNodeIntent? invokedIntent;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Actions(
                actions: <Type, Action<Intent>>{
                  ExpandNodeIntent: CallbackAction<ExpandNodeIntent>(
                    onInvoke: (ExpandNodeIntent intent) {
                      invokedIntent = intent;
                      return null;
                    },
                  ),
                },
                child: ReorderableTreeListViewItem(
                  key: const ValueKey<String>('test'),
                  node: testNode,
                  hasChildren: true,
                  onExpansionToggle: () {
                    // This should NOT be called when using Actions.maybeInvoke
                    fail(
                      'onExpansionToggle should not be called when Actions.maybeInvoke is used',
                    );
                  },
                  child: const Text('Test Folder'),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find and tap the expansion button
        final Finder expansionButton = find.byIcon(Icons.keyboard_arrow_right);
        expect(expansionButton, findsOneWidget);

        await tester.tap(expansionButton);
        await tester.pumpAndSettle();

        // Verify that the ExpandNodeIntent was invoked
        expect(invokedIntent, isNotNull);
        expect(invokedIntent!.path, equals(testNode.path));
      });

      testWidgets(
        'should invoke CollapseNodeIntent when collapse button is tapped',
        (WidgetTester tester) async {
          CollapseNodeIntent? invokedIntent;

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Actions(
                  actions: <Type, Action<Intent>>{
                    CollapseNodeIntent: CallbackAction<CollapseNodeIntent>(
                      onInvoke: (CollapseNodeIntent intent) {
                        invokedIntent = intent;
                        return null;
                      },
                    ),
                  },
                  child: ReorderableTreeListViewItem(
                    key: const ValueKey<String>('test'),
                    node: testNode,
                    hasChildren: true,
                    isExpanded:
                        true, // Expanded, so should show collapse button
                    onExpansionToggle: () {
                      fail(
                        'onExpansionToggle should not be called when Actions.maybeInvoke is used',
                      );
                    },
                    child: const Text('Test Folder'),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          // Find and tap the expansion button (should be keyboard_arrow_down for expanded)
          final Finder expansionButton = find.byIcon(Icons.keyboard_arrow_down);
          expect(expansionButton, findsOneWidget);

          await tester.tap(expansionButton);
          await tester.pumpAndSettle();

          // Verify that the CollapseNodeIntent was invoked
          expect(invokedIntent, isNotNull);
          expect(invokedIntent!.path, equals(testNode.path));
        },
      );

      testWidgets('should invoke ActivateNodeIntent when item is activated', (
        WidgetTester tester,
      ) async {
        ActivateNodeIntent? invokedIntent;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Actions(
                actions: <Type, Action<Intent>>{
                  ActivateNodeIntent: CallbackAction<ActivateNodeIntent>(
                    onInvoke: (ActivateNodeIntent intent) {
                      invokedIntent = intent;
                      return null;
                    },
                  ),
                },
                child: ReorderableTreeListViewItem(
                  key: const ValueKey<String>('test'),
                  node: testNode,
                  hasChildren: true,
                  child: const Text('Test Folder'),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Double-tap the item to activate it
        await tester.tap(find.text('Test Folder'));
        await tester.tap(find.text('Test Folder'));
        await tester.pumpAndSettle();

        // Verify that the ActivateNodeIntent was invoked
        expect(invokedIntent, isNotNull);
        expect(invokedIntent!.path, equals(testNode.path));
      });
    });

    group('Fallback Behavior', () {
      testWidgets(
        'should fallback to callback when no action handler is provided',
        (WidgetTester tester) async {
          bool callbackCalled = false;

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: ReorderableTreeListViewItem(
                  key: const ValueKey<String>('test'),
                  node: testNode,
                  hasChildren: true,
                  onExpansionToggle: () {
                    callbackCalled = true;
                  },
                  child: const Text('Test Folder'),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          // Find and tap the expansion button
          final Finder expansionButton = find.byIcon(
            Icons.keyboard_arrow_right,
          );
          expect(expansionButton, findsOneWidget);

          await tester.tap(expansionButton);
          await tester.pumpAndSettle();

          // Verify that the callback was called as fallback
          expect(callbackCalled, isTrue);
        },
      );
    });

    group('Actions.maybeInvoke Pattern', () {
      testWidgets(
        'should prefer Actions over direct callbacks when both are available',
        (WidgetTester tester) async {
          ExpandNodeIntent? invokedIntent;
          bool callbackCalled = false;

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Actions(
                  actions: <Type, Action<Intent>>{
                    ExpandNodeIntent: CallbackAction<ExpandNodeIntent>(
                      onInvoke: (ExpandNodeIntent intent) {
                        invokedIntent = intent;
                        return null;
                      },
                    ),
                  },
                  child: ReorderableTreeListViewItem(
                    key: const ValueKey<String>('test'),
                    node: testNode,
                    hasChildren: true,
                    onExpansionToggle: () {
                      callbackCalled = true;
                    },
                    child: const Text('Test Folder'),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          // Find and tap the expansion button
          final Finder expansionButton = find.byIcon(
            Icons.keyboard_arrow_right,
          );
          expect(expansionButton, findsOneWidget);

          await tester.tap(expansionButton);
          await tester.pumpAndSettle();

          // Verify that the Action was invoked, NOT the callback
          expect(invokedIntent, isNotNull);
          expect(invokedIntent!.path, equals(testNode.path));
          expect(
            callbackCalled,
            isFalse,
            reason: 'Callback should not be called when Action is available',
          );
        },
      );
    });
  });
}
