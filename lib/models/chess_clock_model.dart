import 'dart:async';
import 'package:flutter/foundation.dart';

enum Player { one, two }

class ChessClockModel extends ChangeNotifier {
  final Duration initialTime;
  final int incrementSeconds;

  late Duration _remainingOne = initialTime;
  late Duration _remainingTwo = initialTime;
  Player? _activePlayer;
  Player? _flaggedPlayer;
  bool _isRunning = false;
  Timer? _ticker;
  DateTime? _lastTick;

  ChessClockModel({required this.initialTime, this.incrementSeconds = 0});

  Duration remaining(Player p) => p == Player.one ? _remainingOne : _remainingTwo;

  double remainingFraction(Player p) {
    if (initialTime.inMilliseconds == 0) return 0;
    final r = remaining(p).inMilliseconds / initialTime.inMilliseconds;
    return r.clamp(0.0, 1.0);
  }

  Player? get activePlayer => _activePlayer;
  Player? get flaggedPlayer => _flaggedPlayer;
  bool get isRunning => _isRunning;
  bool get isStarted => _activePlayer != null;

  /// Arms the clock at the start of a game: matches official over-the-board
  /// rules, where the first player's clock is already running while they
  /// think about their first move, rather than waiting for a first tap.
  void startGame([Player first = Player.one]) {
    if (_activePlayer != null || _flaggedPlayer != null) return;
    _activePlayer = first;
    _resumeTicking();
  }

  /// Tap your own clock after making a move: applies the increment to
  /// yourself, then hands the turn (and the running clock) to the opponent.
  void tapPlayer(Player p) {
    if (_flaggedPlayer != null) return;
    if (_activePlayer != p) return;

    if (p == Player.one) {
      _remainingOne += Duration(seconds: incrementSeconds);
      _activePlayer = Player.two;
    } else {
      _remainingTwo += Duration(seconds: incrementSeconds);
      _activePlayer = Player.one;
    }
    _resumeTicking();
  }

  void pause() {
    _isRunning = false;
    _ticker?.cancel();
    notifyListeners();
  }

  void resume() {
    if (_activePlayer == null || _flaggedPlayer != null) return;
    _resumeTicking();
  }

  void reset() {
    _ticker?.cancel();
    _remainingOne = initialTime;
    _remainingTwo = initialTime;
    _activePlayer = null;
    _flaggedPlayer = null;
    _isRunning = false;
    notifyListeners();
  }

  void _resumeTicking() {
    _isRunning = true;
    _lastTick = DateTime.now();
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), _onTick);
    notifyListeners();
  }

  void _onTick(Timer timer) {
    final now = DateTime.now();
    final elapsed = now.difference(_lastTick!);
    _lastTick = now;

    if (_activePlayer == Player.one) {
      _remainingOne -= elapsed;
      if (_remainingOne <= Duration.zero) {
        _remainingOne = Duration.zero;
        _flag(Player.one);
      }
    } else if (_activePlayer == Player.two) {
      _remainingTwo -= elapsed;
      if (_remainingTwo <= Duration.zero) {
        _remainingTwo = Duration.zero;
        _flag(Player.two);
      }
    }
    notifyListeners();
  }

  void _flag(Player p) {
    _flaggedPlayer = p;
    _isRunning = false;
    _ticker?.cancel();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
