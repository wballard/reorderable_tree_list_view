import 'package:flutter/widgets.dart';

/// Intent to activate a tree node.
///
/// This intent represents the user's intention to activate a node in the tree view,
/// typically triggered by Enter key, Space key, or double-click. Activation usually
/// means opening/executing the item or performing the default action.
class ActivateNodeIntent extends Intent {
  /// Creates an ActivateNodeIntent.
  const ActivateNodeIntent(this.path);

  /// The path of the node to activate.
  final Uri path;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivateNodeIntent &&
          runtimeType == other.runtimeType &&
          path == other.path;

  @override
  int get hashCode => path.hashCode;
}
