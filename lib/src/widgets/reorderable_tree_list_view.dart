import 'package:flutter/material.dart';
import 'package:reorderable_tree_list_view/src/actions/activate_node_action.dart';
import 'package:reorderable_tree_list_view/src/actions/select_node_action.dart';
import 'package:reorderable_tree_list_view/src/core/drag_drop_handler.dart';
import 'package:reorderable_tree_list_view/src/core/event_controller.dart';
import 'package:reorderable_tree_list_view/src/core/focus_manager.dart';
import 'package:reorderable_tree_list_view/src/core/keyboard_navigation_controller.dart';
import 'package:reorderable_tree_list_view/src/core/tree_builder.dart';
import 'package:reorderable_tree_list_view/src/core/tree_state.dart';
import 'package:reorderable_tree_list_view/src/intents/activate_node_intent.dart';
import 'package:reorderable_tree_list_view/src/intents/collapse_node_intent.dart';
import 'package:reorderable_tree_list_view/src/intents/expand_node_intent.dart';
import 'package:reorderable_tree_list_view/src/intents/select_node_intent.dart';
import 'package:reorderable_tree_list_view/src/models/selection_mode.dart';
import 'package:reorderable_tree_list_view/src/models/tree_node.dart';
import 'package:reorderable_tree_list_view/src/models/tree_path.dart';
import 'package:reorderable_tree_list_view/src/theme/tree_theme.dart';
import 'package:reorderable_tree_list_view/src/typedefs.dart';
import 'package:reorderable_tree_list_view/src/widgets/reorderable_tree_list_view_item.dart';
import 'package:reorderable_tree_list_view/src/widgets/tree_view_shortcuts.dart';

/// A reorderable list view that displays hierarchical tree data.
///
/// This widget takes a sparse list of URI paths and automatically generates
/// a complete tree structure, including intermediate folder nodes.
///
/// Supports expand/collapse functionality for folder nodes.
class ReorderableTreeListView extends StatefulWidget {
  /// Creates a ReorderableTreeListView.
  ReorderableTreeListView({
    required List<Uri> paths,
    required this.itemBuilder,
    super.key,
    this.theme,
    this.folderBuilder,
    this.scrollController,
    this.scrollDirection = Axis.vertical,
    this.shrinkWrap = false,
    this.padding,
    this.physics,
    this.initiallyExpanded,
    this.animateExpansion = true,
    this.onReorder,
    this.onDragStart,
    this.onDragEnd,
    this.onWillAcceptDrop,
    this.proxyDecorator,
    this.enableDropIndicators = false,
    this.onDropZoneEntered,
    this.enableKeyboardNavigation = true,
    this.selectionMode = SelectionMode.none,
    this.initialSelection,
    this.onSelectionChanged,
    this.onItemActivated,
    this.onExpandStart,
    this.onExpandEnd,
    this.onCollapseStart,
    this.onCollapseEnd,
    this.onItemTap,
    this.canExpand,
    this.canDrag,
    this.canDrop,
    this.onContextMenu,
    this.canExpandAsync,
    this.canDragAsync,
    this.canDropAsync,
  }) : paths = List.unmodifiable(paths);

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

  /// A set of paths that should be initially expanded.
  ///
  /// If null, all folders start collapsed.
  /// If provided, the specified paths will be expanded while others remain collapsed.
  final Set<Uri>? initiallyExpanded;

  /// Whether to animate expansion and collapse operations.
  ///
  /// If true, expanding and collapsing folders will be animated.
  /// If false, changes will be immediate.
  final bool animateExpansion;

  /// Called when an item is reordered via drag and drop.
  ///
  /// Provides the old path and new path of the moved item.
  final void Function(Uri oldPath, Uri newPath)? onReorder;

  /// Called when a drag operation starts.
  ///
  /// Provides the path of the item being dragged.
  final void Function(Uri path)? onDragStart;

  /// Called when a drag operation ends.
  ///
  /// Provides the path of the item that was being dragged.
  final void Function(Uri path)? onDragEnd;

  /// Called to determine if a drop is allowed.
  ///
  /// Return false to prevent the drop operation.
  final bool Function(Uri draggedPath, Uri targetPath)? onWillAcceptDrop;

  /// Custom decoration for the item being dragged.
  ///
  /// If not provided, uses the default Material elevation.
  final Widget Function(Widget child, int index, Animation<double> animation)?
  proxyDecorator;

  /// Whether to show drop indicators during drag operations.
  final bool enableDropIndicators;

  /// Called when the drag enters a drop zone.
  ///
  /// Provides the type of drop zone ('folder' or 'sibling') and target path.
  final void Function(String type, Uri path)? onDropZoneEntered;

  /// Whether to enable keyboard navigation for the tree view.
  final bool enableKeyboardNavigation;

