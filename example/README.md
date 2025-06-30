# ReorderableTreeListView Storybook

This directory contains the interactive Storybook documentation for the ReorderableTreeListView widget.

## Overview

The Storybook showcases all features of the ReorderableTreeListView widget with interactive examples, making it easy for developers to understand and experiment with the widget's capabilities.

## Running Locally

```bash
cd example
flutter run -d chrome
```

## Story Categories

### 1. Basic Stories
- **Simple Tree**: Basic tree with minimal configuration
- **File System**: Tree displaying file system structure
- **Custom Item Builder**: Custom item and folder builders
- **Minimal Example**: Quick start example

### 2. Interaction Stories
- **Drag and Drop**: Reordering with visual feedback
- **Selection Modes**: Single, multiple, and no selection
- **Context Menu**: Right-click context menu support
- **Validation**: Control user actions with callbacks
- **Event Handling**: Comprehensive event handling

### 3. Theme Stories
- **Basic Theming**: Simple theme customization
- **Advanced Styling**: Custom colors and effects
- **Dark Mode**: Dark theme showcase
- **Material Design**: Material Design 3 integration
- **Custom Indicators**: Custom expand/collapse indicators

### 4. Data Stories
- **Large Dataset**: Performance with hierarchical data
- **Dynamic Data**: Add/remove items dynamically
- **Different URI Schemes**: Various URI types (file://, https://, custom://)
- **Empty States**: Handle empty data and loading
- **Deep Hierarchy**: Very deep tree structures

### 5. Accessibility Stories
- **Keyboard Navigation**: Navigate with keyboard shortcuts
- **Screen Reader**: Semantic labels and ARIA support
- **Focus Management**: Visual focus indicators
- **High Contrast**: Accessibility themes
- **Voice Control**: Voice control simulation

## Interactive Features

Each story includes:
- **Knobs**: Interactive controls to modify widget properties
- **Device Preview**: Test on different screen sizes
- **Theme Switching**: Toggle between light and dark themes
- **Live Code**: See the code for each example

## Deployment

### Manual Deployment

```bash
# Run the deployment script
./deploy_storybook.sh
```

### Automated Deployment

The Storybook is automatically deployed to GitHub Pages when changes are pushed to the main branch.

## Development

### Adding New Stories

1. Create a new story file in `stories/`
2. Import it in the appropriate category
3. Add it to the stories list in `main.dart`

Example:
```dart
Story(
  name: 'Category/Story Name',
  description: 'Brief description of what this story demonstrates',
  builder: (context) => YourStoryWidget(),
)
```

### Story Best Practices

1. Use descriptive names with category prefixes
2. Add clear descriptions for each story
3. Use knobs for interactive properties
4. Include realistic example data
5. Show both code and visual output
6. Test on different screen sizes
7. Ensure accessibility compliance

## Web Build

To build for web deployment:

```bash
cd example
flutter build web 
```

The built files will be in `build/web/` directory.