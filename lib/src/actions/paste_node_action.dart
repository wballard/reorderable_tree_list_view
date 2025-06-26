import 'package:reorderable_tree_list_view/src/actions/tree_view_action.dart';
import 'package:reorderable_tree_list_view/src/intents/paste_node_intent.dart';
import 'package:reorderable_tree_list_view/src/models/tree_node.dart';

/// Action that handles pasting tree nodes.
///
/// This action is invoked when a user wants to paste previously copied
/// nodes into a target location. Since tree views typically don't manage
/// clipboard operations directly, this serves as a hook for parent widgets.
class PasteNodeAction extends TreeViewAction<PasteNodeIntent> {
  /// Creates a PasteNodeAction.
  PasteNodeAction({required super.treeState, this.onPaste});

  /// Optional callback for handling paste operations.
  ///
  /// If provided, this callback will be called with the paste details.
  final void Function(
    List<Uri> sourcePaths,
    Uri targetParent, {
    required bool move,
  })?
  onPaste;

  @override
  bool isEnabled(PasteNodeIntent intent) {
    // Check that target parent exists and is a folder (or root)
    final TreeNode? targetNode = treeState.getNodeByPath(intent.targetParent);
    if (targetNode != null && targetNode.isLeaf) {
      return false; // Can't paste into a leaf node
    }

    // Check that source paths exist (if not a move operation)
    if (!intent.move) {
      for (final Uri path in intent.sourcePaths) {
        if (treeState.getNodeByPath(path) == null) {
          return false;
        }
      }
    }

    return intent.sourcePaths.isNotEmpty && onPaste != null;
  }

  @override
  void performAction(PasteNodeIntent intent) {
    onPaste?.call(intent.sourcePaths, intent.targetParent, move: intent.move);
  }
}