  /// The selection mode for the tree view.
  final SelectionMode selectionMode;

  /// The initial selection when the tree view is first displayed.
  final Set<Uri>? initialSelection;

  /// Called when the selection changes.
  final void Function(Set<Uri> selection)? onSelectionChanged;

  /// Called when an item is activated (e.g., double-clicked or Enter pressed).
  final void Function(Uri path)? onItemActivated;

  /// Called when node expansion starts.
  final TreeExpandCallback? onExpandStart;

  /// Called when node expansion completes.
  final TreeExpandCallback? onExpandEnd;

  /// Called when node collapse starts.
  final TreeExpandCallback? onCollapseStart;

  /// Called when node collapse completes.
  final TreeExpandCallback? onCollapseEnd;

  /// Called when an item is tapped.
  final TreeItemTapCallback? onItemTap;

  /// Callback to determine if a node can be expanded.
  final TreeCanExpandCallback? canExpand;

  /// Callback to determine if a node can be dragged.
  final TreeCanDragCallback? canDrag;

  /// Callback to determine if a drop is allowed.
  final TreeCanDropCallback? canDrop;

  /// Called when right-click context menu is requested.
  final TreeContextMenuCallback? onContextMenu;

  /// Async callback to determine if a node can be expanded.
  final TreeCanExpandAsyncCallback? canExpandAsync;

  /// Async callback to determine if a node can be dragged.
  final TreeCanDragAsyncCallback? canDragAsync;

  /// Async callback to determine if a drop is allowed.
  final TreeCanDropAsyncCallback? canDropAsync;

  @override
  State<ReorderableTreeListView> createState() =>
      _ReorderableTreeListViewState();
}

class _ReorderableTreeListViewState extends State<ReorderableTreeListView> {
  TreeState? _treeState;
  late KeyboardNavigationController _keyboardController;
  late TreeFocusManager _focusManager;
  late EventController _eventController;
  final FocusNode _treeFocusNode = FocusNode();
  Uri? _draggingPath;

  @override
  void initState() {
    super.initState();
    _buildTreeState();
    _focusManager = TreeFocusManager();
    _eventController = EventController()
      ..onExpandStart = widget.onExpandStart
      ..onExpandEnd = widget.onExpandEnd
      ..onCollapseStart = widget.onCollapseStart
      ..onCollapseEnd = widget.onCollapseEnd
      ..onDragStart = widget.onDragStart
      ..onDragEnd = widget.onDragEnd
      ..onReorder = widget.onReorder
      ..onSelectionChanged = widget.onSelectionChanged
      ..onItemTap = widget.onItemTap
      ..onItemActivated = widget.onItemActivated
      ..canExpandCallback = widget.canExpand
      ..canDragCallback = widget.canDrag
      ..canDropCallback = widget.canDrop
      ..onContextMenu = widget.onContextMenu
      ..canExpandAsyncCallback = widget.canExpandAsync
      ..canDragAsyncCallback = widget.canDragAsync
      ..canDropAsyncCallback = widget.canDropAsync;
    _keyboardController = KeyboardNavigationController(
      treeState: _treeState!,
      selectionMode: widget.selectionMode,
      initialSelection: widget.initialSelection,
      onItemActivated: (Uri path) {
        _eventController.notifyItemActivated(path);
      },
    );
    _keyboardController.addListener(_onKeyboardControllerChanged);
  }

  @override
  void didUpdateWidget(ReorderableTreeListView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if paths or expansion settings have changed
    if (_pathsChanged(oldWidget.paths, widget.paths) ||
        oldWidget.initiallyExpanded != widget.initiallyExpanded) {
      _buildTreeState();
      _keyboardController.treeState = _treeState!;
    }

    // Update selection mode if changed
    if (oldWidget.selectionMode != widget.selectionMode) {
      _keyboardController.dispose();
      _keyboardController = KeyboardNavigationController(
        treeState: _treeState!,
        selectionMode: widget.selectionMode,
        initialSelection: _keyboardController.selectedPaths,
        onItemActivated: (Uri path) {
          _eventController.notifyItemActivated(path);
        },
      );
      _keyboardController.addListener(_onKeyboardControllerChanged);
    }

    // Update EventController callbacks
    _eventController
      ..onExpandStart = widget.onExpandStart
      ..onExpandEnd = widget.onExpandEnd
      ..onCollapseStart = widget.onCollapseStart
      ..onCollapseEnd = widget.onCollapseEnd
      ..onDragStart = widget.onDragStart
      ..onDragEnd = widget.onDragEnd
      ..onReorder = widget.onReorder
      ..onSelectionChanged = widget.onSelectionChanged
      ..onItemTap = widget.onItemTap
      ..onItemActivated = widget.onItemActivated
      ..canExpandCallback = widget.canExpand
      ..canDragCallback = widget.canDrag
      ..canDropCallback = widget.canDrop
      ..onContextMenu = widget.onContextMenu
      ..canExpandAsyncCallback = widget.canExpandAsync
      ..canDragAsyncCallback = widget.canDragAsync
      ..canDropAsyncCallback = widget.canDropAsync;
  }

