String formatDuration(Duration d) {
  final abs = d.isNegative ? -d : d;
  final hours = abs.inHours;
  final minutes = abs.inMinutes % 60;
  final seconds = abs.inSeconds % 60;
  if (hours > 0) {
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  return '${abs.inMinutes}:${seconds.toString().padLeft(2, '0')}';
}
