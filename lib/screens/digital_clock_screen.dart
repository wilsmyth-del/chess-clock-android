import 'package:flutter/material.dart';
import '../models/chess_clock_model.dart';
import '../theme/clock_palette.dart';
import '../utils/duration_format.dart';
import 'clock_control_bar.dart';
import 'start_overlay.dart';

class DigitalClockScreen extends StatelessWidget {
  final ChessClockModel model;
  const DigitalClockScreen({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClockPalette.walnutShadow,
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

    final dial = ClockPalette.dialFor(isActive: isActive, isFlagged: isFlagged);
    final numeral =
        ClockPalette.numeralFor(isActive: isActive, isFlagged: isFlagged);

    return GestureDetector(
      onTap: () => model.tapPlayer(player),
      child: Container(
        // The wooden case shows through as a margin, so each half reads as an
        // inset dial rather than a full-bleed coloured panel.
        padding: const EdgeInsets.all(10),
        color: ClockPalette.walnut,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: dial,
            borderRadius: BorderRadius.circular(6),
            // Brass bezel only on the running side — the second half of the
            // active signal, alongside the brighter dial.
            border: Border.all(
              color: isActive ? ClockPalette.brass : ClockPalette.brassDim,
              width: isActive ? 3 : 1,
            ),
          ),
          child: Text(
            isFlagged ? 'FLAG' : formatDuration(remaining),
            style: TextStyle(
              color: numeral,
              fontSize: 64,
              fontWeight: FontWeight.bold,
              // Slight tracking stops the big numerals looking cramped on the
              // cream dial the way tight default spacing did on black.
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