  @override
  void dispose() {
    _keyboardController
      ..removeListener(_onKeyboardControllerChanged)
      ..dispose();
    _focusManager.dispose();
    _eventController.dispose();
    _treeFocusNode.dispose();
    super.dispose();
  }

  void _onKeyboardControllerChanged() {
    setState(() {
      // Update focused path in focus manager
      if (_keyboardController.focusedPath != null) {
        // Delay focus request to next frame to ensure the widget tree is built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _focusManager.requestFocus(_keyboardController.focusedPath!);
        });
      }

      // Notify selection changes
      _eventController.notifySelectionChanged(
        _keyboardController.selectedPaths,
      );
    });
  }

  void _buildTreeState() {
    // Preserve current expansion state if tree state exists
    Set<Uri> previouslyExpandedPaths = <Uri>{};
    if (_treeState != null) {
      previouslyExpandedPaths = _treeState!.expandedPaths;
    }

    final List<TreeNode> nodes = TreeBuilder.buildFromPaths(widget.paths);
    _treeState = TreeState(nodes);

    // Start with all folders collapsed by default
    _treeState!.collapseAll();

    // Restore previous expansion state for paths that still exist
    for (final Uri path in previouslyExpandedPaths) {
      if (_treeState!.getNodeByPath(path) != null) {
        _treeState!.setExpanded(path, expanded: true);
      }
    }

    // Apply initially expanded paths if provided (this can override preserved state)
    if (widget.initiallyExpanded != null) {
      for (final Uri path in widget.initiallyExpanded!) {
        _treeState!.setExpanded(path, expanded: true);
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

  Future<void> _toggleExpansion(Uri path) async {
    final bool isExpanded = _treeState!.isExpanded(path);

    // Check if expansion/collapse is allowed
    if (!isExpanded) {
      // Attempting to expand
      if (!_eventController.canExpand(path)) {
        return; // Not allowed
      }

      // Check async validation if provided
      if (_eventController.canExpandAsyncCallback != null) {
        final bool canExpand = await _eventController.canExpandAsync(path);
        if (!canExpand) {
          return; // Not allowed
        }
      }

      _eventController.notifyExpandStart(path);
    } else {
      // Attempting to collapse
      _eventController.notifyCollapseStart(path);
    }

    setState(() {
      _treeState!.toggleExpanded(path);
    });

    // Notify completion
    if (!isExpanded) {
      _eventController.notifyExpandEnd(path);
    } else {
      _eventController.notifyCollapseEnd(path);
    }
  }

  Future<void> _handleReorder(
    int oldIndex,
    int newIndex,
    List<TreeNode> visibleNodes,
  ) async {
    // Get the dragged node
    final TreeNode draggedNode = visibleNodes[oldIndex];

    // Calculate new path - pass the raw newIndex, DragDropHandler will handle the logic
    final Uri newPath = DragDropHandler.calculateNewPath(
      draggedNode: draggedNode,
      oldIndex: oldIndex,
      newIndex: newIndex,
      visibleNodes: visibleNodes,
    );

    // Validate the drop using EventController
    if (!_eventController.canDrop(draggedNode.path, newPath)) {
      return; // Drop not allowed
    }

    // Check async validation if provided
    if (_eventController.canDropAsyncCallback != null) {
      final bool canDrop = await _eventController.canDropAsync(
        draggedNode.path,
        newPath,
      );
      if (!canDrop) {
        return; // Drop not allowed
      }
    }

    // Also check the legacy callback if provided
    if (widget.onWillAcceptDrop != null) {
      // Pass the new path to the callback for validation
      if (!widget.onWillAcceptDrop!(draggedNode.path, newPath)) {
        return; // Drop not allowed
      }
    }

    // Additional validation
    final DropValidationResult validation = DragDropHandler.validateDrop(
      draggedNode: draggedNode,
      targetParentPath: TreePath.getParentPath(newPath) ?? Uri.parse('file://'),
      allNodes: _treeState!.allNodes,
    );

    if (!validation.isValid) {
      // Show error message if needed
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(validation.reason ?? 'Invalid drop')),
        );
      }
      return;
    }

    // Call the onReorder callback via EventController
    _eventController.notifyReorder(draggedNode.path, newPath);
  }

  /// Creates the map of actions for the tree view.
  Map<Type, Action<Intent>> _createActions() => <Type, Action<Intent>>{
    ExpandNodeIntent: CallbackAction<ExpandNodeIntent>(
      onInvoke: (ExpandNodeIntent intent) {
        // Execute async toggle in a non-blocking way
        () async {
          await _toggleExpansion(intent.path);
        }();
        return null;
      },
    ),
    CollapseNodeIntent: CallbackAction<CollapseNodeIntent>(
      onInvoke: (CollapseNodeIntent intent) {
        // Execute async toggle in a non-blocking way
        () async {
          await _toggleExpansion(intent.path);
        }();
        return null;
      },
    ),
    ActivateNodeIntent: ActivateNodeAction(
      treeState: _treeState!,
      onActivate: (Uri path) {
        _eventController.notifyItemActivated(path);
      },
    ),
    SelectNodeIntent: SelectNodeAction(
      treeState: _treeState!,
      keyboardController: _keyboardController,
      selectionMode: widget.selectionMode,
    ),
    // MoveNodeIntent: MoveNodeAction(treeState: _treeState),
    // DeleteNodeIntent: DeleteNodeAction(treeState: _treeState),
    // CopyNodeIntent: CopyNodeAction(treeState: _treeState),
    // PasteNodeIntent: PasteNodeAction(treeState: _treeState),
  };

  @override
  Widget build(BuildContext context) {
    final List<TreeNode> visibleNodes = _treeState!.getVisibleNodes();

    // Cleanup stale focus nodes
    final Set<Uri> activePaths = visibleNodes
        .map((TreeNode n) => n.path)
        .toSet();
    _focusManager.cleanup(activePaths);

    // Use ReorderableListView for drag-and-drop functionality
    final Widget listView = ReorderableListView.builder(
      scrollDirection: widget.scrollDirection,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding as EdgeInsets?,
      // buildDefaultDragHandles defaults to true, so no need to specify
      itemCount: visibleNodes.length,
      itemBuilder: (BuildContext context, int index) {
        final TreeNode node = visibleNodes[index];
        final bool hasChildren = _treeState!.getChildren(node.path).isNotEmpty;
        final bool isExpanded = _treeState!.isExpanded(node.path);

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
          animateExpansion: widget.animateExpansion,
          onExpansionToggle: hasChildren
              ? () => _toggleExpansion(node.path)
              : null,
          focusNode: _focusManager.getFocusNode(node.path),
          isFocused: _keyboardController.isFocused(node.path),
          isSelected: _keyboardController.isSelected(node.path),
          onTap: () {
            _eventController.notifyItemTap(node.path);
            if (widget.selectionMode != SelectionMode.none) {
              _keyboardController.setFocus(node.path);
              if (widget.selectionMode == SelectionMode.single) {
                _keyboardController.updateSelection(<Uri>{node.path});
              }
            }
          },
          onContextMenu: widget.onContextMenu != null
              ? (Offset globalPosition) {
                  _eventController.notifyContextMenu(node.path, globalPosition);
                }
              : null,
          child: userContent,
        );
      },
      onReorder: (int oldIndex, int newIndex) {
        _handleReorder(oldIndex, newIndex, visibleNodes);
      },
      onReorderStart: (int index) {
        final Uri path = visibleNodes[index].path;
        _draggingPath = path;
        // Check if drag is allowed
        if (!_eventController.canDrag(path)) {
          // no op
        }
        _eventController.notifyDragStart(path);
      },
      onReorderEnd: (int index) {
        if (_draggingPath != null) {
          _eventController.notifyDragEnd(_draggingPath!);
          _draggingPath = null;
        }
      },
      proxyDecorator: widget.proxyDecorator,
    );

    // Wrap with TreeThemeData if a theme is provided
    Widget result = listView;
    if (widget.theme != null) {
      result = TreeThemeData(theme: widget.theme!, child: result);
    }

    // Wrap with Actions to provide tree-specific actions
    result = Actions(actions: _createActions(), child: result);

    // Wrap with keyboard navigation if enabled
    if (widget.enableKeyboardNavigation) {
      result = TreeViewShortcuts(
        controller: _keyboardController,
        focusNode: _treeFocusNode,
        child: Focus(
          focusNode: _treeFocusNode,
          onFocusChange: (bool hasFocus) {
            if (hasFocus && _keyboardController.focusedPath == null) {
              // When the tree gains focus and no item is focused, focus the first item
              final List<TreeNode> visible = _treeState!.getVisibleNodes();
              if (visible.isNotEmpty) {
                // Find first meaningful node (skip root protocol nodes)
                TreeNode? firstNode;
                for (final TreeNode node in visible) {
                  if (node.depth > 0) {
                    firstNode = node;
                    break;
                  }
                }
                firstNode ??= visible.first;
                _keyboardController.setFocus(firstNode.path);
              }
            }
          },
          onKeyEvent: (FocusNode node, KeyEvent event) {
            if (_keyboardController.handleKeyEvent(event)) {
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: result,
        ),
      );
    }

    return result;
  }
}
