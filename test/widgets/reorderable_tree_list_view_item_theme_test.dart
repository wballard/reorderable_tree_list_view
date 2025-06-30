import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

void main() {
  group('ReorderableTreeListViewItem Theme Integration', () {
    testWidgets('should use default theme when no TreeTheme provided', (
      WidgetTester tester,
    ) async {
      final TreeNode node = TreeNode(
        path: Uri.parse('file://folder/subfolder/test.txt'),
        isLeaf: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableTreeListViewItem(
              node: node,
              child: const Text('Test'),
            ),
          ),
        ),
      );

      // Should use default indentation (depth is 3 for file://folder/subfolder/test.txt)
      final SizedBox sizedBox = tester.widget<SizedBox>(
        find.byType(SizedBox).first,
      );
      expect(sizedBox.width, equals(3 * 24)); // depth * default indentSize
    });

    testWidgets('should use TreeTheme when provided', (
      WidgetTester tester,
    ) async {
      final TreeNode node = TreeNode(
        path: Uri.parse('file://folder/subfolder/test.txt'),
        isLeaf: true,
      );

      const TreeTheme theme = TreeTheme(
        indentSize: 48,
        itemPadding: EdgeInsets.all(16),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TreeThemeData(
              theme: theme,
              child: ReorderableTreeListViewItem(
                node: node,
                child: const Text('Test'),
              ),
            ),
          ),
        ),
      );

      // Should use theme's indentation (depth is 3 for file://folder/subfolder/test.txt)
      final SizedBox sizedBox = tester.widget<SizedBox>(
        find.byType(SizedBox).first,
      );
      expect(sizedBox.width, equals(3 * 48)); // depth * theme indentSize

      // Should have proper padding
      final Padding padding = tester.widget<Padding>(
        find.byType(Padding).first,
      );
      expect(padding.padding, equals(const EdgeInsets.all(16)));

      // Should have proper border radius
      final InkWell inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(
        inkWell.borderRadius,
        equals(const BorderRadius.all(Radius.circular(8))),
      );
    });


    testWidgets('should use Material Design colors when provided', (
      WidgetTester tester,
    ) async {
      final TreeNode node = TreeNode(
        path: Uri.parse('file://folder/test.txt'),
        isLeaf: true,
      );

      final TreeTheme theme = TreeTheme(
        hoverColor: Colors.blue.withValues(alpha: 0.1),
        focusColor: Colors.blue.withValues(alpha: 0.2),
        splashColor: Colors.blue.withValues(alpha: 0.3),
        highlightColor: Colors.blue.withValues(alpha: 0.4),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TreeThemeData(
              theme: theme,
              child: ReorderableTreeListViewItem(
                node: node,
                child: const Text('Test'),
              ),
            ),
          ),
        ),
      );

      final InkWell inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.hoverColor, equals(Colors.blue.withValues(alpha: 0.1)));
      expect(inkWell.focusColor, equals(Colors.blue.withValues(alpha: 0.2)));
      expect(inkWell.splashColor, equals(Colors.blue.withValues(alpha: 0.3)));
      expect(
        inkWell.highlightColor,
        equals(Colors.blue.withValues(alpha: 0.4)),
      );
    });

    testWidgets('should use Material theme colors as fallback', (
      WidgetTester tester,
    ) async {
      final TreeNode node = TreeNode(
        path: Uri.parse('file://folder/test.txt'),
        isLeaf: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            hoverColor: Colors.red.withValues(alpha: 0.1),
            focusColor: Colors.red.withValues(alpha: 0.2),
            splashColor: Colors.red.withValues(alpha: 0.3),
            highlightColor: Colors.red.withValues(alpha: 0.4),
          ),
          home: Scaffold(
            body: ReorderableTreeListViewItem(
              node: node,
              child: const Text('Test'),
            ),
          ),
        ),
      );

      final InkWell inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.hoverColor, equals(Colors.red.withValues(alpha: 0.1)));
      expect(inkWell.focusColor, equals(Colors.red.withValues(alpha: 0.2)));
      expect(inkWell.splashColor, equals(Colors.red.withValues(alpha: 0.3)));
      expect(inkWell.highlightColor, equals(Colors.red.withValues(alpha: 0.4)));
    });

    testWidgets('should handle zero depth correctly', (
      WidgetTester tester,
    ) async {
      final TreeNode node = TreeNode(path: Uri.parse('file://'), isLeaf: false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableTreeListViewItem(
              node: node,
              child: const Text('Test'),
            ),
          ),
        ),
      );

      // Should have no indentation
      final SizedBox sizedBox = tester.widget<SizedBox>(
        find.byType(SizedBox).first,
      );
      expect(sizedBox.width, equals(0));
    });

    testWidgets('should handle deep nesting correctly', (
      WidgetTester tester,
    ) async {
      final TreeNode node = TreeNode(
        path: Uri.parse('file://a/b/c/d/e/f/g/h/i/j/test.txt'),
        isLeaf: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableTreeListViewItem(
              node: node,
              child: const Text('Test'),
            ),
          ),
        ),
      );

      // Should have proper deep indentation (depth is 11 for the given path)
      final SizedBox sizedBox = tester.widget<SizedBox>(
        find.byType(SizedBox).first,
      );
      expect(sizedBox.width, equals(11 * 24)); // depth * default indentSize
    });
  });
}
