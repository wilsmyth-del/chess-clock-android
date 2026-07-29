import 'package:flutter/material.dart';
import '../models/chess_clock_model.dart';
import '../models/time_control.dart';
import 'analog_clock_screen.dart';
import 'digital_clock_screen.dart';

enum ClockDisplayMode { digital, classic }

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  String _category = 'Blitz';
  TimeControlOption? _selected = kPresetGroups['Blitz']!.first;
  ClockDisplayMode _mode = ClockDisplayMode.digital;

  final _customMinutes = TextEditingController(text: '10');
  final _customIncrement = TextEditingController(text: '0');

  bool get _isCustom => _category == 'Custom';

  @override
  void dispose() {
    _customMinutes.dispose();
    _customIncrement.dispose();
    super.dispose();
  }

  void _start() {
    final Duration time;
    final int increment;

    if (_isCustom) {
      final minutes = int.tryParse(_customMinutes.text) ?? 10;
      increment = int.tryParse(_customIncrement.text) ?? 0;
      time = Duration(minutes: minutes);
    } else {
      time = _selected!.time;
      increment = _selected!.incrementSeconds;
    }

    final model = ChessClockModel(initialTime: time, incrementSeconds: increment);

    if (_mode == ClockDisplayMode.digital) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => DigitalClockScreen(model: model),
      ));
    } else {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => AnalogClockScreen(model: model),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chess Clock')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            children: [...kPresetGroups.keys, 'Custom'].map((cat) {
              return ChoiceChip(
                label: Text(cat),
                selected: _category == cat,
                onSelected: (_) => setState(() {
                  _category = cat;
                  if (!_isCustom) _selected = kPresetGroups[cat]!.first;
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          if (_isCustom) ...[
            TextField(
              controller: _customMinutes,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Minutes per side'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _customIncrement,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Increment (seconds)'),
            ),
          ] else
            ...kPresetGroups[_category]!.map((opt) => RadioListTile<TimeControlOption>(
                  title: Text(opt.label),
                  value: opt,
                  groupValue: _selected,
                  onChanged: (v) => setState(() => _selected = v),
                )),
          const SizedBox(height: 24),
          const Text('Clock style', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SegmentedButton<ClockDisplayMode>(
            segments: const [
              ButtonSegment(value: ClockDisplayMode.digital, label: Text('Digital')),
              ButtonSegment(value: ClockDisplayMode.classic, label: Text('Classic')),
            ],
            selected: {_mode},
            onSelectionChanged: (s) => setState(() => _mode = s.first),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _start,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Start Game'),
            ),
          ),
        ],
      ),
    );
  }
}
