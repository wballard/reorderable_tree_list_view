import 'package:flutter/widgets.dart';

/// Intent to copy a tree node.
///
/// This intent represents the user's intention to copy one or more nodes
/// to the clipboard or internal copy buffer, typically triggered by Ctrl+C
/// or context menu.
class CopyNodeIntent extends Intent {
  /// Creates a CopyNodeIntent for a single node.
  const CopyNodeIntent(this.path) : paths = const <Uri>[];

  /// Creates a CopyNodeIntent for multiple nodes.
  const CopyNodeIntent.multiple(this.paths) : path = null;

  /// The path of the single node to copy (if copying one node).
  final Uri? path;

  /// The paths of multiple nodes to copy (if copying multiple nodes).
  final List<Uri> paths;

  /// Gets all paths to copy (handles both single and multiple copying).
  List<Uri> get allPaths => path != null ? <Uri>[path!] : paths;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CopyNodeIntent &&
          runtimeType == other.runtimeType &&
          path == other.path &&
          paths == other.paths;

  @override
  int get hashCode => Object.hash(path, paths);
}
