import 'package:flutter/widgets.dart';

/// Intent to paste copied nodes.
///
/// This intent represents the user's intention to paste previously copied
/// nodes into a target location in the tree view, typically triggered by
/// Ctrl+V or context menu.
class PasteNodeIntent extends Intent {
  /// Creates a PasteNodeIntent.
  const PasteNodeIntent({
    required this.sourcePaths,
    required this.targetParent,
    this.move = false,
  });

  /// The paths of the nodes to paste.
  final List<Uri> sourcePaths;

  /// The parent path where the nodes should be pasted.
  final Uri targetParent;

  /// Whether this is a move operation (cut/paste) vs copy operation.
  final bool move;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PasteNodeIntent &&
          runtimeType == other.runtimeType &&
          sourcePaths == other.sourcePaths &&
          targetParent == other.targetParent &&
          move == other.move;

  @override
  int get hashCode => Object.hash(sourcePaths, targetParent, move);
}
