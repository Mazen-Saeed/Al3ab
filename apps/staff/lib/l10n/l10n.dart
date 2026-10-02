import 'package:flutter/widgets.dart';

import 'arb/app_localizations.dart';

export 'arb/app_localizations.dart';

/// Short access to translations: `context.l10n.homeTitle`
/// instead of `AppLocalizations.of(context).homeTitle`.
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
