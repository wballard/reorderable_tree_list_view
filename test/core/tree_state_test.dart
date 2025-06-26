import 'package:flutter_test/flutter_test.dart';
import 'package:reorderable_tree_list_view/src/core/tree_builder.dart';
import 'package:reorderable_tree_list_view/src/core/tree_state.dart';
import 'package:reorderable_tree_list_view/src/models/tree_node.dart';

void main() {
  group('TreeState', () {
    late TreeState treeState;
    late List<Uri> samplePaths;
    
    setUp(() {
      samplePaths = <Uri>[
        Uri.parse('file://var/data/readme.txt'),
        Uri.parse('file://var/data/info.txt'),
        Uri.parse('file://var/config.json'),
        Uri.parse('file://usr/bin/app'),
      ];
      
      final List<TreeNode> nodes = TreeBuilder.buildFromPaths(samplePaths);
      treeState = TreeState(nodes);
    });
    
    test('provides access to all nodes', () {
      expect(treeState.allNodes.length, greaterThan(samplePaths.length));
      expect(treeState.allNodes.any((TreeNode n) => n.path == Uri.parse('file://')), isTrue);
      expect(treeState.allNodes.any((TreeNode n) => n.path == Uri.parse('file://var')), isTrue);
    });
    
    test('provides quick lookup by path', () {
      final TreeNode? node = treeState.getNodeByPath(Uri.parse('file://var/data/readme.txt'));
      expect(node, isNotNull);
      expect(node!.isLeaf, isTrue);
      expect(node.displayName, equals('readme.txt'));
      
      final TreeNode? folderNode = treeState.getNodeByPath(Uri.parse('file://var/data'));
      expect(folderNode, isNotNull);
      expect(folderNode!.isLeaf, isFalse);
    });
    
    test('returns null for non-existent path', () {
      final TreeNode? node = treeState.getNodeByPath(Uri.parse('file://does/not/exist'));
      expect(node, isNull);
    });
    
    test('gets children of a node', () {
      final List<TreeNode> rootChildren = treeState.getChildren(Uri.parse('file://'));
      expect(rootChildren.length, equals(2)); // var and usr
      expect(rootChildren[0].displayName, equals('usr'));
      expect(rootChildren[1].displayName, equals('var'));
      
      final List<TreeNode> varChildren = treeState.getChildren(Uri.parse('file://var'));
      expect(varChildren.length, equals(2)); // config.json and data
      expect(varChildren[0].displayName, equals('config.json'));
      expect(varChildren[1].displayName, equals('data'));
    });
    
    test('returns empty list for leaf nodes', () {
      final List<TreeNode> children = treeState.getChildren(Uri.parse('file://var/config.json'));
      expect(children, isEmpty);
    });
    
    test('gets visible nodes (all expanded by default)', () {
      final List<TreeNode> visibleNodes = treeState.getVisibleNodes();
      expect(visibleNodes.length, equals(treeState.allNodes.length));
    });
    
    test('tracks expansion state', () {
      expect(treeState.isExpanded(Uri.parse('file://var')), isTrue);
      
      treeState.setExpanded(Uri.parse('file://var'), expanded: false);
      expect(treeState.isExpanded(Uri.parse('file://var')), isFalse);
      
      treeState.toggleExpanded(Uri.parse('file://var'));
      expect(treeState.isExpanded(Uri.parse('file://var')), isTrue);
    });
    
    test('visible nodes respect expansion state', () {
      // Collapse file://var
      treeState.setExpanded(Uri.parse('file://var'), expanded: false);
      
      final List<TreeNode> visibleNodes = treeState.getVisibleNodes();
      
      // Should not include children of collapsed node
      expect(visibleNodes.any((TreeNode n) => n.path == Uri.parse('file://var/data')), isFalse);
      expect(visibleNodes.any((TreeNode n) => n.path == Uri.parse('file://var/config.json')), isFalse);
      expect(visibleNodes.any((TreeNode n) => n.path == Uri.parse('file://var/data/readme.txt')), isFalse);
      
      // But should include the collapsed node itself
      expect(visibleNodes.any((TreeNode n) => n.path == Uri.parse('file://var')), isTrue);
      
      // And other branches should be visible
      expect(visibleNodes.any((TreeNode n) => n.path == Uri.parse('file://usr')), isTrue);
      expect(visibleNodes.any((TreeNode n) => n.path == Uri.parse('file://usr/bin')), isTrue);
    });
    
    test('collapseAll and expandAll work correctly', () {
      treeState.collapseAll();
      
      // Only root nodes should be visible
      final List<TreeNode> collapsedVisible = treeState.getVisibleNodes();
      expect(collapsedVisible.length, equals(1)); // Just file://
      
      treeState.expandAll();
      
      // All nodes should be visible again
      final List<TreeNode> expandedVisible = treeState.getVisibleNodes();
      expect(expandedVisible.length, equals(treeState.allNodes.length));
    });
    
    test('handles expansion state for non-folder nodes gracefully', () {
      // Trying to expand a leaf should have no effect
      final Uri leafPath = Uri.parse('file://var/config.json');
      treeState.setExpanded(leafPath, expanded: false);
      
      // Should still be visible since it's a leaf
      final List<TreeNode> visibleNodes = treeState.getVisibleNodes();
      expect(visibleNodes.any((TreeNode n) => n.path == leafPath), isTrue);
    });
    
    test('preserves sort order in visible nodes', () {
      final List<TreeNode> visibleNodes = treeState.getVisibleNodes();
      
      // Verify hierarchical order is maintained
      for (int i = 0; i < visibleNodes.length; i++) {
        final TreeNode node = visibleNodes[i];
        final Uri? parentPath = node.parentPath;
        
        if (parentPath != null) {
          // Parent must appear before child in visible list
          final int parentIndex = visibleNodes.indexWhere((TreeNode n) => n.path == parentPath);
          expect(parentIndex, greaterThanOrEqualTo(0));
          expect(parentIndex, lessThan(i));
        }
      }
    });
  });
}