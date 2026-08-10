import 'dart:math';
import 'package:flutter/material.dart';
import '../models/chess_clock_model.dart';
import '../theme/clock_palette.dart';
import '../utils/duration_format.dart';
import 'clock_control_bar.dart';
import 'keep_awake.dart';
import 'start_overlay.dart';

class AnalogClockScreen extends StatelessWidget {
  final ChessClockModel model;
  const AnalogClockScreen({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return KeepAwake(
      child: Scaffold(
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
                          child: _AnalogHalf(player: Player.one, model: model),
                        ),
                      ),
                      ClockControlBar(model: model),
                      Expanded(
                        child: _AnalogHalf(player: Player.two, model: model),
                      ),
                    ],
                  ),
                  if (!model.isStarted)
                    Positioned.fill(
                      child: StartOverlay(onStart: model.startGame),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AnalogHalf extends StatelessWidget {
  final Player player;
  final ChessClockModel model;
  const _AnalogHalf({required this.player, required this.model});

  @override
  Widget build(BuildContext context) {
    final isActive = model.activePlayer == player && model.isRunning;
    final isFlagged = model.flaggedPlayer == player;
    final fraction = model.remainingFraction(player);
    final remaining = model.remaining(player);

    return GestureDetector(
      onTap: () => model.tapPlayer(player),
      child: Container(
        color: ClockPalette.walnut,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: CustomPaint(
                painter: _ClockFacePainter(
                  fraction: fraction,
                  isActive: isActive,
                  isFlagged: isFlagged,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              isFlagged ? 'FLAG' : formatDuration(remaining),
              style: TextStyle(
                // Sits on the wooden case, not on the dial — so cream, and
                // brass-toned when idle so it recedes with the rest of the half.
                color: isFlagged
                    ? ClockPalette.lacquer
                    : (isActive ? ClockPalette.cream : ClockPalette.brassDim),
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Draws a classic chess-clock face as a gauge: the hand always sweeps one
/// full circle from 12 (full time) back to 12 (zero), regardless of what the
/// total time control actually is, and a small flag falls at 12 when it hits
/// zero — the visual, not literal-time-of-day, matters here.
class _ClockFacePainter extends CustomPainter {
  final double fraction;
  final bool isActive;
  final bool isFlagged;

  _ClockFacePainter({
    required this.fraction,
    required this.isActive,
    required this.isFlagged,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 * 0.85;

    final faceColor =
        ClockPalette.dialFor(isActive: isActive, isFlagged: isFlagged);
    // Ink reads on cream; on the red flag face it doesn't, so switch to cream.
    final markings = isFlagged ? ClockPalette.cream : ClockPalette.ink;

    canvas.drawCircle(center, radius, Paint()..color = faceColor);
    // Brass bezel, thicker on the running side — same active cue as the
    // digital half, so both modes signal identically.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = isActive ? ClockPalette.brass : ClockPalette.brassDim
        ..style = PaintingStyle.stroke
        ..strokeWidth = isActive ? 6 : 3,
    );

    final tickPaint = Paint()
      ..color = markings.withValues(alpha: 0.55)
      ..strokeWidth = 2;
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * pi / 180;
      final direction = Offset(sin(angle), -cos(angle));
      canvas.drawLine(
        center + direction * (radius * 0.88),
        center + direction * radius,
        tickPaint,
      );
    }

    final sweepAngle = (1 - fraction) * 2 * pi;
    final handDirection = Offset(sin(sweepAngle), -cos(sweepAngle));
    canvas.drawLine(
      center,
      center + handDirection * (radius * 0.75),
      Paint()
        ..color = markings
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    // Brass centre cap, as on a real movement.
    canvas.drawCircle(center, 6, Paint()..color = ClockPalette.brass);
    canvas.drawCircle(
      center,
      6,
      Paint()
        ..color = markings.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Flag marker at 12 o'clock: upright normally, falls flat at zero.
    canvas.save();
    canvas.translate(center.dx, center.dy - radius * 0.95);
    if (isFlagged) canvas.rotate(pi / 2);
    final flagPath = Path()
      ..moveTo(0, 0)
      ..lineTo(0, -14)
      ..lineTo(10, -10)
      ..lineTo(0, -6)
      ..close();
    canvas.drawPath(
      flagPath,
      Paint()
        ..color = isFlagged ? ClockPalette.cream : ClockPalette.lacquer,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ClockFacePainter oldDelegate) {
    return oldDelegate.fraction != fraction ||
        oldDelegate.isActive != isActive ||
        oldDelegate.isFlagged != isFlagged;
  }
}
