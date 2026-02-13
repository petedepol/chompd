import 'package:flutter/widgets.dart';
import '../l10n/generated/app_localizations.dart';

/// Shorthand for accessing localised strings.
///
/// Usage: `context.l10n.someKey`
extension L10n on BuildContext {
  S get l10n => S.of(this);
}
