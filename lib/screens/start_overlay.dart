import 'package:flutter/material.dart';
import '../theme/clock_palette.dart';

class StartOverlay extends StatelessWidget {
  final VoidCallback onStart;
  const StartOverlay({super.key, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onStart,
      child: Container(
        color: ClockPalette.walnut.withValues(alpha: 0.94),
        alignment: Alignment.center,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_circle_fill, color: ClockPalette.brass, size: 64),
            SizedBox(height: 14),
            Text(
              'Tap to start',
              style: TextStyle(
                color: ClockPalette.cream,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
