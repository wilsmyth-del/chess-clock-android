/// Below this, the display switches from whole seconds to seconds-and-
/// hundredths ("59.99", "4.37"). The last minute is where a clock actually
/// earns its keep, and "0:04" hides the difference between four seconds and
/// four and a bit.
const kSubSecondThreshold = Duration(seconds: 60);

String formatDuration(Duration d) {
  final abs = d.isNegative ? -d : d;

  if (abs < kSubSecondThreshold) {
    // Floor rather than round, so 59.999s reads "59.99" and never briefly
    // shows "60.00" — a countdown should never appear to gain time.
    final hundredths = abs.inMilliseconds ~/ 10;
    final seconds = hundredths ~/ 100;
    final fraction = hundredths % 100;
    return '$seconds.${fraction.toString().padLeft(2, '0')}';
  }

  final hours = abs.inHours;
  final minutes = abs.inMinutes % 60;
  final seconds = abs.inSeconds % 60;
  if (hours > 0) {
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  return '${abs.inMinutes}:${seconds.toString().padLeft(2, '0')}';
}
