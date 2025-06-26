import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// Example application demonstrating ReorderableTreeListView
class MyApp extends StatelessWidget {
  /// Creates the example app
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'ReorderableTreeListView Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'ReorderableTreeListView Demo'),
      );
}

/// Home page for the demo
class MyHomePage extends StatefulWidget {
  /// Creates the home page
  const MyHomePage({required this.title, super.key});

  /// The title of the page
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'ReorderableTreeListView example coming soon!',
              ),
            ],
          ),
        ),
      );
}