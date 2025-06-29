import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

/// Test utilities for ReorderableTreeListView tests
class TestUtils {
  TestUtils._();

  /// Sample file system paths for testing
  static List<Uri> get sampleFilePaths => [
    Uri.parse('file:///folder1/file1.txt'),
    Uri.parse('file:///folder1/file2.txt'),
    Uri.parse('file:///folder2/subfolder/file3.txt'),
    Uri.parse('file:///folder2/file4.txt'),
    Uri.parse('file:///file5.txt'),
  ];

  /// Large dataset for performance testing
  static List<Uri> generateLargePaths(int count) {
    final List<Uri> paths = [];
    for (int i = 0; i < count ~/ 10; i++) {
      paths.add(Uri.parse('file:///folder$i/'));
      for (int j = 0; j < 10; j++) {
        paths.add(Uri.parse('file:///folder$i/file$j.txt'));
      }
    }
    return paths;
  }

  /// Creates a test app with the tree view
  static Widget createTestApp({
    required List<Uri> paths,
    Widget Function(BuildContext, Uri)? itemBuilder,
    Widget Function(BuildContext, Uri)? folderBuilder,
    void Function(Uri, Uri)? onReorder,
    TreeTheme? theme,
    bool expandedByDefault = true,
    SelectionMode selectionMode = SelectionMode.none,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ReorderableTreeListView(
          paths: paths,
          itemBuilder: itemBuilder ?? (context, path) => Text(TreePath.getDisplayName(path)),
          folderBuilder: folderBuilder,
          onReorder: onReorder,
          theme: theme,
          expandedByDefault: expandedByDefault,
          selectionMode: selectionMode,
        ),
      ),
    );
  }

  /// Pumps widget and waits for animations to complete
  static Future<void> pumpAndSettle(
    WidgetTester tester, {
    Duration duration = const Duration(milliseconds: 100),
    int maxAttempts = 10,
  }) async {
    for (int i = 0; i < maxAttempts; i++) {
      await tester.pump(duration);
      if (!tester.binding.hasScheduledFrame) {
        break;
      }
    }
  }

  /// Simulates a drag gesture
  static Future<void> dragItem(
    WidgetTester tester,
    Finder from,
    Finder to,
  ) async {
    final Offset fromCenter = tester.getCenter(from);
    final Offset toCenter = tester.getCenter(to);
    
    final TestGesture gesture = await tester.startGesture(fromCenter);
    await tester.pump(const Duration(milliseconds: 100));
    
    await gesture.moveTo(toCenter);
    await tester.pump(const Duration(milliseconds: 100));
    
    await gesture.up();
    await pumpAndSettle(tester);
  }

  /// Finds a tree item by its display name
  static Finder findTreeItem(String displayName) {
    return find.descendant(
      of: find.byType(ReorderableTreeListViewItem),
      matching: find.text(displayName),
    );
  }

  /// Finds the expand/collapse icon for a folder
  static Finder findExpandIcon(String folderName) {
    return find.descendant(
      of: find.ancestor(
        of: find.text(folderName),
        matching: find.byType(ReorderableTreeListViewItem),
      ),
      matching: find.byIcon(Icons.expand_more).or(find.byIcon(Icons.chevron_right)),
    );
  }

  /// Mock data for various test scenarios
  static class MockData {
    /// Empty path list
    static List<Uri> get empty => [];

    /// Single item
    static List<Uri> get single => [
      Uri.parse('file:///single.txt'),
    ];

    /// Deep hierarchy (5+ levels)
    static List<Uri> get deepHierarchy => [
      Uri.parse('file:///l1/l2/l3/l4/l5/deep.txt'),
      Uri.parse('file:///l1/l2/l3/l4/l5/l6/deeper.txt'),
      Uri.parse('file:///l1/l2/another.txt'),
    ];

    /// Mixed URI schemes
    static List<Uri> get mixedSchemes => [
      Uri.parse('file:///local/file.txt'),
      Uri.parse('https://example.com/api/data.json'),
      Uri.parse('ftp://server.com/upload/doc.pdf'),
      Uri.parse('custom://app/settings/config.xml'),
    ];

    /// Duplicate names at different levels
    static List<Uri> get duplicateNames => [
      Uri.parse('file:///folder1/config.json'),
      Uri.parse('file:///folder2/config.json'),
      Uri.parse('file:///config.json'),
    ];
  }
}

/// Custom matcher for checking tree structure
class HasTreeStructure extends Matcher {
  final int expectedFolders;
  final int expectedFiles;

  const HasTreeStructure({
    required this.expectedFolders,
    required this.expectedFiles,
  });

  @override
  bool matches(dynamic item, Map<dynamic, dynamic> matchState) {
    if (item is! Finder) return false;

    final folders = find.descendant(
      of: item,
      matching: find.byIcon(Icons.folder),
    ).evaluate().length;

    final files = find.descendant(
      of: item,
      matching: find.byIcon(Icons.insert_drive_file),
    ).evaluate().length;

    matchState['actualFolders'] = folders;
    matchState['actualFiles'] = files;

    return folders == expectedFolders && files == expectedFiles;
  }

  @override
  Description describe(Description description) =>
      description.add('has $expectedFolders folders and $expectedFiles files');

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    final actualFolders = matchState['actualFolders'] ?? 0;
    final actualFiles = matchState['actualFiles'] ?? 0;
    
    return mismatchDescription
        .add('has $actualFolders folders and $actualFiles files');
  }
}

/// Matcher for checking if a node is expanded
class IsExpanded extends Matcher {
  @override
  bool matches(dynamic item, Map<dynamic, dynamic> matchState) {
    if (item is! Finder) return false;

    // Check for chevron_right icon (collapsed) vs expand_more (expanded)
    final hasExpandMore = find.descendant(
      of: item,
      matching: find.byIcon(Icons.expand_more),
    ).evaluate().isNotEmpty;

    return hasExpandMore;
  }

  @override
  Description describe(Description description) =>
      description.add('is expanded');
}

/// Helper extensions for testing
extension FinderExtensions on Finder {
  /// Checks if this finder represents an expanded tree node
  bool get isExpanded {
    final expandIcon = find.descendant(
      of: this,
      matching: find.byIcon(Icons.expand_more),
    );
    return expandIcon.evaluate().isNotEmpty;
  }

  /// Checks if this finder represents a collapsed tree node
  bool get isCollapsed {
    final collapseIcon = find.descendant(
      of: this,
      matching: find.byIcon(Icons.chevron_right),
    );
    return collapseIcon.evaluate().isNotEmpty;
  }
}