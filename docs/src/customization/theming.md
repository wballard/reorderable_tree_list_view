# Theming

ReorderableTreeListView provides extensive theming capabilities through the `TreeTheme` class, allowing you to customize the visual appearance of your tree view to match your application's design system.

## TreeTheme Overview

The `TreeTheme` class controls the visual aspects of the tree view:

```dart
ReorderableTreeListView(
  paths: paths,
  theme: TreeTheme(
    indentSize: 32.0,
    expandIconSize: 20.0,
    itemPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    borderRadius: BorderRadius.circular(8),
    hoverColor: Colors.grey.shade100,
    focusColor: Colors.blue.shade100,
    splashColor: Colors.blue.shade200,
    highlightColor: Colors.blue.shade50,
  ),
  itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
)
```

## Theme Properties

### Indentation

Control the horizontal spacing for each tree level:

```dart
TreeTheme(
  indentSize: 24.0, // Default indentation per level
)

// Examples of different indentation sizes
TreeTheme(indentSize: 16.0), // Compact
TreeTheme(indentSize: 32.0), // Spacious
TreeTheme(indentSize: 48.0), // Very spacious
```

### Icon Sizing

Customize expand/collapse icon appearance:

```dart
TreeTheme(
  expandIconSize: 20.0, // Size of expand/collapse icons
)

// Different icon sizes
TreeTheme(expandIconSize: 16.0), // Small icons
TreeTheme(expandIconSize: 24.0), // Large icons
```

### Item Padding

Control spacing around tree items:

```dart
TreeTheme(
  itemPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
)

// Different padding configurations
TreeTheme(
  itemPadding: EdgeInsets.all(12), // Equal padding all sides
)

TreeTheme(
  itemPadding: EdgeInsets.only(
    left: 20,
    right: 16,
    top: 6,
    bottom: 6,
  ),
)
```

### Border Radius

Add rounded corners to tree items:

```dart
TreeTheme(
  borderRadius: BorderRadius.circular(8), // Rounded corners
)

// Different border radius styles
TreeTheme(
  borderRadius: BorderRadius.circular(4), // Subtle rounding
)

TreeTheme(
  borderRadius: BorderRadius.only(
    topLeft: Radius.circular(8),
    topRight: Radius.circular(8),
  ), // Top corners only
)
```

### Interaction Colors

Customize colors for user interactions:

```dart
TreeTheme(
  hoverColor: Colors.grey.shade100,      // Color when hovering
  focusColor: Colors.blue.shade100,      // Color when focused
  splashColor: Colors.blue.shade200,     // Tap splash effect
  highlightColor: Colors.blue.shade50,   // Highlight color
)
```

## Complete Theme Examples

### Material Design 3 Theme

```dart
TreeTheme materialTheme(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  
  return TreeTheme(
    indentSize: 24.0,
    expandIconSize: 20.0,
    itemPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    borderRadius: BorderRadius.circular(12),
    hoverColor: colorScheme.onSurface.withOpacity(0.08),
    focusColor: colorScheme.onSurface.withOpacity(0.12),
    splashColor: colorScheme.onSurface.withOpacity(0.16),
    highlightColor: colorScheme.onSurface.withOpacity(0.04),
  );
}

// Usage
ReorderableTreeListView(
  paths: paths,
  theme: materialTheme(context),
  itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
)
```

### Compact Theme

```dart
const TreeTheme compactTheme = TreeTheme(
  indentSize: 16.0,
  expandIconSize: 16.0,
  itemPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  borderRadius: BorderRadius.zero,
  hoverColor: Color(0x0F000000),
);

// Usage
ReorderableTreeListView(
  paths: paths,
  theme: compactTheme,
  itemBuilder: (context, path) => Text(
    TreePath.getDisplayName(path),
    style: TextStyle(fontSize: 14),
  ),
)
```

### Card-like Theme

```dart
TreeTheme cardTheme(BuildContext context) {
  return TreeTheme(
    indentSize: 28.0,
    expandIconSize: 22.0,
    itemPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    borderRadius: BorderRadius.circular(16),
    hoverColor: Colors.grey.shade50,
    focusColor: Colors.blue.shade50,
    splashColor: Colors.blue.shade100,
    highlightColor: Colors.blue.shade25,
  );
}

// Usage with shadow effect
ReorderableTreeListView(
  paths: paths,
  theme: cardTheme(context),
  itemBuilder: (context, path) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(TreePath.getDisplayName(path)),
    );
  },
)
```

