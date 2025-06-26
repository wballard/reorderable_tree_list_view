import 'package:reorderable_tree_list_view/src/models/tree_node.dart';

/// Manages the state of a tree structure.
/// 
/// This class holds the complete list of TreeNodes and provides methods
/// for querying the tree structure and managing expansion state.
class TreeState {
  /// Creates a TreeState from a list of TreeNodes.
  TreeState(List<TreeNode> nodes) 
    : allNodes = List<TreeNode>.unmodifiable(nodes) {
    // Build lookup map for quick access
    for (final TreeNode node in allNodes) {
      _nodeMap[node.path] = node;
    }
    
    // Build parent-child relationships
    for (final TreeNode node in allNodes) {
      final Uri? parentPath = node.parentPath;
      if (parentPath != null) {
        _childrenMap.putIfAbsent(parentPath, () => <TreeNode>[]).add(node);
      }
    }
    
    // Sort children lists
    for (final List<TreeNode> children in _childrenMap.values) {
      children.sort(_compareNodes);
    }
    
    // All folders are expanded by default
    for (final TreeNode node in allNodes) {
      if (!node.isLeaf) {
        _expandedPaths.add(node.path);
      }
    }
  }
  
  /// All nodes in the tree, in hierarchical order.
  final List<TreeNode> allNodes;
  
  // Private maps for efficient lookups
  final Map<Uri, TreeNode> _nodeMap = <Uri, TreeNode>{};
  final Map<Uri, List<TreeNode>> _childrenMap = <Uri, List<TreeNode>>{};
  final Set<Uri> _expandedPaths = <Uri>{};
  
  /// Set of paths that are currently expanded.
  /// 
  /// This allows external code to track which nodes are expanded.
  Set<Uri> get expandedPaths => Set<Uri>.unmodifiable(_expandedPaths);
  
  /// Gets a node by its path.
  /// 
  /// Returns null if no node exists at the given path.
  TreeNode? getNodeByPath(Uri path) => _nodeMap[path];
  
  /// Gets the immediate children of a node.
  /// 
  /// Returns an empty list if the node has no children or doesn't exist.
  List<TreeNode> getChildren(Uri path) => _childrenMap[path] ?? <TreeNode>[];
  
  /// Gets all nodes that should be visible based on expansion state.
  /// 
  /// This includes all nodes whose ancestors are all expanded.
  List<TreeNode> getVisibleNodes() {
    final List<TreeNode> visibleNodes = <TreeNode>[];
    
    for (final TreeNode node in allNodes) {
      if (_isNodeVisible(node)) {
        visibleNodes.add(node);
      }
    }
    
    return visibleNodes;
  }
  
  /// Checks if a folder node is expanded.
  /// 
  /// Always returns true for leaf nodes.
  bool isExpanded(Uri path) => _expandedPaths.contains(path);
  
  /// Sets the expansion state of a folder node.
  /// 
  /// Has no effect on leaf nodes.
  void setExpanded(Uri path, {required bool expanded}) {
    final TreeNode? node = _nodeMap[path];
    if (node != null && !node.isLeaf) {
      if (expanded) {
        _expandedPaths.add(path);
      } else {
        _expandedPaths.remove(path);
      }
    }
  }
  
  /// Toggles the expansion state of a folder node.
  /// 
  /// Has no effect on leaf nodes.
  void toggleExpanded(Uri path) {
    setExpanded(path, expanded: !isExpanded(path));
  }
  
  /// Collapses all folder nodes.
  void collapseAll() {
    _expandedPaths.clear();
  }
  
  /// Expands all folder nodes.
  void expandAll() {
    for (final TreeNode node in allNodes) {
      if (!node.isLeaf) {
        _expandedPaths.add(node.path);
      }
    }
  }
  
  /// Checks if a node should be visible based on expansion state.
  bool _isNodeVisible(TreeNode node) {
    // Root nodes are always visible
    if (node.depth == 0) {
      return true;
    }
    
    // Check if all ancestors are expanded
    Uri? currentPath = node.parentPath;
    while (currentPath != null) {
      if (!isExpanded(currentPath)) {
        return false;
      }
      
      final TreeNode? parentNode = _nodeMap[currentPath];
      if (parentNode == null) {
        break;
      }
      
      currentPath = parentNode.parentPath;
    }
    
    return true;
  }
  
  /// Compares two nodes for sorting.
  static int _compareNodes(TreeNode a, TreeNode b) =>
      a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
}