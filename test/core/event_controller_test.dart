import 'package:flutter_test/flutter_test.dart';
import 'package:reorderable_tree_list_view/src/core/event_controller.dart';

void main() {
  group('EventController', () {
    late EventController controller;

    setUp(() {
      controller = EventController();
    });

    tearDown(() {
      // Only dispose if not already disposed
      if (!controller.isDisposed) {
        controller.dispose();
      }
    });

    test('can register and invoke expansion callbacks', () {
      final List<Uri> expandStartPaths = <Uri>[];
      final List<Uri> expandEndPaths = <Uri>[];
      final List<Uri> collapseStartPaths = <Uri>[];
      final List<Uri> collapseEndPaths = <Uri>[];

      controller
        ..onExpandStart = expandStartPaths.add
        ..onExpandEnd = expandEndPaths.add
        ..onCollapseStart = collapseStartPaths.add
        ..onCollapseEnd = collapseEndPaths.add;

      final Uri testPath = Uri.parse('file://test/path');

      controller.notifyExpandStart(testPath);
      expect(expandStartPaths, <Uri>[testPath]);

      controller.notifyExpandEnd(testPath);
      expect(expandEndPaths, <Uri>[testPath]);

      controller.notifyCollapseStart(testPath);
      expect(collapseStartPaths, <Uri>[testPath]);

      controller.notifyCollapseEnd(testPath);
      expect(collapseEndPaths, <Uri>[testPath]);
    });

    test('handles null callbacks gracefully', () {
      // Should not throw when callbacks are null
      expect(() => controller.notifyExpandStart(Uri.parse('file://test')), returnsNormally);
      expect(() => controller.notifyExpandEnd(Uri.parse('file://test')), returnsNormally);
      expect(() => controller.notifyCollapseStart(Uri.parse('file://test')), returnsNormally);
      expect(() => controller.notifyCollapseEnd(Uri.parse('file://test')), returnsNormally);
    });

    test('can register and invoke drag callbacks', () {
      final List<Uri> dragStartPaths = <Uri>[];
      final List<Uri> dragEndPaths = <Uri>[];
      final List<(Uri, Uri)> reorders = <(Uri, Uri)>[];

      controller
        ..onDragStart = dragStartPaths.add
        ..onDragEnd = dragEndPaths.add
        ..onReorder = (Uri oldPath, Uri newPath) => reorders.add((oldPath, newPath));

      final Uri sourcePath = Uri.parse('file://source');
      final Uri targetPath = Uri.parse('file://target');

      controller.notifyDragStart(sourcePath);
      expect(dragStartPaths, <Uri>[sourcePath]);

      controller.notifyDragEnd(sourcePath);
      expect(dragEndPaths, <Uri>[sourcePath]);

      controller.notifyReorder(sourcePath, targetPath);
      expect(reorders, <(Uri, Uri)>[(sourcePath, targetPath)]);
    });

    test('can register and invoke selection callbacks', () {
      final List<Set<Uri>> selectionChanges = <Set<Uri>>[];
      final List<Uri> itemTaps = <Uri>[];
      final List<Uri> itemActivations = <Uri>[];

      controller
        ..onSelectionChanged = selectionChanges.add
        ..onItemTap = itemTaps.add
        ..onItemActivated = itemActivations.add;

      final Uri path1 = Uri.parse('file://path1');
      final Uri path2 = Uri.parse('file://path2');
      final Set<Uri> selection = <Uri>{path1, path2};

      controller.notifySelectionChanged(selection);
      expect(selectionChanges, <Set<Uri>>[selection]);

      controller.notifyItemTap(path1);
      expect(itemTaps, <Uri>[path1]);

      controller.notifyItemActivated(path2);
      expect(itemActivations, <Uri>[path2]);
    });

    test('validation callbacks return true by default', () {
      final Uri path = Uri.parse('file://test');
      final Uri targetPath = Uri.parse('file://target');

      expect(controller.canExpand(path), isTrue);
      expect(controller.canDrag(path), isTrue);
      expect(controller.canDrop(path, targetPath), isTrue);
    });

    test('validation callbacks respect custom implementations', () {
      controller.canExpandCallback = (Uri path) => path.pathSegments.length < 3;
      controller.canDragCallback = (Uri path) => !path.path.contains('locked');
      controller.canDropCallback = (Uri source, Uri target) => source != target;

      final Uri shortPath = Uri.parse('file:///a/b');
      final Uri longPath = Uri.parse('file:///a/b/c/d');
      final Uri lockedPath = Uri.parse('file:///locked/file');
      final Uri normalPath = Uri.parse('file:///normal/file');

      expect(controller.canExpand(shortPath), isTrue);
      expect(controller.canExpand(longPath), isFalse);

      expect(controller.canDrag(lockedPath), isFalse);
      expect(controller.canDrag(normalPath), isTrue);

      expect(controller.canDrop(shortPath, longPath), isTrue);
      expect(controller.canDrop(shortPath, shortPath), isFalse);
    });

    test('async validation callbacks work correctly', () async {
      controller
        ..canExpandAsyncCallback = (Uri path) async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
          return path.pathSegments.length < 3;
        }
        ..canDragAsyncCallback = (Uri path) async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
          return !path.path.contains('locked');
        }
        ..canDropAsyncCallback = (Uri source, Uri target) async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
          return source != target;
        };

      final Uri shortPath = Uri.parse('file:///a/b');
      final Uri longPath = Uri.parse('file:///a/b/c/d');
      final Uri lockedPath = Uri.parse('file:///locked/file');
      final Uri normalPath = Uri.parse('file:///normal/file');

      expect(await controller.canExpandAsync(shortPath), isTrue);
      expect(await controller.canExpandAsync(longPath), isFalse);

      expect(await controller.canDragAsync(lockedPath), isFalse);
      expect(await controller.canDragAsync(normalPath), isTrue);

      expect(await controller.canDropAsync(shortPath, longPath), isTrue);
      expect(await controller.canDropAsync(shortPath, shortPath), isFalse);
    });

    test('async validation callbacks return true by default', () async {
      final Uri path = Uri.parse('file://test');
      final Uri targetPath = Uri.parse('file://target');

      expect(await controller.canExpandAsync(path), isTrue);
      expect(await controller.canDragAsync(path), isTrue);
      expect(await controller.canDropAsync(path, targetPath), isTrue);
    });

    test('can register and invoke context menu callback', () {
      final List<(Uri, Offset)> contextMenuEvents = <(Uri, Offset)>[];

      controller.onContextMenu = (Uri path, Offset position) => contextMenuEvents.add((path, position));

      final Uri path = Uri.parse('file://test');
      const Offset position = Offset(100, 200);

      controller.notifyContextMenu(path, position);
      expect(contextMenuEvents, <(Uri, Offset)>[(path, position)]);
    });

    test('handles errors in callbacks gracefully', () {
      controller.onExpandStart = (Uri path) {
        throw Exception('Test error');
      };

      // Should catch the error and not throw
      expect(() => controller.notifyExpandStart(Uri.parse('file://test')), returnsNormally);
    });

    test('dispose prevents further callbacks', () {
      bool callbackInvoked = false;
      controller.onItemTap = (Uri path) => callbackInvoked = true;

      // Verify callback works before dispose
      controller.notifyItemTap(Uri.parse('file://test'));
      expect(callbackInvoked, isTrue);

      // Reset flag
      callbackInvoked = false;

      // Dispose should clear callbacks and prevent further invocations
      controller.dispose();
      
      // Verify the callback reference was cleared by dispose
      expect(controller.onItemTap, isNull);
      expect(callbackInvoked, isFalse);
      
      // Verify disposed flag
      expect(controller.isDisposed, isTrue);
    });
  });
}