import 'package:flutter/material.dart';

/// A custom painter that draws tree connector lines.
///
/// This painter draws vertical and horizontal lines to visually connect
/// tree nodes and show the hierarchical structure.
class TreeConnectorPainter extends CustomPainter {
  /// Creates a tree connector painter.
  const TreeConnectorPainter({
    required this.depth,
    required this.indentSize,
    required this.connectorColor,
    required this.connectorWidth,
    this.hasChildren = false,
    this.isExpanded = false,
    this.isLastInLevel = false,
    this.parentConnections = const <bool>[],
  });

  /// The depth of the current node.
  final int depth;

  /// The indentation size for each level.
  final double indentSize;

  /// The color of the connector lines.
  final Color connectorColor;

  /// The width of the connector lines.
  final double connectorWidth;

  /// Whether this node has children.
  final bool hasChildren;

  /// Whether this node is expanded (only relevant if hasChildren is true).
  final bool isExpanded;

  /// Whether this is the last node at its level.
  final bool isLastInLevel;

  /// List of booleans indicating which parent levels have more siblings.
  /// Used to determine which vertical lines to draw.
  final List<bool> parentConnections;

  @override
  void paint(Canvas canvas, Size size) {
    if (depth == 0) {
      return; // No connectors for root level
    }

    final Paint paint = Paint()
      ..color = connectorColor
      ..strokeWidth = connectorWidth
      ..style = PaintingStyle.stroke;

    final double centerY = size.height / 2;
    final double halfIndent = indentSize / 2;

    // Draw vertical lines for parent connections
    for (int i = 0; i < parentConnections.length && i < depth - 1; i++) {
      if (parentConnections[i]) {
        final double x = (i + 1) * indentSize + halfIndent;
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      }
    }

    // Draw lines for current level
    final double currentX = depth * indentSize + halfIndent;

    // Vertical line from top to center (unless this is the first child)
    canvas.drawLine(Offset(currentX, 0), Offset(currentX, centerY), paint);

    // Vertical line from center to bottom (if not the last child)
    if (!isLastInLevel) {
      canvas.drawLine(
        Offset(currentX, centerY),
        Offset(currentX, size.height),
        paint,
      );
    }

    // Horizontal line from vertical line to content
    canvas.drawLine(
      Offset(currentX, centerY),
      Offset(currentX + halfIndent, centerY),
      paint,
    );

    // Additional vertical line for expanded nodes with children
    if (hasChildren && isExpanded) {
      canvas.drawLine(
        Offset(currentX, centerY),
        Offset(currentX, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(TreeConnectorPainter oldDelegate) =>
      depth != oldDelegate.depth ||
      indentSize != oldDelegate.indentSize ||
      connectorColor != oldDelegate.connectorColor ||
      connectorWidth != oldDelegate.connectorWidth ||
      hasChildren != oldDelegate.hasChildren ||
      isExpanded != oldDelegate.isExpanded ||
      isLastInLevel != oldDelegate.isLastInLevel ||
      !_listEquals(parentConnections, oldDelegate.parentConnections);

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) {
      return false;
    }
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }
}
