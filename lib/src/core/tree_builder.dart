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
    
    // Process each path
    for (final Uri path in originalPaths) {
      // Add the original path as a leaf
      allPaths[path] = true;
      
      // Generate and add all intermediate paths as folders
      final List<Uri> intermediatePaths = TreePath.generateIntermediatePaths(path);
      for (final Uri intermediatePath in intermediatePaths) {
        // Only mark as folder if it's not also an original path
        allPaths.putIfAbsent(intermediatePath, () => false);
      }
    }
    
    // Create TreeNode instances
    final List<TreeNode> nodes = <TreeNode>[];
    for (final MapEntry<Uri, bool> entry in allPaths.entries) {
      nodes.add(TreeNode(
        path: entry.key,
        isLeaf: entry.value,
      ));
    }
    
    // Sort nodes
    _sortNodes(nodes);
    
    return nodes;
  }
  
  /// Sorts nodes in hierarchical order.
  /// 
  /// Sorting rules:
  /// 1. Parents always come before their children
  /// 2. Within the same parent, sort by scheme first
  /// 3. Then sort alphabetically by display name
  static void _sortNodes(List<TreeNode> nodes) {
    nodes.sort((TreeNode a, TreeNode b) {
      // First, ensure hierarchical order (parents before children)
      if (TreePath.isAncestorOf(a.path, b.path)) {
        return -1; // a is ancestor of b, so a comes first
      }
      if (TreePath.isAncestorOf(b.path, a.path)) {
        return 1; // b is ancestor of a, so b comes first
      }
      
      // If they're not in a parent-child relationship, compare depths
      final int depthDiff = a.depth - b.depth;
      if (depthDiff != 0) {
        return depthDiff; // Shallower nodes come first
      }
      
      // Same depth, not parent-child - they must be siblings or in different branches
      // First sort by scheme
      final int schemeCompare = a.path.scheme.compareTo(b.path.scheme);
      if (schemeCompare != 0) {
        return schemeCompare;
      }
      
      // Same scheme, compare full paths for consistent ordering
      // This ensures siblings are sorted alphabetically
      return _comparePaths(a.path, b.path);
    });
  }
  
  /// Compares two paths segment by segment for sorting.
  static int _comparePaths(Uri a, Uri b) {
    final List<String> aSegments = TreePath.calculateDepth(a) == 0 
        ? <String>[] 
        : _getPathSegments(a);
    final List<String> bSegments = TreePath.calculateDepth(b) == 0 
        ? <String>[] 
        : _getPathSegments(b);
    
    // Compare segment by segment
    final int minLength = aSegments.length < bSegments.length 
        ? aSegments.length 
        : bSegments.length;
    
    for (int i = 0; i < minLength; i++) {
      final int compare = aSegments[i].toLowerCase().compareTo(bSegments[i].toLowerCase());
      if (compare != 0) {
        return compare;
      }
    }
    
    // If all segments match, shorter path comes first
    return aSegments.length - bSegments.length;
  }
  
  /// Gets all segments of a path including host for certain schemes.
  static List<String> _getPathSegments(Uri path) {
    final List<String> segments = <String>[];
    
    // For non-standard web protocols, include host as first segment
    if (path.host.isNotEmpty && 
        !<String>['http', 'https', 'ftp', 'ws', 'wss'].contains(path.scheme)) {
      segments.add(path.host);
    }
    
    segments.addAll(path.pathSegments.where((String s) => s.isNotEmpty));
    return segments;
  }
}