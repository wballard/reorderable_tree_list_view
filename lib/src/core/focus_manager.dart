import 'package:flutter/material.dart';

/// Manages focus nodes for tree items.
class TreeFocusManager {
  /// Creates a tree focus manager.
  TreeFocusManager();

  final Map<Uri, FocusNode> _focusNodes = <Uri, FocusNode>{};

  /// Gets or creates a focus node for a path.
  FocusNode getFocusNode(Uri path) =>
      _focusNodes.putIfAbsent(path, FocusNode.new);

  /// Requests focus for a specific path.
  void requestFocus(Uri path) {
    getFocusNode(path).requestFocus();
  }

  /// Gets the currently focused path.
  Uri? get focusedPath {
    for (final MapEntry<Uri, FocusNode> entry in _focusNodes.entries) {
      if (entry.value.hasFocus) {
        return entry.key;
      }
    }
    return null;
  }

  /// Checks if a path is focused.
  bool isFocused(Uri path) {
    final FocusNode? node = _focusNodes[path];
    return node?.hasFocus ?? false;
  }

  /// Cleans up focus nodes that are no longer needed.
  void cleanup(Set<Uri> activePaths) {
    final List<Uri> toRemove = <Uri>[];
    for (final Uri path in _focusNodes.keys) {
      if (!activePaths.contains(path)) {
        toRemove.add(path);
      }
    }
    for (final Uri path in toRemove) {
      _focusNodes[path]?.dispose();
      _focusNodes.remove(path);
    }
  }

  /// Disposes all focus nodes.
  void dispose() {
    for (final FocusNode node in _focusNodes.values) {
      node.dispose();
    }
    _focusNodes.clear();
  }
}
