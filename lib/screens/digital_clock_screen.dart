import 'package:flutter/material.dart';
import '../models/chess_clock_model.dart';

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
            return Column(
              children: [
                Expanded(
                  child: RotatedBox(
                    quarterTurns: 2,
                    child: _ClockHalf(player: Player.one, model: model),
                  ),
                ),
                _ControlBar(model: model),
                Expanded(
                  child: _ClockHalf(player: Player.two, model: model),
                ),
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
          isFlagged ? 'FLAG' : _formatDuration(remaining),
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

class _ControlBar extends StatelessWidget {
  final ChessClockModel model;
  const _ControlBar({required this.model});

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

String _formatDuration(Duration d) {
  final abs = d.isNegative ? -d : d;
  final hours = abs.inHours;
  final minutes = abs.inMinutes % 60;
  final seconds = abs.inSeconds % 60;
  if (hours > 0) {
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  return '${abs.inMinutes}:${seconds.toString().padLeft(2, '0')}';
}
