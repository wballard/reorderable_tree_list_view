import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

import 'stories/basic_stories.dart';
import 'stories/interaction_stories.dart';
import 'stories/theme_stories.dart';
import 'stories/data_stories.dart';
import 'stories/accessibility_stories.dart';
import 'stories/advanced_stories.dart';

void main() {
  runApp(const StorybookApp());
}

/// Storybook app for ReorderableTreeListView widget showcase
class StorybookApp extends StatelessWidget {
  /// Creates the Storybook app
  const StorybookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Storybook(
      wrapperBuilder: (context, child) => MaterialApp(
        title: 'ReorderableTreeListView Storybook',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: child,
        debugShowCheckedModeBanner: false,
      ),
      
      plugins: [
        DeviceFramePlugin(),
        ThemeModePlugin(),
        KnobsPlugin(),
      ],
      
      stories: [
        // Welcome story
        Story(
          name: 'Welcome',
          builder: (context) => _WelcomeStory(),
        ),
        
        // Basic examples
        ...basicStories,
        
        // Interaction examples
        ...interactionStories,
        
        // Theme examples
        ...themeStories,
        
        // Data scenarios
        ...dataStories,
        
        // Accessibility examples
        ...accessibilityStories,
        
        // Advanced examples
        ...advancedStories,
      ],
    );
  }
}

/// Welcome story widget
class _WelcomeStory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ReorderableTreeListView'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'ReorderableTreeListView',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'A Flutter widget for displaying hierarchical data with drag-and-drop reordering capabilities.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            
            // Key Features
            Text(
              'Key Features',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._buildFeatureList(context),
            const SizedBox(height: 32),
            
            // Quick Start
            Text(
              'Quick Start',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '''ReorderableTreeListView(
  paths: [
    Uri.parse('file:///folder1/file1.txt'),
    Uri.parse('file:///folder1/file2.txt'),
    Uri.parse('file:///folder2/file3.txt'),
  ],
  itemBuilder: (context, path) => Text(
    TreePath.getDisplayName(path),
  ),
  onReorder: (oldPath, newPath) {
    // Handle reordering
  },
)''',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Story Categories
            Text(
              'Story Categories',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._buildStoryCategoryList(context),
          ],
        ),
      ),
    );
  }
  
  List<Widget> _buildFeatureList(BuildContext context) {
    final features = [
      'Hierarchical tree display with automatic grouping',
      'Drag-and-drop reordering with smooth animations',
      'Customizable themes and visual styling',
      'Keyboard navigation and accessibility support',
      'Selection modes (single, multiple, none)',
      'Expandable/collapsible nodes',
      'Context menu support',
      'Validation callbacks for user interactions',
      'Event handling with callbacks and Actions/Intents',
      'Performance optimized for large datasets',
    ];
    
    return features.map((feature) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.primary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              feature,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    )).toList();
  }
  
  List<Widget> _buildStoryCategoryList(BuildContext context) {
    final categories = [
      ('Basic Stories', 'Simple tree examples and getting started'),
      ('Interaction Stories', 'Drag/drop, selection, and user interactions'),
      ('Theme Stories', 'Theming and visual customization'),
      ('Data Stories', 'Different data scenarios and use cases'),
      ('Accessibility Stories', 'Keyboard navigation and screen reader support'),
    ];
    
    return categories.map((category) => Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.folder,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          category.$1,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(category.$2),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    )).toList();
  }
}