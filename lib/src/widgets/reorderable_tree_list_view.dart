import 'package:flutter/material.dart';
import 'package:reorderable_tree_list_view/src/core/tree_builder.dart';
import 'package:reorderable_tree_list_view/src/core/tree_state.dart';
import 'package:reorderable_tree_list_view/src/models/tree_node.dart';
import 'package:reorderable_tree_list_view/src/theme/tree_theme.dart';
import 'package:reorderable_tree_list_view/src/widgets/reorderable_tree_list_view_item.dart';

/// A reorderable list view that displays hierarchical tree data.
/// 
/// This widget takes a sparse list of URI paths and automatically generates
/// a complete tree structure, including intermediate folder nodes.
/// 
/// Supports expand/collapse functionality for folder nodes.
class ReorderableTreeListView extends StatefulWidget {
  /// Creates a ReorderableTreeListView.
  const ReorderableTreeListView({
    required this.paths,
    required this.itemBuilder,
    super.key,
    this.theme,
    this.folderBuilder,
    this.scrollController,
    this.scrollDirection = Axis.vertical,
    this.shrinkWrap = false,
    this.padding,
    this.physics,
    this.expandedByDefault = true,
    this.initiallyExpanded,
    this.animateExpansion = true,
  });
  
  /// The sparse list of URI paths to display in the tree.
  final List<Uri> paths;

  /// Optional theme configuration for the tree view.
  /// 
  /// If provided, this theme will be applied to all tree items via TreeThemeData.
  /// If not provided, items will use the default theme or inherit from an ancestor TreeThemeData.
  final TreeTheme? theme;
  
  /// Builds widgets for leaf nodes (files).
  final Widget Function(BuildContext context, Uri path) itemBuilder;
  
  /// Builds widgets for folder nodes. If not provided, uses itemBuilder.
  final Widget Function(BuildContext context, Uri path)? folderBuilder;
  
  /// An optional scroll controller for the list view.
  final ScrollController? scrollController;
  
  /// The axis along which the list view scrolls.
  final Axis scrollDirection;
  
  /// Whether the list view should shrink-wrap its contents.
  final bool shrinkWrap;
  
  /// The amount of space by which to inset the list view.
  final EdgeInsetsGeometry? padding;
  
  /// How the list view should respond to user input.
  final ScrollPhysics? physics;

  /// Whether folders should be expanded by default.
  /// 
  /// If true, all folder nodes start in the expanded state.
  /// If false, all folder nodes start collapsed.
  final bool expandedByDefault;

  /// A set of paths that should be initially expanded, regardless of [expandedByDefault].
  /// 
  /// If null, uses [expandedByDefault] for all folders.
  /// If provided, the specified paths will be expanded while others follow [expandedByDefault].
  final Set<Uri>? initiallyExpanded;

  /// Whether to animate expansion and collapse operations.
  /// 
  /// If true, expanding and collapsing folders will be animated.
  /// If false, changes will be immediate.
  final bool animateExpansion;
  
  @override
  State<ReorderableTreeListView> createState() => _ReorderableTreeListViewState();
}

class _ReorderableTreeListViewState extends State<ReorderableTreeListView> {
  late TreeState _treeState;
  
  @override
  void initState() {
    super.initState();
    _buildTreeState();
  }
  
  @override
  void didUpdateWidget(ReorderableTreeListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check if paths have changed
    if (_pathsChanged(oldWidget.paths, widget.paths)) {
      _buildTreeState();
    }
  }
  
  void _buildTreeState() {
    final List<TreeNode> nodes = TreeBuilder.buildFromPaths(widget.paths);
    _treeState = TreeState(nodes);
    
    // Apply expansion settings
    if (!widget.expandedByDefault) {
      _treeState.collapseAll();
    }
    
    // Apply initially expanded paths if provided
    if (widget.initiallyExpanded != null) {
      for (final Uri path in widget.initiallyExpanded!) {
        _treeState.setExpanded(path, expanded: true);
      }
    }
  }
  
  bool _pathsChanged(List<Uri> oldPaths, List<Uri> newPaths) {
    if (oldPaths.length != newPaths.length) {
      return true;
    }
    
    final Set<Uri> oldSet = oldPaths.toSet();
    final Set<Uri> newSet = newPaths.toSet();
    
    return !oldSet.containsAll(newSet) || !newSet.containsAll(oldSet);
  }
  
  void _toggleExpansion(Uri path) {
    setState(() {
      _treeState.toggleExpanded(path);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<TreeNode> visibleNodes = _treeState.getVisibleNodes();
    
    // Use ReorderableListView for drag-and-drop functionality
    Widget listView = ReorderableListView.builder(
      scrollDirection: widget.scrollDirection,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding as EdgeInsets?,
      // buildDefaultDragHandles defaults to true, so no need to specify
      itemCount: visibleNodes.length,
      itemBuilder: (BuildContext context, int index) {
        final TreeNode node = visibleNodes[index];
        final bool hasChildren = _treeState.getChildren(node.path).isNotEmpty;
        final bool isExpanded = _treeState.isExpanded(node.path);
        
        // Get the user-provided content
        final Widget userContent;
        if (node.isLeaf) {
          userContent = widget.itemBuilder(context, node.path);
        } else {
          // Use folder builder if provided, otherwise use item builder
          if (widget.folderBuilder != null) {
            userContent = widget.folderBuilder!(context, node.path);
          } else {
            userContent = widget.itemBuilder(context, node.path);
          }
        }
        
        // Wrap with ReorderableTreeListViewItem for proper indentation and styling
        return ReorderableTreeListViewItem(
          key: ValueKey<String>(node.key),
          node: node,
          hasChildren: hasChildren,
          isExpanded: isExpanded,
          onExpansionToggle: hasChildren ? () => _toggleExpansion(node.path) : null,
          child: userContent,
        );
      },
      onReorder: (int oldIndex, int newIndex) {
        // Placeholder for proper path recalculation implementation
        // Currently logs debug information for development
        debugPrint('DEBUG: Reorder from $oldIndex to $newIndex');
        debugPrint('DEBUG: Moving ${visibleNodes[oldIndex].path} to position $newIndex');
      },
    );

    // Wrap with TreeThemeData if a theme is provided
    if (widget.theme != null) {
      listView = TreeThemeData(
        theme: widget.theme!,
        child: listView,
      );
    }

    return listView;
  }
}