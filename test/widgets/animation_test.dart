import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

import '../test_utils.dart';

void main() {
  group('Animation Tests', () {
    testWidgets('should animate expansion when animateExpansion is true', (WidgetTester tester) async {
      final List<Uri> paths = TestUtils.sampleFilePaths;
      
      await tester.pumpWidget(TestUtils.createTestApp(
        paths: paths,
        animateExpansion: true,
        initiallyExpanded: <Uri>{Uri.parse('file:///')},
      ));

      // Find the folder1 item
      final Finder folder1Item = find.ancestor(
        of: find.text('folder1'),
        matching: find.byType(ReorderableTreeListViewItem),
      );
      
      // Find the expansion icon within folder1
      final Finder expandIcon = find.descendant(
        of: folder1Item,
        matching: find.byIcon(Icons.keyboard_arrow_right),
      );
      
      expect(expandIcon, findsOneWidget);
      
      // Tap to expand
      await tester.tap(expandIcon);
      
      // Pump to start animation
      await tester.pump();
      
      // During animation, we should have an animated widget within folder1
      expect(find.descendant(
        of: folder1Item,
        matching: find.byType(AnimatedRotation),
      ), findsOneWidget);
      
      // Complete animation
      await tester.pumpAndSettle();
      
      // After animation, the AnimatedRotation should still be there
      // but rotated to show as down arrow (0.25 turns = 90 degrees)
      final AnimatedRotation animatedIcon = tester.widget<AnimatedRotation>(
        find.descendant(
          of: folder1Item,
          matching: find.byType(AnimatedRotation),
        ),
      );
      expect(animatedIcon.turns, 0.25);
    });

    testWidgets('should not animate expansion when animateExpansion is false', (WidgetTester tester) async {
      final List<Uri> paths = TestUtils.sampleFilePaths;
      
      await tester.pumpWidget(TestUtils.createTestApp(
        paths: paths,
        animateExpansion: false,
        initiallyExpanded: <Uri>{Uri.parse('file:///')},
      ));

      // Find the folder1 item
      final Finder folder1Item = find.ancestor(
        of: find.text('folder1'),
        matching: find.byType(ReorderableTreeListViewItem),
      );
      
      // Find the expansion icon within folder1
      final Finder expandIcon = find.descendant(
        of: folder1Item,
        matching: find.byIcon(Icons.keyboard_arrow_right),
      );
      
      expect(expandIcon, findsOneWidget);
      
      // Tap to expand
      await tester.tap(expandIcon);
      
      // Pump once
      await tester.pump();
      
      // Without animation, icon should immediately change within folder1
      expect(find.descendant(
        of: folder1Item,
        matching: find.byIcon(Icons.keyboard_arrow_down),
      ), findsOneWidget);
      expect(find.descendant(
        of: folder1Item,
        matching: find.byIcon(Icons.keyboard_arrow_right),
      ), findsNothing);
      
      // No animated widgets should be present
      expect(find.byType(AnimatedRotation), findsNothing);
    });

    testWidgets('should animate collapse when animateExpansion is true', (WidgetTester tester) async {
      final List<Uri> paths = TestUtils.sampleFilePaths;
      
      await tester.pumpWidget(TestUtils.createTestApp(
        paths: paths,
        animateExpansion: true,
        initiallyExpanded: <Uri>{
          Uri.parse('file:///'),
          Uri.parse('file:///folder1'),
        },
      ));

      // Find the folder1 item
      final Finder folder1Item = find.ancestor(
        of: find.text('folder1'),
        matching: find.byType(ReorderableTreeListViewItem),
      );
      
      // Initially should be expanded (0.25 turns)
      AnimatedRotation animatedIcon = tester.widget<AnimatedRotation>(
        find.descendant(
          of: folder1Item,
          matching: find.byType(AnimatedRotation),
        ),
      );
      expect(animatedIcon.turns, 0.25);
      
      // Find and tap the collapse icon
      final Finder collapseIcon = find.descendant(
        of: folder1Item,
        matching: find.byType(IconButton),
      );
      
      await tester.tap(collapseIcon);
      
      // Pump to start animation
      await tester.pump();
      
      // Complete animation
      await tester.pumpAndSettle();
      
      // After animation, should be collapsed (0.0 turns)
      animatedIcon = tester.widget<AnimatedRotation>(
        find.descendant(
          of: folder1Item,
          matching: find.byType(AnimatedRotation),
        ),
      );
      expect(animatedIcon.turns, 0.0);
    });
  });
}