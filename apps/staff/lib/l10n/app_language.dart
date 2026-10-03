import 'package:flutter/widgets.dart';

/// The app's language. Arabic by default; the Manage page flips it.
/// A plain global for now: when a Settings page exists it will read and write this (and save it).
final appLanguage = ValueNotifier<Locale>(const Locale('ar'));