## Dark Theme Support

### Adaptive Theme

```dart
TreeTheme adaptiveTheme(BuildContext context) {
  final brightness = Theme.of(context).brightness;
  final isDark = brightness == Brightness.dark;
  
  return TreeTheme(
    indentSize: 24.0,
    expandIconSize: 20.0,
    itemPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    borderRadius: BorderRadius.circular(8),
    hoverColor: isDark 
      ? Colors.white.withOpacity(0.08)
      : Colors.black.withOpacity(0.04),
    focusColor: isDark
      ? Colors.white.withOpacity(0.12)
      : Colors.black.withOpacity(0.08),
    splashColor: isDark
      ? Colors.white.withOpacity(0.16)
      : Colors.black.withOpacity(0.12),
    highlightColor: isDark
      ? Colors.white.withOpacity(0.04)
      : Colors.black.withOpacity(0.02),
  );
}
```

### Custom Dark Theme

```dart
const TreeTheme darkTheme = TreeTheme(
  indentSize: 28.0,
  expandIconSize: 20.0,
  itemPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  borderRadius: BorderRadius.circular(6),
  hoverColor: Color(0x1FFFFFFF),
  focusColor: Color(0x2FFFFFFF),
  splashColor: Color(0x3FFFFFFF),
  highlightColor: Color(0x0FFFFFFF),
);
```

## Theme Inheritance

### Using TreeThemeData Widget

