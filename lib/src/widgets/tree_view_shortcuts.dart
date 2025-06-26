import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reorderable_tree_list_view/src/intents/tree_collapse_all_intent.dart';
import 'package:reorderable_tree_list_view/src/intents/tree_copy_intent.dart';
import 'package:reorderable_tree_list_view/src/intents/tree_delete_intent.dart';
import 'package:reorderable_tree_list_view/src/intents/tree_expand_all_intent.dart';
import 'package:reorderable_tree_list_view/src/intents/tree_paste_intent.dart';
import 'package:reorderable_tree_list_view/src/intents/tree_select_all_intent.dart';

/// A widget that provides default keyboard shortcuts for tree view operations.
///
/// This widget wraps its child with a [Shortcuts] widget that maps keyboard
/// events to tree view intents. It provides common shortcuts like:
/// - Ctrl+C for copy
/// - Ctrl+V for paste
/// - Delete for delete
/// - Space for selection
/// - Enter for activation
///
/// Custom shortcuts can be provided to override the defaults.
class TreeViewShortcuts extends StatelessWidget {
  /// Creates a TreeViewShortcuts widget.
  const TreeViewShortcuts({
    required this.child,
    super.key,
    this.shortcuts,
    this.enableDefaultShortcuts = true,
    this.controller,
    this.focusNode,
  });

  /// The widget to wrap with shortcuts.
  final Widget child;

  /// Custom shortcuts to add or override defaults.
  ///
  /// If provided, these shortcuts will be merged with the default shortcuts.
  /// Custom shortcuts take precedence over defaults.
  final Map<ShortcutActivator, Intent>? shortcuts;

  /// Whether to enable the default tree view shortcuts.
  ///
  /// If false, only custom shortcuts will be available.
  final bool enableDefaultShortcuts;

  /// The keyboard navigation controller (unused for now, for future compatibility).
  final dynamic controller;

  /// The focus node (unused for now, for future compatibility).
  final FocusNode? focusNode;

  /// Gets the default shortcuts for tree view operations.
  ///
  /// These shortcuts use generic intents. The actual target nodes are determined
  /// by the Actions based on the current focus/selection state.
  static Map<ShortcutActivator, Intent>
  get defaultShortcuts => <ShortcutActivator, Intent>{
    // Copy operations
    const SingleActivator(LogicalKeyboardKey.keyC, control: true):
        const TreeCopyIntent(),

    // Paste operations
    const SingleActivator(LogicalKeyboardKey.keyV, control: true):
        const TreePasteIntent(),

    // Delete operations
    const SingleActivator(LogicalKeyboardKey.delete): const TreeDeleteIntent(),

    // Selection operations (handled by keyboard controller)
    // Space key is handled directly by the tree for context-aware selection

    // Activation (handled by keyboard controller)
    // Enter key is handled directly by the tree for context-aware activation

    // Expand all
    const SingleActivator(
          LogicalKeyboardKey.equal,
          control: true,
          shift: true,
        ): // Ctrl+Shift+= (Plus)
        const TreeExpandAllIntent(),

    // Collapse all
    const SingleActivator(LogicalKeyboardKey.minus, control: true):
        const TreeCollapseAllIntent(),

    // Select all
    const SingleActivator(LogicalKeyboardKey.keyA, control: true):
        const TreeSelectAllIntent(),
  };

  /// Gets the platform-specific shortcuts.
  ///
  /// On macOS, uses Cmd instead of Ctrl for copy/paste operations.
  Map<ShortcutActivator, Intent> getPlatformShortcuts(BuildContext context) {
    final Map<ShortcutActivator, Intent> shortcuts =
        Map<ShortcutActivator, Intent>.from(defaultShortcuts);

    // On macOS, use Cmd instead of Ctrl for system shortcuts
    if (Theme.of(context).platform == TargetPlatform.macOS) {
      shortcuts
        ..remove(const SingleActivator(LogicalKeyboardKey.keyC, control: true))
        ..remove(const SingleActivator(LogicalKeyboardKey.keyV, control: true))
        ..remove(const SingleActivator(LogicalKeyboardKey.keyA, control: true))
        ..remove(
          const SingleActivator(
            LogicalKeyboardKey.equal,
            control: true,
            shift: true,
          ),
        )
        ..remove(const SingleActivator(LogicalKeyboardKey.minus, control: true))
        ..addAll(<ShortcutActivator, Intent>{
          const SingleActivator(LogicalKeyboardKey.keyC, meta: true):
              const TreeCopyIntent(),
          const SingleActivator(LogicalKeyboardKey.keyV, meta: true):
              const TreePasteIntent(),
          const SingleActivator(LogicalKeyboardKey.keyA, meta: true):
              const TreeSelectAllIntent(),
          const SingleActivator(
            LogicalKeyboardKey.equal,
            meta: true,
            shift: true,
          ): const TreeExpandAllIntent(),
          const SingleActivator(LogicalKeyboardKey.minus, meta: true):
              const TreeCollapseAllIntent(),
        });
    }

    return shortcuts;
  }

  @override
  Widget build(BuildContext context) {
    final Map<ShortcutActivator, Intent> effectiveShortcuts =
        <ShortcutActivator, Intent>{};

    // Add default shortcuts if enabled
    if (enableDefaultShortcuts) {
      effectiveShortcuts.addAll(getPlatformShortcuts(context));
    }

    // Add custom shortcuts (override defaults)
    if (shortcuts != null) {
      effectiveShortcuts.addAll(shortcuts!);
    }

    // If no shortcuts are defined, just return the child
    if (effectiveShortcuts.isEmpty) {
      return child;
    }

    return Shortcuts(shortcuts: effectiveShortcuts, child: child);
  }
}
