import 'package:flutter/services.dart';

/// Money is kept as whole piasters (an `int`): 77.34 EGP is 7734. Whole numbers add up exactly, a
/// `double` would not. Only this file turns piasters into text and back; everything else
/// (models, providers, SQLite later) holds the plain int. The sync API will still send pounds
/// with decimals (77.34), converted at that edge.
const piastersPerPound = 100;

/// 7734 -> "77.34", 6000 -> "60" (no ".00" on whole pounds).
String formatMoney(int piasters) {
  final sign = piasters < 0 ? '-' : '';
  final abs = piasters.abs();
  final pounds = abs ~/ piastersPerPound;
  final rest = abs % piastersPerPound;
  if (rest == 0) return '$sign$pounds';
  return '$sign$pounds.${rest.toString().padLeft(2, '0')}';
}

/// What the staff typed -> piasters: "77.34" and "77,34" -> 7734, "60" -> 6000, ".5" -> 50.
/// Null when it is empty or not a number.
int? parseMoney(String text) {
  final clean = text.trim().replaceAll(',', '.');
  if (!RegExp(r'^\d*\.?\d*$').hasMatch(clean) || !clean.contains(RegExp(r'\d'))) return null;
  final parts = clean.split('.');
  final pounds = parts[0].isEmpty ? 0 : int.parse(parts[0]);
  final fraction = parts.length == 2 ? parts[1].padRight(2, '0') : '00';
  if (fraction.length > 2) return null; // more than 2 decimals is not money
  return pounds * piastersPerPound + int.parse(fraction);
}

/// For money text fields: digits, one "." or ",", at most 2 digits after it.
final moneyInputFormatters = [FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d{0,2}'))];

/// Keyboard for money fields (digits plus a decimal separator).
const moneyKeyboard = TextInputType.numberWithOptions(decimal: true);
