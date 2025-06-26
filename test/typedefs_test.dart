import 'package:flutter_test/flutter_test.dart';
import 'package:reorderable_tree_list_view/src/typedefs.dart';

void main() {
  group('Typedefs', () {
    test('expansion callbacks have correct signatures', () {
      // Test that we can create instances of each typedef
      TreeExpandCallback? onExpandStart;
      TreeExpandCallback? onExpandEnd;
      TreeExpandCallback? onCollapseStart;
      TreeExpandCallback? onCollapseEnd;
      
      // Assign functions with matching signatures
      onExpandStart = (Uri path) {};
      onExpandEnd = (Uri path) {};
      onCollapseStart = (Uri path) {};
      onCollapseEnd = (Uri path) {};
      
      // Verify they're not null after assignment
      expect(onExpandStart, isNotNull);
      expect(onExpandEnd, isNotNull);
      expect(onCollapseStart, isNotNull);
      expect(onCollapseEnd, isNotNull);
    });
    
    test('drag callbacks have correct signatures', () {
      TreeDragStartCallback? onDragStart;
      TreeDragEndCallback? onDragEnd;
      TreeReorderCallback? onReorder;
      
      onDragStart = (Uri path) {};
      onDragEnd = (Uri path) {};
      onReorder = (Uri oldPath, Uri newPath) {};
      
      expect(onDragStart, isNotNull);
      expect(onDragEnd, isNotNull);
      expect(onReorder, isNotNull);
    });
    
    test('selection callbacks have correct signatures', () {
      TreeSelectionChangedCallback? onSelectionChanged;
      TreeItemTapCallback? onItemTap;
      TreeItemActivatedCallback? onItemActivated;
      
      onSelectionChanged = (Set<Uri> selection) {};
      onItemTap = (Uri path) {};
      onItemActivated = (Uri path) {};
      
      expect(onSelectionChanged, isNotNull);
      expect(onItemTap, isNotNull);
      expect(onItemActivated, isNotNull);
    });
    
    test('validation callbacks have correct signatures', () {
      TreeCanExpandCallback? canExpand;
      TreeCanDragCallback? canDrag;
      TreeCanDropCallback? canDrop;
      
      canExpand = (Uri path) => true;
      canDrag = (Uri path) => true;
      canDrop = (Uri draggedPath, Uri targetPath) => true;
      
      expect(canExpand, isNotNull);
      expect(canDrag, isNotNull);
      expect(canDrop, isNotNull);
      expect(canExpand(Uri.parse('file://test')), isTrue);
      expect(canDrag(Uri.parse('file://test')), isTrue);
      expect(canDrop(Uri.parse('file://a'), Uri.parse('file://b')), isTrue);
    });
    
    test('context menu callback has correct signature', () {
      TreeContextMenuCallback? onContextMenu;
      
      onContextMenu = (Uri path, Offset globalPosition) {};
      
      expect(onContextMenu, isNotNull);
    });
    
    test('async validation callbacks have correct signatures', () {
      TreeCanExpandAsyncCallback? canExpandAsync;
      TreeCanDragAsyncCallback? canDragAsync;
      TreeCanDropAsyncCallback? canDropAsync;
      
      canExpandAsync = (Uri path) async => true;
      canDragAsync = (Uri path) async => true;
      canDropAsync = (Uri draggedPath, Uri targetPath) async => true;
      
      expect(canExpandAsync, isNotNull);
      expect(canDragAsync, isNotNull);
      expect(canDropAsync, isNotNull);
    });
  });
}