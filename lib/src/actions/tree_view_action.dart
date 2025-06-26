import 'package:flutter/widgets.dart';
import 'package:reorderable_tree_list_view/src/core/tree_state.dart';

/// Base class for all tree view actions.
///
/// This provides a common interface for tree actions and gives access
/// to the tree state for performing operations.
abstract class TreeViewAction<T extends Intent> extends Action<T> {
  /// Creates a TreeViewAction.
  TreeViewAction({required this.treeState});

  /// The tree state this action operates on.
  final TreeState treeState;

  @override
  bool isEnabled(T intent) => true;

  @override
  void invoke(T intent) {
    if (isEnabled(intent)) {
      performAction(intent);
    }
  }

  /// Performs the specific action for this intent.
  ///
  /// Subclasses must implement this method to define their behavior.
  void performAction(T intent);
}
