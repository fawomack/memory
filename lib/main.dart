// Imports
import 'package:flutter/material.dart'; // Material widgets and theming
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/ui/screens/game_screen.dart';

// Entry point
void main() => runApp(const MyApp()); // Attach `MyApp` to the screen

// Root widget
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key); // Const constructor

  @override
  Widget build(BuildContext context) {
      // Wrap the app with `ProviderScope` to enable Riverpod providers.
      return ProviderScope(
        child: MaterialApp(
          title: 'Memory App', // OS/task title
          theme: ThemeData(primarySwatch: Colors.blue), // App theme
          // Show the GameScreen directly for now.
          home: const GameScreen(),
        ),
      );
  }
}

// Home screen (stateful)
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key); // Immutable widget

  @override
  State<HomePage> createState() => _HomePageState(); // Create state
}

// State for HomePage
class _HomePageState extends State<HomePage> {
  int _counter = 0; // current counter value shown in UI

  @override
  Widget build(BuildContext context) {
    // Scaffold: page layout with app bar, body, and FAB
    return Scaffold(
      appBar: AppBar(title: const Text('Memory App')), // Top toolbar
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Column sized to children
          children: [
            const Text('You have pressed the button this many times:'), // Instruction
            const SizedBox(height: 8), // Spacing
            Text('$_counter', // Display counter value
                style: Theme.of(context).textTheme.headlineMedium), // Styled via theme
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _counter++), // Increment counter
        child: const Icon(Icons.add), // Add icon
      ),
    );
  }
}
