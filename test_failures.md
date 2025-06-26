# Test Failures TODO List

## Keyboard Navigation Tests

1. ❌ **Focus Management - should focus first item on initial tab**
   - Issue: Focus system mismatch - tests expect individual item focus
   - Fix: Update implementation to use individual FocusNodes per item

2. ❌ **Focus Management - should maintain focus during tree updates**
   - Issue: Focus not persisting after tree update
   - Fix: Preserve focus state across rebuilds

3. ❌ **Arrow Navigation - should navigate down with arrow down**
   - Issue: Focus not moving to next item
   - Fix: Implement proper focus traversal

4. ❌ **Arrow Navigation - should navigate up with arrow up**
   - Issue: Focus not moving to previous item
   - Fix: Implement proper focus traversal

5. ❌ **Arrow Navigation - should expand folder with arrow right**
   - Issue: Expansion not working with keyboard
   - Fix: Handle expansion in keyboard controller

6. ❌ **Arrow Navigation - should collapse folder with arrow left**
   - Issue: Collapse not working with keyboard
   - Fix: Handle collapse in keyboard controller

7. ❌ **Arrow Navigation - should move to parent with arrow left on leaf**
   - Issue: Parent navigation not working
   - Fix: Implement parent navigation logic

8. ❌ **Home/End Navigation - should jump to first item with Home**
   - Issue: Home key not working
   - Fix: Implement Home key handler

9. ❌ **Home/End Navigation - should jump to last item with End**
   - Issue: End key not working
   - Fix: Implement End key handler

10. ❌ **Item Activation - should activate item with Enter**
    - Issue: Enter key not triggering activation
    - Fix: Handle Enter key in keyboard controller

11. ❌ **Item Activation - should activate item with Space**
    - Issue: Space key not triggering activation
    - Fix: Handle Space key in keyboard controller

12. ❌ **Selection - should select item in single selection mode**
    - Issue: Selection not working
    - Fix: Implement selection handling

13. ❌ **Selection - should handle multiple selection with Ctrl+Space**
    - Issue: Multiple selection not working
    - Fix: Implement multi-selection logic

14. ❌ **Selection - should handle range selection with Shift+Arrow**
    - Issue: Range selection not working
    - Fix: Implement range selection logic

15. ❌ **Accessibility - should disable keyboard navigation when flag is false**
    - Issue: Keyboard still active when disabled
    - Fix: Respect enableKeyboardNavigation flag

16. ❌ **Accessibility - should announce tree structure with Semantics**
    - Issue: Semantic labels not matching expectations
    - Fix: Update semantic label generation