import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/l10n/l10n_extension.dart';

/// شاشة "اتصل بنا" بوسائل تواصل رسمية (مطلب News Policy).
class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  Future<void> _launch(BuildContext context, Uri uri) async {
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.errorUnknown)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.contactTitle)),
      body: ListView(
        padding: const EdgeInsetsDirectional.all(16),
        children: <Widget>[
          Card(
            child: ListTile(
              leading: const Icon(Icons.email_outlined),
              title: Text(l10n.emailLabel),
              subtitle: const Text(EnvConfig.contactEmail),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _launch(
                context,
                Uri(scheme: 'mailto', path: EnvConfig.contactEmail),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.language_rounded),
              title: Text(l10n.websiteLabel),
              subtitle: const Text(EnvConfig.officialWebsite),
              trailing: const Icon(Icons.open_in_new_rounded),
              onTap: () =>
                  _launch(context, Uri.parse(EnvConfig.officialWebsite)),
            ),
          ),
        ],
      ),
    );
  }
}
