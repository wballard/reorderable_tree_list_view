import 'package:flutter/material.dart';
import 'package:reorderable_tree_list_view/src/core/tree_builder.dart';
import 'package:reorderable_tree_list_view/src/core/tree_state.dart';
import 'package:reorderable_tree_list_view/src/models/tree_node.dart';

/// A reorderable list view that displays hierarchical tree data.
/// 
/// This widget takes a sparse list of URI paths and automatically generates
/// a complete tree structure, including intermediate folder nodes.
class ReorderableTreeListView extends StatefulWidget {
  /// Creates a ReorderableTreeListView.
  const ReorderableTreeListView({
    required this.paths,
    required this.itemBuilder,
    super.key,
    this.folderBuilder,
    this.scrollController,
    this.scrollDirection = Axis.vertical,
    this.shrinkWrap = false,
    this.padding,
    this.physics,
  });
  
  /// The sparse list of URI paths to display in the tree.
  final List<Uri> paths;
  
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
  }
  
  bool _pathsChanged(List<Uri> oldPaths, List<Uri> newPaths) {
    if (oldPaths.length != newPaths.length) {
      return true;
    }
    
    final Set<Uri> oldSet = oldPaths.toSet();
    final Set<Uri> newSet = newPaths.toSet();
    
    return !oldSet.containsAll(newSet) || !newSet.containsAll(oldSet);
  }
  
  @override
  Widget build(BuildContext context) {
    final List<TreeNode> allNodes = _treeState.allNodes;
    
    // Use ListView directly with a header as the first item
    return ListView.builder(
      controller: widget.scrollController,
      scrollDirection: widget.scrollDirection,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding,
      physics: widget.physics,
      itemCount: allNodes.length + 1, // +1 for the header
      itemBuilder: (BuildContext context, int index) {
        // First item is the header
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.all(8),
            child: Text('Tree with ${allNodes.length} nodes'),
          );
        }
        
        // Adjust index for actual nodes
        final TreeNode node = allNodes[index - 1];
        
        if (node.isLeaf) {
          return widget.itemBuilder(context, node.path);
        } else {
          // Use folder builder if provided, otherwise use item builder
          if (widget.folderBuilder != null) {
            return widget.folderBuilder!(context, node.path);
          } else {
            return widget.itemBuilder(context, node.path);
          }
        }
      },
    );
  }
}