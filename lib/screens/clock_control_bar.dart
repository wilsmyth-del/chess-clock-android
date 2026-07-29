import 'package:flutter/material.dart';
import '../models/chess_clock_model.dart';

class ClockControlBar extends StatelessWidget {
  final ChessClockModel model;
  const ClockControlBar({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            iconSize: 32,
            icon: Icon(
              model.isRunning ? Icons.pause : Icons.play_arrow,
              color: model.isStarted ? Colors.white : Colors.grey,
            ),
            onPressed: model.isStarted
                ? () => model.isRunning ? model.pause() : model.resume()
                : null,
          ),
          const SizedBox(width: 24),
          IconButton(
            iconSize: 32,
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: model.reset,
          ),
        ],
      ),
    );
  }
}
