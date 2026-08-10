import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Keeps the display awake for as long as [child] is on screen.
///
/// Scoped to the clock screens rather than set app-wide, so the setup screen
/// still respects the normal display timeout — there's no reason to burn
/// battery while someone is picking a time control.
///
/// Wrapping is deliberate: it lets the two clock screens stay stateless and
/// share one lifecycle, instead of both growing their own initState/dispose
/// pair that could drift apart.
class KeepAwake extends StatefulWidget {
  final Widget child;
  const KeepAwake({super.key, required this.child});

  @override
  State<KeepAwake> createState() => _KeepAwakeState();
}

class _KeepAwakeState extends State<KeepAwake> {
  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    // Runs when the user backs out to the setup screen, so the wakelock never
    // outlives the game it was taken for.
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
