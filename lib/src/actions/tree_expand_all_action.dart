import 'package:reorderable_tree_list_view/src/actions/tree_view_action.dart';
import 'package:reorderable_tree_list_view/src/intents/tree_expand_all_intent.dart';

/// Action that expands all nodes in the tree view.
class TreeExpandAllAction extends TreeViewAction<TreeExpandAllIntent> {
  /// Creates a TreeExpandAllAction.
  TreeExpandAllAction({required super.treeState});

  @override
  void performAction(TreeExpandAllIntent intent) {
    treeState.expandAll();
  }
}
