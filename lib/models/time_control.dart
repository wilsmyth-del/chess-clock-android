class TimeControlOption {
  final String label;
  final Duration time;
  final int incrementSeconds;

  const TimeControlOption({
    required this.label,
    required this.time,
    this.incrementSeconds = 0,
  });
}

const Map<String, List<TimeControlOption>> kPresetGroups = {
  'Bullet': [
    TimeControlOption(label: '1 min', time: Duration(minutes: 1)),
    TimeControlOption(label: '2 | 1', time: Duration(minutes: 2), incrementSeconds: 1),
  ],
  'Blitz': [
    TimeControlOption(label: '3 min', time: Duration(minutes: 3)),
    TimeControlOption(label: '3 | 2', time: Duration(minutes: 3), incrementSeconds: 2),
    TimeControlOption(label: '5 min', time: Duration(minutes: 5)),
    TimeControlOption(label: '5 | 3', time: Duration(minutes: 5), incrementSeconds: 3),
  ],
  'Rapid': [
    TimeControlOption(label: '10 min', time: Duration(minutes: 10)),
    TimeControlOption(label: '15 | 10', time: Duration(minutes: 15), incrementSeconds: 10),
    TimeControlOption(label: '30 min', time: Duration(minutes: 30)),
  ],
};
