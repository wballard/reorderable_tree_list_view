import 'package:reorderable_tree_list_view/src/actions/tree_view_action.dart';
import 'package:reorderable_tree_list_view/src/intents/expand_node_intent.dart';
import 'package:reorderable_tree_list_view/src/models/tree_node.dart';

/// Action that handles expanding tree nodes.
///
/// This action expands a collapsed folder node when an [ExpandNodeIntent]
/// is invoked. It only affects folder nodes and has no effect on leaf nodes.
class ExpandNodeAction extends TreeViewAction<ExpandNodeIntent> {
  /// Creates an ExpandNodeAction.
  ExpandNodeAction({required super.treeState});

  @override
  bool isEnabled(ExpandNodeIntent intent) {
    final TreeNode? node = treeState.getNodeByPath(intent.path);
    // Only enable for folder nodes that are currently collapsed
    return node != null && !node.isLeaf && !treeState.isExpanded(intent.path);
  }

  @override
  void performAction(ExpandNodeIntent intent) {
    treeState.setExpanded(intent.path, expanded: true);
  }
}
