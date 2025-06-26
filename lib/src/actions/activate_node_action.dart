import 'package:reorderable_tree_list_view/src/actions/tree_view_action.dart';
import 'package:reorderable_tree_list_view/src/intents/activate_node_intent.dart';
import 'package:reorderable_tree_list_view/src/models/tree_node.dart';

/// Action that handles activating tree nodes.
///
/// This action is invoked when a user activates a node (via Enter, Space,
/// or double-click). The default behavior is to expand/collapse folders,
/// but this can be overridden by parent widgets to provide custom activation.
class ActivateNodeAction extends TreeViewAction<ActivateNodeIntent> {
  /// Creates an ActivateNodeAction.
  ActivateNodeAction({required super.treeState, this.onActivate});

  /// Optional callback for custom activation handling.
  ///
  /// If provided, this callback will be called instead of the default behavior.
  final void Function(Uri path)? onActivate;

  @override
  bool isEnabled(ActivateNodeIntent intent) =>
      treeState.getNodeByPath(intent.path) != null;

  @override
  void performAction(ActivateNodeIntent intent) {
    if (onActivate != null) {
      // Custom activation handling
      onActivate!(intent.path);
    } else {
      // Default behavior: toggle expansion for folders
      final TreeNode? node = treeState.getNodeByPath(intent.path);
      if (node != null && !node.isLeaf) {
        treeState.toggleExpanded(intent.path);
      }
    }
  }
}
