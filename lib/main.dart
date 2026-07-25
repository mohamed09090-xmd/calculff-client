import 'package:flutter/material.dart';

void main() {
  runApp(const CalculFFClientBootstrapApp());
}

class CalculFFClientBootstrapApp extends StatelessWidget {
  const CalculFFClientBootstrapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CalculFF Client',
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Semantics(
              header: true,
              child: const Text('CalculFF Client'),
            ),
          ),
        ),
      ),
    );
  }
}
