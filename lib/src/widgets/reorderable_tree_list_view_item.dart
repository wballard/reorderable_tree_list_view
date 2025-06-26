import 'package:flutter/material.dart';
import 'package:reorderable_tree_list_view/src/models/tree_node.dart';

/// A widget that wraps content for display in a ReorderableTreeListView.
/// 
/// This widget provides:
/// - Proper indentation based on tree depth
/// - Material Design compliance with InkWell feedback
/// - Consistent layout structure for tree items
class ReorderableTreeListViewItem extends StatelessWidget {
  /// Creates a ReorderableTreeListViewItem.
  const ReorderableTreeListViewItem({
    required this.node,
    required this.child,
    super.key,
    this.indentWidth = 24,
  });
  
  /// The tree node data that determines depth and other properties.
  final TreeNode node;
  
  /// The user-provided widget to display.
  final Widget child;
  
  /// The width in pixels for each level of indentation.
  final double indentWidth;
  
  @override
  Widget build(BuildContext context) => Material(
    child: InkWell(
      child: Row(
        children: <Widget>[
          // Indentation based on depth
          SizedBox(width: node.depth * indentWidth),
          // User content
          Expanded(child: child),
        ],
      ),
    ),
  );
}