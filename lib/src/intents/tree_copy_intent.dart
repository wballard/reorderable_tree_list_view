import 'package:flutter/widgets.dart';

/// Intent to copy the currently selected tree nodes.
///
/// This intent represents the user's intention to copy the currently selected
/// nodes to the clipboard or internal buffer. The actual nodes to copy are
/// determined by the current selection state.
class TreeCopyIntent extends Intent {
  /// Creates a TreeCopyIntent.
  const TreeCopyIntent();
}
