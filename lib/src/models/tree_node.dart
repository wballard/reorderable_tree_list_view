import 'package:flutter/foundation.dart';
import 'package:reorderable_tree_list_view/src/models/tree_path.dart';

/// Represents a node in the tree structure.
///
/// Each node is identified by a [Uri] path and can be either a leaf node
/// (representing an actual item from the input paths) or a folder node
/// (generated to fill gaps in the tree structure).
///
/// Example:
/// ```dart
/// final node = TreeNode(
///   path: Uri.parse('file://var/data/readme.txt'),
///   isLeaf: true,
/// );
/// print(node.displayName); // 'readme.txt'
/// print(node.depth); // 3
/// ```
@immutable
class TreeNode {
  /// Creates a tree node with the given path and leaf status.
  TreeNode({required this.path, required this.isLeaf})
    : key = path.toString(),
      depth = TreePath.calculateDepth(path);

  /// The full URI path for this node.
  ///
  /// This uniquely identifies the node in the tree structure.
  final Uri path;

  /// The depth of this node in the tree (0 for root).
  ///
  /// Calculated based on the number of path segments.
  /// - Root nodes (e.g., 'file://') have depth 0
  /// - Direct children of root have depth 1
  /// - And so on...
  final int depth;

  /// Whether this is a leaf node (from original paths).
  ///
  /// - `true`: This node was in the original list of paths
  /// - `false`: This node was generated as an intermediate folder
  final bool isLeaf;

  /// Unique key for use with ReorderableListView.
  ///
  /// This is the string representation of the path URI.
  final String key;

  /// Gets the display name for this node.
  ///
  /// - For root nodes: Returns the full scheme (e.g., 'file://')
  /// - For other nodes: Returns the last path segment
  String get displayName => TreePath.getDisplayName(path);

  /// Gets the parent path of this node.
  ///
  /// Returns `null` if this is a root node.
  Uri? get parentPath => TreePath.getParentPath(path);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TreeNode &&
          runtimeType == other.runtimeType &&
          path == other.path &&
          isLeaf == other.isLeaf;

  @override
  int get hashCode => path.hashCode ^ isLeaf.hashCode;

  @override
  String toString() => 'TreeNode(path: $path, depth: $depth, isLeaf: $isLeaf)';
}
