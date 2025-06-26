import 'package:flutter_test/flutter_test.dart';
import 'package:reorderable_tree_list_view/src/core/drag_drop_handler.dart';
import 'package:reorderable_tree_list_view/src/models/tree_node.dart';

void main() {
  group('DragDropHandler', () {
    late List<TreeNode> testNodes;

    setUp(() {
      testNodes = <TreeNode>[
        TreeNode(path: Uri.parse('file://'), isLeaf: false),
        TreeNode(path: Uri.parse('file://folder1'), isLeaf: false),
        TreeNode(path: Uri.parse('file://folder1/file1.txt'), isLeaf: true),
        TreeNode(path: Uri.parse('file://folder1/file2.txt'), isLeaf: true),
        TreeNode(path: Uri.parse('file://folder2'), isLeaf: false),
        TreeNode(path: Uri.parse('file://folder2/subfolder'), isLeaf: false),
        TreeNode(
          path: Uri.parse('file://folder2/subfolder/file3.txt'),
          isLeaf: true,
        ),
        TreeNode(path: Uri.parse('file://folder3'), isLeaf: false),
        TreeNode(path: Uri.parse('file://file4.txt'), isLeaf: true),
      ];
    });

    group('calculateNewPath', () {
      test('should move file to different folder', () {
        // Moving file1.txt from folder1 to folder2
        final Uri result = DragDropHandler.calculateNewPath(
          draggedNode: testNodes[2], // file1.txt
          oldIndex: 2,
          newIndex: 5,
          visibleNodes: testNodes,
        );

        expect(result.toString(), 'file://folder2/file1.txt');
      });

      test('should move file to root level', () {
        // Moving file1.txt from folder1 to root
        final Uri result = DragDropHandler.calculateNewPath(
          draggedNode: testNodes[2], // file1.txt
          oldIndex: 2,
          newIndex: 8,
          visibleNodes: testNodes,
        );

        expect(result.toString(), 'file://file1.txt/');
      });

      test('should move folder to different parent', () {
        // Moving subfolder from folder2 to folder1
        final Uri result = DragDropHandler.calculateNewPath(
          draggedNode: testNodes[5], // subfolder
          oldIndex: 5,
          newIndex: 3,
          visibleNodes: testNodes,
        );

        expect(result.toString(), 'file://folder1/subfolder');
      });

      test('should reorder within same parent', () {
        // Moving file2.txt before file1.txt in folder1
        final Uri result = DragDropHandler.calculateNewPath(
          draggedNode: testNodes[3], // file2.txt
          oldIndex: 3,
          newIndex: 2,
          visibleNodes: testNodes,
        );

        expect(result.toString(), 'file://folder1/file2.txt');
      });

      test('should handle moving to end of list', () {
        // Moving folder1 to the end
        final Uri result = DragDropHandler.calculateNewPath(
          draggedNode: testNodes[1], // folder1
          oldIndex: 1,
          newIndex: 9,
          visibleNodes: testNodes,
        );

        expect(result.toString(), 'file://folder1/');
      });

      test('should handle drop into folder (as last child)', () {
        // Moving file4.txt into folder3
        final Uri result = DragDropHandler.calculateNewPath(
          draggedNode: testNodes[8], // file4.txt
          oldIndex: 8,
          newIndex: 8,
          visibleNodes: testNodes,
          dropIntoFolder: true,
          targetFolderPath: testNodes[7].path, // folder3
        );

        expect(result.toString(), 'file://folder3/file4.txt');
      });
    });

    group('validateDrop', () {
      test('should allow valid file moves', () {
        // Moving file1.txt to folder2
        final DropValidationResult result = DragDropHandler.validateDrop(
          draggedNode: testNodes[2], // file1.txt
          targetParentPath: Uri.parse('file://folder2'),
          allNodes: testNodes,
        );

        expect(result.isValid, true);
        expect(result.reason, isNull);
      });

      test('should prevent moving folder into itself', () {
        // Trying to move folder2 into itself
        final DropValidationResult result = DragDropHandler.validateDrop(
          draggedNode: testNodes[4], // folder2
          targetParentPath: testNodes[4].path, // folder2
          allNodes: testNodes,
        );

        expect(result.isValid, false);
        expect(result.reason, contains('into itself'));
      });

      test('should prevent moving folder into its descendant', () {
        // Trying to move folder2 into its subfolder
        final DropValidationResult result = DragDropHandler.validateDrop(
          draggedNode: testNodes[4], // folder2
          targetParentPath: testNodes[5].path, // subfolder
          allNodes: testNodes,
        );

        expect(result.isValid, false);
        expect(result.reason, contains('into its descendant'));
      });

      test('should prevent duplicate names in same parent', () {
        // Trying to move file2.txt to root where file4.txt exists
        // First need a scenario where names would clash
        final List<TreeNode> nodesWithDuplicate = <TreeNode>[
          ...testNodes,
          TreeNode(path: Uri.parse('file://folder2/file1.txt'), isLeaf: true),
        ];

        final DropValidationResult result = DragDropHandler.validateDrop(
          draggedNode: testNodes[2], // file1.txt from folder1
          targetParentPath: Uri.parse('file://folder2'),
          allNodes: nodesWithDuplicate,
        );

        expect(result.isValid, false);
        expect(result.reason, contains('already exists'));
      });

      test('should allow moving to same parent (reordering)', () {
        // Moving file1.txt within folder1
        final DropValidationResult result = DragDropHandler.validateDrop(
          draggedNode: testNodes[2], // file1.txt
          targetParentPath: Uri.parse('file://folder1'),
          allNodes: testNodes,
        );

        expect(result.isValid, true);
        expect(result.reason, isNull);
      });

      test('should handle root level drops', () {
        // Moving folder1 to root (where it already is)
        final DropValidationResult result = DragDropHandler.validateDrop(
          draggedNode: testNodes[1], // folder1
          targetParentPath: Uri.parse('file://'),
          allNodes: testNodes,
        );

        expect(result.isValid, true);
        expect(result.reason, isNull);
      });
    });

    group('getDropTarget', () {
      test('should identify folder drop target', () {
        // Dropping onto a folder
        final DropTargetInfo result = DragDropHandler.getDropTarget(
          newIndex: 4,
          visibleNodes: testNodes,
        );

        expect(result.targetNode, testNodes[4]); // folder2
        expect(result.dropIntoFolder, false);
        expect(result.targetParentPath, Uri.parse('file://'));
      });

      test('should identify parent from previous sibling', () {
        // Dropping after file2.txt (index 4)
        final DropTargetInfo result = DragDropHandler.getDropTarget(
          newIndex: 4,
          visibleNodes: testNodes,
        );

        expect(result.targetParentPath, Uri.parse('file://'));
      });

      test('should handle drop at beginning', () {
        // Dropping at index 0
        final DropTargetInfo result = DragDropHandler.getDropTarget(
          newIndex: 0,
          visibleNodes: testNodes,
        );

        expect(result.targetNode, isNull);
        expect(result.targetParentPath, Uri.parse('file://'));
      });

      test('should handle drop at end', () {
        // Dropping at the end
        final DropTargetInfo result = DragDropHandler.getDropTarget(
          newIndex: testNodes.length,
          visibleNodes: testNodes,
        );

        expect(result.targetParentPath, Uri.parse('file://'));
      });
    });
  });
}
