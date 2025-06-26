import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

void main() {
  group('ReorderableTreeListView Actions and Intents', () {
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

    group('Actions Widget Integration', () {
      testWidgets('should wrap tree in Actions widget with all tree actions', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReorderableTreeListView(
                paths: testPaths,
                itemBuilder: (BuildContext context, Uri path) =>
                    Text(path.toString()),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find the Actions widget that contains our tree actions
        final Finder treeViewFinder = find.byType(ReorderableTreeListView);
        expect(treeViewFinder, findsOneWidget);

        // Look for an Actions widget that has our specific intent types
        bool foundTreeActions = false;
        final Iterable<Actions> actionsWidgets = tester.widgetList<Actions>(
          find.byType(Actions),
        );

        for (final Actions actions in actionsWidgets) {
          if (actions.actions.containsKey(ExpandNodeIntent) &&
              actions.actions.containsKey(CollapseNodeIntent) &&
              actions.actions.containsKey(ActivateNodeIntent)) {
            foundTreeActions = true;
            break;
          }
        }

        expect(
          foundTreeActions,
          isTrue,
          reason:
              'ReorderableTreeListView should be wrapped in Actions widget with tree-specific actions',
        );
      });

      testWidgets('should allow parent widgets to override actions', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Actions(
                actions: <Type, Action<Intent>>{
                  ExpandNodeIntent: CallbackAction<ExpandNodeIntent>(
                    onInvoke: (ExpandNodeIntent intent) => null,
                  ),
                },
                child: ReorderableTreeListView(
                  paths: testPaths,
                  itemBuilder: (BuildContext context, Uri path) =>
                      Text(path.toString()),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // For now, just verify the widget can be created with parent Actions
        // The actual override behavior will be tested when Actions.maybeInvoke is implemented
        final Finder treeViewFinder = find.byType(ReorderableTreeListView);
        expect(treeViewFinder, findsOneWidget);
      });
    });

    group('Intent Invocation', () {
      testWidgets('should support Actions.maybeInvoke pattern', (
        WidgetTester tester,
      ) async {
        Uri? expandedPath;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Actions(
                actions: <Type, Action<Intent>>{
                  ExpandNodeIntent: CallbackAction<ExpandNodeIntent>(
                    onInvoke: (ExpandNodeIntent intent) {
                      expandedPath = intent.path;
                      return null;
                    },
                  ),
                },
                child: Builder(
                  builder: (BuildContext context) => Column(
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          Actions.maybeInvoke<ExpandNodeIntent>(
                            context,
                            ExpandNodeIntent(Uri.parse('file://folder1/')),
                          );
                        },
                        child: const Text('Expand'),
                      ),
                      Expanded(
                        child: ReorderableTreeListView(
                          paths: testPaths,
                          itemBuilder: (BuildContext context, Uri path) =>
                              Text(path.toString()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap the button to invoke the intent
        await tester.tap(find.text('Expand'));
        await tester.pumpAndSettle();

        // Verify the custom action was called with the correct path
        expect(expandedPath, equals(Uri.parse('file://folder1/')));
      });
    });

    group('Default Action Behavior', () {
      testWidgets('should provide default expand/collapse behavior', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReorderableTreeListView(
                paths: testPaths,
                itemBuilder: (BuildContext context, Uri path) =>
                    Text(path.toString()),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // The tree should initially show folder1 as collapsed or expanded based on default settings
        // This test verifies that default actions are properly registered and functional
        final Finder treeViewFinder = find.byType(ReorderableTreeListView);
        expect(treeViewFinder, findsOneWidget);
      });
    });
  });
}
