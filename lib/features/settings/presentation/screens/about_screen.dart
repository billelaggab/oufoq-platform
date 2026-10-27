import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extension.dart';

/// شاشة "من نحن وهيئة التحرير" — إلزامية لسياسة التطبيقات الإخبارية.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: ListView(
        padding: const EdgeInsetsDirectional.all(20),
        children: <Widget>[
          Icon(
            Icons.newspaper_rounded,
            size: 72,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(l10n.appTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          Text(l10n.aboutBody, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 16),
          Text(l10n.editorialBody,
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
