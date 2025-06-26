import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

void main() {
  group('ReorderableTreeListViewItem', () {
    late TreeNode sampleNode;
    late Widget sampleChild;
    
    setUp(() {
      sampleNode = TreeNode(
        path: Uri.parse('file://var/data/readme.txt'),
        isLeaf: true,
      );
      sampleChild = const Text('Sample content');
    });
    
    testWidgets('creates widget with required parameters', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableTreeListViewItem(
              node: sampleNode,
              child: sampleChild,
            ),
          ),
        ),
      );
      
      expect(find.byType(ReorderableTreeListViewItem), findsOneWidget);
      expect(find.text('Sample content'), findsOneWidget);
    });
    
    testWidgets('applies correct indentation based on depth', (WidgetTester tester) async {
      // Test with depth 0 (root level)
      final TreeNode rootNode = TreeNode(
        path: Uri.parse('file://'),
        isLeaf: false,
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableTreeListViewItem(
              node: rootNode,
              child: const Text('Root'),
            ),
          ),
        ),
      );
      
      // Find the SizedBox used for indentation
      final Finder indentBox = find.byType(SizedBox);
      expect(indentBox, findsWidgets);
      
      final SizedBox rootIndent = tester.widget<SizedBox>(indentBox.first);
      expect(rootIndent.width, equals(0)); // depth 0 * 24 = 0
    });
    
    testWidgets('applies correct indentation for nested nodes', (WidgetTester tester) async {
      // Test with depth 2 node
      final TreeNode nestedNode = TreeNode(
        path: Uri.parse('file://var/data'),
        isLeaf: false,
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableTreeListViewItem(
              node: nestedNode,
              child: const Text('Nested'),
            ),
          ),
        ),
      );
      
      final Finder indentBox = find.byType(SizedBox);
      final SizedBox nestedIndent = tester.widget<SizedBox>(indentBox.first);
      expect(nestedIndent.width, equals(48)); // depth 2 * 24 = 48
    });
    
    testWidgets('uses custom indent width', (WidgetTester tester) async {
      const double customIndent = 32;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableTreeListViewItem(
              node: sampleNode,
              indentWidth: customIndent,
              child: sampleChild,
            ),
          ),
        ),
      );
      
      final Finder indentBox = find.byType(SizedBox);
      final SizedBox customIndentBox = tester.widget<SizedBox>(indentBox.first);
      expect(customIndentBox.width, equals(sampleNode.depth * customIndent));
    });
    
    testWidgets('child is properly wrapped in Expanded', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableTreeListViewItem(
              node: sampleNode,
              child: sampleChild,
            ),
          ),
        ),
      );
      
      // Check that child is wrapped in Expanded
      expect(find.byType(Expanded), findsOneWidget);
      
      // Check that our child is inside the Expanded widget
      final Finder expandedFinder = find.byType(Expanded);
      final Expanded expandedWidget = tester.widget<Expanded>(expandedFinder);
      expect(find.descendant(
        of: find.byWidget(expandedWidget),
        matching: find.text('Sample content'),
      ), findsOneWidget);
    });
    
    testWidgets('uses Row layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableTreeListViewItem(
              node: sampleNode,
              child: sampleChild,
            ),
          ),
        ),
      );
      
      expect(find.byType(Row), findsOneWidget);
    });
    
    testWidgets('has Material wrapper', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableTreeListViewItem(
              node: sampleNode,
              child: sampleChild,
            ),
          ),
        ),
      );
      
      expect(find.byType(Material), findsWidgets);
    });
    
    testWidgets('has InkWell for tap feedback', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableTreeListViewItem(
              node: sampleNode,
              child: sampleChild,
            ),
          ),
        ),
      );
      
      expect(find.byType(InkWell), findsOneWidget);
    });
    
    testWidgets('preserves node key', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableTreeListViewItem(
              key: ValueKey<String>(sampleNode.key),
              node: sampleNode,
              child: sampleChild,
            ),
          ),
        ),
      );
      
      final Finder itemFinder = find.byType(ReorderableTreeListViewItem);
      final ReorderableTreeListViewItem item = tester.widget<ReorderableTreeListViewItem>(itemFinder);
      expect(item.key, equals(ValueKey<String>(sampleNode.key)));
    });
    
    testWidgets('responds to tap gestures', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableTreeListViewItem(
              node: sampleNode,
              child: sampleChild,
            ),
          ),
        ),
      );
      
      // Verify the InkWell can be tapped without throwing errors
      await tester.tap(find.byType(InkWell));
      await tester.pump();
      
      // No exception should be thrown and widget should still be present
      expect(find.byType(ReorderableTreeListViewItem), findsOneWidget);
    });
    
    testWidgets('integrates with Material theme', (WidgetTester tester) async {
      final ThemeData customTheme = ThemeData(
        primarySwatch: Colors.green,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.red),
        ),
      );
      
      await tester.pumpWidget(
        MaterialApp(
          theme: customTheme,
          home: Scaffold(
            body: ReorderableTreeListViewItem(
              node: sampleNode,
              child: const Text('Themed content'),
            ),
          ),
        ),
      );
      
      // Verify the widget builds without theme-related errors
      expect(find.byType(ReorderableTreeListViewItem), findsOneWidget);
      expect(find.text('Themed content'), findsOneWidget);
    });
  });
}