import 'package:flutter/material.dart';
import 'package:reorderable_tree_list_view/src/models/tree_node.dart';
import 'package:reorderable_tree_list_view/src/theme/tree_theme.dart';
import 'package:reorderable_tree_list_view/src/widgets/tree_connector_painter.dart';

/// A widget that wraps content for display in a ReorderableTreeListView.
/// 
/// This widget provides:
/// - Proper indentation based on tree depth with visual tree connectors
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
  
  @override
  Widget build(BuildContext context) {
    final TreeTheme? theme = TreeTheme.maybeOf(context);
    final ThemeData materialTheme = Theme.of(context);
    
    // Use TreeTheme values if available, fallback to defaults or Material theme
    final double indentSize = theme?.indentSize ?? indentWidth;
    final bool showConnectors = theme?.showConnectors ?? false;
    final bool connectors = showConnectors && node.depth > 0;
    final EdgeInsetsGeometry padding = theme?.itemPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    final BorderRadiusGeometry borderRadius = theme?.borderRadius ?? BorderRadius.zero;
    
    // Material Design colors with TreeTheme override
    final Color hoverColor = theme?.hoverColor ?? materialTheme.hoverColor;
    final Color focusColor = theme?.focusColor ?? materialTheme.focusColor;
    final Color splashColor = theme?.splashColor ?? materialTheme.splashColor;
    final Color highlightColor = theme?.highlightColor ?? materialTheme.highlightColor;

    Widget content = Row(
      children: <Widget>[
        // Indentation and connector lines
        SizedBox(
          width: node.depth * indentSize,
          child: connectors ? CustomPaint(
            painter: TreeConnectorPainter(
              depth: node.depth,
              indentSize: indentSize,
              connectorColor: theme?.connectorColor ?? Colors.grey,
              connectorWidth: theme?.connectorWidth ?? 1,
              hasChildren: hasChildren,
              isExpanded: isExpanded,
              isLastInLevel: isLastInLevel,
              parentConnections: parentConnections,
            ),
          ) : const SizedBox.shrink(),
        ),
        // Expansion icon for nodes with children
        if (hasChildren) ...<Widget>[
          SizedBox(
            width: 24,
            height: 24,
            child: IconButton(
              onPressed: onExpansionToggle,
              icon: Icon(
                isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
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
          const SizedBox(width: 28), // Same width as icon + spacing to maintain alignment
        ],
        // User content
        Expanded(child: child),
      ],
    );

    // Wrap in padding if specified
    if (padding != EdgeInsets.zero) {
      content = Padding(
        padding: padding,
        child: content,
      );
    }

    return Material(
      child: Semantics(
        enabled: hasChildren,
        expanded: hasChildren ? isExpanded : null,
        child: InkWell(
          onTap: onTap,
          hoverColor: hoverColor,
          focusColor: focusColor,
          splashColor: splashColor,
          highlightColor: highlightColor,
          borderRadius: borderRadius is BorderRadius ? borderRadius : null,
          child: content,
        ),
      ),
    );
  }
}