import 'package:flutter/material.dart';

/// Temporary bootstrap screen for project verification (`flutter run`).
///
/// Remove when the Splash screen is implemented from Stitch.
class BootstrapCounterPage extends StatefulWidget {
  const BootstrapCounterPage({super.key});

  static const String routePath = '/';
  static const String routeName = 'bootstrap-counter';

  @override
  State<BootstrapCounterPage> createState() => _BootstrapCounterPageState();
}

class _BootstrapCounterPageState extends State<BootstrapCounterPage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() => _counter++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VoteChain'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
