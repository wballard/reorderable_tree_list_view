# Installation

This guide will walk you through adding ReorderableTreeListView to your Flutter project.

## Requirements

Before installing ReorderableTreeListView, ensure your development environment meets these requirements:

- **Flutter SDK**: 3.0.0 or higher
- **Dart SDK**: 3.0.0 or higher
- **Supported Platforms**: iOS, Android, Web, macOS, Windows, Linux

## Adding the Dependency

### Using pub.dev (Recommended)

Add ReorderableTreeListView to your `pubspec.yaml` file:

```yaml
dependencies:
  reorderable_tree_list_view: ^1.0.0
```

Then run:

```bash
flutter pub get
```

### Using Git

For the latest development version, you can reference the GitHub repository directly:

```yaml
dependencies:
  reorderable_tree_list_view:
    git:
      url: https://github.com/wballard/reorderable_tree_list_view.git
      ref: main # or specify a specific branch/tag
```

### Using a Local Path

For local development or testing:

```yaml
dependencies:
  reorderable_tree_list_view:
    path: ../path/to/reorderable_tree_list_view
```

## Import the Package

Once installed, import the package in your Dart files:

```dart
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';
```

## Verify Installation

Create a simple test to verify the installation:

```dart
import 'package:flutter/material.dart';
import 'package:reorderable_tree_list_view/reorderable_tree_list_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('ReorderableTreeListView Test')),
        body: ReorderableTreeListView(
          paths: [
            Uri.parse('file:///test/file1.txt'),
            Uri.parse('file:///test/folder/file2.txt'),
          ],
          itemBuilder: (context, path) => Text(path.toString()),
        ),
      ),
    );
  }
}
```

Run your app:

```bash
flutter run
```

If you see a tree structure with your test files, the installation was successful!

## Platform-Specific Setup

### Web

No additional setup required. ReorderableTreeListView works out of the box on Flutter Web.

### Desktop (macOS, Windows, Linux)

Ensure desktop support is enabled:

```bash
flutter config --enable-macos-desktop
flutter config --enable-windows-desktop
flutter config --enable-linux-desktop
```

### Mobile (iOS, Android)

No additional setup required for mobile platforms.

## Optional Dependencies

ReorderableTreeListView works great with these optional packages:

### State Management

```yaml
dependencies:
  flutter_hooks: ^0.20.5  # For hook-based state management
  provider: ^6.0.0        # For provider pattern
  riverpod: ^2.0.0        # For Riverpod state management
```

### Icons and Visuals

```yaml
dependencies:
  flutter_vector_icons: ^2.0.0  # Additional icon sets
  animations: ^2.0.0            # Enhanced animations
```

## Troubleshooting

### Dependency Conflicts

If you encounter version conflicts, try:

1. Run `flutter pub outdated` to check for outdated packages
2. Update dependencies: `flutter pub upgrade`
3. Clear pub cache: `flutter pub cache clean`
4. Delete `pubspec.lock` and run `flutter pub get` again

### Build Issues

For build-related issues:

1. Clean the build: `flutter clean`
2. Rebuild: `flutter pub get && flutter run`

### Platform-Specific Issues

**iOS**: Ensure you're using the latest version of Xcode and have run `pod install` in the `ios` directory.

**Android**: Make sure your `minSdkVersion` is at least 21 in `android/app/build.gradle`.

**Web**: Clear browser cache if you see stale content.

## Next Steps

Now that you have ReorderableTreeListView installed, proceed to the [Quick Start](./quick-start.md) guide to build your first tree view!