import 'package:flutter/widgets.dart';

/// Intent to expand a tree node.
///
/// This intent represents the user's intention to expand a collapsed folder node
/// in the tree view. The [path] specifies which node should be expanded.
class ExpandNodeIntent extends Intent {
  /// Creates an ExpandNodeIntent.
  const ExpandNodeIntent(this.path);

  /// The path of the node to expand.
  final Uri path;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpandNodeIntent &&
          runtimeType == other.runtimeType &&
          path == other.path;

  @override
  int get hashCode => path.hashCode;
}
