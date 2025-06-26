import 'package:flutter/material.dart';

/// Callback for expansion-related events.
/// 
/// Called with the [Uri] path of the node being expanded or collapsed.
typedef TreeExpandCallback = void Function(Uri path);

/// Callback for drag start events.
/// 
/// Called with the [Uri] path of the node being dragged.
typedef TreeDragStartCallback = void Function(Uri path);

/// Callback for drag end events.
/// 
/// Called with the [Uri] path of the node that was being dragged.
typedef TreeDragEndCallback = void Function(Uri path);

/// Callback for reorder events.
/// 
/// Called with the old and new [Uri] paths when a node is moved.
typedef TreeReorderCallback = void Function(Uri oldPath, Uri newPath);

/// Callback for selection change events.
/// 
/// Called with the updated set of selected [Uri] paths.
typedef TreeSelectionChangedCallback = void Function(Set<Uri> selection);

/// Callback for item tap events.
/// 
/// Called with the [Uri] path of the tapped node.
typedef TreeItemTapCallback = void Function(Uri path);

/// Callback for item activation events.
/// 
/// Called with the [Uri] path of the activated node (e.g., double-click or Enter key).
typedef TreeItemActivatedCallback = void Function(Uri path);

/// Callback to determine if a node can be expanded.
/// 
/// Return true to allow expansion, false to prevent it.
typedef TreeCanExpandCallback = bool Function(Uri path);

/// Callback to determine if a node can be dragged.
/// 
/// Return true to allow dragging, false to prevent it.
typedef TreeCanDragCallback = bool Function(Uri path);

/// Callback to determine if a drop is allowed.
/// 
/// Return true to allow the drop, false to prevent it.
typedef TreeCanDropCallback = bool Function(Uri draggedPath, Uri targetPath);

/// Callback for context menu events.
/// 
/// Called with the [Uri] path of the node and the global position of the right-click.
typedef TreeContextMenuCallback = void Function(Uri path, Offset globalPosition);

/// Async callback to determine if a node can be expanded.
/// 
/// Return a Future of bool - true to allow expansion, false to prevent it.
/// Useful for validation that requires async operations.
typedef TreeCanExpandAsyncCallback = Future<bool> Function(Uri path);

/// Async callback to determine if a node can be dragged.
/// 
/// Return a Future of bool - true to allow dragging, false to prevent it.
/// Useful for validation that requires async operations.
typedef TreeCanDragAsyncCallback = Future<bool> Function(Uri path);

/// Async callback to determine if a drop is allowed.
/// 
/// Return a Future of bool - true to allow the drop, false to prevent it.
/// Useful for validation that requires async operations.
typedef TreeCanDropAsyncCallback = Future<bool> Function(Uri draggedPath, Uri targetPath);