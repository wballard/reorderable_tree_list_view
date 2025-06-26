import 'package:reorderable_tree_list_view/src/actions/tree_view_action.dart';
import 'package:reorderable_tree_list_view/src/core/keyboard_navigation_controller.dart';
import 'package:reorderable_tree_list_view/src/intents/tree_select_all_intent.dart';
import 'package:reorderable_tree_list_view/src/models/selection_mode.dart';
import 'package:reorderable_tree_list_view/src/models/tree_node.dart';

/// Action that selects all visible nodes in the tree view.
class TreeSelectAllAction extends TreeViewAction<TreeSelectAllIntent> {
  /// Creates a TreeSelectAllAction.
  TreeSelectAllAction({
    required super.treeState,
    required this.keyboardController,
    required this.selectionMode,
  });

  /// The keyboard navigation controller.
  final KeyboardNavigationController keyboardController;

  /// The selection mode for the tree view.
  final SelectionMode selectionMode;

  @override
  bool isEnabled(TreeSelectAllIntent intent) =>
      // Only enable if selection is allowed
      selectionMode != SelectionMode.none;

  @override
  void performAction(TreeSelectAllIntent intent) {
    if (selectionMode == SelectionMode.none) {
      return;
    }

    // Get all visible nodes
    final List<TreeNode> visibleNodes = treeState.getVisibleNodes();
    final Set<Uri> visiblePaths = visibleNodes
        .map((TreeNode node) => node.path)
        .toSet();

    // Select all visible nodes
    keyboardController.updateSelection(visiblePaths);
  }
}
