import 'package:reorderable_tree_list_view/src/actions/tree_view_action.dart';
import 'package:reorderable_tree_list_view/src/core/keyboard_navigation_controller.dart';
import 'package:reorderable_tree_list_view/src/intents/tree_copy_intent.dart';

/// Action that copies the currently selected tree nodes.
class TreeCopyAction extends TreeViewAction<TreeCopyIntent> {
  /// Creates a TreeCopyAction.
  TreeCopyAction({
    required super.treeState,
    required this.keyboardController,
    this.onCopy,
  });

  /// The keyboard navigation controller to get current selection.
  final KeyboardNavigationController keyboardController;

  /// Optional callback for handling copy operations.
  ///
  /// If provided, this callback will be called with the paths to copy.
  final void Function(List<Uri> paths)? onCopy;

  @override
  bool isEnabled(TreeCopyIntent intent) =>
      // Enable if there are selected nodes
      keyboardController.selectedPaths.isNotEmpty;

  @override
  void performAction(TreeCopyIntent intent) {
    final List<Uri> pathsToCopy = keyboardController.selectedPaths.toList();
    if (pathsToCopy.isNotEmpty) {
      onCopy?.call(pathsToCopy);
    }
  }
}
