import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

void main() {
  group('TreeViewShortcuts', () {
    group('Default Shortcuts', () {
      testWidgets(
        'should wrap child with Shortcuts widget containing default shortcuts',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: TreeViewShortcuts(child: Text('Test Content')),
              ),
            ),
          );
          await tester.pumpAndSettle();

          // Should find the child content
          expect(find.text('Test Content'), findsOneWidget);

          // Find the Shortcuts widget that contains our tree shortcuts
          // There will be multiple Shortcuts widgets (from MaterialApp, etc.)
          final Iterable<Shortcuts> shortcutsWidgets = tester
              .widgetList<Shortcuts>(find.byType(Shortcuts));

          // Find the one with our tree shortcuts (should have TreeCopyIntent)
          Shortcuts? treeShortcutsWidget;
          for (final Shortcuts widget in shortcutsWidgets) {
            if (widget.shortcuts.values.any(
              (Intent intent) => intent is TreeCopyIntent,
            )) {
              treeShortcutsWidget = widget;
              break;
            }
          }

          expect(
            treeShortcutsWidget,
            isNotNull,
            reason: 'Should find Shortcuts widget with tree shortcuts',
          );
          final Shortcuts shortcutsWidget = treeShortcutsWidget!;
          expect(shortcutsWidget.shortcuts, isNotEmpty);

          // Verify some expected shortcuts exist
          final Map<ShortcutActivator, Intent> shortcuts =
              shortcutsWidget.shortcuts;

          // Check for Ctrl+C (copy)
          expect(
            shortcuts.containsKey(
              const SingleActivator(LogicalKeyboardKey.keyC, control: true),
            ),
            isTrue,
            reason: 'Should have Ctrl+C shortcut for copy',
          );

          // Check for Ctrl+V (paste)
          expect(
            shortcuts.containsKey(
              const SingleActivator(LogicalKeyboardKey.keyV, control: true),
            ),
            isTrue,
            reason: 'Should have Ctrl+V shortcut for paste',
          );

          // Check for Delete key
          expect(
            shortcuts.containsKey(
              const SingleActivator(LogicalKeyboardKey.delete),
            ),
            isTrue,
            reason: 'Should have Delete shortcut',
          );

          // Check for Ctrl+A (select all)
          expect(
            shortcuts.containsKey(
              const SingleActivator(LogicalKeyboardKey.keyA, control: true),
            ),
            isTrue,
            reason: 'Should have Ctrl+A shortcut for select all',
          );
        },
      );

      testWidgets('should provide platform-specific shortcuts on macOS', (
        WidgetTester tester,
      ) async {
        // Override the platform for this test
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: TargetPlatform.macOS),
            home: const Scaffold(
              body: TreeViewShortcuts(child: Text('Test Content')),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find the Shortcuts widget that contains our tree shortcuts
        final Iterable<Shortcuts> shortcutsWidgets = tester
            .widgetList<Shortcuts>(find.byType(Shortcuts));
        Shortcuts? treeShortcutsWidget;
        for (final Shortcuts widget in shortcutsWidgets) {
          if (widget.shortcuts.values.any(
            (Intent intent) => intent is TreeCopyIntent,
          )) {
            treeShortcutsWidget = widget;
            break;
          }
        }
        expect(treeShortcutsWidget, isNotNull);
        final Map<ShortcutActivator, Intent> shortcuts =
            treeShortcutsWidget!.shortcuts;

        // On macOS, should use Cmd instead of Ctrl for copy
        expect(
          shortcuts.containsKey(
            const SingleActivator(LogicalKeyboardKey.keyC, meta: true),
          ),
          isTrue,
          reason: 'Should have Cmd+C shortcut for copy on macOS',
        );

        // Should NOT have Ctrl+C on macOS
        expect(
          shortcuts.containsKey(
            const SingleActivator(LogicalKeyboardKey.keyC, control: true),
          ),
          isFalse,
          reason: 'Should not have Ctrl+C shortcut on macOS',
        );
      });
    });

    group('Custom Shortcuts', () {
      testWidgets('should merge custom shortcuts with defaults', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TreeViewShortcuts(
                shortcuts: <ShortcutActivator, Intent>{
                  SingleActivator(LogicalKeyboardKey.keyF, control: true):
                      TreeExpandAllIntent(),
                },
                child: Text('Test Content'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find the Shortcuts widget that contains our tree shortcuts
        final Iterable<Shortcuts> shortcutsWidgets = tester
            .widgetList<Shortcuts>(find.byType(Shortcuts));
        Shortcuts? treeShortcutsWidget;
        for (final Shortcuts widget in shortcutsWidgets) {
          if (widget.shortcuts.values.any(
            (Intent intent) => intent is TreeExpandAllIntent,
          )) {
            treeShortcutsWidget = widget;
            break;
          }
        }
        expect(treeShortcutsWidget, isNotNull);
        final Map<ShortcutActivator, Intent> shortcuts =
            treeShortcutsWidget!.shortcuts;

        // Should have custom shortcut
        expect(
          shortcuts.containsKey(
            const SingleActivator(LogicalKeyboardKey.keyF, control: true),
          ),
          isTrue,
          reason: 'Should have custom Ctrl+F shortcut',
        );

        // Should still have default shortcuts
        expect(
          shortcuts.containsKey(
            const SingleActivator(LogicalKeyboardKey.keyC, control: true),
          ),
          isTrue,
          reason: 'Should still have default Ctrl+C shortcut',
        );
      });

      testWidgets('should override default shortcuts with custom ones', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TreeViewShortcuts(
                shortcuts: <ShortcutActivator, Intent>{
                  // Override the default Ctrl+C shortcut with a different intent
                  SingleActivator(LogicalKeyboardKey.keyC, control: true):
                      TreeDeleteIntent(),
                },
                child: Text('Test Content'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find the Shortcuts widget that contains our tree shortcuts
        final Iterable<Shortcuts> shortcutsWidgets = tester
            .widgetList<Shortcuts>(find.byType(Shortcuts));
        Shortcuts? treeShortcutsWidget;
        for (final Shortcuts widget in shortcutsWidgets) {
          if (widget.shortcuts.values.any(
            (Intent intent) => intent is TreeDeleteIntent,
          )) {
            treeShortcutsWidget = widget;
            break;
          }
        }
        expect(treeShortcutsWidget, isNotNull);
        final Map<ShortcutActivator, Intent> shortcuts =
            treeShortcutsWidget!.shortcuts;

        // Should have the custom intent for Ctrl+C
        final Intent? ctrlCIntent =
            shortcuts[const SingleActivator(
              LogicalKeyboardKey.keyC,
              control: true,
            )];
        expect(ctrlCIntent, isA<TreeDeleteIntent>());
      });

      testWidgets(
        'should only use custom shortcuts when defaults are disabled',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: TreeViewShortcuts(
                  enableDefaultShortcuts: false,
                  shortcuts: <ShortcutActivator, Intent>{
                    SingleActivator(LogicalKeyboardKey.keyF, control: true):
                        TreeExpandAllIntent(),
                  },
                  child: Text('Test Content'),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          // Find the Shortcuts widget that contains our tree shortcuts
          final Iterable<Shortcuts> shortcutsWidgets = tester
              .widgetList<Shortcuts>(find.byType(Shortcuts));
          Shortcuts? treeShortcutsWidget;
          for (final Shortcuts widget in shortcutsWidgets) {
            if (widget.shortcuts.values.any(
              (Intent intent) => intent is TreeExpandAllIntent,
            )) {
              treeShortcutsWidget = widget;
              break;
            }
          }
          expect(treeShortcutsWidget, isNotNull);
          final Map<ShortcutActivator, Intent> shortcuts =
              treeShortcutsWidget!.shortcuts;

          // Should only have the custom shortcut
          expect(shortcuts.length, equals(1));
          expect(
            shortcuts.containsKey(
              const SingleActivator(LogicalKeyboardKey.keyF, control: true),
            ),
            isTrue,
            reason: 'Should have custom Ctrl+F shortcut',
          );

          // Should NOT have default shortcuts
          expect(
            shortcuts.containsKey(
              const SingleActivator(LogicalKeyboardKey.keyC, control: true),
            ),
            isFalse,
            reason:
                'Should not have default Ctrl+C shortcut when defaults disabled',
          );
        },
      );

      testWidgets(
        'should return child directly when no shortcuts are defined',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: TreeViewShortcuts(
                  enableDefaultShortcuts: false,
                  shortcuts: <ShortcutActivator, Intent>{},
                  child: Text('Test Content'),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          // Should still find the child content
          expect(find.text('Test Content'), findsOneWidget);

          // Check that no TreeViewShortcuts-specific shortcuts exist
          // (There will still be system shortcuts from MaterialApp)
          final Iterable<Shortcuts> shortcutsWidgets = tester
              .widgetList<Shortcuts>(find.byType(Shortcuts));
          bool foundTreeShortcuts = false;
          for (final Shortcuts widget in shortcutsWidgets) {
            if (widget.shortcuts.values.any(
              (Intent intent) =>
                  intent is TreeCopyIntent || intent is TreeDeleteIntent,
            )) {
              foundTreeShortcuts = true;
              break;
            }
          }
          expect(
            foundTreeShortcuts,
            isFalse,
            reason: 'Should not have tree-specific shortcuts when disabled',
          );
        },
      );
    });

    group('Intent Invocation', () {
      testWidgets('should invoke TreeCopyIntent when Ctrl+C is pressed', (
        WidgetTester tester,
      ) async {
        TreeCopyIntent? invokedIntent;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Actions(
                actions: <Type, Action<Intent>>{
                  TreeCopyIntent: CallbackAction<TreeCopyIntent>(
                    onInvoke: (TreeCopyIntent intent) {
                      invokedIntent = intent;
                      return null;
                    },
                  ),
                },
                child: const TreeViewShortcuts(
                  child: Focus(autofocus: true, child: Text('Test Content')),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Send Ctrl+C key event
        await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
        await tester.pumpAndSettle();

        // Verify the intent was invoked
        expect(invokedIntent, isNotNull);
      });

      testWidgets('should invoke TreeDeleteIntent when Delete is pressed', (
        WidgetTester tester,
      ) async {
        TreeDeleteIntent? invokedIntent;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Actions(
                actions: <Type, Action<Intent>>{
                  TreeDeleteIntent: CallbackAction<TreeDeleteIntent>(
                    onInvoke: (TreeDeleteIntent intent) {
                      invokedIntent = intent;
                      return null;
                    },
                  ),
                },
                child: const TreeViewShortcuts(
                  child: Focus(autofocus: true, child: Text('Test Content')),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Send Delete key event
        await tester.sendKeyEvent(LogicalKeyboardKey.delete);
        await tester.pumpAndSettle();

        // Verify the intent was invoked
        expect(invokedIntent, isNotNull);
      });
    });

    group('Static Methods', () {
      test('defaultShortcuts should return expected shortcuts', () {
        final Map<ShortcutActivator, Intent> shortcuts =
            TreeViewShortcuts.defaultShortcuts;

        expect(shortcuts, isNotEmpty);

        // Verify specific shortcuts exist
        expect(
          shortcuts[const SingleActivator(
            LogicalKeyboardKey.keyC,
            control: true,
          )],
          isA<TreeCopyIntent>(),
        );
        expect(
          shortcuts[const SingleActivator(
            LogicalKeyboardKey.keyV,
            control: true,
          )],
          isA<TreePasteIntent>(),
        );
        expect(
          shortcuts[const SingleActivator(LogicalKeyboardKey.delete)],
          isA<TreeDeleteIntent>(),
        );
        expect(
          shortcuts[const SingleActivator(
            LogicalKeyboardKey.keyA,
            control: true,
          )],
          isA<TreeSelectAllIntent>(),
        );
        expect(
          shortcuts[const SingleActivator(
            LogicalKeyboardKey.equal,
            control: true,
            shift: true,
          )],
          isA<TreeExpandAllIntent>(),
        );
        expect(
          shortcuts[const SingleActivator(
            LogicalKeyboardKey.minus,
            control: true,
          )],
          isA<TreeCollapseAllIntent>(),
        );
      });
    });
  });
}
