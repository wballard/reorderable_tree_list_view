import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reorderable_tree_list_view/src/core/tree_state.dart';
import 'package:reorderable_tree_list_view/src/models/selection_mode.dart';
import 'package:reorderable_tree_list_view/src/models/tree_node.dart';

/// Controls keyboard navigation and selection for the tree view.
class KeyboardNavigationController extends ChangeNotifier {
  /// Creates a keyboard navigation controller.
  KeyboardNavigationController({
    required this.treeState,
    required this.selectionMode,
    Set<Uri>? initialSelection,
    this.onItemActivated,
  }) : _selectedPaths = initialSelection ?? <Uri>{};

  /// The tree state to navigate.
  TreeState treeState;

  /// The selection mode.
  final SelectionMode selectionMode;

  /// Optional callback for item activation.
  final void Function(Uri path)? onItemActivated;

  /// The currently focused node path.
  Uri? _focusedPath;

  /// The currently selected paths.
  final Set<Uri> _selectedPaths;

  /// The anchor path for range selection.
  Uri? _selectionAnchor;

  /// Gets the currently focused path.
  Uri? get focusedPath => _focusedPath;

  /// Gets the currently selected paths.
  Set<Uri> get selectedPaths => Set<Uri>.unmodifiable(_selectedPaths);

  /// Checks if a path is selected.
  bool isSelected(Uri path) => _selectedPaths.contains(path);

  /// Checks if a path is focused.
  bool isFocused(Uri path) => _focusedPath == path;

  /// Sets the focused path.
  void setFocus(Uri? path) {
    if (_focusedPath != path) {
      _focusedPath = path;
      notifyListeners();
    }
  }

