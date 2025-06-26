import 'package:flutter/widgets.dart';

/// Intent to collapse a tree node.
///
/// This intent represents the user's intention to collapse an expanded folder node
/// in the tree view. The [path] specifies which node should be collapsed.
class CollapseNodeIntent extends Intent {
  /// Creates a CollapseNodeIntent.
  const CollapseNodeIntent(this.path);

  /// The path of the node to collapse.
  final Uri path;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollapseNodeIntent &&
          runtimeType == other.runtimeType &&
          path == other.path;

  @override
  int get hashCode => path.hashCode;
}
