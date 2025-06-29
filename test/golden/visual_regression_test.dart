import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

import '../test_utils.dart';

void main() {
  group('Visual Regression Tests', () {
    testWidgets('basic tree structure', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(
          body: ReorderableTreeListView(
            paths: TestUtils.sampleFilePaths,
            itemBuilder: (context, path) => Row(
              children: [
                const Icon(Icons.insert_drive_file, size: 20),
                const SizedBox(width: 8),
                Text(TreePath.getDisplayName(path)),
              ],
            ),
            folderBuilder: (context, path) => Row(
              children: [
                const Icon(Icons.folder, size: 20, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  TreePath.getDisplayName(path),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ));

      await expectLater(
        find.byType(ReorderableTreeListView),
        matchesGoldenFile('basic_tree_structure.png'),
      );
    });

    testWidgets('expanded tree structure', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(
          body: ReorderableTreeListView(
            paths: TestUtils.sampleFilePaths,
            expandedByDefault: true,
            theme: const TreeTheme(
              showConnectors: true,
              connectorColor: Colors.grey,
            ),
            itemBuilder: (context, path) => Row(
              children: [
                const Icon(Icons.insert_drive_file, size: 20),
                const SizedBox(width: 8),
                Text(TreePath.getDisplayName(path)),
              ],
            ),
            folderBuilder: (context, path) => Row(
              children: [
                const Icon(Icons.folder, size: 20, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  TreePath.getDisplayName(path),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ));

      await expectLater(
        find.byType(ReorderableTreeListView),
        matchesGoldenFile('expanded_tree_structure.png'),
      );
    });

    testWidgets('dark theme', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData.dark(useMaterial3: true),
        home: Scaffold(
          body: ReorderableTreeListView(
            paths: TestUtils.sampleFilePaths,
            theme: TreeTheme(
              connectorColor: Colors.grey[700]!,
              hoverColor: Colors.white.withOpacity(0.1),
              focusColor: Colors.white.withOpacity(0.2),
            ),
            itemBuilder: (context, path) => Row(
              children: [
                const Icon(Icons.insert_drive_file, size: 20),
                const SizedBox(width: 8),
                Text(TreePath.getDisplayName(path)),
              ],
            ),
            folderBuilder: (context, path) => Row(
              children: [
                const Icon(Icons.folder, size: 20, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  TreePath.getDisplayName(path),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ));

      await expectLater(
        find.byType(ReorderableTreeListView),
        matchesGoldenFile('dark_theme.png'),
      );
    });

    testWidgets('selected items state', (WidgetTester tester) async {
      final selectedPaths = {
        Uri.parse('file:///folder1/file1.txt'),
        Uri.parse('file:///folder2/file4.txt'),
      };

      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(
          body: ReorderableTreeListView(
            paths: TestUtils.sampleFilePaths,
            selectionMode: SelectionMode.multiple,
            initialSelection: selectedPaths,
            itemBuilder: (context, path) {
              final isSelected = selectedPaths.contains(path);
              return Container(
                color: isSelected ? Colors.blue.withOpacity(0.2) : null,
                child: Row(
                  children: [
                    if (isSelected) const Icon(Icons.check_circle, size: 20, color: Colors.blue),
                    if (!isSelected) const Icon(Icons.insert_drive_file, size: 20),
                    const SizedBox(width: 8),
                    Text(TreePath.getDisplayName(path)),
                  ],
                ),
              );
            },
            folderBuilder: (context, path) => Row(
              children: [
                const Icon(Icons.folder, size: 20, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  TreePath.getDisplayName(path),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ));

      await expectLater(
        find.byType(ReorderableTreeListView),
        matchesGoldenFile('selected_items_state.png'),
      );
    });

    testWidgets('drag feedback visual', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(
          body: ReorderableTreeListView(
            paths: TestUtils.sampleFilePaths,
            onReorder: (oldPath, newPath) {},
            proxyDecorator: (child, index, animation) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(8),
                    shadowColor: Colors.blue.withOpacity(0.5),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue, width: 2),
                      ),
                      child: child,
                    ),
                  );
                },
                child: child,
              );
            },
            itemBuilder: (context, path) => Row(
              children: [
                const Icon(Icons.insert_drive_file, size: 20),
                const SizedBox(width: 8),
                Text(TreePath.getDisplayName(path)),
              ],
            ),
          ),
        ),
      ));

      // Start drag
      final firstItem = find.byType(ReorderableTreeListViewItem).first;
      final gesture = await tester.startGesture(tester.getCenter(firstItem));
      await tester.pump(const Duration(milliseconds: 100));
      
      // Move slightly to show drag feedback
      await gesture.moveBy(const Offset(0, 20));
      await tester.pump();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('drag_feedback_visual.png'),
      );

      // Clean up
      await gesture.up();
    });

    testWidgets('custom indentation', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(
          body: ReorderableTreeListView(
            paths: TestUtils.MockData.deepHierarchy,
            expandedByDefault: true,
            theme: const TreeTheme(
              indentSize: 48,
              showConnectors: true,
              connectorColor: Colors.indigo,
              connectorWidth: 2,
            ),
            itemBuilder: (context, path) => Row(
              children: [
                const Icon(Icons.insert_drive_file, size: 20),
                const SizedBox(width: 8),
                Text(TreePath.getDisplayName(path)),
              ],
            ),
            folderBuilder: (context, path) => Row(
              children: [
                const Icon(Icons.folder, size: 20, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  TreePath.getDisplayName(path),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ));

      await expectLater(
        find.byType(ReorderableTreeListView),
        matchesGoldenFile('custom_indentation.png'),
      );
    });

    testWidgets('compact density', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          visualDensity: VisualDensity.compact,
        ),
        home: Scaffold(
          body: ReorderableTreeListView(
            paths: TestUtils.sampleFilePaths,
            theme: const TreeTheme(
              itemPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              indentSize: 20,
            ),
            itemBuilder: (context, path) => Row(
              children: [
                const Icon(Icons.insert_drive_file, size: 16),
                const SizedBox(width: 4),
                Text(
                  TreePath.getDisplayName(path),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            folderBuilder: (context, path) => Row(
              children: [
                const Icon(Icons.folder, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  TreePath.getDisplayName(path),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ));

      await expectLater(
        find.byType(ReorderableTreeListView),
        matchesGoldenFile('compact_density.png'),
      );
    });

    testWidgets('mixed content types', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(
          body: ReorderableTreeListView(
            paths: TestUtils.MockData.mixedSchemes,
            itemBuilder: (context, path) {
              final scheme = path.scheme;
              IconData icon;
              Color color;
              
              switch (scheme) {
                case 'https':
                case 'http':
                  icon = Icons.language;
                  color = Colors.green;
                  break;
                case 'ftp':
                  icon = Icons.cloud_upload;
                  color = Colors.blue;
                  break;
                case 'custom':
                  icon = Icons.settings;
                  color = Colors.purple;
                  break;
                default:
                  icon = Icons.insert_drive_file;
                  color = Colors.grey;
              }
              
              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      scheme.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(icon, size: 20, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      TreePath.getDisplayName(path),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ));

      await expectLater(
        find.byType(ReorderableTreeListView),
        matchesGoldenFile('mixed_content_types.png'),
      );
    });
  });
}