import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/theme/theme_provider.dart';

/// نافذة سفلية لاختيار حجم خط قراءة المقال مع معاينة حية.
class FontScaleBottomSheet extends ConsumerWidget {
  const FontScaleBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => const FontScaleBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double current = ref.watch(articleFontScaleProvider);
    final l10n = context.l10n;

    final List<(double, String)> options = <(double, String)>[
      (ArticleFontScales.small, l10n.fontSmall),
      (ArticleFontScales.medium, l10n.fontMedium),
      (ArticleFontScales.large, l10n.fontLarge),
      (ArticleFontScales.extraLarge, l10n.fontExtraLarge),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.fontScaleTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsetsDirectional.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadiusDirectional.circular(14),
                border: Border.all(
                  color: Theme.of(context).dividerTheme.color ??
                      Colors.transparent,
                ),
              ),
              child: Text(
                l10n.fontPreviewText,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 17 * current,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            RadioGroup<double>(
              groupValue: current,
              onChanged: (double? value) {
                if (value != null) {
                  ref.read(articleFontScaleProvider.notifier).setScale(value);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (final (double scale, String label) in options)
                    RadioListTile<double>(
                      value: scale,
                      title: Text(label),
                      contentPadding: EdgeInsetsDirectional.zero,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
