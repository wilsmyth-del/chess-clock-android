import 'package:flutter/material.dart';

/// Wood-and-brass palette, modelled on a classic mechanical tournament clock
/// (Garde/BHB style): a walnut body, two cream dials, brass fittings, and a
/// lacquer-red flag.
///
/// The one thing worth understanding here: on a real clock both dials are the
/// same cream, and you tell whose turn it is from the mechanism, not colour.
/// A phone can't do that, so the active side is distinguished two ways at
/// once — a brighter, "lit" dial *and* a brass bezel. Either alone is too
/// subtle to read at a glance across a table; together they're unmistakable
/// without resorting to a colour that would break the wooden look.
class ClockPalette {
  const ClockPalette._();

  // Body — the wooden case.
  static const walnut = Color(0xFF3B2A20);
  static const walnutDeep = Color(0xFF2A1D16); // control bar, app bar
  static const walnutShadow = Color(0xFF1E1510); // recess behind the dials

  // Dials. The idle dial sits in shadow; the active one is lit.
  static const dialIdle = Color(0xFFD8C9AB);
  static const dialActive = Color(0xFFFBF3DF);

  // Brass fittings.
  static const brass = Color(0xFFB8893B);
  static const brassDim = Color(0xFF7E5E2A); // disabled/idle fittings

  // The flag, and the face it falls on.
  static const lacquer = Color(0xFFA33B25);

  // Numerals: dark ink on cream. inkDim lets the idle side recede.
  static const ink = Color(0xFF2A211B);
  static const inkDim = Color(0xFF5F5245);

  // Text sitting directly on wood.
  static const cream = Color(0xFFE8DCC4);

  /// Dial fill for a half, by state.
  static Color dialFor({required bool isActive, required bool isFlagged}) {
    if (isFlagged) return lacquer;
    return isActive ? dialActive : dialIdle;
  }

  /// Numeral colour to match [dialFor] — cream on the red flag face, ink on
  /// cream, dimmed ink when idle so the running side draws the eye.
  static Color numeralFor({required bool isActive, required bool isFlagged}) {
    if (isFlagged) return cream;
    return isActive ? ink : inkDim;
  }

  /// Explicit ColorScheme rather than a seed: seeded schemes generate their
  /// own tonal palette and would drift away from these exact wood/brass
  /// values, which is the whole point of the look.
  static ThemeData theme() {
    const scheme = ColorScheme.dark(
      primary: brass,
      onPrimary: ink,
      secondary: brass,
      onSecondary: ink,
      surface: walnut,
      onSurface: cream,
      error: lacquer,
      onError: cream,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: walnut,
      appBarTheme: const AppBarTheme(
        backgroundColor: walnutDeep,
        foregroundColor: cream,
        centerTitle: true,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: walnutDeep,
        selectedColor: brass,
        labelStyle: const TextStyle(color: cream),
        secondaryLabelStyle: const TextStyle(color: ink),
        side: const BorderSide(color: brassDim),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? brass : brassDim,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        labelStyle: TextStyle(color: cream),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: brassDim),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: brass, width: 2),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) =>
                states.contains(WidgetState.selected) ? brass : walnutDeep,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected) ? ink : cream,
          ),
          side: WidgetStateProperty.all(const BorderSide(color: brassDim)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: brass,
          foregroundColor: ink,
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
