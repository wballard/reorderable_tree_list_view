import 'package:flutter/widgets.dart';

/// Intent to select a tree node.
///
/// This intent represents the user's intention to select or toggle selection
/// of a node in the tree view. The behavior depends on the current selection mode
/// and modifier keys pressed.
class SelectNodeIntent extends Intent {
  /// Creates a SelectNodeIntent.
  const SelectNodeIntent(
    this.path, {
    this.addToSelection = false,
    this.rangeSelection = false,
  });

  /// The path of the node to select.
  final Uri path;

  /// Whether to add this node to the current selection (Ctrl+click behavior).
  final bool addToSelection;

  /// Whether this is a range selection (Shift+click behavior).
  final bool rangeSelection;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectNodeIntent &&
          runtimeType == other.runtimeType &&
          path == other.path &&
          addToSelection == other.addToSelection &&
          rangeSelection == other.rangeSelection;

  @override
  int get hashCode => Object.hash(path, addToSelection, rangeSelection);
}
