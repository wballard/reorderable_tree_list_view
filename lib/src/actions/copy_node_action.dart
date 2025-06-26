import 'package:reorderable_tree_list_view/src/actions/tree_view_action.dart';
import 'package:reorderable_tree_list_view/src/intents/copy_node_intent.dart';

/// Action that handles copying tree nodes.
///
/// This action is invoked when a user wants to copy one or more nodes
/// to a clipboard or internal buffer. Since tree views typically don't
/// manage clipboard operations directly, this serves as a hook for
/// parent widgets to handle copying.
class CopyNodeAction extends TreeViewAction<CopyNodeIntent> {
  /// Creates a CopyNodeAction.
  CopyNodeAction({required super.treeState, this.onCopy});

  /// Optional callback for handling copy operations.
  ///
  /// If provided, this callback will be called with the paths to copy.
  final void Function(List<Uri> paths)? onCopy;

  @override
  bool isEnabled(CopyNodeIntent intent) {
    final List<Uri> pathsToCopy = intent.allPaths;

    // Check that all paths exist in the tree
    for (final Uri path in pathsToCopy) {
      if (treeState.getNodeByPath(path) == null) {
        return false;
      }
    }

    return pathsToCopy.isNotEmpty;
  }

  @override
  void performAction(CopyNodeIntent intent) {
    onCopy?.call(intent.allPaths);
  }
}
