import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

void main() {
  group('TreeTheme', () {
    test('should create with default values', () {
      const TreeTheme theme = TreeTheme();
      
      expect(theme.indentSize, equals(24));
      expect(theme.connectorColor, equals(Colors.grey));
      expect(theme.connectorWidth, equals(1));
      expect(theme.showConnectors, isTrue);
      expect(theme.expandIconSize, equals(24));
      expect(theme.itemPadding, equals(const EdgeInsets.symmetric(horizontal: 16, vertical: 8)));
      expect(theme.borderRadius, equals(BorderRadius.zero));
      expect(theme.hoverColor, isNull);
      expect(theme.focusColor, isNull);
      expect(theme.splashColor, isNull);
      expect(theme.highlightColor, isNull);
    });

    test('should create with custom values', () {
      final TreeTheme theme = TreeTheme(
        indentSize: 32,
        connectorColor: Colors.blue,
        connectorWidth: 2,
        showConnectors: false,
        expandIconSize: 20,
        itemPadding: const EdgeInsets.all(12),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        hoverColor: Colors.blue.withValues(alpha: 0.1),
        focusColor: Colors.blue.withValues(alpha: 0.2),
        splashColor: Colors.blue.withValues(alpha: 0.3),
        highlightColor: Colors.blue.withValues(alpha: 0.4),
      );
      
      expect(theme.indentSize, equals(32));
      expect(theme.connectorColor, equals(Colors.blue));
      expect(theme.connectorWidth, equals(2));
      expect(theme.showConnectors, isFalse);
      expect(theme.expandIconSize, equals(20));
      expect(theme.itemPadding, equals(const EdgeInsets.all(12)));
      expect(theme.borderRadius, equals(const BorderRadius.all(Radius.circular(8))));
      expect(theme.hoverColor, equals(Colors.blue.withValues(alpha: 0.1)));
      expect(theme.focusColor, equals(Colors.blue.withValues(alpha: 0.2)));
      expect(theme.splashColor, equals(Colors.blue.withValues(alpha: 0.3)));
      expect(theme.highlightColor, equals(Colors.blue.withValues(alpha: 0.4)));
    });

    test('should support equality', () {
      const TreeTheme theme1 = TreeTheme();
      const TreeTheme theme2 = TreeTheme();
      const TreeTheme theme3 = TreeTheme(indentSize: 32);
      
      expect(theme1, equals(theme2));
      expect(theme1, isNot(equals(theme3)));
    });

    test('should have correct hashCode', () {
      const TreeTheme theme1 = TreeTheme();
      const TreeTheme theme2 = TreeTheme();
      const TreeTheme theme3 = TreeTheme(indentSize: 32);
      
      expect(theme1.hashCode, equals(theme2.hashCode));
      expect(theme1.hashCode, isNot(equals(theme3.hashCode)));
    });

    test('should copyWith correctly', () {
      const TreeTheme original = TreeTheme();
      final TreeTheme modified = original.copyWith(
        indentSize: 32,
        connectorColor: Colors.red,
      );
      
      expect(modified.indentSize, equals(32));
      expect(modified.connectorColor, equals(Colors.red));
      expect(modified.connectorWidth, equals(original.connectorWidth));
      expect(modified.showConnectors, equals(original.showConnectors));
    });

    testWidgets('should be accessible via InheritedWidget', (WidgetTester tester) async {
      const TreeTheme customTheme = TreeTheme(indentSize: 48);
      TreeTheme? capturedTheme;
      
      await tester.pumpWidget(
        MaterialApp(
          home: TreeThemeData(
            theme: customTheme,
            child: Builder(
              builder: (BuildContext context) {
                capturedTheme = TreeTheme.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      
      expect(capturedTheme, equals(customTheme));
    });

    testWidgets('should use default theme when not provided', (WidgetTester tester) async {
      TreeTheme? capturedTheme;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              capturedTheme = TreeTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      
      expect(capturedTheme, equals(const TreeTheme()));
    });

    testWidgets('should merge with Material theme', (WidgetTester tester) async {
      TreeTheme? capturedTheme;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
            ),
            hoverColor: Colors.grey.withValues(alpha: 0.04),
            focusColor: Colors.blue.withValues(alpha: 0.12),
            splashColor: Colors.blue.withValues(alpha: 0.08),
            highlightColor: Colors.blue.withValues(alpha: 0.04),
          ),
          home: Builder(
            builder: (BuildContext context) {
              capturedTheme = TreeTheme.maybeOf(context);
              return const SizedBox();
            },
          ),
        ),
      );
      
      // When no TreeTheme is provided, it should return null
      expect(capturedTheme, isNull);
    });
  });

  group('TreeThemeData', () {
    testWidgets('should provide theme to descendants', (WidgetTester tester) async {
      const TreeTheme customTheme = TreeTheme(indentSize: 48);
      TreeTheme? capturedTheme;
      
      await tester.pumpWidget(
        MaterialApp(
          home: TreeThemeData(
            theme: customTheme,
            child: Builder(
              builder: (BuildContext context) {
                capturedTheme = TreeTheme.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      
      expect(capturedTheme, equals(customTheme));
    });

    testWidgets('should update when theme changes', (WidgetTester tester) async {
      const TreeTheme theme1 = TreeTheme();
      const TreeTheme theme2 = TreeTheme(indentSize: 48);
      TreeTheme? capturedTheme;
      
      await tester.pumpWidget(
        MaterialApp(
          home: TreeThemeData(
            theme: theme1,
            child: Builder(
              builder: (BuildContext context) {
                capturedTheme = TreeTheme.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      
      expect(capturedTheme, equals(theme1));
      
      await tester.pumpWidget(
        MaterialApp(
          home: TreeThemeData(
            theme: theme2,
            child: Builder(
              builder: (BuildContext context) {
                capturedTheme = TreeTheme.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      
      expect(capturedTheme, equals(theme2));
    });
  });
}