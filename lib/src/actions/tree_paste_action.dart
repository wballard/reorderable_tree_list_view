import 'package:reorderable_tree_list_view/src/actions/tree_view_action.dart';
import 'package:reorderable_tree_list_view/src/core/keyboard_navigation_controller.dart';
import 'package:reorderable_tree_list_view/src/intents/tree_paste_intent.dart';
import 'package:reorderable_tree_list_view/src/models/tree_node.dart';
import 'package:reorderable_tree_list_view/src/models/tree_path.dart';

/// Action that pastes copied nodes at the current location.
class TreePasteAction extends TreeViewAction<TreePasteIntent> {
  /// Creates a TreePasteAction.
  TreePasteAction({
    required super.treeState,
    required this.keyboardController,
    this.onPaste,
    this.copiedPaths = const <Uri>[],
  });

  /// The keyboard navigation controller to get current focus.
  final KeyboardNavigationController keyboardController;

  /// Optional callback for handling paste operations.
  ///
  /// If provided, this callback will be called with the source paths, target parent, and move flag.
  final void Function(
    List<Uri> sourcePaths,
    Uri targetParent, {
    required bool move,
  })?
  onPaste;

  /// The currently copied paths (would typically be managed by parent widget).
  final List<Uri> copiedPaths;

  @override
  bool isEnabled(TreePasteIntent intent) =>
      // Enable if there are copied paths and a focused location
      copiedPaths.isNotEmpty && keyboardController.focusedPath != null;

  @override
  void performAction(TreePasteIntent intent) {
    if (copiedPaths.isEmpty || keyboardController.focusedPath == null) {
      return;
    }

    final Uri focusedPath = keyboardController.focusedPath!;
    final TreeNode? focusedNode = treeState.getNodeByPath(focusedPath);

    if (focusedNode == null) {
      return;
    }

    // Determine target parent path
    final Uri targetParent;
    if (focusedNode.isLeaf) {
      // If focused on a file, paste to its parent directory
      targetParent =
          TreePath.getParentPath(focusedPath) ?? Uri.parse('file://');
    } else {
      // If focused on a folder, paste into that folder
      targetParent = focusedPath;
    }

    onPaste?.call(copiedPaths, targetParent, move: false);
  }
}
