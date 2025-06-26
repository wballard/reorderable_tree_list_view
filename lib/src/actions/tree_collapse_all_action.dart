import 'package:reorderable_tree_list_view/src/actions/tree_view_action.dart';
import 'package:reorderable_tree_list_view/src/intents/tree_collapse_all_intent.dart';

/// Action that collapses all nodes in the tree view.
class TreeCollapseAllAction extends TreeViewAction<TreeCollapseAllIntent> {
  /// Creates a TreeCollapseAllAction.
  TreeCollapseAllAction({required super.treeState});

  @override
  void performAction(TreeCollapseAllIntent intent) {
    treeState.collapseAll();
  }
}
