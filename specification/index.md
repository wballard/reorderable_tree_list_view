# ReorderableTreeListView Specification

ReorderableTreeListView is a tree view Flutter widget modeled on ReorderableListView.

This widget uses a unique approach of managing just a list of paths, with builder callbacks to provide Widgets for those paths.

## Technology

- Use storybook_flutter https://pub.dev/packages/storybook_flutter

## Standards

Create thoughful and easy to use Flutter Widgets following Material Design.

Search the web for inspiration from other tree view controls. Use this to create a plan for an excellent tree view control that will exceed user expectations.

Think deeply about the properties to pass to the constructor.

Think deeply about the Intents each widget will invoke, and how Actions to handle intents.
All callbacks `onX` should have a corresponding Intent.

## Concepts

We have:

- ReorderableTreeListView: the overall list
- ReorderableTreeListViewItem: this will be built for a single 'row' or item in the List
- Path: each Widget is paired with a Path, which is an URI

## Guidelines

- use ReorderableListView as the base implementation, ReorderableTreeListView delegates to ReorderableListView
  - this allows recycling the drag and drop, list index builder behavior
- ReorderableTreeListViewItem in the list need to indent automatically a theme driven amount per path segment nesting
- the programmer does not create ReorderableTreeListViewItem, they create a Widget that is its child
- maintain internal state of collapsed and expanded nodes to compute the list of Paths actually showing
  - use this to delegate to the underlying ReorderableListView itemCount

## Requirements

### Paths

As a programmer, I want to supply the constructor with a List<Uri> of paths.

This will be a sparse list of paths, and I expect the tree to fill in the gaps.

As a programmer, I do not expect to supply `children`.

### Item Nodes

As a programmer, I want to be able to create new Widgets for nodes with an itemBuilder(context, path).

### Automatic Folder Nodes

As a programmer, I want to be able to create folder Widgets to fill in missing gaps in the path.

Assuming I add a path file://var/data/readme.txt. This will internally create a sorted list of paths:

- file://
- file://var
- file://var/data
- file://var/data/readme.txt

Scheme at the root, then nested by path segments, then finally the entire path.

### Drag and Drop

As a user, I want to drag and drop Widgets to move them to another path.
I expect that when I drag and item, it's 'parent path' is set to the same as the preceding item.

As a programmer, I expect a onMoveStart(path), onMoveEnd(oldPath, newPath) callbacks.

### Indentation

As a user, I expect Widgets to be indented based on the segments of their Uri path.

### Collapse

As a user, I want to be able to collapse a Widget, hiding all items with a subordinate path.

As a programmer, I expect

- onExpandStart(path)
- onExpandEnd(path)
- onCollapseStart(path)
- onCollapseEnd(path)

### Nest Indicators

As a user I want visual indentation showing the path nesting.

I do not need 'tree lines' like old style tree controls.

As a programmer, I want these visual indicators to use Theme information from Divider.

### Keyboard Navigation

As a user I want to be able to navigate using keyboard shortcuts for accessibility.

### Example Project

As a programmer, I want an example project using Storybook that show me how to use the widget.
