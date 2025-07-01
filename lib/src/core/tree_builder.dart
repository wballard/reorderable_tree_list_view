import 'package:reorderable_tree_list_view/src/models/tree_node.dart';
import 'package:reorderable_tree_list_view/src/models/tree_path.dart';

/// Builds a complete tree structure from a sparse list of URI paths.
///
/// This class handles the creation of intermediate folder nodes and
/// ensures proper sorting of the resulting tree structure.
class TreeBuilder {
  // Private constructor to prevent instantiation
  TreeBuilder._();

  /// Builds a complete tree from a sparse list of URI paths.
  ///
  /// Takes a list of URIs and:
  /// - Generates all intermediate paths
  /// - Creates TreeNode instances for each unique path
  /// - Marks original paths as leaves (isLeaf = true)
  /// - Marks generated intermediate paths as folders (isLeaf = false)
  /// - Sorts nodes in hierarchical order
  ///
  /// Example:
  /// ```dart
  /// final paths = [
  ///   Uri.parse('file://var/data/readme.txt'),
  ///   Uri.parse('file://var/config.json'),
  /// ];
  /// final nodes = TreeBuilder.buildFromPaths(paths);
  /// // Returns nodes for: file://, file://var, file://var/config.json,
  /// // file://var/data, file://var/data/readme.txt
  /// ```
  static List<TreeNode> buildFromPaths(List<Uri> paths) {
    if (paths.isEmpty) {
      return <TreeNode>[];
    }

    // Create a set to track original paths (these will be leaves)
    final Set<Uri> originalPaths = paths.toSet();

    // Create a map to store all unique paths and their leaf status
    final Map<Uri, bool> allPaths = <Uri, bool>{};

    // First, collect all intermediate paths to identify folders
    final Set<Uri> allIntermediatePaths = <Uri>{};
    for (final Uri path in originalPaths) {
      final List<Uri> intermediatePaths = TreePath.generateIntermediatePaths(path);
      allIntermediatePaths.addAll(intermediatePaths);
    }

    // Process each path
    for (final Uri path in originalPaths) {
      // A path is a leaf only if:
      // 1. It's in the original paths list AND
      // 2. It's NOT an intermediate path for any other path
      final bool isLeaf = !allIntermediatePaths.contains(path);
      allPaths[path] = isLeaf;

      // Generate and add all intermediate paths as folders
      final List<Uri> intermediatePaths = TreePath.generateIntermediatePaths(path);
      for (final Uri intermediatePath in intermediatePaths) {
        // Intermediate paths are always folders
        allPaths.putIfAbsent(intermediatePath, () => false);
      }
    }

    // Create TreeNode instances
    final List<TreeNode> nodes = <TreeNode>[];
    for (final MapEntry<Uri, bool> entry in allPaths.entries) {
      nodes.add(TreeNode(path: entry.key, isLeaf: entry.value));
    }

    // Sort nodes
    _sortNodes(nodes);

    return nodes;
  }

  /// Sorts nodes in hierarchical order.
  ///
  /// Sorting rules:
  /// 1. Parents always come before their children
  /// 2. Children appear immediately after their parent
  /// 3. Within the same parent, sort alphabetically by display name
  static void _sortNodes(List<TreeNode> nodes) {
    // Create a map to quickly find children of each node
    final Map<Uri, List<TreeNode>> childrenMap = <Uri, List<TreeNode>>{};
    final Set<TreeNode> processedNodes = <TreeNode>{};
    
    // Build parent-child relationships
    for (final TreeNode node in nodes) {
      final Uri? parentPath = node.parentPath;
      if (parentPath != null) {
        childrenMap.putIfAbsent(parentPath, () => <TreeNode>[]).add(node);
      }
    }
    
    // Sort children within each parent
    for (final List<TreeNode> children in childrenMap.values) {
      children.sort((TreeNode a, TreeNode b) {
        // First by scheme
        final int schemeCompare = a.path.scheme.compareTo(b.path.scheme);
        if (schemeCompare != 0) return schemeCompare;
        
        // Then alphabetically by display name
        return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
      });
    }
    
    // Rebuild the list in hierarchical order
    final List<TreeNode> sortedNodes = <TreeNode>[];
    
    // Find root nodes (nodes with no parent)
    final List<TreeNode> rootNodes = nodes.where((node) => node.parentPath == null).toList();
    rootNodes.sort((TreeNode a, TreeNode b) {
      // First by scheme
      final int schemeCompare = a.path.scheme.compareTo(b.path.scheme);
      if (schemeCompare != 0) return schemeCompare;
      
      // Then alphabetically
      return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
    });
    
    // Recursively add nodes in hierarchical order
    void addNodeAndChildren(TreeNode node) {
      if (processedNodes.contains(node)) return;
      
      sortedNodes.add(node);
      processedNodes.add(node);
      
      // Add children immediately after parent
      final List<TreeNode> children = childrenMap[node.path] ?? <TreeNode>[];
      for (final TreeNode child in children) {
        addNodeAndChildren(child);
      }
    }
    
    // Process all root nodes and their descendants
    for (final TreeNode rootNode in rootNodes) {
      addNodeAndChildren(rootNode);
    }
    
    // Replace the original list with the sorted one
    nodes.clear();
    nodes.addAll(sortedNodes);
  }
}
