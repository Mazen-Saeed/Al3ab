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
  static const primary = Color(0xFFA9D3A0); // sage
  static const onPrimary = Color(0xFF14200F);
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
  ),
);
