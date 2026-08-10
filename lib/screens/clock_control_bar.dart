import 'package:flutter/material.dart';
import '../models/chess_clock_model.dart';
import '../theme/clock_palette.dart';

class ClockControlBar extends StatelessWidget {
  final ChessClockModel model;
  const ClockControlBar({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Container(
      // The brass rule between the two dials — the seam of the case.
      decoration: const BoxDecoration(
        color: ClockPalette.walnutDeep,
        border: Border(
          top: BorderSide(color: ClockPalette.brassDim),
          bottom: BorderSide(color: ClockPalette.brassDim),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            iconSize: 32,
            icon: Icon(
              model.isRunning ? Icons.pause : Icons.play_arrow,
              color:
                  model.isStarted ? ClockPalette.brass : ClockPalette.brassDim,
            ),
            onPressed: model.isStarted
                ? () => model.isRunning ? model.pause() : model.resume()
                : null,
          ),
          const SizedBox(width: 32),
          IconButton(
            iconSize: 32,
            icon: const Icon(Icons.refresh, color: ClockPalette.brass),
            onPressed: model.reset,
          ),
        ],
      ),
    );
  }
}
