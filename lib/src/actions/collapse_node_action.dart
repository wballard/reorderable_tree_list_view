import 'package:reorderable_tree_list_view/src/actions/tree_view_action.dart';
import 'package:reorderable_tree_list_view/src/intents/collapse_node_intent.dart';
import 'package:reorderable_tree_list_view/src/models/tree_node.dart';

/// Action that handles collapsing tree nodes.
///
/// This action collapses an expanded folder node when a [CollapseNodeIntent]
/// is invoked. It only affects folder nodes and has no effect on leaf nodes.
class CollapseNodeAction extends TreeViewAction<CollapseNodeIntent> {
  /// Creates a CollapseNodeAction.
  CollapseNodeAction({required super.treeState});

  @override
  bool isEnabled(CollapseNodeIntent intent) {
    final TreeNode? node = treeState.getNodeByPath(intent.path);
    // Only enable for folder nodes that are currently expanded
    return node != null && !node.isLeaf && treeState.isExpanded(intent.path);
  }

  @override
  void performAction(CollapseNodeIntent intent) {
    treeState.setExpanded(intent.path, expanded: false);
  }
}
