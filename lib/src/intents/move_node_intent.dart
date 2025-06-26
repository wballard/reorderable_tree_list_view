import 'package:flutter/widgets.dart';

/// Intent to move a tree node.
///
/// This intent represents the user's intention to move a node from one location
/// to another in the tree view, typically triggered by drag-and-drop operations
/// or cut/paste operations.
class MoveNodeIntent extends Intent {
  /// Creates a MoveNodeIntent.
  const MoveNodeIntent({required this.oldPath, required this.newPath});

  /// The current path of the node to move.
  final Uri oldPath;

  /// The new path where the node should be moved.
  final Uri newPath;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoveNodeIntent &&
          runtimeType == other.runtimeType &&
          oldPath == other.oldPath &&
          newPath == other.newPath;

  @override
  int get hashCode => Object.hash(oldPath, newPath);
}
