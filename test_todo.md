# Test TODO List

## Summary
Total tests: 249 (some tests didn't run due to errors)
Passed: 200
Failed: 49

## Current Issues
1. Drag and drop tests expect folder drop functionality but ReorderableListView only supports reordering
   - Tests expect dragging files into folders (e.g., file5.txt → folder1/file5.txt)
   - Current implementation only supports reordering at same level
   
2. Actions integration tests expect parent Actions widgets to override tree's Actions
   - Tree creates its own Actions widget which overrides parent Actions
   - Tests are written for a feature that isn't implemented yet
   
3. Some tests have basic issues:
   - Wrong icon names in TestUtils (fixed)
   - Index out of bounds in drag end callback (fixed)
   - URI parsing issues in DragDropHandler (fixed)

## Failed Tests

### test/accessibility/keyboard_test.dart (0 failures)
- All tests passed ✅

### test/accessibility/screen_reader_test.dart (0 failures)
- All tests passed ✅

### test/actions/copy_node_action_test.dart (4 failures)
1. CopyNodeAction should copy single node to clipboard
2. CopyNodeAction should copy multiple nodes to clipboard
3. CopyNodeAction should return null when invoked (consumed)
4. CopyNodeAction should handle intents without context

### test/actions/delete_node_action_test.dart (4 failures)
1. DeleteNodeAction should delete single node from tree
2. DeleteNodeAction should delete multiple nodes from tree
3. DeleteNodeAction should return null when invoked (consumed)
4. DeleteNodeAction should handle intents without context

### test/actions/move_node_action_test.dart (4 failures)
1. MoveNodeAction should move node to new location
2. MoveNodeAction should handle invalid moves gracefully
3. MoveNodeAction should return null when invoked (consumed)
4. MoveNodeAction should handle intents without context

### test/actions/paste_node_action_test.dart (4 failures)
1. PasteNodeAction should paste single node from clipboard
2. PasteNodeAction should paste multiple nodes from clipboard
3. PasteNodeAction should return null when invoked (consumed)
4. PasteNodeAction should handle intents without context

### test/actions/tree_copy_action_test.dart (4 failures)
1. TreeCopyAction should copy all selected nodes
2. TreeCopyAction should handle empty selection gracefully
3. TreeCopyAction should return null when invoked (consumed)
4. TreeCopyAction should handle intents without context

### test/actions/tree_delete_action_test.dart (4 failures)
1. TreeDeleteAction should delete all selected nodes
2. TreeDeleteAction should handle empty selection gracefully
3. TreeDeleteAction should return null when invoked (consumed)
4. TreeDeleteAction should handle intents without context

### test/actions/tree_paste_action_test.dart (4 failures)
1. TreePasteAction should paste at current focus position
2. TreePasteAction should handle no focus gracefully
3. TreePasteAction should return null when invoked (consumed)
4. TreePasteAction should handle intents without context

### test/widgets/reorderable_tree_list_view_actions_test.dart (21 failures)
1. ReorderableTreeListView Actions MoveNodeAction should move node via Action
2. ReorderableTreeListView Actions MoveNodeAction should handle invalid move gracefully
3. ReorderableTreeListView Actions MoveNodeAction should be accessible via Actions.invoke
4. ReorderableTreeListView Actions DeleteNodeAction should delete node via Action
5. ReorderableTreeListView Actions DeleteNodeAction should handle multiple delete gracefully
6. ReorderableTreeListView Actions DeleteNodeAction should be accessible via Actions.invoke
7. ReorderableTreeListView Actions CopyNodeAction should copy node to clipboard
8. ReorderableTreeListView Actions CopyNodeAction should handle multiple copy
9. ReorderableTreeListView Actions CopyNodeAction should be accessible via Actions.invoke
10. ReorderableTreeListView Actions PasteNodeAction should paste from clipboard
11. ReorderableTreeListView Actions PasteNodeAction should handle paste into folder
12. ReorderableTreeListView Actions PasteNodeAction should be accessible via Actions.invoke
13. ReorderableTreeListView Actions TreeSelectAllAction should select all visible nodes
14. ReorderableTreeListView Actions TreeSelectAllAction should be accessible via Actions.invoke
15. ReorderableTreeListView Actions TreeExpandAllAction should expand all folders
16. ReorderableTreeListView Actions TreeExpandAllAction should be accessible via Actions.invoke
17. ReorderableTreeListView Actions TreeCollapseAllAction should collapse all folders
18. ReorderableTreeListView Actions TreeCollapseAllAction should be accessible via Actions.invoke
19. ReorderableTreeListView Actions TreeCopyAction should copy selected nodes
20. ReorderableTreeListView Actions TreeDeleteAction should delete selected nodes
21. ReorderableTreeListView Actions TreePasteAction should paste at focused position

### test/widgets/reorderable_tree_list_view_keyboard_test.dart (0 failures)
- All tests passed ✅

## Fix Order
1. Start with action tests (they seem to have consistent patterns)
2. Then fix the widget action tests
3. Finally fix the keyboard tests