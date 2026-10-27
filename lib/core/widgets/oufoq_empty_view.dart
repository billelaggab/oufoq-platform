import 'package:flutter/material.dart';

import '../l10n/l10n_extension.dart';

/// واجهة موحدة للقوائم الفارغة.
class OufoqEmptyView extends StatelessWidget {
  const OufoqEmptyView({
    super.key,
    this.icon = Icons.inbox_rounded,
    this.title,
    this.body,
  });

  final IconData icon;
  final String? title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              title ?? context.l10n.emptyDefaultTitle,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              body ?? context.l10n.emptyDefaultBody,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
