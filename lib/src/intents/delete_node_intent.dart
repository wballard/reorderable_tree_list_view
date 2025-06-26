import 'package:flutter/widgets.dart';

/// Intent to delete a tree node.
///
/// This intent represents the user's intention to delete one or more nodes
/// from the tree view, typically triggered by the Delete key or context menu.
class DeleteNodeIntent extends Intent {
  /// Creates a DeleteNodeIntent for a single node.
  const DeleteNodeIntent(this.path) : paths = const <Uri>[];

  /// Creates a DeleteNodeIntent for multiple nodes.
  const DeleteNodeIntent.multiple(this.paths) : path = null;

  /// The path of the single node to delete (if deleting one node).
  final Uri? path;

  /// The paths of multiple nodes to delete (if deleting multiple nodes).
  final List<Uri> paths;

  /// Gets all paths to delete (handles both single and multiple deletion).
  List<Uri> get allPaths => path != null ? <Uri>[path!] : paths;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeleteNodeIntent &&
          runtimeType == other.runtimeType &&
          path == other.path &&
          paths == other.paths;

  @override
  int get hashCode => Object.hash(path, paths);
}
