import 'package:reorderable_tree_list_view/src/actions/tree_view_action.dart';
import 'package:reorderable_tree_list_view/src/core/keyboard_navigation_controller.dart';
import 'package:reorderable_tree_list_view/src/intents/select_node_intent.dart';
import 'package:reorderable_tree_list_view/src/models/selection_mode.dart';

/// Action that handles selecting tree nodes.
///
/// This action manages node selection when a [SelectNodeIntent] is invoked.
/// The behavior depends on the selection mode and modifier keys.
class SelectNodeAction extends TreeViewAction<SelectNodeIntent> {
  /// Creates a SelectNodeAction.
  SelectNodeAction({
    required super.treeState,
    required this.keyboardController,
    required this.selectionMode,
  });

  /// The keyboard navigation controller that manages selection.
  final KeyboardNavigationController keyboardController;

  /// The current selection mode.
  final SelectionMode selectionMode;

  @override
  bool isEnabled(SelectNodeIntent intent) =>
      // Selection is only enabled when not in none mode
      selectionMode != SelectionMode.none &&
      treeState.getNodeByPath(intent.path) != null;

  @override
  void performAction(SelectNodeIntent intent) {
    if (selectionMode == SelectionMode.single) {
      // Single selection mode - replace current selection
      keyboardController.updateSelection(<Uri>{intent.path});
    } else if (selectionMode == SelectionMode.multiple) {
      if (intent.addToSelection) {
        // Add to or remove from selection (Ctrl+click behavior)
        final Set<Uri> currentSelection = Set<Uri>.from(
          keyboardController.selectedPaths,
        );
        if (currentSelection.contains(intent.path)) {
          currentSelection.remove(intent.path);
        } else {
          currentSelection.add(intent.path);
        }
        keyboardController.updateSelection(currentSelection);
      } else if (intent.rangeSelection) {
        // Range selection (Shift+click behavior)
        // This would require more complex logic with the last selected item
        // For now, just select the single item
        keyboardController.updateSelection(<Uri>{intent.path});
      } else {
        // Regular click - replace selection
        keyboardController.updateSelection(<Uri>{intent.path});
      }
    }
  }
}
