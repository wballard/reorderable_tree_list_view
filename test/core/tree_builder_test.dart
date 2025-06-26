import 'package:flutter_test/flutter_test.dart';
import 'package:reorderable_tree_list_view/src/core/tree_builder.dart';
import 'package:reorderable_tree_list_view/src/models/tree_node.dart';

void main() {
  group('TreeBuilder', () {
    test('builds tree from simple paths', () {
      final List<Uri> paths = <Uri>[
        Uri.parse('file://var/data/readme.txt'),
        Uri.parse('file://var/config.json'),
      ];

      final List<TreeNode> nodes = TreeBuilder.buildFromPaths(paths);

      // Expected nodes in order:
      // file:// (folder)
      // file://var (folder)
      // file://var/config.json (leaf)
      // file://var/data (folder)
      // file://var/data/readme.txt (leaf)

      expect(nodes.length, equals(5));

      expect(nodes[0].path, equals(Uri.parse('file://')));
      expect(nodes[0].isLeaf, isFalse);

      expect(nodes[1].path, equals(Uri.parse('file://var')));
      expect(nodes[1].isLeaf, isFalse);

      expect(nodes[2].path, equals(Uri.parse('file://var/config.json')));
      expect(nodes[2].isLeaf, isTrue);

      expect(nodes[3].path, equals(Uri.parse('file://var/data')));
      expect(nodes[3].isLeaf, isFalse);

      expect(nodes[4].path, equals(Uri.parse('file://var/data/readme.txt')));
      expect(nodes[4].isLeaf, isTrue);
    });

    test('handles empty path list', () {
      final List<Uri> paths = <Uri>[];
      final List<TreeNode> nodes = TreeBuilder.buildFromPaths(paths);

      expect(nodes, isEmpty);
    });

    test('handles duplicate paths', () {
      final List<Uri> paths = <Uri>[
        Uri.parse('file://var/data/readme.txt'),
        Uri.parse('file://var/data/readme.txt'), // duplicate
        Uri.parse('file://var/config.json'),
      ];

      final List<TreeNode> nodes = TreeBuilder.buildFromPaths(paths);

      // Should have same 5 nodes as before, no duplicates
      expect(nodes.length, equals(5));
    });

    test('handles multiple schemes', () {
      final List<Uri> paths = <Uri>[
        Uri.parse('file://var/data.txt'),
        Uri.parse('http://example.com/api/v1'),
        Uri.parse('custom://root/branch'),
      ];

      final List<TreeNode> nodes = TreeBuilder.buildFromPaths(paths);

      // Should be sorted by scheme first
      final List<String> schemes = nodes
          .map((TreeNode n) => n.path.scheme)
          .toSet()
          .toList();
      expect(schemes, equals(<String>['custom', 'file', 'http']));
    });

    test('maintains hierarchical order', () {
      final List<Uri> paths = <Uri>[
        Uri.parse('file://z/deep/nested/file.txt'),
        Uri.parse('file://a/first.txt'),
        Uri.parse('file://m/middle.txt'),
      ];

      final List<TreeNode> nodes = TreeBuilder.buildFromPaths(paths);

      // Verify parents come before children
      for (int i = 0; i < nodes.length; i++) {
        final TreeNode node = nodes[i];
        final Uri? parentPath = node.parentPath;

        if (parentPath != null) {
          // Find parent in list
          final int parentIndex = nodes.indexWhere(
            (TreeNode n) => n.path == parentPath,
          );
          expect(parentIndex, greaterThanOrEqualTo(0));
          expect(parentIndex, lessThan(i)); // Parent must come before child
        }
      }
    });

    test('sorts siblings alphabetically', () {
      final List<Uri> paths = <Uri>[
        Uri.parse('file://var/zebra.txt'),
        Uri.parse('file://var/apple.txt'),
        Uri.parse('file://var/banana.txt'),
      ];

      final List<TreeNode> nodes = TreeBuilder.buildFromPaths(paths);

      // Find the three leaf nodes
      final List<TreeNode> leafNodes = nodes
          .where((TreeNode n) => n.isLeaf)
          .toList();

      expect(leafNodes[0].displayName, equals('apple.txt'));
      expect(leafNodes[1].displayName, equals('banana.txt'));
      expect(leafNodes[2].displayName, equals('zebra.txt'));
    });

    test('handles deep nesting efficiently', () {
      // Create a deeply nested path
      final StringBuffer pathBuffer = StringBuffer('file://');
      for (int i = 0; i < 20; i++) {
        pathBuffer.write('level$i/');
      }
      pathBuffer.write('deep.txt');

      final List<Uri> paths = <Uri>[Uri.parse(pathBuffer.toString())];

      final List<TreeNode> nodes = TreeBuilder.buildFromPaths(paths);

      // Should create 22 nodes (1 root + 20 folders + 1 file)
      expect(nodes.length, equals(22));

      // Verify depth of last node
      expect(nodes.last.depth, equals(21));
    });

    test('handles URIs with special characters', () {
      final List<Uri> paths = <Uri>[
        Uri.parse('file://var/my%20folder/file%20with%20spaces.txt'),
        Uri.parse('file://var/special%2Bchars/test%40file.txt'),
      ];

      final List<TreeNode> nodes = TreeBuilder.buildFromPaths(paths);

      // Verify paths are preserved correctly
      expect(nodes.any((TreeNode n) => n.displayName == 'my folder'), isTrue);
      expect(
        nodes.any((TreeNode n) => n.displayName == 'file with spaces.txt'),
        isTrue,
      );
      expect(
        nodes.any((TreeNode n) => n.displayName == 'special+chars'),
        isTrue,
      );
      expect(
        nodes.any((TreeNode n) => n.displayName == 'test@file.txt'),
        isTrue,
      );
    });

    test('performance with large path lists', () {
      // Generate 1000 paths
      final List<Uri> paths = <Uri>[];
      for (int i = 0; i < 10; i++) {
        for (int j = 0; j < 10; j++) {
          for (int k = 0; k < 10; k++) {
            paths.add(Uri.parse('file://folder$i/subfolder$j/file$k.txt'));
          }
        }
      }

      final Stopwatch stopwatch = Stopwatch()..start();
      final List<TreeNode> nodes = TreeBuilder.buildFromPaths(paths);
      stopwatch.stop();

      // Should complete quickly (under 100ms for 1000 paths)
      expect(stopwatch.elapsedMilliseconds, lessThan(100));

      // Verify correct number of nodes
      // 1 root + 10 folders + 10*10 subfolders + 1000 files = 1111 nodes
      expect(nodes.length, equals(1111));
    });
  });
}
