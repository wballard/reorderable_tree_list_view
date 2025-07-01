import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

import 'package:reorderable_tree_list_view/src/intents/activate_node_intent.dart';
import 'package:reorderable_tree_list_view/src/intents/collapse_node_intent.dart';
import 'package:reorderable_tree_list_view/src/intents/expand_node_intent.dart';
import 'package:reorderable_tree_list_view/src/models/tree_node.dart';
import 'package:reorderable_tree_list_view/src/theme/tree_theme.dart';

/// A widget that wraps content for display in a ReorderableTreeListView.
///
/// This widget provides:
/// - Proper indentation based on tree depth
/// - Material Design compliance with InkWell feedback and theming
/// - Consistent layout structure for tree items
/// - Integration with TreeTheme for customizable appearance
/// - Expansion/collapse functionality for nodes with children
class ReorderableTreeListViewItem extends StatelessWidget {
  /// Creates a ReorderableTreeListViewItem.
  const ReorderableTreeListViewItem({
    required this.node,
    required this.child,
    super.key,
    this.indentWidth = 24,
    this.hasChildren = false,
    this.isExpanded = false,
    this.isLastInLevel = false,
    this.parentConnections = const <bool>[],
    this.onTap,
    this.onExpansionToggle,
    this.focusNode,
    this.isFocused = false,
    this.isSelected = false,
    this.onContextMenu,
    this.animateExpansion = true,
  });

  /// The tree node data that determines depth and other properties.
  final TreeNode node;

  /// The user-provided widget to display.
  final Widget child;

  /// The width in pixels for each level of indentation.
  ///
  /// This is used as a fallback when no TreeTheme is available.
  final double indentWidth;

  /// Whether this node has children.
  final bool hasChildren;

  /// Whether this node is expanded (only relevant if hasChildren is true).
  final bool isExpanded;

  /// Whether this is the last node at its level.
  final bool isLastInLevel;

  /// List of booleans indicating which parent levels have more siblings.
  final List<bool> parentConnections;

  /// Callback for when the item is tapped.
  final VoidCallback? onTap;

  /// Callback for when the expansion state should be toggled.
  ///
  /// Only called for nodes with children when the expansion icon is tapped.
  final VoidCallback? onExpansionToggle;

  /// The focus node for this item.
  final FocusNode? focusNode;

  /// Whether this item is currently focused.
  final bool isFocused;

  /// Whether this item is currently selected.
  final bool isSelected;

  /// Callback for when context menu is requested (right-click).
  final void Function(Offset globalPosition)? onContextMenu;

  /// Whether to animate the expansion/collapse of folders.
  final bool animateExpansion;

  /// Handles expansion toggle using Actions.maybeInvoke pattern.
  void _handleExpansionToggle(BuildContext context) {
    if (isExpanded) {
      // Try to find CollapseNodeIntent action first
      final Action<CollapseNodeIntent>? action =
          Actions.maybeFind<CollapseNodeIntent>(context);
      if (action != null) {
        // Action found, invoke it
        Actions.invoke<CollapseNodeIntent>(
          context,
          CollapseNodeIntent(node.path),
        );
      } else {
        // No action found, use callback
        onExpansionToggle?.call();
      }
    } else {
      // Try to find ExpandNodeIntent action first
      final Action<ExpandNodeIntent>? action =
          Actions.maybeFind<ExpandNodeIntent>(context);
      if (action != null) {
        // Action found, invoke it
        Actions.invoke<ExpandNodeIntent>(context, ExpandNodeIntent(node.path));
      } else {
        // No action found, use callback
        onExpansionToggle?.call();
      }
    }
  }

  /// Handles item activation using Actions.maybeInvoke pattern.
  void _handleActivation(BuildContext context) {
    // Always call the onTap callback if provided
    onTap?.call();
    
    // Also try to find ActivateNodeIntent action
    final Action<ActivateNodeIntent>? action =
        Actions.maybeFind<ActivateNodeIntent>(context);
    if (action != null) {
      // Action found, invoke it
      Actions.invoke<ActivateNodeIntent>(
        context,
        ActivateNodeIntent(node.path),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TreeTheme? theme = TreeTheme.maybeOf(context);
    final ThemeData materialTheme = Theme.of(context);

    // Use TreeTheme values if available, fallback to defaults or Material theme
    final double indentSize = theme?.indentSize ?? indentWidth;
    final EdgeInsetsGeometry padding =
        theme?.itemPadding ??
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    final BorderRadiusGeometry borderRadius =
        theme?.borderRadius ?? BorderRadius.zero;

    // Material Design colors with TreeTheme override
    final Color hoverColor = theme?.hoverColor ?? materialTheme.hoverColor;
    final Color focusColor = theme?.focusColor ?? materialTheme.focusColor;
    final Color splashColor = theme?.splashColor ?? materialTheme.splashColor;
    final Color highlightColor =
        theme?.highlightColor ?? materialTheme.highlightColor;

    Widget content = Row(
      children: <Widget>[
        // Indentation
        SizedBox(
          width: node.depth * indentSize,
        ),
        // Expansion icon for nodes with children
        if (hasChildren) ...<Widget>[
          SizedBox(
            width: 24,
            height: 24,
            child: IconButton(
              onPressed: () => _handleExpansionToggle(context),
              icon: animateExpansion
                  ? AnimatedRotation(
                      turns: isExpanded ? 0.25 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.keyboard_arrow_right,
                        size: 18,
                      ),
                    )
                  : Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_right,
                      size: 18,
                    ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              style: IconButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ] else ...<Widget>[
          const SizedBox(
            width: 28,
          ), // Same width as icon + spacing to maintain alignment
        ],
        // User content
        Expanded(child: child),
      ],
    );

    // Wrap in padding if specified
    if (padding != EdgeInsets.zero) {
      content = Padding(padding: padding, child: content);
    }

    // Apply selection/focus styling
    Widget result = InkWell(
      onTap: () => _handleActivation(context),
      hoverColor: hoverColor,
      focusColor: focusColor,
      splashColor: splashColor,
      highlightColor: highlightColor,
      borderRadius: borderRadius is BorderRadius ? borderRadius : null,
      focusNode: focusNode,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isSelected
              ? materialTheme.colorScheme.primary.withValues(alpha: 0.12)
              : isFocused
              ? materialTheme.focusColor.withValues(alpha: 0.12)
              : null,
          borderRadius: borderRadius,
        ),
        child: content,
      ),
    );

    // Wrap with GestureDetector for context menu support
    if (onContextMenu != null) {
      if (kIsWeb) {
        // On web, use Listener to capture right-click and prevent browser context menu
        result = Listener(
          onPointerDown: (PointerDownEvent event) {
            if (event.kind == PointerDeviceKind.mouse && 
                event.buttons == kSecondaryButton) {
              // Temporarily disable browser context menu
              BrowserContextMenu.disableContextMenu();
              
              // Call context menu handler
              onContextMenu!(event.position);
              
              // Re-enable browser context menu after a delay
              // This ensures our custom menu has time to show
              Future.delayed(const Duration(milliseconds: 100), () {
                BrowserContextMenu.enableContextMenu();
              });
            }
          },
          child: result,
        );
      } else {
        // On other platforms, use GestureDetector with onSecondaryTapUp
        result = GestureDetector(
          onSecondaryTapUp: (TapUpDetails details) {
            onContextMenu!(details.globalPosition);
          },
          child: result,
        );
      }
    }

    return Material(
      child: Semantics(
        enabled: hasChildren,
        expanded: hasChildren ? isExpanded : null,
        child: result,
      ),
    );
  }
}
