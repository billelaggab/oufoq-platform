import 'package:flutter/material.dart';

import '../error/app_failure.dart';
import '../l10n/generated/app_localizations.dart';
import '../l10n/l10n_extension.dart';

/// واجهة خطأ أنيقة مع زر إعادة محاولة مترجم.
class OufoqErrorView extends StatelessWidget {
  const OufoqErrorView({super.key, required this.failure, this.onRetry});

  final AppFailure? failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final (IconData icon, String message) = _mapFailure(failure, l10n);

    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              l10n.errorViewTitle,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...<Widget>[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }

  (IconData, String) _mapFailure(
    AppFailure? failure,
    AppLocalizations l10n,
  ) {
    return switch (failure) {
      NetworkFailure() => (Icons.cloud_off_rounded, l10n.errorNoInternet),
      ServerFailure() => (Icons.dns_rounded, l10n.errorServer),
      EmptyCacheFailure() => (Icons.inbox_rounded, l10n.errorEmptyCache),
      UnexpectedFailure() || null => (Icons.error_outline_rounded, l10n.errorUnknown),
    };
  }
}
