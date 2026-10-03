import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_theme.dart';
import '../l10n/app_language.dart';
import '../l10n/l10n.dart';
import '../shell/pill.dart';

/// Manage > Settings. Only the language for now; the shop's rules (#38) will be added here.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key, required this.onBack});

  final VoidCallback onBack; // back to the Manage list

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final language = ref.watch(appLanguageProvider).languageCode;
    final languages = ref.read(appLanguageProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton.filledTonal(onPressed: onBack, icon: const Icon(Icons.arrow_back)),
            const SizedBox(width: 14),
            Text(l10n.settingsTitle, style: AppText.sectionTitle),
          ],
        ),
        const SizedBox(height: 18),
        Text(l10n.languageLabel, style: AppText.label),
        const SizedBox(height: 10),
        // Each language is written in its own language, so it can be found whatever the app shows.
        Wrap(
          spacing: 8,
          children: [
            Pill(label: 'العربية', selected: language == 'ar', onTap: () => languages.set(const Locale('ar'))),
            Pill(label: 'English', selected: language == 'en', onTap: () => languages.set(const Locale('en'))),
          ],
        ),
      ],
    );
  }
}
