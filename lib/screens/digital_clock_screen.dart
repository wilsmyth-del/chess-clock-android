import 'package:flutter/material.dart';
import '../models/chess_clock_model.dart';
import '../utils/duration_format.dart';
import 'clock_control_bar.dart';
import 'start_overlay.dart';

class DigitalClockScreen extends StatelessWidget {
  final ChessClockModel model;
  const DigitalClockScreen({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: model,
          builder: (context, _) {
            return Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: RotatedBox(
                        quarterTurns: 2,
                        child: _ClockHalf(player: Player.one, model: model),
                      ),
                    ),
                    ClockControlBar(model: model),
                    Expanded(
                      child: _ClockHalf(player: Player.two, model: model),
                    ),
                  ],
                ),
                if (!model.isStarted)
                  Positioned.fill(child: StartOverlay(onStart: model.startGame)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ClockHalf extends StatelessWidget {
  final Player player;
  final ChessClockModel model;
  const _ClockHalf({required this.player, required this.model});

  @override
  Widget build(BuildContext context) {
    final isActive = model.activePlayer == player && model.isRunning;
    final isFlagged = model.flaggedPlayer == player;
    final remaining = model.remaining(player);

    final Color bg;
    if (isFlagged) {
      bg = Colors.red.shade700;
    } else if (isActive) {
      bg = Colors.green.shade600;
    } else {
      bg = Colors.grey.shade800;
    }

    return GestureDetector(
      onTap: () => model.tapPlayer(player),
      child: Container(
        color: bg,
        alignment: Alignment.center,
        child: Text(
          isFlagged ? 'FLAG' : formatDuration(remaining),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 64,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
