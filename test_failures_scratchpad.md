# Test Failures Scratchpad

## Failed Tests

### ✅ 1. ReorderableTreeListView Drag and Drop - should call onReorder when item is moved
- **File**: test/widgets/reorderable_tree_list_view_drag_drop_test.dart:75
- **Error**: Expected Uri:<file://folder1/file1.txt>, Actual: <null>
- **Description**: The onReorder callback is not being called with the expected path when an item is moved via drag and drop.
- **Status**: FIXED ✅
- **Fix Applied**: Added direct callback invocation alongside Actions.maybeInvoke to maintain backward compatibility

### ✅ 2. ReorderableTreeListView Drag and Drop - should handle complex tree reorganization  
- **File**: test/widgets/reorderable_tree_list_view_drag_drop_test.dart:243
- **Error**: Expected Uri:<file://projecta/src/utils/helpers.dart>, Actual: <null>
- **Description**: Complex tree reorganization is not triggering the onReorder callback with the expected path.
- **Status**: FIXED ✅
- **Fix Applied**: Same fix as above - restored callback invocation

## Root Cause Analysis

The issue was that in my Actions and Intents implementation, I replaced the direct callback invocation with Actions.maybeInvoke but forgot to maintain backward compatibility by also calling the original callback.

## Fix Applied

Modified `_handleReorder` method in ReorderableTreeListView to call both:
1. `Actions.maybeInvoke(context, MoveNodeIntent(...))` - for the new Actions system
2. `widget.onReorder?.call(draggedNode.path, newPath)` - for backward compatibility

This ensures that existing code using callbacks continues to work while new code can leverage the Actions system.