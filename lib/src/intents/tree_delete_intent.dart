import 'package:flutter/widgets.dart';

/// Intent to delete the currently selected tree nodes.
///
/// This intent represents the user's intention to delete the currently selected
/// nodes. The actual nodes to delete are determined by the current selection state.
class TreeDeleteIntent extends Intent {
  /// Creates a TreeDeleteIntent.
  const TreeDeleteIntent();
}
