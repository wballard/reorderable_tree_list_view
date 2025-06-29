# Contributing to ReorderableTreeListView

First off, thank you for considering contributing to ReorderableTreeListView! It's people like you that make this package better for everyone.

## Code of Conduct

By participating in this project, you are expected to uphold our Code of Conduct:
- Be respectful and inclusive
- Welcome newcomers and help them get started
- Focus on constructive criticism
- Show empathy towards other community members

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When you create a bug report, include as many details as possible:

- **Use a clear and descriptive title**
- **Describe the exact steps to reproduce the problem**
- **Provide specific examples**
- **Describe the behavior you observed and expected**
- **Include screenshots if applicable**
- **Include your environment details** (Flutter version, platform, etc.)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion:

- **Use a clear and descriptive title**
- **Provide a detailed description of the proposed enhancement**
- **Provide specific examples to demonstrate the enhancement**
- **Describe the current behavior and expected behavior**
- **Explain why this enhancement would be useful**

### Pull Requests

1. Fork the repo and create your branch from `main`
2. If you've added code that should be tested, add tests
3. If you've changed APIs, update the documentation
4. Ensure the test suite passes
5. Make sure your code follows the style guidelines
6. Issue that pull request!

## Development Setup

1. **Fork and clone the repository**
   ```bash
   git clone https://github.com/yourusername/reorderable_tree_list_view.git
   cd reorderable_tree_list_view
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run tests**
   ```bash
   flutter test
   ```

4. **Run the example app**
   ```bash
   cd example
   flutter run
   ```

## Style Guidelines

### Dart Style Guide

We follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style). Key points:

- Use `dart format` to format your code
- Follow naming conventions (lowerCamelCase for variables, UpperCamelCase for types)
- Add dartdoc comments for all public APIs
- Keep lines under 80 characters when possible

### Code Organization

- Place each class in its own file
- Group related functionality in subdirectories
- Keep files focused and single-purpose
- Use meaningful file and directory names

### Testing

- Write tests for all new features
- Maintain or improve code coverage
- Test edge cases and error conditions
- Use descriptive test names

Example test structure:
```dart
group('TreeBuilder', () {
  group('buildFromPaths', () {
    test('should create tree from flat list', () {
      // Test implementation
    });
    
    test('should handle empty paths', () {
      // Test implementation
    });
  });
});
```

### Documentation

- Add dartdoc comments for all public APIs
- Include code examples in documentation
- Update README.md if adding new features
- Add entries to CHANGELOG.md

Example documentation:
```dart
/// Builds a tree structure from a list of URI paths.
/// 
/// Takes a sparse list of [paths] and generates a complete tree
/// structure including intermediate folder nodes.
/// 
/// Example:
/// ```dart
/// final paths = [
///   Uri.parse('file:///folder/file.txt'),
///   Uri.parse('file:///folder/subfolder/other.txt'),
/// ];
/// final nodes = TreeBuilder.buildFromPaths(paths);
/// ```
static List<TreeNode> buildFromPaths(List<Uri> paths) {
  // Implementation
}
```

## Commit Messages

We use [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes (formatting, etc.)
- `refactor:` Code refactoring
- `test:` Test additions or modifications
- `chore:` Maintenance tasks

Examples:
```
feat: add keyboard navigation support
fix: resolve drag and drop issue on web platform
docs: update README with migration guide
```

## Testing Your Changes

### Running All Tests
```bash
flutter test
```

### Running Specific Tests
```bash
flutter test test/core/tree_builder_test.dart
```

### Running with Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Running Integration Tests
```bash
flutter test test/integration/
```

## Submitting Changes

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Write code
   - Add tests
   - Update documentation

3. **Run checks**
   ```bash
   dart format .
   flutter analyze
   flutter test
   ```

4. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: add amazing feature"
   ```

5. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create a Pull Request**
   - Go to the original repository
   - Click "New Pull Request"
   - Select your fork and branch
   - Fill in the PR template
   - Submit!

## Pull Request Guidelines

- **PR Title**: Use conventional commit format
- **Description**: Clearly describe what the PR does
- **Breaking Changes**: Clearly mark any breaking changes
- **Screenshots**: Include for UI changes
- **Tests**: Ensure all tests pass
- **Documentation**: Update relevant docs

## Questions?

Feel free to:
- Open an issue for questions
- Join our Discord community
- Email the maintainers

Thank you for contributing! 🎉