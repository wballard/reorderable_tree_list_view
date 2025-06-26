import 'package:flutter/widgets.dart';

/// Intent to paste copied nodes at the current location.
///
/// This intent represents the user's intention to paste previously copied
/// nodes. The target location is determined by the current focus or selection.
class TreePasteIntent extends Intent {
  /// Creates a TreePasteIntent.
  const TreePasteIntent();
}
