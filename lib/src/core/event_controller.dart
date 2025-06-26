import 'package:flutter/material.dart';
import 'package:reorderable_tree_list_view/src/typedefs.dart';

/// Controller that manages callbacks and event handling for the tree view.
/// 
/// This class coordinates between the tree view widget and the action system,
/// providing a centralized place to manage all callbacks and ensure proper
/// event timing and error handling.
class EventController extends ChangeNotifier {
  /// Callback invoked when node expansion starts.
  TreeExpandCallback? onExpandStart;

  /// Callback invoked when node expansion completes.
  TreeExpandCallback? onExpandEnd;

  /// Callback invoked when node collapse starts.
  TreeExpandCallback? onCollapseStart;

  /// Callback invoked when node collapse completes.
  TreeExpandCallback? onCollapseEnd;

  /// Callback invoked when a drag operation starts.
  TreeDragStartCallback? onDragStart;

  /// Callback invoked when a drag operation ends.
  TreeDragEndCallback? onDragEnd;

  /// Callback invoked when a node is reordered.
  TreeReorderCallback? onReorder;

  /// Callback invoked when the selection changes.
  TreeSelectionChangedCallback? onSelectionChanged;

  /// Callback invoked when an item is tapped.
  TreeItemTapCallback? onItemTap;

  /// Callback invoked when an item is activated (double-click or Enter).
  TreeItemActivatedCallback? onItemActivated;

  /// Callback to determine if a node can be expanded.
  TreeCanExpandCallback? canExpandCallback;

  /// Callback to determine if a node can be dragged.
  TreeCanDragCallback? canDragCallback;

  /// Callback to determine if a drop is allowed.
  TreeCanDropCallback? canDropCallback;

  /// Callback invoked when right-click context menu is requested.
  TreeContextMenuCallback? onContextMenu;

  /// Async callback to determine if a node can be expanded.
  TreeCanExpandAsyncCallback? canExpandAsyncCallback;

  /// Async callback to determine if a node can be dragged.
  TreeCanDragAsyncCallback? canDragAsyncCallback;

  /// Async callback to determine if a drop is allowed.
  TreeCanDropAsyncCallback? canDropAsyncCallback;

  /// Whether the controller has been disposed.
  bool _disposed = false;

  /// Whether this controller has been disposed.
  bool get isDisposed => _disposed;

  /// Notifies that expansion has started for a node.
  void notifyExpandStart(Uri path) {
    _invokeCallback(() => onExpandStart?.call(path));
  }

  /// Notifies that expansion has completed for a node.
  void notifyExpandEnd(Uri path) {
    _invokeCallback(() => onExpandEnd?.call(path));
  }

  /// Notifies that collapse has started for a node.
  void notifyCollapseStart(Uri path) {
    _invokeCallback(() => onCollapseStart?.call(path));
  }

  /// Notifies that collapse has completed for a node.
  void notifyCollapseEnd(Uri path) {
    _invokeCallback(() => onCollapseEnd?.call(path));
  }

  /// Notifies that a drag operation has started.
  void notifyDragStart(Uri path) {
    _invokeCallback(() => onDragStart?.call(path));
  }

  /// Notifies that a drag operation has ended.
  void notifyDragEnd(Uri path) {
    _invokeCallback(() => onDragEnd?.call(path));
  }

  /// Notifies that a node has been reordered.
  void notifyReorder(Uri oldPath, Uri newPath) {
    _invokeCallback(() => onReorder?.call(oldPath, newPath));
  }

  /// Notifies that the selection has changed.
  void notifySelectionChanged(Set<Uri> selection) {
    _invokeCallback(() => onSelectionChanged?.call(selection));
  }

  /// Notifies that an item has been tapped.
  void notifyItemTap(Uri path) {
    _invokeCallback(() => onItemTap?.call(path));
  }

  /// Notifies that an item has been activated.
  void notifyItemActivated(Uri path) {
    _invokeCallback(() => onItemActivated?.call(path));
  }

  /// Notifies that a context menu has been requested.
  void notifyContextMenu(Uri path, Offset globalPosition) {
    _invokeCallback(() => onContextMenu?.call(path, globalPosition));
  }

  /// Checks if a node can be expanded.
  /// 
  /// Returns true if no validation callback is set or if the callback returns true.
  bool canExpand(Uri path) => canExpandCallback?.call(path) ?? true;

  /// Checks if a node can be dragged.
  /// 
  /// Returns true if no validation callback is set or if the callback returns true.
  bool canDrag(Uri path) => canDragCallback?.call(path) ?? true;

  /// Checks if a drop operation is allowed.
  /// 
  /// Returns true if no validation callback is set or if the callback returns true.
  bool canDrop(Uri draggedPath, Uri targetPath) => canDropCallback?.call(draggedPath, targetPath) ?? true;

  /// Asynchronously checks if a node can be expanded.
  /// 
  /// Returns true if no validation callback is set or if the callback returns true.
  Future<bool> canExpandAsync(Uri path) async => await canExpandAsyncCallback?.call(path) ?? true;

  /// Asynchronously checks if a node can be dragged.
  /// 
  /// Returns true if no validation callback is set or if the callback returns true.
  Future<bool> canDragAsync(Uri path) async => await canDragAsyncCallback?.call(path) ?? true;

  /// Asynchronously checks if a drop operation is allowed.
  /// 
  /// Returns true if no validation callback is set or if the callback returns true.
  Future<bool> canDropAsync(Uri draggedPath, Uri targetPath) async => await canDropAsyncCallback?.call(draggedPath, targetPath) ?? true;

  /// Invokes a callback with error handling.
  void _invokeCallback(VoidCallback callback) {
    if (_disposed) {
      return;
    }

    try {
      callback();
    } catch (error, stackTrace) {
      // Log the error but don't rethrow to prevent disrupting the tree view
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'reorderable_tree_list_view',
        context: ErrorDescription('while invoking a tree view callback'),
      ));
    }
  }

  @override
  void dispose() {
    _disposed = true;
    
    // Clear all callbacks to prevent memory leaks
    onExpandStart = null;
    onExpandEnd = null;
    onCollapseStart = null;
    onCollapseEnd = null;
    onDragStart = null;
    onDragEnd = null;
    onReorder = null;
    onSelectionChanged = null;
    onItemTap = null;
    onItemActivated = null;
    canExpandCallback = null;
    canDragCallback = null;
    canDropCallback = null;
    onContextMenu = null;
    canExpandAsyncCallback = null;
    canDragAsyncCallback = null;
    canDropAsyncCallback = null;
    
    super.dispose();
  }
}