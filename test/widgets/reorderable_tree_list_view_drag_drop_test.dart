import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

const Duration kLongPressTimeout = Duration(milliseconds: 500);

void main() {
  group('ReorderableTreeListView Drag and Drop', () {
    late List<Uri> testPaths;

    setUp(() {
      testPaths = <Uri>[
        Uri.parse('file://folder1/file1.txt'),
        Uri.parse('file://folder1/file2.txt'),
        Uri.parse('file://folder2/subfolder/file3.txt'),
        Uri.parse('file://folder3/file4.txt'),
        Uri.parse('file://file5.txt'),
      ];
    });

    Widget buildTestWidget({
      required List<Uri> paths,
      void Function(Uri oldPath, Uri newPath)? onReorder,
      void Function(Uri path)? onDragStart,
      void Function(Uri path)? onDragEnd,
      bool Function(Uri draggedPath, Uri targetPath)? onWillAcceptDrop,
      Widget Function(Widget child, int index, Animation<double> animation)?
      proxyDecorator,
      Set<Uri>? initiallyExpanded,
    }) => MaterialApp(
      home: Scaffold(
        body: ReorderableTreeListView(
          paths: paths,
          itemBuilder: (BuildContext context, Uri path) =>
              Text(path.toString()),
          onReorder: onReorder,
          onDragStart: onDragStart,
          onDragEnd: onDragEnd,
          onWillAcceptDrop: onWillAcceptDrop,
          proxyDecorator: proxyDecorator,
          initiallyExpanded: initiallyExpanded,
        ),
      ),
    );

    testWidgets('should call onReorder when item is moved', (
      WidgetTester tester,
    ) async {
      Uri? reorderedOldPath;
      Uri? reorderedNewPath;

      await tester.pumpWidget(
        buildTestWidget(
          paths: testPaths,
          initiallyExpanded: <Uri>{
            Uri.parse('file://'),
            Uri.parse('file://folder1'),
            Uri.parse('file://folder2'),
            Uri.parse('file://folder3'),
          },
          onReorder: (Uri oldPath, Uri newPath) {
            reorderedOldPath = oldPath;
            reorderedNewPath = newPath;
          },
        ),
      );

      // Wait for tree to build
      await tester.pumpAndSettle();

      // Find and drag file1.txt
      final Finder file1Finder = find.text('file://folder1/file1.txt');
      expect(file1Finder, findsOneWidget);

      // Drag to a new position
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(file1Finder),
      );
      await tester.pump(kLongPressTimeout);

      // Move down past file2.txt
      await gesture.moveBy(const Offset(0, 100));
      await tester.pump();

      // Release
      await gesture.up();
      await tester.pumpAndSettle();

      // Verify onReorder was called
      expect(reorderedOldPath, Uri.parse('file://folder1/file1.txt'));
      expect(reorderedNewPath, isNotNull);
    });

    testWidgets('should call onDragStart when drag begins', (
      WidgetTester tester,
    ) async {
      Uri? dragStartPath;

      await tester.pumpWidget(
        buildTestWidget(
          paths: testPaths,
          initiallyExpanded: <Uri>{
            Uri.parse('file://'),
            Uri.parse('file://folder1'),
            Uri.parse('file://folder2'),
            Uri.parse('file://folder3'),
          },
          onDragStart: (Uri path) {
            dragStartPath = path;
          },
        ),
      );

      await tester.pumpAndSettle();

      // Start dragging file1.txt
      final Finder file1Finder = find.text('file://folder1/file1.txt');
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(file1Finder),
      );
      await tester.pump(kLongPressTimeout);

      // Verify onDragStart was called
      expect(dragStartPath, Uri.parse('file://folder1/file1.txt'));

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('should call onDragEnd when drag ends', (
      WidgetTester tester,
    ) async {
      Uri? dragEndPath;

      await tester.pumpWidget(
        buildTestWidget(
          paths: testPaths,
          initiallyExpanded: <Uri>{
            Uri.parse('file://'),
            Uri.parse('file://folder1'),
            Uri.parse('file://folder2'),
            Uri.parse('file://folder3'),
          },
          onDragEnd: (Uri path) {
            dragEndPath = path;
          },
        ),
      );

      await tester.pumpAndSettle();

      // Start and end drag
      final Finder file1Finder = find.text('file://folder1/file1.txt');
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(file1Finder),
      );
      await tester.pump(kLongPressTimeout);
      await gesture.up();
      await tester.pumpAndSettle();

      // Verify onDragEnd was called
      expect(dragEndPath, Uri.parse('file://folder1/file1.txt'));
    });

    testWidgets('should respect onWillAcceptDrop validation', (
      WidgetTester tester,
    ) async {
      bool reorderCalled = false;

      await tester.pumpWidget(
        buildTestWidget(
          paths: testPaths,
          initiallyExpanded: <Uri>{
            Uri.parse('file://'),
            Uri.parse('file://folder1'),
            Uri.parse('file://folder2'),
            Uri.parse('file://folder3'),
          },
          onReorder: (Uri oldPath, Uri newPath) {
            reorderCalled = true;
          },
          onWillAcceptDrop: (Uri draggedPath, Uri targetPath) =>
              // Prevent moving into folder2
              !targetPath.toString().contains('folder2'),
        ),
      );

      await tester.pumpAndSettle();

      // Try to drag file1.txt to a position that would put it in folder2
      final Finder file1Finder = find.text('file://folder1/file1.txt');

      // Find folder2 first
      final Finder folder2Finder = find.text('file://folder2/');

      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(file1Finder),
      );
      await tester.pump(kLongPressTimeout);

      // Move just below folder2 to drop into it
      final Offset folder2Position = tester.getCenter(folder2Finder);
      await gesture.moveTo(Offset(folder2Position.dx, folder2Position.dy + 30));
      await tester.pump();

      await gesture.up();
      await tester.pumpAndSettle();

      // Verify onReorder was NOT called due to validation failure
      expect(reorderCalled, false);
    });

    testWidgets('should apply custom proxyDecorator during drag', (
      WidgetTester tester,
    ) async {
      bool decoratorApplied = false;

      await tester.pumpWidget(
        buildTestWidget(
          paths: testPaths,
          initiallyExpanded: <Uri>{
            Uri.parse('file://'),
            Uri.parse('file://folder1'),
            Uri.parse('file://folder2'),
            Uri.parse('file://folder3'),
          },
          proxyDecorator:
              (Widget child, int index, Animation<double> animation) {
                decoratorApplied = true;
                return Material(
                  elevation: 8,
                  color: Colors.blue.withValues(alpha: 0.5),
                  child: child,
                );
              },
        ),
      );

      await tester.pumpAndSettle();

      // Start dragging
      final Finder file1Finder = find.text('file://folder1/file1.txt');
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(file1Finder),
      );
      await tester.pump(kLongPressTimeout);

      // Move a bit to trigger proxy
      await gesture.moveBy(const Offset(0, 10));
      await tester.pump();

      // Verify decorator was applied
      expect(decoratorApplied, true);

      // Check for elevated material (proxy)
      expect(
        find.byType(Material).evaluate().where((Element element) {
          final Material material = element.widget as Material;
          return material.elevation == 8;
        }),
        isNotEmpty,
      );

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('should handle complex tree reorganization', (
      WidgetTester tester,
    ) async {
      final List<Uri> complexPaths = <Uri>[
        Uri.parse('file://projectA/src/main.dart'),
        Uri.parse('file://projectA/src/utils/helpers.dart'),
        Uri.parse('file://projectA/tests/main_test.dart'),
        Uri.parse('file://projectB/lib/app.dart'),
        Uri.parse('file://projectB/lib/widgets/button.dart'),
        Uri.parse('file://shared/config.yaml'),
      ];

      Uri? movedFrom;
      Uri? movedTo;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableTreeListView(
              paths: complexPaths,
              initiallyExpanded: <Uri>{
                Uri.parse('file://'),
                Uri.parse('file://projectA'),
                Uri.parse('file://projectA/src'),
                Uri.parse('file://projectA/src/utils'),
                Uri.parse('file://projectA/tests'),
                Uri.parse('file://projectB'),
                Uri.parse('file://projectB/lib'),
                Uri.parse('file://projectB/lib/widgets'),
                Uri.parse('file://shared'),
              },
              itemBuilder: (BuildContext context, Uri path) =>
                  Text(path.toString()),
              onReorder: (Uri oldPath, Uri newPath) {
                movedFrom = oldPath;
                movedTo = newPath;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Move helpers.dart from projectA to projectB/lib
      final Finder helpersFinder = find.text(
        'file://projecta/src/utils/helpers.dart',
      );
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(helpersFinder),
      );
      await tester.pump(kLongPressTimeout);

      // Move to projectB area
      await gesture.moveBy(const Offset(0, 200));
      await tester.pump();

      await gesture.up();
      await tester.pumpAndSettle();

      // Verify the move
      expect(movedFrom, Uri.parse('file://projectA/src/utils/helpers.dart'));
      expect(movedTo?.toString(), contains('projectb'));
    });

    testWidgets('should notify when folder is moved (children handled by parent)', (
      WidgetTester tester,
    ) async {
      final List<Uri> paths = <Uri>[
        Uri.parse('file://root/folder1/file1.txt'),
        Uri.parse('file://root/folder1/file2.txt'),
        Uri.parse('file://root/folder1/subfolder/file3.txt'),
        Uri.parse('file://root/folder2/file4.txt'),
        Uri.parse('file://root/file5.txt'),
      ];

      final List<Uri> reorderHistory = <Uri>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableTreeListView(
              paths: paths,
              initiallyExpanded: <Uri>{
                Uri.parse('file://'),
                Uri.parse('file://root'),
                Uri.parse('file://root/folder1'),
                Uri.parse('file://root/folder1/subfolder'),
                Uri.parse('file://root/folder2'),
              },
              itemBuilder: (BuildContext context, Uri path) => Text(
                path.toString(),
                key: ValueKey<String>(path.toString()),
              ),
              onReorder: (Uri oldPath, Uri newPath) {
                reorderHistory.add(oldPath);
                reorderHistory.add(newPath);
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Debug: print all text widgets
      final Finder allTexts = find.byType(Text);
      for (final Element element in allTexts.evaluate()) {
        final Text text = element.widget as Text;
        if (text.data != null && text.data!.contains('folder1')) {
          debugPrint('Found text: "${text.data}"');
        }
      }

      // Find and drag folder1 (which contains files and a subfolder)
      // Look for the folder text that is exactly the folder path
      final Finder folder1Finder = find.text('file://root/folder1');
      expect(folder1Finder, findsOneWidget);

      // Find folder2
      final Finder folder2Finder = find.text('file://root/folder2');
      expect(folder2Finder, findsOneWidget);

      // Start dragging folder1
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(folder1Finder.first),
      );
      await tester.pump(kLongPressTimeout);

      // Move folder1 after folder2
      final Offset folder2Position = tester.getCenter(folder2Finder);
      await gesture.moveTo(Offset(folder2Position.dx, folder2Position.dy + 50));
      await tester.pump();

      // Release
      await gesture.up();
      await tester.pumpAndSettle();

      // Verify that the folder move was recorded
      expect(reorderHistory.isNotEmpty, true);
      
      // Debug: print all reorder history
      debugPrint('Reorder history:');
      for (int i = 0; i < reorderHistory.length; i += 2) {
        if (i + 1 < reorderHistory.length) {
          debugPrint('  ${reorderHistory[i]} -> ${reorderHistory[i + 1]}');
        }
      }
      
      // Should have the folder move
      expect(reorderHistory.contains(Uri.parse('file://root/folder1')), true);
      
      // The widget should only notify about the folder itself
      // Moving children is the responsibility of the parent widget
      expect(reorderHistory.length, 2, 
          reason: 'Should only have one reorder notification (folder only)');
    });

    /* Commented out - this functionality is tested in folder_drag_expansion_test.dart
    testWidgets('should preserve expansion state after dragging Downloads into Documents', (
      WidgetTester tester,
    ) async {
      // Use the exact same paths as in the simple tree story
      final List<Uri> paths = <Uri>[
        Uri.parse('file:///Documents/Projects/flutter_app/lib/main.dart'),
        Uri.parse('file:///Documents/Projects/flutter_app/lib/models/user.dart'),
        Uri.parse('file:///Documents/Projects/flutter_app/lib/widgets/tree_view.dart'),
        Uri.parse('file:///Documents/Projects/flutter_app/test/widget_test.dart'),
        Uri.parse('file:///Documents/Projects/flutter_app/pubspec.yaml'),
        Uri.parse('file:///Documents/Projects/react_app/src/index.js'),
        Uri.parse('file:///Documents/Projects/react_app/src/components/App.js'),
        Uri.parse('file:///Documents/Projects/react_app/package.json'),
        Uri.parse('file:///Downloads/document.pdf'),
        Uri.parse('file:///Downloads/archive.zip'),
        Uri.parse('file:///Pictures/vacation/beach.jpg'),
        Uri.parse('file:///Pictures/vacation/sunset.jpg'),
        Uri.parse('file:///Pictures/family/birthday.jpg'),
        Uri.parse('file:///Music/playlists/favorites.m3u'),
        Uri.parse('file:///Music/albums/rock/song1.mp3'),
        Uri.parse('file:///Music/albums/rock/song2.mp3'),
      ];

      // Track state changes
      final List<Uri> reorderedPaths = List.from(paths);
      Set<Uri> expandedPaths = <Uri>{};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return ReorderableTreeListView(
                  paths: reorderedPaths,
                  initiallyExpanded: <Uri>{
                    Uri.parse('file:///'),
                    Uri.parse('file:///Documents'),
                    Uri.parse('file:///Downloads'),
                    Uri.parse('file:///Pictures'),
                    Uri.parse('file:///Music'),
                  },
                  itemBuilder: (BuildContext context, Uri path) => Text(
                    path.toString(),
                    key: ValueKey<String>(path.toString()),
                  ),
                  onReorder: (Uri oldPath, Uri newPath) {
                    debugPrint('onReorder called: $oldPath -> $newPath');
                    setState(() {
                      // Remove the old path and add the new path
                      reorderedPaths.remove(oldPath);
                      reorderedPaths.add(newPath);
                    });
                  },
                  onDragStart: (Uri path) {
                    debugPrint('Drag started: $path');
                  },
                  onDragEnd: (Uri path) {
                    debugPrint('Drag ended: $path');
                  },
                  onExpandStart: (Uri path) {
                    expandedPaths.add(path);
                    debugPrint('Expanding: $path');
                  },
                  onCollapseStart: (Uri path) {
                    expandedPaths.remove(path);
                    debugPrint('Collapsing: $path');
                  },
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find Downloads folder
      final Finder downloadsFinder = find.text('file:///Downloads');
      expect(downloadsFinder, findsOneWidget);

      // Find Documents folder  
      final Finder documentsFinder = find.text('file:///Documents');
      expect(documentsFinder, findsOneWidget);

      // Start dragging Downloads
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(downloadsFinder),
      );
      await tester.pump(kLongPressTimeout);

      // Move Downloads just below Documents (to drop it into Documents)
      final Offset documentsPosition = tester.getCenter(documentsFinder);
      await gesture.moveTo(Offset(documentsPosition.dx, documentsPosition.dy + 30));
      await tester.pump();

      // Release
      await gesture.up();
      await tester.pumpAndSettle();

      // Debug: print all paths after reorder
      debugPrint('Paths after reorder:');
      for (final Uri path in reorderedPaths) {
        debugPrint('  $path');
      }

      // Debug: print all visible text widgets
      final Finder allTexts = find.byType(Text);
      debugPrint('Visible text widgets:');
      for (final Element element in allTexts.evaluate()) {
        final Text text = element.widget as Text;
        if (text.data != null) {
          debugPrint('  "${text.data}"');
        }
      }

      // Now try to find and expand the moved Downloads folder
      final Finder newDownloadsFinder = find.text('file:///Documents/Downloads');
      expect(newDownloadsFinder, findsOneWidget, 
          reason: 'Downloads folder should be visible under Documents');

      // Try to tap on the expansion icon for Downloads
      // Find the expansion icon next to Downloads
      final Finder expansionIcon = find.byIcon(Icons.keyboard_arrow_right).at(
        find.ancestor(
          of: newDownloadsFinder,
          matching: find.byType(ReorderableTreeListViewItem),
        ).evaluate().isEmpty ? 0 : 0,
      );
      
      // Tap to expand
      await tester.tap(expansionIcon);
      await tester.pumpAndSettle();

      // Verify Downloads can be expanded and its contents are visible
      final Finder pdfFinder = find.text('file:///Documents/Downloads/document.pdf');
      expect(pdfFinder, findsOneWidget, 
          reason: 'Downloads contents should be visible after expansion');
    });
    */
  });
}
