import 'package:flutter/material.dart';

/// Theme configuration for the tree list view.
///
/// This class defines the visual appearance of tree items including indentation,
/// connectors, colors, and Material Design integration.
@immutable
class TreeTheme {
  /// Creates a tree theme.
  const TreeTheme({
    this.indentSize = 24,
    this.expandIconSize = 24,
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.borderRadius = BorderRadius.zero,
    this.hoverColor,
    this.focusColor,
    this.splashColor,
    this.highlightColor,
  });

  /// Factory constructor that returns the theme from the closest [TreeThemeData] ancestor.
  ///
  /// If no [TreeThemeData] is found, returns a default theme.
  factory TreeTheme.of(BuildContext context) {
    final TreeThemeData? data = context
        .dependOnInheritedWidgetOfExactType<TreeThemeData>();
    return data?.theme ?? const TreeTheme();
  }

  /// The indentation size for each level of nesting.
  final double indentSize;

  /// The size of expand/collapse icons.
  final double expandIconSize;

  /// The padding around each tree item.
  final EdgeInsetsGeometry itemPadding;

  /// The border radius for tree items.
  final BorderRadiusGeometry borderRadius;

  /// The color displayed when a tree item is being hovered over.
  final Color? hoverColor;

  /// The color displayed when a tree item has input focus.
  final Color? focusColor;

  /// The color of the splash effect when a tree item is tapped.
  final Color? splashColor;

  /// The color of the highlight effect when a tree item is pressed.
  final Color? highlightColor;

  /// Returns the theme from the closest [TreeThemeData] ancestor, if any.
  ///
  /// If no [TreeThemeData] is found, returns null.
  static TreeTheme? maybeOf(BuildContext context) {
    final TreeThemeData? data = context
        .dependOnInheritedWidgetOfExactType<TreeThemeData>();
    return data?.theme;
  }

  /// Creates a copy of this theme with the given fields replaced with new values.
  TreeTheme copyWith({
    double? indentSize,
    double? expandIconSize,
    EdgeInsetsGeometry? itemPadding,
    BorderRadiusGeometry? borderRadius,
    Color? hoverColor,
    Color? focusColor,
    Color? splashColor,
    Color? highlightColor,
  }) => TreeTheme(
    indentSize: indentSize ?? this.indentSize,
    expandIconSize: expandIconSize ?? this.expandIconSize,
    itemPadding: itemPadding ?? this.itemPadding,
    borderRadius: borderRadius ?? this.borderRadius,
    hoverColor: hoverColor ?? this.hoverColor,
    focusColor: focusColor ?? this.focusColor,
    splashColor: splashColor ?? this.splashColor,
    highlightColor: highlightColor ?? this.highlightColor,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is TreeTheme &&
        other.indentSize == indentSize &&
        other.expandIconSize == expandIconSize &&
        other.itemPadding == itemPadding &&
        other.borderRadius == borderRadius &&
        other.hoverColor == hoverColor &&
        other.focusColor == focusColor &&
        other.splashColor == splashColor &&
        other.highlightColor == highlightColor;
  }

  @override
  int get hashCode => Object.hash(
    indentSize,
    expandIconSize,
    itemPadding,
    borderRadius,
    hoverColor,
    focusColor,
    splashColor,
    highlightColor,
  );
}

/// An [InheritedWidget] that provides a [TreeTheme] to its descendants.
class TreeThemeData extends InheritedWidget {
  /// Creates a tree theme data widget.
  const TreeThemeData({required this.theme, required super.child, super.key});

  /// The tree theme configuration.
  final TreeTheme theme;

  @override
  bool updateShouldNotify(TreeThemeData oldWidget) => theme != oldWidget.theme;
}
