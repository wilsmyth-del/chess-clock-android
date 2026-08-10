import 'package:flutter/material.dart';
import 'screens/setup_screen.dart';
import 'theme/clock_palette.dart';

void main() {
  runApp(const ChessClockApp());
}

class ChessClockApp extends StatelessWidget {
  const ChessClockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Clock',
      theme: ClockPalette.theme(),
      home: const SetupScreen(),
    );
  }
}
