import 'package:reorderable_tree_list_view/src/actions/tree_view_action.dart';
import 'package:reorderable_tree_list_view/src/intents/delete_node_intent.dart';

/// Action that handles deleting tree nodes.
///
/// This action is invoked when a user wants to delete one or more nodes.
/// Since tree views typically don't modify data directly, this action
/// primarily serves as a hook for parent widgets to handle deletion.
class DeleteNodeAction extends TreeViewAction<DeleteNodeIntent> {
  /// Creates a DeleteNodeAction.
  DeleteNodeAction({required super.treeState, this.onDelete});

  /// Optional callback for handling delete operations.
  ///
  /// If provided, this callback will be called with the paths to delete.
  final void Function(List<Uri> paths)? onDelete;

  @override
  bool isEnabled(DeleteNodeIntent intent) {
    final List<Uri> pathsToDelete = intent.allPaths;

    // Check that all paths exist in the tree
    for (final Uri path in pathsToDelete) {
      if (treeState.getNodeByPath(path) == null) {
        return false;
      }
    }

    return pathsToDelete.isNotEmpty && onDelete != null;
  }

  @override
  void performAction(DeleteNodeIntent intent) {
    onDelete?.call(intent.allPaths);
  }
}
