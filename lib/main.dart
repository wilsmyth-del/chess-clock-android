import 'package:flutter/material.dart';
import 'screens/setup_screen.dart';

void main() {
  runApp(const ChessClockApp());
}

class ChessClockApp extends StatelessWidget {
  const ChessClockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Clock',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const SetupScreen(),
    );
  }
}