Provide theme to multiple tree views using `TreeThemeData`:

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TreeThemeData(
        theme: TreeTheme(
          indentSize: 32.0,
          expandIconSize: 24.0,
          itemPadding: EdgeInsets.all(12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // This tree inherits the theme from TreeThemeData
          Expanded(
            child: ReorderableTreeListView(
              paths: paths1,
              itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
            ),
          ),
          
          // This tree overrides the inherited theme
          Expanded(
            child: ReorderableTreeListView(
              paths: paths2,
              theme: TreeTheme(indentSize: 16.0), // Override
              itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Accessing Inherited Theme

```dart
class CustomTreeItem extends StatelessWidget {
  final Uri path;
  
  const CustomTreeItem({required this.path});
  
  @override
  Widget build(BuildContext context) {
    final theme = TreeTheme.of(context); // Get inherited theme
    
    return Container(
      padding: theme.itemPadding,
      decoration: BoxDecoration(
        borderRadius: theme.borderRadius,
        color: theme.hoverColor,
      ),
      child: Text(TreePath.getDisplayName(path)),
    );
  }
}
```

## Advanced Theming

### Context-Sensitive Theming

```dart
class ContextualThemeExample extends StatelessWidget {
  final List<Uri> paths;
  
  const ContextualThemeExample({required this.paths});
  
  @override
  Widget build(BuildContext context) {
    return ReorderableTreeListView(
      paths: paths,
      theme: _getContextualTheme(context),
      itemBuilder: (context, path) => _buildContextualItem(context, path),
    );
  }
  
  TreeTheme _getContextualTheme(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Adjust theme based on screen size
    if (screenWidth < 600) {
      // Mobile theme
      return TreeTheme(
        indentSize: 16.0,
        expandIconSize: 18.0,
        itemPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        borderRadius: BorderRadius.circular(4),
      );
    } else {
      // Desktop theme
      return TreeTheme(
        indentSize: 32.0,
        expandIconSize: 24.0,
        itemPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        borderRadius: BorderRadius.circular(8),
      );
    }
  }
  
  Widget _buildContextualItem(BuildContext context, Uri path) {
    final isTablet = MediaQuery.of(context).size.width > 768;
    
    return Text(
      TreePath.getDisplayName(path),
      style: TextStyle(
        fontSize: isTablet ? 16 : 14,
      ),
    );
  }
}
```

### Animation-Aware Theming

```dart
class AnimatedThemeExample extends StatefulWidget {
  @override
  State<AnimatedThemeExample> createState() => _AnimatedThemeExampleState();
}

class _AnimatedThemeExampleState extends State<AnimatedThemeExample>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ReorderableTreeListView(
          paths: paths,
          theme: TreeTheme(
            indentSize: 24.0 + (_animation.value * 16.0), // Animate indent
            expandIconSize: 20.0 + (_animation.value * 8.0), // Animate icon size
            itemPadding: EdgeInsets.symmetric(
              horizontal: 16 + (_animation.value * 8),
              vertical: 8 + (_animation.value * 4),
            ),
            borderRadius: BorderRadius.circular(4.0 + (_animation.value * 12.0)),
            hoverColor: Color.lerp(
              Colors.grey.shade100,
              Colors.blue.shade100,
              _animation.value,
            ),
          ),
          itemBuilder: (context, path) => Text(TreePath.getDisplayName(path)),
        );
      },
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

## Custom Theme Properties

### Creating Theme Extensions

```dart
class CustomTreeTheme extends TreeTheme {
  const CustomTreeTheme({
    super.indentSize,
    super.expandIconSize,
    super.itemPadding,
    super.borderRadius,
    super.hoverColor,
    super.focusColor,
    super.splashColor,
    super.highlightColor,
    this.selectedColor,
    this.selectedTextColor,
    this.dragColor,
  });
  
  final Color? selectedColor;
  final Color? selectedTextColor;
  final Color? dragColor;
  
  @override
  CustomTreeTheme copyWith({
    double? indentSize,
    double? expandIconSize,
    EdgeInsetsGeometry? itemPadding,
    BorderRadiusGeometry? borderRadius,
    Color? hoverColor,
    Color? focusColor,
    Color? splashColor,
    Color? highlightColor,
    Color? selectedColor,
    Color? selectedTextColor,
    Color? dragColor,
  }) {
    return CustomTreeTheme(
      indentSize: indentSize ?? this.indentSize,
      expandIconSize: expandIconSize ?? this.expandIconSize,
      itemPadding: itemPadding ?? this.itemPadding,
      borderRadius: borderRadius ?? this.borderRadius,
      hoverColor: hoverColor ?? this.hoverColor,
      focusColor: focusColor ?? this.focusColor,
      splashColor: splashColor ?? this.splashColor,
      highlightColor: highlightColor ?? this.highlightColor,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedTextColor: selectedTextColor ?? this.selectedTextColor,
      dragColor: dragColor ?? this.dragColor,
    );
  }
}
```

## Best Practices

### 1. Consistency with App Theme

```dart
// ✅ Good: Use app's color scheme
TreeTheme(
  hoverColor: Theme.of(context).hoverColor,
  focusColor: Theme.of(context).focusColor,
)

// ❌ Avoid: Hard-coded colors that clash
TreeTheme(
  hoverColor: Colors.red, // May not fit app theme
)
```

### 2. Accessibility Considerations

```dart
// ✅ Good: Sufficient contrast
TreeTheme(
  hoverColor: Colors.grey.shade100,      // Light hover
  focusColor: Colors.blue.shade100,      // Visible focus
)

// ❌ Poor: Low contrast
TreeTheme(
  hoverColor: Colors.grey.shade50,       // Too subtle
  focusColor: Colors.grey.shade75,       // Hard to see
)
```

### 3. Platform Adaptation

```dart
TreeTheme platformTheme(BuildContext context) {
  switch (Theme.of(context).platform) {
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return TreeTheme(
        borderRadius: BorderRadius.circular(8),
        itemPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      );
    
    case TargetPlatform.android:
    case TargetPlatform.fuchsia:
      return TreeTheme(
        borderRadius: BorderRadius.circular(4),
        itemPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      );
    
    default:
      return TreeTheme();
  }
}
```

### 4. Performance Optimization

```dart
// ✅ Good: Static theme for better performance
static const TreeTheme appTreeTheme = TreeTheme(
  indentSize: 24.0,
  expandIconSize: 20.0,
  itemPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
);

// ❌ Avoid: Creating new theme on every build
TreeTheme(
  indentSize: 24.0,
  expandIconSize: 20.0,
  itemPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
)
```

## See Also

- [Basic Example](../getting-started/basic-example.md) - Simple theming examples
- [Widget Architecture](../core-concepts/widget-architecture.md) - How theming works internally
- [API Reference](../api/tree-theme.md) - Complete TreeTheme API
- [Custom Item Builders](./item-builders.md) - Combining themes with custom builders