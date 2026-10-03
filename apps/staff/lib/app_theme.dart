import 'package:flutter/material.dart';

/// The "Lounge" palette. Named by meaning, never by look,
/// so widgets say "running" instead of "cream".
class AppColors {
  // Surfaces
  static const background = Color(0xFF1B1714); // whole app
  static const surface = Color(0xFF241E1A); // panels, free tiles, nav
  static const raised = Color(0xFF3A302A); // secondary buttons, borders

  // Text
  static const text = Color(0xFFF4ECE1); // main text (cream)
  static const textMuted = Color(0xFFB5A797); // labels, secondary info
  static const textOnLight = Color(0xFF1B1714); // text on cream cards
  static const textOnLightMuted = Color(0xFF6B5E52);

  // Device states
  static const running = Color(0xFFF4ECE1); // cream card, the strongest element
  static const free = Color(0xFFA9D3A0); // sage text on a dark tile
  static const waitingPayment = Color(0xFFF08A6B); // coral, needs action
  static const onWaitingPayment = Color(0xFF2A120A);
  static const reserved = Color(0xFF3F3566); // lavender chip background
  static const onReserved = Color(0xFFC9BCF5); // lavender text
  static const maintenance = Color(0xFF8C7F72); // faded

  // Main action ("End & pay")
  static const alert = Color(0xFFB5412A); // text on a cream card: last minute / overtime
  static const primary = Color(0xFFA9D3A0); // sage
  static const onPrimary = Color(0xFF14200F);
}

/// Text styles used in many places. Named by role, like AppColors.
class AppText {
  static const label = TextStyle(fontSize: 14, color: AppColors.textMuted); // small grey line above a field
  static const small = TextStyle(fontSize: 13, color: AppColors.textMuted); // secondary info
  static const sectionTitle = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text);
  static const formTitle = TextStyle(fontSize: 30, fontWeight: FontWeight.w700); // big name in a form
}

/// The app-wide theme. Every Material widget reads its colors from here.
final appTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Alexandria', // bundled in assets/fonts, declared in pubspec.yaml
  scaffoldBackgroundColor: AppColors.background,
  // Arabic letters reach far below the line (dots under ي، ب): give every line
  // extra room, split evenly above and below, so stacked lines never overlap.
  textTheme: const TextTheme(
    bodyMedium: TextStyle(
      height: 1.4,
      leadingDistribution: TextLeadingDistribution.even,
    ),
  ),
  colorScheme: const ColorScheme.dark(
    surface: AppColors.background,
    onSurface: AppColors.text,
    onSurfaceVariant: AppColors.textMuted,
    surfaceContainer: AppColors.surface,
    surfaceContainerHigh: AppColors.raised,
    outline: AppColors.raised,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primary, // floating buttons use this
    onPrimaryContainer: AppColors.onPrimary,
    inversePrimary: AppColors.surface,
    error: AppColors.waitingPayment,
    onError: AppColors.onWaitingPayment,
    // Secondary buttons and the selected segment of a toggle use these.
    secondaryContainer: AppColors.raised,
    onSecondaryContainer: AppColors.text,
  ),
  // Every TextField: dark fill, rounded, green ring when focused.
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.background,
    contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 18, vertical: 16),
    hintStyle: const TextStyle(color: AppColors.maintenance),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: AppColors.raised, width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: AppColors.raised, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
  ),
  // The bottom bar of a phone has five tabs: a small label, so none of them wraps onto a second line.
  navigationBarTheme: NavigationBarThemeData(
    labelPadding: const EdgeInsets.only(top: 2),
    labelTextStyle: WidgetStateProperty.all(const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
  ),
  // Every FilledButton: rounded, tall enough to tap easily, semibold text.
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(0, 52),
      // Less side padding than the default, so short labels like "حوّل زوجي" fit on one line.
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      textStyle: const TextStyle(fontFamily: 'Alexandria', fontSize: 15, fontWeight: FontWeight.w600),
    ),
  ),
);
