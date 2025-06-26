/// Utility class for working with URI paths in the tree structure.
///
/// This class provides static methods for path manipulation, including
/// generating intermediate paths, calculating depth, and extracting
/// display names from URIs.
///
/// The tree structure is based on URI paths where:
/// - The scheme (e.g., 'file://') is the root
/// - Path segments represent nested levels
/// - Depth is calculated from the number of segments
///
/// Example URI: `file://var/data/readme.txt`
/// - Root: `file://`
/// - Depth 1: `file://var`
/// - Depth 2: `file://var/data`
/// - Depth 3: `file://var/data/readme.txt`
class TreePath {
  // Private constructor to prevent instantiation
  TreePath._();

  // Standard web protocols that use host in the traditional way
  static const List<String> _standardWebProtocols = <String>[
    'http',
    'https',
    'ftp',
    'ws',
    'wss',
  ];

  /// Generates all intermediate parent paths for a given URI.
  ///
  /// Given a path like `file://var/data/readme.txt`, this returns:
  /// `[file://, file://var, file://var/data]`
  ///
  /// Returns an empty list for root paths.
  static List<Uri> generateIntermediatePaths(Uri path) {
    final List<Uri> paths = <Uri>[];

    // For file:// URIs with host, we treat the host as the first path segment
    final List<String> segments = _getEffectiveSegments(path);

    // If no segments, this is a root path
    if (segments.isEmpty) {
      return paths;
    }

    // Add each intermediate path, including root
    for (int i = 0; i < segments.length; i++) {
      if (i == 0) {
        // Add root - for standard web protocols include host, for others just scheme
        final bool isStandardWebProtocol = _standardWebProtocols.contains(
          path.scheme,
        );
        if (isStandardWebProtocol || path.host.isEmpty) {
          paths.add(Uri(scheme: path.scheme, host: path.host));
        } else {
          paths.add(Uri(scheme: path.scheme));
        }
      } else {
        // Check if host is treated as a segment
        final bool hostAsSegment =
            path.host.isNotEmpty &&
            !_standardWebProtocols.contains(path.scheme);

        if (hostAsSegment) {
          if (i == 1 && segments[0] == path.host) {
            // First segment is the host
            paths.add(Uri(scheme: path.scheme, host: segments[0]));
          } else {
            // Subsequent segments (skip the host segment in path)
            final int startIdx = segments[0] == path.host ? 1 : 0;
            final String intermediatePath = segments
                .sublist(startIdx, i)
                .join('/');
            if (intermediatePath.isNotEmpty) {
              paths.add(
                Uri(
                  scheme: path.scheme,
                  host: path.host,
                  path: '/$intermediatePath',
                ),
              );
            }
          }
        } else {
          // Normal URI handling
          final String intermediatePath = segments.sublist(0, i).join('/');
          paths.add(
            Uri(
              scheme: path.scheme,
              host: path.host,
              path: '/$intermediatePath',
            ),
          );
        }
      }
    }

    return paths;
  }

  /// Gets effective segments treating host as first segment for certain schemes
  static List<String> _getEffectiveSegments(Uri path) {
    final List<String> segments = <String>[];

    // For file:// and custom schemes, treat host as first segment
    // Standard web protocols (http, https) keep host separate
    if (path.host.isNotEmpty && !_standardWebProtocols.contains(path.scheme)) {
      segments.add(path.host);
    }

    // Add regular path segments
    segments.addAll(path.pathSegments.where((String s) => s.isNotEmpty));

    return segments;
  }

  /// Calculates the depth of a path based on its segments.
  ///
  /// - Root paths (scheme only) have depth 0
  /// - Each path segment adds 1 to the depth
  ///
  /// Empty segments are ignored.
  static int calculateDepth(Uri path) {
    final List<String> segments = _getEffectiveSegments(path);
    return segments.length;
  }

  /// Extracts the display name from a URI path.
  ///
  /// - For root paths: Returns the scheme with host (e.g., 'file://' or 'http://example.com')
  /// - For other paths: Returns the last non-empty segment
  ///
  /// URL-encoded characters are decoded for display.
  static String getDisplayName(Uri path) {
    final List<String> segments = _getEffectiveSegments(path);

    // For root paths, return scheme with host if present
    if (segments.isEmpty) {
      if (path.host.isEmpty) {
        return '${path.scheme}://';
      } else {
        return '${path.scheme}://${path.host}';
      }
    }

    // Return the last segment, URL decoded
    return Uri.decodeComponent(segments.last);
  }

  /// Gets the parent path of a URI.
  ///
  /// Returns `null` for root paths (scheme only).
  ///
  /// Example:
  /// - `file://var/data` → `file://var`
  /// - `file://var` → `file://`
  /// - `file://` → `null`
  static Uri? getParentPath(Uri path) {
    final List<String> segments = _getEffectiveSegments(path);

    // Root paths have no parent
    if (segments.isEmpty) {
      return null;
    }

    // If only one segment, parent is root
    if (segments.length == 1) {
      // Check if this scheme treats host as segment
      final bool hostAsSegment =
          path.host.isNotEmpty && !_standardWebProtocols.contains(path.scheme);

      if (hostAsSegment && segments[0] == path.host) {
        return Uri(scheme: path.scheme);
      }
      return Uri(scheme: path.scheme, host: path.host);
    }

    // Check if host is treated as segment
    final bool hostAsSegment =
        path.host.isNotEmpty && !_standardWebProtocols.contains(path.scheme);

    if (hostAsSegment) {
      // Check if we have path segments beyond the host
      final List<String> pathOnlySegments = path.pathSegments
          .where((String s) => s.isNotEmpty)
          .toList();

      if (pathOnlySegments.isEmpty) {
        // file://var -> file://
        return Uri(scheme: path.scheme);
      } else if (pathOnlySegments.length == 1) {
        // file://var/data -> file://var
        return Uri(scheme: path.scheme, host: path.host);
      } else {
        // file://var/data/more -> file://var/data
        final String parentPath = pathOnlySegments
            .sublist(0, pathOnlySegments.length - 1)
            .join('/');
        return Uri(scheme: path.scheme, host: path.host, path: '/$parentPath');
      }
    }

    // Normal URI handling
    final String parentPath = segments
        .sublist(0, segments.length - 1)
        .join('/');
    return Uri(scheme: path.scheme, host: path.host, path: '/$parentPath');
  }

  /// Checks if one URI is an ancestor of another.
  ///
  /// A path is considered an ancestor if it appears in the descendant's
  /// path hierarchy. Paths must have the same scheme to be related.
  ///
  /// Note: A path is not considered an ancestor of itself.
  static bool isAncestorOf(Uri ancestor, Uri descendant) {
    // Must have same scheme
    if (ancestor.scheme != descendant.scheme) {
      return false;
    }

    // Get effective segments for comparison
    final List<String> ancestorSegments = _getEffectiveSegments(ancestor);
    final List<String> descendantSegments = _getEffectiveSegments(descendant);

    // Ancestor must have fewer segments
    if (ancestorSegments.length >= descendantSegments.length) {
      return false;
    }

    // Check if all ancestor segments match the beginning of descendant
    for (int i = 0; i < ancestorSegments.length; i++) {
      if (ancestorSegments[i] != descendantSegments[i]) {
        return false;
      }
    }

    return true;
  }
}
