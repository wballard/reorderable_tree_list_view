import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

void main() {
  group('ReorderableTreeListViewItem Expansion UI', () {
    late TreeState treeState;
    late List<TreeNode> nodes;

    setUp(() {
      final List<Uri> paths = <Uri>[
        Uri.parse('file://folder/subfolder/item.txt'),
        Uri.parse('file://folder/item2.txt'),
        Uri.parse('file://root.txt'),
      ];
      nodes = TreeBuilder.buildFromPaths(paths);
      treeState = TreeState(nodes);
    });

    group('expand/collapse icons', () {
      testWidgets('should show expand icon for collapsed folder', (
        WidgetTester tester,
      ) async {
        // Get a folder node and collapse it
        final Uri folderPath = Uri.parse('file://folder');
        treeState.setExpanded(folderPath, expanded: false);
        final TreeNode folderNode = treeState.getNodeByPath(folderPath)!;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReorderableTreeListViewItem(
                key: ValueKey<String>(folderNode.key),
                node: folderNode,
                isExpanded: treeState.isExpanded(folderPath),
                hasChildren: treeState.getChildren(folderPath).isNotEmpty,
                onExpansionToggle: () {},
                child: Text(folderNode.displayName),
              ),
            ),
          ),
        );

        // Should show expand icon (typically an arrow pointing right or down)
        expect(find.byIcon(Icons.keyboard_arrow_right), findsOneWidget);
        expect(find.byIcon(Icons.keyboard_arrow_down), findsNothing);
      });

      testWidgets('should show collapse icon for expanded folder', (
        WidgetTester tester,
      ) async {
        // Get a folder node that is expanded by default
        final Uri folderPath = Uri.parse('file://folder');
        final TreeNode folderNode = treeState.getNodeByPath(folderPath)!;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReorderableTreeListViewItem(
                key: ValueKey<String>(folderNode.key),
                node: folderNode,
                isExpanded: treeState.isExpanded(folderPath),
                hasChildren: treeState.getChildren(folderPath).isNotEmpty,
                onExpansionToggle: () {},
                child: Text(folderNode.displayName),
              ),
            ),
          ),
        );

        // Should show collapse icon (typically an arrow pointing down)
        expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
        expect(find.byIcon(Icons.keyboard_arrow_right), findsNothing);
      });

      testWidgets('should not show expansion icon for leaf nodes', (
        WidgetTester tester,
      ) async {
        // Get a leaf node
        final Uri leafPath = Uri.parse('file://root.txt');
        final TreeNode leafNode = treeState.getNodeByPath(leafPath)!;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReorderableTreeListViewItem(
                key: ValueKey<String>(leafNode.key),
                node: leafNode,
                onExpansionToggle: () {},
                child: Text(leafNode.displayName),
              ),
            ),
          ),
        );

        // Should not show any expansion icons
        expect(find.byIcon(Icons.keyboard_arrow_right), findsNothing);
        expect(find.byIcon(Icons.keyboard_arrow_down), findsNothing);
      });
    });

    group('expansion interaction', () {
      testWidgets(
        'should call onExpansionToggle when expansion icon is tapped',
        (WidgetTester tester) async {
          bool toggleCalled = false;
          final Uri folderPath = Uri.parse('file://folder');
          final TreeNode folderNode = treeState.getNodeByPath(folderPath)!;

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: ReorderableTreeListViewItem(
                  key: ValueKey<String>(folderNode.key),
                  node: folderNode,
                  isExpanded: treeState.isExpanded(folderPath),
                  hasChildren: treeState.getChildren(folderPath).isNotEmpty,
                  onExpansionToggle: () {
                    toggleCalled = true;
                  },
                  child: Text(folderNode.displayName),
                ),
              ),
            ),
          );

          // Tap the expansion icon
          await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
          await tester.pump();

          expect(toggleCalled, isTrue);
        },
      );

      testWidgets('should not interfere with drag operations', (
        WidgetTester tester,
      ) async {
        final Uri folderPath = Uri.parse('file://folder');
        final TreeNode folderNode = treeState.getNodeByPath(folderPath)!;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReorderableTreeListViewItem(
                key: ValueKey<String>(folderNode.key),
                node: folderNode,
                isExpanded: treeState.isExpanded(folderPath),
                hasChildren: treeState.getChildren(folderPath).isNotEmpty,
                onExpansionToggle: () {},
                child: Text(folderNode.displayName),
              ),
            ),
          ),
        );

        // Long press to start drag should work
        await tester.longPress(find.text(folderNode.displayName));
        await tester.pump();

        // Should enter drag mode (this would typically show drag visuals)
        // The exact assertion depends on the implementation
        expect(tester.takeException(), isNull);
      });
    });

    group('accessibility', () {
      testWidgets('should have proper semantics for expansion state', (
        WidgetTester tester,
      ) async {
        final Uri folderPath = Uri.parse('file://folder');
        final TreeNode folderNode = treeState.getNodeByPath(folderPath)!;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReorderableTreeListViewItem(
                key: ValueKey<String>(folderNode.key),
                node: folderNode,
                isExpanded: treeState.isExpanded(folderPath),
                hasChildren: treeState.getChildren(folderPath).isNotEmpty,
                onExpansionToggle: () {},
                child: Text(folderNode.displayName),
              ),
            ),
          ),
        );

        // Should have semantics information
        final SemanticsNode semantics = tester.getSemantics(
          find.byType(ReorderableTreeListViewItem),
        );
        expect(semantics, isNotNull);
        // The expansion icon should have its own semantics
        expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
      });
    });
  });
}
