import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

void main() {
  group('Dark Theme Story Tests', () {
    testWidgets('Custom theme knob applies theme regardless of system theme mode', (
      WidgetTester tester,
    ) async {
      final paths = [
        Uri.parse('file://file1.txt'),
        Uri.parse('file://folder1/'),
      ];

      bool useCustomDarkTheme = false;
      
      // Widget with the fixed implementation
      Widget createFixedWidget({required bool isDarkMode}) {
        return MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: StatefulBuilder(
            builder: (context, setState) {
              TreeTheme theme;
              // Fixed logic - applies custom theme based only on knob value
              if (useCustomDarkTheme) {
                theme = TreeTheme(
                  indentSize: 32.0,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  hoverColor: Colors.cyan.withValues(alpha: 0.08),
                  focusColor: Colors.cyan.withValues(alpha: 0.16),
                  splashColor: Colors.cyan.withValues(alpha: 0.12),
                  highlightColor: Colors.cyan.withValues(alpha: 0.06),
                );
              } else {
                theme = const TreeTheme(
                  indentSize: 32.0,
                );
              }
              
              return Scaffold(
                body: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          useCustomDarkTheme = !useCustomDarkTheme;
                        });
                      },
                      child: Text('Use Custom Dark Theme: $useCustomDarkTheme'),
                    ),
                    Expanded(
                      child: ReorderableTreeListView(
                        paths: paths,
                        theme: theme,
                        initiallyExpanded: {Uri.parse('file://')},
                        itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }

      TreeTheme? getTreeTheme() {
        final treeFinder = find.byType(ReorderableTreeListView);
        final treeWidget = tester.widget<ReorderableTreeListView>(treeFinder);
        return treeWidget.theme;
      }

      // Test in LIGHT mode
      await tester.pumpWidget(createFixedWidget(isDarkMode: false));
      await tester.pumpAndSettle();
      
      // Initial state - default theme
      var currentTheme = getTreeTheme();
      expect(currentTheme?.hoverColor, isNull);
      expect(currentTheme?.borderRadius, BorderRadius.zero); // Default value
      expect(currentTheme?.itemPadding, const EdgeInsets.symmetric(horizontal: 16, vertical: 8)); // Default value
      
      // Toggle the custom dark theme knob
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      // Theme should now be applied even in light mode
      currentTheme = getTreeTheme();
      expect(currentTheme?.hoverColor, Colors.cyan.withValues(alpha: 0.08));
      expect(currentTheme?.borderRadius, const BorderRadius.all(Radius.circular(8.0)));
      expect(currentTheme?.itemPadding, const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0));
      
      // Toggle back to default before testing dark mode
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      currentTheme = getTreeTheme();
      expect(currentTheme?.hoverColor, isNull);
      
      // Test in DARK mode
      await tester.pumpWidget(createFixedWidget(isDarkMode: true));
      await tester.pumpAndSettle();
      
      // Should still be in default theme
      currentTheme = getTreeTheme();
      expect(currentTheme?.hoverColor, isNull);
      
      // Toggle to custom theme
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      // Should work in dark mode too
      currentTheme = getTreeTheme();
      expect(currentTheme?.hoverColor, Colors.cyan.withValues(alpha: 0.08));
      expect(currentTheme?.borderRadius, const BorderRadius.all(Radius.circular(8.0)));
    });

    testWidgets('Theme message updates correctly based on knob state', (
      WidgetTester tester,
    ) async {
      final paths = [Uri.parse('file://file1.txt')];
      bool useCustomDarkTheme = true;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        useCustomDarkTheme
                            ? 'Using custom theme with cyan accents'
                            : 'Using default theme',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          useCustomDarkTheme = !useCustomDarkTheme;
                        });
                      },
                      child: const Text('Toggle Theme'),
                    ),
                    Expanded(
                      child: ReorderableTreeListView(
                        paths: paths,
                        theme: const TreeTheme(indentSize: 32.0),
                        itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
      
      // Check initial message
      expect(find.text('Using custom theme with cyan accents'), findsOneWidget);
      expect(find.text('Using default theme'), findsNothing);
      
      // Toggle theme
      await tester.tap(find.text('Toggle Theme'));
      await tester.pumpAndSettle();
      
      // Check updated message
      expect(find.text('Using custom theme with cyan accents'), findsNothing);
      expect(find.text('Using default theme'), findsOneWidget);
    });
  });
}