  /// Handles keyboard events.
  bool handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return false;
    }

    final List<TreeNode> visibleNodes = treeState.getVisibleNodes();
    if (visibleNodes.isEmpty) {
      return false;
    }

    // Initialize focus if needed
    if (_focusedPath == null && visibleNodes.isNotEmpty) {
      _focusedPath = visibleNodes.first.path;
      notifyListeners();
      return true;
    }

    final bool isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
    final bool isControlPressed =
        HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowDown:
        return _handleArrowDown(visibleNodes, isShiftPressed, isControlPressed);

      case LogicalKeyboardKey.arrowUp:
        return _handleArrowUp(visibleNodes, isShiftPressed, isControlPressed);

      case LogicalKeyboardKey.arrowLeft:
        return _handleArrowLeft();

      case LogicalKeyboardKey.arrowRight:
        return _handleArrowRight();

      case LogicalKeyboardKey.home:
        return _handleHome(visibleNodes, isShiftPressed);

      case LogicalKeyboardKey.end:
        return _handleEnd(visibleNodes, isShiftPressed);

      case LogicalKeyboardKey.space:
        return _handleSpace(isControlPressed);

      case LogicalKeyboardKey.enter:
        return _handleEnter();

      default:
        return false;
    }
  }

  bool _handleArrowDown(
    List<TreeNode> visibleNodes,
    bool isShiftPressed,
    bool isControlPressed,
  ) {
    if (_focusedPath == null) {
      return false;
    }

    final int currentIndex = visibleNodes.indexWhere(
      (TreeNode node) => node.path == _focusedPath,
    );
    if (currentIndex == -1 || currentIndex >= visibleNodes.length - 1) {
      return false;
    }

    final Uri nextPath = visibleNodes[currentIndex + 1].path;

    if (isShiftPressed && selectionMode == SelectionMode.multiple) {
      _extendSelection(nextPath, visibleNodes);
    }
    // Note: Don't automatically select on navigation - only change focus

    _focusedPath = nextPath;
    notifyListeners();
    return true;
  }

  bool _handleArrowUp(
    List<TreeNode> visibleNodes,
    bool isShiftPressed,
    bool isControlPressed,
  ) {
    if (_focusedPath == null) {
      return false;
    }

    final int currentIndex = visibleNodes.indexWhere(
      (TreeNode node) => node.path == _focusedPath,
    );
    if (currentIndex <= 0) {
      return false;
    }

    final Uri prevPath = visibleNodes[currentIndex - 1].path;

    if (isShiftPressed && selectionMode == SelectionMode.multiple) {
      _extendSelection(prevPath, visibleNodes);
    }
    // Note: Don't automatically select on navigation - only change focus

    _focusedPath = prevPath;
    notifyListeners();
    return true;
  }

  bool _handleArrowLeft() {
    if (_focusedPath == null) {
      return false;
    }

    final TreeNode? node = treeState.getNodeByPath(_focusedPath!);
    if (node == null) {
      return false;
    }

    if (!node.isLeaf && treeState.isExpanded(node.path)) {
      // Collapse the folder
      treeState.toggleExpanded(node.path);
      notifyListeners();
      return true;
    } else if (node.parentPath != null) {
      // Move to parent
      _focusedPath = node.parentPath;
      // Note: Don't automatically select on navigation - only change focus
      notifyListeners();
      return true;
    }

    return false;
  }

  bool _handleArrowRight() {
    if (_focusedPath == null) {
      return false;
    }

    final TreeNode? node = treeState.getNodeByPath(_focusedPath!);
    if (node == null) {
      return false;
    }

    if (!node.isLeaf) {
      if (!treeState.isExpanded(node.path)) {
        // Expand the folder
        treeState.toggleExpanded(node.path);
        notifyListeners();
        return true;
      } else {
        // Move to first child
        final List<TreeNode> children = treeState.getChildren(node.path);
        if (children.isNotEmpty) {
          _focusedPath = children.first.path;
          // Note: Don't automatically select on navigation - only change focus
          notifyListeners();
          return true;
        }
      }
    }

    return false;
  }

  bool _handleHome(List<TreeNode> visibleNodes, bool isShiftPressed) {
    if (visibleNodes.isEmpty) {
      return false;
    }

    // Find the first non-root item (skip depth 0 nodes which are typically protocol roots)
    TreeNode? targetNode;
    for (final TreeNode node in visibleNodes) {
      if (node.depth > 0) {
        targetNode = node;
        break;
      }
    }
    // Fallback to first node if no suitable node found
    targetNode ??= visibleNodes.first;
    final Uri firstPath = targetNode.path;

    if (isShiftPressed && selectionMode == SelectionMode.multiple) {
      _extendSelection(firstPath, visibleNodes);
    }
    // Note: Don't automatically select on navigation - only change focus

    _focusedPath = firstPath;
    notifyListeners();
    return true;
  }

  bool _handleEnd(List<TreeNode> visibleNodes, bool isShiftPressed) {
    if (visibleNodes.isEmpty) {
      return false;
    }

    final Uri lastPath = visibleNodes.last.path;

    if (isShiftPressed && selectionMode == SelectionMode.multiple) {
      _extendSelection(lastPath, visibleNodes);
    }
    // Note: Don't automatically select on navigation - only change focus

    _focusedPath = lastPath;
    notifyListeners();
    return true;
  }

  bool _handleSpace(bool isControlPressed) {
    if (_focusedPath == null) {
      return false;
    }

    // If no selection mode, treat space as activation
    if (selectionMode == SelectionMode.none) {
      onItemActivated?.call(_focusedPath!);
      return true;
    }

    if (selectionMode == SelectionMode.single) {
      _setSingleSelection(_focusedPath!);
    } else if (selectionMode == SelectionMode.multiple) {
      if (isControlPressed) {
        // Toggle selection
        if (_selectedPaths.contains(_focusedPath)) {
          _selectedPaths.remove(_focusedPath);
        } else {
          _selectedPaths.add(_focusedPath!);
        }
        _selectionAnchor = _focusedPath;
      } else {
        _setSingleSelection(_focusedPath!);
      }
    }

    notifyListeners();
    return true;
  }

  bool _handleEnter() {
    if (_focusedPath != null) {
      // Call the activation callback if provided
      onItemActivated?.call(_focusedPath!);
      return true;
    }
    return false;
  }

  void _setSingleSelection(Uri path) {
    if (selectionMode != SelectionMode.none) {
      _selectedPaths
        ..clear()
        ..add(path);
      _selectionAnchor = path;
    }
  }

  void _extendSelection(Uri toPath, List<TreeNode> visibleNodes) {
    _selectionAnchor ??= _focusedPath;

    final int anchorIndex = visibleNodes.indexWhere(
      (TreeNode node) => node.path == _selectionAnchor,
    );
    final int toIndex = visibleNodes.indexWhere(
      (TreeNode node) => node.path == toPath,
    );

    if (anchorIndex == -1 || toIndex == -1) {
      return;
    }

    final int start = anchorIndex < toIndex ? anchorIndex : toIndex;
    final int end = anchorIndex < toIndex ? toIndex : anchorIndex;

    _selectedPaths.clear();
    for (int i = start; i <= end; i++) {
      _selectedPaths.add(visibleNodes[i].path);
    }
  }

  /// Updates the selection programmatically.
  void updateSelection(Set<Uri> selection) {
    _selectedPaths
      ..clear()
      ..addAll(selection);
    if (_selectedPaths.isNotEmpty) {
      _selectionAnchor = _selectedPaths.first;
    }
    notifyListeners();
  }

  /// Clears the selection.
  void clearSelection() {
    _selectedPaths.clear();
    _selectionAnchor = null;
    notifyListeners();
  }
}
