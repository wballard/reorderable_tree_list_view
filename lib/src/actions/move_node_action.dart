import 'package:reorderable_tree_list_view/src/actions/tree_view_action.dart';
import 'package:reorderable_tree_list_view/src/core/drag_drop_handler.dart';
import 'package:reorderable_tree_list_view/src/intents/move_node_intent.dart';
import 'package:reorderable_tree_list_view/src/models/tree_node.dart';
import 'package:reorderable_tree_list_view/src/models/tree_path.dart';

/// Action that handles moving tree nodes.
///
/// This action validates and performs node moves when a [MoveNodeIntent]
/// is invoked, typically from drag-and-drop operations.
class MoveNodeAction extends TreeViewAction<MoveNodeIntent> {
  /// Creates a MoveNodeAction.
  MoveNodeAction({
    required super.treeState,
    this.onMove,
    this.onWillAcceptDrop,
  });

  /// Optional callback for handling move operations.
  ///
  /// If provided, this callback will be called with the validated move.
  final void Function(Uri oldPath, Uri newPath)? onMove;

  /// Optional callback for validating moves.
  ///
  /// If provided, this callback can reject moves by returning false.
  final bool Function(Uri oldPath, Uri newPath)? onWillAcceptDrop;

  @override
  bool isEnabled(MoveNodeIntent intent) {
    final TreeNode? draggedNode = treeState.getNodeByPath(intent.oldPath);
    if (draggedNode == null) {
      return false;
    }

    // Validate the move
    final Uri targetParentPath =
        TreePath.getParentPath(intent.newPath) ?? Uri.parse('file://');
    final DropValidationResult validation = DragDropHandler.validateDrop(
      draggedNode: draggedNode,
      targetParentPath: targetParentPath,
      allNodes: treeState.allNodes,
    );

    if (!validation.isValid) {
      return false;
    }

    // Check with external validator if provided
    if (onWillAcceptDrop != null) {
      return onWillAcceptDrop!(intent.oldPath, intent.newPath);
    }

    return true;
  }

  @override
  void performAction(MoveNodeIntent intent) {
    onMove?.call(intent.oldPath, intent.newPath);
    // Note: The actual tree state update would typically be handled
    // by the parent widget that provides the onMove callback
  }
}
