import 'package:reorderable_tree_list_view/src/actions/tree_view_action.dart';
import 'package:reorderable_tree_list_view/src/core/keyboard_navigation_controller.dart';
import 'package:reorderable_tree_list_view/src/intents/tree_delete_intent.dart';

/// Action that deletes the currently selected tree nodes.
class TreeDeleteAction extends TreeViewAction<TreeDeleteIntent> {
  /// Creates a TreeDeleteAction.
  TreeDeleteAction({
    required super.treeState,
    required this.keyboardController,
    this.onDelete,
  });

  /// The keyboard navigation controller to get current selection.
  final KeyboardNavigationController keyboardController;

  /// Optional callback for handling delete operations.
  ///
  /// If provided, this callback will be called with the paths to delete.
  final void Function(List<Uri> paths)? onDelete;

  @override
  bool isEnabled(TreeDeleteIntent intent) =>
      // Enable if there are selected nodes
      keyboardController.selectedPaths.isNotEmpty;

  @override
  void performAction(TreeDeleteIntent intent) {
    final List<Uri> pathsToDelete = keyboardController.selectedPaths.toList();
    if (pathsToDelete.isNotEmpty) {
      onDelete?.call(pathsToDelete);
    }
  }
}
