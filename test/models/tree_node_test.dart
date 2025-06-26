import 'package:flutter_test/flutter_test.dart';
import 'package:reorderable_tree_list_view/src/models/tree_node.dart';

void main() {
  group('TreeNode', () {
    test('creates node with all properties', () {
      final Uri path = Uri.parse('file://var/data/readme.txt');
      const bool isLeaf = true;

      final TreeNode node = TreeNode(path: path, isLeaf: isLeaf);

      expect(node.path, equals(path));
      expect(node.isLeaf, equals(isLeaf));
      expect(node.key, equals('file://var/data/readme.txt'));
      expect(node.depth, equals(3)); // file:// + var + data + readme.txt
    });

    test('calculates depth correctly for various paths', () {
      final TreeNode rootNode = TreeNode(
        path: Uri.parse('file://'),
        isLeaf: false,
      );
      expect(rootNode.depth, equals(0));

      final TreeNode level1Node = TreeNode(
        path: Uri.parse('file://var'),
        isLeaf: false,
      );
      expect(level1Node.depth, equals(1));

      final TreeNode level2Node = TreeNode(
        path: Uri.parse('file://var/data'),
        isLeaf: false,
      );
      expect(level2Node.depth, equals(2));

      final TreeNode level3Node = TreeNode(
        path: Uri.parse('file://var/data/readme.txt'),
        isLeaf: true,
      );
      expect(level3Node.depth, equals(3));
    });

    test('gets display name correctly', () {
      final TreeNode rootNode = TreeNode(
        path: Uri.parse('file://'),
        isLeaf: false,
      );
      expect(rootNode.displayName, equals('file://'));

      final TreeNode folderNode = TreeNode(
        path: Uri.parse('file://var/data'),
        isLeaf: false,
      );
      expect(folderNode.displayName, equals('data'));

      final TreeNode fileNode = TreeNode(
        path: Uri.parse('file://var/data/readme.txt'),
        isLeaf: true,
      );
      expect(fileNode.displayName, equals('readme.txt'));
    });

    test('gets parent path correctly', () {
      final TreeNode rootNode = TreeNode(
        path: Uri.parse('file://'),
        isLeaf: false,
      );
      expect(rootNode.parentPath, isNull);

      final TreeNode level1Node = TreeNode(
        path: Uri.parse('file://var'),
        isLeaf: false,
      );
      expect(level1Node.parentPath, equals(Uri.parse('file://')));

      final TreeNode level3Node = TreeNode(
        path: Uri.parse('file://var/data/readme.txt'),
        isLeaf: true,
      );
      expect(level3Node.parentPath, equals(Uri.parse('file://var/data')));
    });

    test('handles different URI schemes', () {
      final TreeNode httpNode = TreeNode(
        path: Uri.parse('http://example.com/api/v1'),
        isLeaf: true,
      );
      expect(httpNode.depth, equals(2));
      expect(httpNode.displayName, equals('v1'));
      expect(httpNode.key, equals('http://example.com/api/v1'));

      final TreeNode customNode = TreeNode(
        path: Uri.parse('custom://root/branch/leaf'),
        isLeaf: true,
      );
      expect(customNode.depth, equals(3));
      expect(customNode.displayName, equals('leaf'));
    });

    test('equality and hashCode work correctly', () {
      final TreeNode node1 = TreeNode(
        path: Uri.parse('file://var/data'),
        isLeaf: false,
      );

      final TreeNode node2 = TreeNode(
        path: Uri.parse('file://var/data'),
        isLeaf: false,
      );

      final TreeNode node3 = TreeNode(
        path: Uri.parse('file://var/data'),
        isLeaf: true,
      );

      expect(node1, equals(node2));
      expect(node1.hashCode, equals(node2.hashCode));
      expect(node1, isNot(equals(node3))); // Different isLeaf value
    });
  });
}
