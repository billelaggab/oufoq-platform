import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/app_constants.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/config/feature_flags.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/l10n/locale_provider.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../ads/data/consent_manager.dart';
import '../../../ads/presentation/providers/consent_providers.dart';
import '../../../categories/presentation/providers/categories_providers.dart';
import '../../../categories/presentation/providers/category_articles_notifier.dart';
import '../../../home/presentation/providers/home_feed_notifier.dart';
import '../../../notifications/data/push_notification_service.dart';
import '../../../notifications/presentation/providers/notification_settings_provider.dart';
import '../../../search/presentation/providers/search_notifier.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        children: <Widget>[
          _SectionTitle(title: l10n.appearanceSection),
          _AppearanceCard(),
          const SizedBox(height: 16),
          _SectionTitle(title: l10n.notificationsSection),
          _NotificationsCard(),
          const SizedBox(height: 16),
          _SectionTitle(title: l10n.dataSection),
          _DataCard(),
          const SizedBox(height: 16),
          _SectionTitle(title: l10n.aboutSection),
          _LegalCard(),
          const SizedBox(height: 24),
          Center(
            child: Text(
              l10n.versionLabel(AppConstants.appVersion),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 8, start: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _AppearanceCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final ThemeMode themeMode = ref.watch(themeModeProvider);
    final double fontScale = ref.watch(articleFontScaleProvider);

    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(l10n.themeModeLabel),
            subtitle: Text(_themeLabel(context, themeMode)),
            onTap: () => _showThemePicker(context, ref),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.text_fields_rounded),
            title: Text(l10n.fontScaleSection),
            subtitle: Text(_fontScaleLabel(context, fontScale)),
            onTap: () => _showFontScalePicker(context, ref),
          ),
          if (FeatureFlags.enableLanguageSwitcher) ...<Widget>[
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.language_rounded),
              title: Text(l10n.languageLabel),
              subtitle: Text(ref.watch(localeProvider).languageCode),
              onTap: () => _showLanguagePicker(context, ref),
            ),
          ],
        ],
      ),
    );
  }

  String _themeLabel(BuildContext context, ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => context.l10n.themeSystem,
      ThemeMode.light => context.l10n.themeLight,
      ThemeMode.dark => context.l10n.themeDark,
    };
  }

  String _fontScaleLabel(BuildContext context, double scale) {
    return switch (scale) {
      ArticleFontScales.small => context.l10n.fontSmall,
      ArticleFontScales.large => context.l10n.fontLarge,
      ArticleFontScales.extraLarge => context.l10n.fontExtraLarge,
      _ => context.l10n.fontMedium,
    };
  }

  Future<void> _showThemePicker(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: RadioGroup<ThemeMode>(
          groupValue: ref.read(themeModeProvider),
          onChanged: (ThemeMode? value) => _applyTheme(context, ref, value),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RadioListTile<ThemeMode>(
                value: ThemeMode.system,
                title: Text(l10n.themeSystem),
              ),
              RadioListTile<ThemeMode>(
                value: ThemeMode.light,
                title: Text(l10n.themeLight),
              ),
              RadioListTile<ThemeMode>(
                value: ThemeMode.dark,
                title: Text(l10n.themeDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _applyTheme(BuildContext context, WidgetRef ref, ThemeMode? mode) {
    if (mode != null) {
      ref.read(themeModeProvider.notifier).setMode(mode);
    }
    Navigator.of(context).pop();
  }

  Future<void> _showFontScalePicker(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final List<(double, String)> options = <(double, String)>[
      (ArticleFontScales.small, l10n.fontSmall),
      (ArticleFontScales.medium, l10n.fontMedium),
      (ArticleFontScales.large, l10n.fontLarge),
      (ArticleFontScales.extraLarge, l10n.fontExtraLarge),
    ];
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: RadioGroup<double>(
          groupValue: ref.read(articleFontScaleProvider),
          onChanged: (double? value) {
            if (value != null) {
              ref.read(articleFontScaleProvider.notifier).setScale(value);
            }
            Navigator.of(context).pop();
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsetsDirectional.all(16),
                child: Text(
                  l10n.fontPreviewText,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 17 * ref.read(articleFontScaleProvider)),
                ),
              ),
              for (final (double scale, String label) in options)
                RadioListTile<double>(
                  value: scale,
                  title: Text(label),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showLanguagePicker(BuildContext context, WidgetRef ref) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: RadioGroup<String>(
          groupValue: ref.read(localeProvider).languageCode,
          onChanged: (String? code) {
            if (code != null) {
              final Locale? match = LocaleConfig.activeLocales
                  .where((Locale l) => l.languageCode == code)
                  .firstOrNull;
              if (match != null) {
                final Locale previous = ref.read(localeProvider);
                ref.read(localeProvider.notifier).setLocale(match);
                // المحتوى المخزّن في المزوّدات يخص اللغة السابقة.
                ref.invalidate(homeFeedNotifierProvider);
                ref.invalidate(categoriesProvider);
                ref.invalidate(categoryArticlesNotifierProvider);
                ref.invalidate(searchNotifierProvider);
                if (ref.read(notificationSettingsProvider) &&
                    previous.languageCode != match.languageCode) {
                  unawaited(
                    PushNotificationService.instance.syncLanguageTopic(
                      oldLanguageCode: previous.languageCode,
                      newLanguageCode: match.languageCode,
                    ),
                  );
                }
              }
            }
            Navigator.of(context).pop();
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (final Locale locale in LocaleConfig.activeLocales)
                RadioListTile<String>(
                  value: locale.languageCode,
                  title: Text(locale.languageCode == 'ar'
                      ? 'العربية'
                      : locale.languageCode == 'fr'
                          ? 'Français'
                          : 'English'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationsCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool enabled = ref.watch(notificationSettingsProvider);
    return Card(
      child: SwitchListTile(
        secondary: const Icon(Icons.notifications_active_outlined),
        title: Text(context.l10n.breakingNotificationsLabel),
        value: enabled,
        onChanged: (bool value) =>
            ref.read(notificationSettingsProvider.notifier).setEnabled(value),
      ),
    );
  }
}

class _DataCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.cleaning_services_outlined),
        title: Text(context.l10n.clearCacheLabel),
        subtitle: Text(context.l10n.clearCacheSubtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => _clearCache(context, ref),
      ),
    );
  }

  Future<void> _clearCache(BuildContext context, WidgetRef ref) async {
    // يمسح كاش الصور وكاش HTTP فقط، دون المساس بقاعدة المحفوظات.
    await DefaultCacheManager().emptyCache();
    await ref.read(cacheStoreProvider).clean();
    PaintingBinding.instance.imageCache.clear();
    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(context.l10n.cacheClearedMessage)),
        );
    }
  }
}

class _LegalCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final bool privacyOptionsRequired =
        ref.watch(privacyOptionsRequiredProvider).value ?? false;

    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.groups_outlined),
            title: Text(l10n.aboutUs),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(RouteNames.about),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.mail_outline_rounded),
            title: Text(l10n.contactUs),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(RouteNames.contact),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.privacyPolicy),
            trailing: const Icon(Icons.open_in_new_rounded),
            onTap: () => _openExternal(context, EnvConfig.privacyPolicyUrl),
          ),
          if (privacyOptionsRequired) ...<Widget>[
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.verified_user_outlined),
              title: Text(l10n.adsPrivacyOptions),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: ConsentManager.showPrivacyOptionsForm,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openExternal(BuildContext context, String url) async {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) {
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
