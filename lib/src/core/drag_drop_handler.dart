import 'package:reorderable_tree_list_view/src/models/tree_node.dart';
import 'package:reorderable_tree_list_view/src/models/tree_path.dart';

/// Handles drag and drop operations for the tree view.
/// 
/// This class provides static methods for calculating new paths when nodes
/// are dragged and dropped, and for validating whether drops are allowed.
class DragDropHandler {
  // Private constructor to prevent instantiation
  DragDropHandler._();
  
  /// Calculates the new path for a dragged node based on drop position.
  /// 
  /// Parameters:
  /// - [draggedNode]: The node being dragged
  /// - [oldIndex]: The original index in the visible nodes list
  /// - [newIndex]: The target index in the visible nodes list
  /// - [visibleNodes]: List of currently visible nodes
  /// - [dropIntoFolder]: Whether dropping into a folder (vs. next to it)
  /// - [targetFolderPath]: The folder path when dropping into a folder
  /// 
  /// Returns the new URI path for the dragged node.
  static Uri calculateNewPath({
    required TreeNode draggedNode,
    required int oldIndex,
    required int newIndex,
    required List<TreeNode> visibleNodes,
    bool dropIntoFolder = false,
    Uri? targetFolderPath,
  }) {
    // Handle drop into folder
    if (dropIntoFolder && targetFolderPath != null) {
      final List<String> segments = draggedNode.path.pathSegments;
      final String nodeName = segments.isEmpty ? draggedNode.displayName : segments.last;
      
      // Build new path in target folder
      if (targetFolderPath.pathSegments.isEmpty) {
        // Dropping into root
        return Uri(
          scheme: targetFolderPath.scheme,
          host: targetFolderPath.host,
          path: '/$nodeName',
        );
      } else {
        // Dropping into subfolder
        final String targetPath = targetFolderPath.path;
        final String newPath = targetPath.endsWith('/') 
            ? '$targetPath$nodeName' 
            : '$targetPath/$nodeName';
        return Uri(
          scheme: targetFolderPath.scheme,
          host: targetFolderPath.host,
          path: newPath,
        );
      }
    }
    
    // Get drop target info
    final DropTargetInfo dropTarget = getDropTarget(
      newIndex: newIndex,
      visibleNodes: visibleNodes,
    );
    
    // Extract node name
    final String nodeName = draggedNode.displayName;
    
    // Build new path based on target parent
    final Uri targetParent = dropTarget.targetParentPath;
    
    // Special handling for file:// URIs
    if (targetParent.scheme == 'file') {
      // Check if we're moving to root (file://)
      if (targetParent.host.isEmpty && targetParent.pathSegments.isEmpty) {
        // Moving to root - node name becomes the host
        return Uri(scheme: 'file', host: nodeName);
      } else if (targetParent.host.isNotEmpty && targetParent.pathSegments.isEmpty) {
        // Moving to first level folder (e.g., file://folder1)
        // Node becomes a path under the host
        return Uri(
          scheme: 'file',
          host: targetParent.host,
          path: '/$nodeName',
        );
      } else {
        // Moving to deeper folder
        final String parentPath = targetParent.path;
        final String newPath = parentPath.endsWith('/') 
            ? '$parentPath$nodeName' 
            : '$parentPath/$nodeName';
        return Uri(
          scheme: targetParent.scheme,
          host: targetParent.host,
          path: newPath,
        );
      }
    } else {
      // Non-file schemes
      if (targetParent.pathSegments.isEmpty) {
        return Uri(
          scheme: targetParent.scheme,
          host: targetParent.host,
          path: '/$nodeName',
        );
      } else {
        final String parentPath = targetParent.path;
        final String newPath = parentPath.endsWith('/') 
            ? '$parentPath$nodeName' 
            : '$parentPath/$nodeName';
        return Uri(
          scheme: targetParent.scheme,
          host: targetParent.host,
          path: newPath,
        );
      }
    }
  }
  
