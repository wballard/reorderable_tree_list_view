import 'package:flutter_test/flutter_test.dart';
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

void main() {
  group('TreeState Expansion', () {
    late TreeState treeState;
    late List<Uri> paths;
    late List<TreeNode> nodes;

    setUp(() {
      paths = [
        Uri.parse('file://root/child1/grandchild1'),
        Uri.parse('file://root/child1/grandchild2'),
        Uri.parse('file://root/child2'),
      ];
      nodes = TreeBuilder.buildFromPaths(paths);
      treeState = TreeState(nodes);
    });

    group('expandedPaths tracking', () {
      test('should initialize with expanded folders by default', () {
        // Current implementation expands all folders by default
        expect(treeState.isExpanded(Uri.parse('file://')), isTrue);
        expect(treeState.isExpanded(Uri.parse('file://root')), isTrue);
        expect(treeState.isExpanded(Uri.parse('file://root/child1')), isTrue);
      });

      test('should track expanded paths when toggling', () {
        final child1Path = Uri.parse('file://root/child1');
        // child1 should be expanded by default  
        expect(treeState.expandedPaths.contains(child1Path), isTrue);
        
        // Toggle to collapse
        treeState.toggleExpanded(child1Path);
        expect(treeState.expandedPaths.contains(child1Path), isFalse);
        
        // Toggle to expand again
        treeState.toggleExpanded(child1Path);
        expect(treeState.expandedPaths.contains(child1Path), isTrue);
      });

      test('should handle multiple expanded paths', () {
        // file://, file://root, and file://root/child1 start expanded by default
        expect(treeState.expandedPaths.length, equals(3));
        expect(treeState.expandedPaths.contains(Uri.parse('file://')), isTrue);
        expect(treeState.expandedPaths.contains(Uri.parse('file://root')), isTrue);
        expect(treeState.expandedPaths.contains(Uri.parse('file://root/child1')), isTrue);
        
        // child2 is a leaf so toggling it has no effect
        treeState.toggleExpanded(Uri.parse('file://root/child2'));
        expect(treeState.expandedPaths.length, equals(3));
      });
    });

    group('isExpanded', () {
      test('should return true for expanded nodes by default', () {
        expect(treeState.isExpanded(Uri.parse('file://root/child1')), isTrue);
      });

      test('should return false for collapsed nodes', () {
        final child1Path = Uri.parse('file://root/child1');
        treeState.toggleExpanded(child1Path); // collapse it
        expect(treeState.isExpanded(child1Path), isFalse);
      });

      test('should handle non-existent paths', () {
        expect(treeState.isExpanded(Uri.parse('/non/existent')), isFalse);
      });
    });

    group('expandAll', () {
      test('should expand all nodes with children', () {
        // First collapse everything
        treeState.collapseAll();
        expect(treeState.expandedPaths, isEmpty);
        
        // Then expand all
        treeState.expandAll();
        
        expect(treeState.isExpanded(Uri.parse('file://')), isTrue);
        expect(treeState.isExpanded(Uri.parse('file://root')), isTrue);
        expect(treeState.isExpanded(Uri.parse('file://root/child1')), isTrue);
        expect(treeState.isExpanded(Uri.parse('file://root/child2')), isFalse); // No children
        expect(treeState.isExpanded(Uri.parse('file://root/child1/grandchild1')), isFalse); // No children
      });
    });

    group('collapseAll', () {
      test('should collapse all nodes', () {
        treeState.collapseAll();
        
        expect(treeState.expandedPaths, isEmpty);
        expect(treeState.isExpanded(Uri.parse('file://')), isFalse);
        expect(treeState.isExpanded(Uri.parse('file://root/child1')), isFalse);
      });
    });

    group('getVisibleNodes', () {
      test('should return only root when all collapsed', () {
        treeState.collapseAll();
        final visibleNodes = treeState.getVisibleNodes();
        expect(visibleNodes.length, equals(1));
        expect(visibleNodes.first.displayName, equals('file://'));
      });

      test('should include direct children when root is expanded', () {
        treeState.collapseAll();
        treeState.setExpanded(Uri.parse('file://'), expanded: true);
        final visibleNodes = treeState.getVisibleNodes();
        
        expect(visibleNodes.length, equals(2));
        expect(visibleNodes[0].displayName, equals('file://'));
        expect(visibleNodes[1].displayName, equals('root'));
      });

      test('should include grandchildren when multiple levels expanded', () {
        treeState.collapseAll();
        treeState.setExpanded(Uri.parse('file://'), expanded: true);
        treeState.setExpanded(Uri.parse('file://root'), expanded: true);
        treeState.setExpanded(Uri.parse('file://root/child1'), expanded: true);
        final visibleNodes = treeState.getVisibleNodes();
        
        expect(visibleNodes.length, equals(6));
        expect(visibleNodes[0].displayName, equals('file://'));
        expect(visibleNodes[1].displayName, equals('root'));
        expect(visibleNodes[2].displayName, equals('child1'));
        expect(visibleNodes[3].displayName, equals('child2'));
        expect(visibleNodes[4].displayName, equals('grandchild1'));
        expect(visibleNodes[5].displayName, equals('grandchild2'));
      });

      test('should update visibility after collapse', () {
        treeState.collapseAll();
        treeState.setExpanded(Uri.parse('file://'), expanded: true);
        treeState.setExpanded(Uri.parse('file://root'), expanded: true);
        treeState.setExpanded(Uri.parse('file://root/child1'), expanded: true);
        
        // Collapse child1
        treeState.setExpanded(Uri.parse('file://root/child1'), expanded: false);
        final visibleNodes = treeState.getVisibleNodes();
        
        expect(visibleNodes.length, equals(4));
        expect(visibleNodes.map((n) => n.displayName).toList(),
            equals(['file://', 'root', 'child1', 'child2']));
      });
    });

  });
}