  /// Validates whether a drop operation is allowed.
  /// 
  /// Checks for:
  /// - Circular references (folder into itself or descendants)
  /// - Name conflicts in the target location
  /// 
  /// Returns a [DropValidationResult] indicating if the drop is valid.
  static DropValidationResult validateDrop({
    required TreeNode draggedNode,
    required Uri targetParentPath,
    required List<TreeNode> allNodes,
  }) {
    // Check if trying to drop folder into itself
    if (draggedNode.path == targetParentPath) {
      return const DropValidationResult(
        isValid: false,
        reason: 'Cannot move a folder into itself',
      );
    }
    
    // Check if trying to drop folder into its descendant
    if (!draggedNode.isLeaf) {
      // First check if the target is the dragged node itself
      if (draggedNode.path == targetParentPath) {
        return const DropValidationResult(
          isValid: false,
          reason: 'Cannot move a folder into itself',
        );
      }
      // Then check if it's a descendant
      if (TreePath.isAncestorOf(draggedNode.path, targetParentPath)) {
        return const DropValidationResult(
          isValid: false,
          reason: 'Cannot move a folder into its descendant',
        );
      }
    }
    
    // Check for name conflicts (unless moving within same parent)
    if (draggedNode.parentPath != targetParentPath) {
      final String nodeName = draggedNode.displayName;
      
      // Find all nodes in the target parent
      final List<TreeNode> siblings = allNodes.where((TreeNode node) {
        final Uri? parentPath = node.parentPath;
        return parentPath == targetParentPath && node.path != draggedNode.path;
      }).toList();
      
      // Check if name already exists
      final bool nameExists = siblings.any((TreeNode node) => node.displayName == nodeName);
      if (nameExists) {
        return const DropValidationResult(
          isValid: false,
          reason: 'A file or folder with this name already exists in the target location',
        );
      }
    }
    
    return const DropValidationResult(isValid: true);
  }
  
  /// Gets information about the drop target based on the drop index.
  /// 
  /// Determines the target parent path and whether dropping into a folder.
  static DropTargetInfo getDropTarget({
    required int newIndex,
    required List<TreeNode> visibleNodes,
  }) {
    // Handle drop at beginning
    if (newIndex == 0) {
      return DropTargetInfo(
        targetNode: null,
        targetParentPath: Uri.parse('file://'),
        dropIntoFolder: false,
      );
    }
    
    // Handle drop at end
    if (newIndex >= visibleNodes.length) {
      // Use parent of last node or root
      if (visibleNodes.isNotEmpty) {
        final TreeNode lastNode = visibleNodes.last;
        return DropTargetInfo(
          targetNode: lastNode,
          targetParentPath: lastNode.parentPath ?? Uri.parse('file://'),
          dropIntoFolder: false,
        );
      }
      return DropTargetInfo(
        targetNode: null,
        targetParentPath: Uri.parse('file://'),
        dropIntoFolder: false,
      );
    }
    
    // Get node at drop position
    final TreeNode targetNode = visibleNodes[newIndex];
    
    // For now, always use parent of target node
    // In future, could check drop zones for folder drops
    return DropTargetInfo(
      targetNode: targetNode,
      targetParentPath: targetNode.parentPath ?? Uri.parse('file://'),
      dropIntoFolder: false,
    );
  }
}

/// Result of a drop validation check.
class DropValidationResult {
  /// Creates a drop validation result.
  const DropValidationResult({
    required this.isValid,
    this.reason,
  });
  
  /// Whether the drop is valid.
  final bool isValid;
  
  /// Reason why the drop is invalid (if applicable).
  final String? reason;
}

/// Information about a drop target.
class DropTargetInfo {
  /// Creates drop target information.
  const DropTargetInfo({
    required this.targetNode,
    required this.targetParentPath,
    required this.dropIntoFolder,
  });
  
  /// The node at the drop position (null for drops at beginning).
  final TreeNode? targetNode;
  
  /// The parent path where the node should be dropped.
  final Uri targetParentPath;
  
  /// Whether dropping into a folder (vs. next to it).
  final bool dropIntoFolder;
}