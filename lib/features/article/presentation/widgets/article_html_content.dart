import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:fwfh_cached_network_image/fwfh_cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart';
import '../screens/full_screen_image_viewer.dart';

class _OufoqWidgetFactory extends WidgetFactory
    with CachedNetworkImageFactory {}

/// عرض محتوى ووردبريس HTML كعناصر Flutter أصلية بخط Tajawal.
class ArticleHtmlContent extends ConsumerWidget {
  const ArticleHtmlContent({super.key, required this.html});

  final String html;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double fontScale = ref.watch(articleFontScaleProvider);
    final TextStyle baseStyle =
        Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontSize: 17 * fontScale,
              height: 1.65,
            );

    return HtmlWidget(
      html,
      factoryBuilder: () => _OufoqWidgetFactory(),
      textStyle: baseStyle,
      onTapUrl: (String url) async {
        final Uri? uri = Uri.tryParse(url);
        if (uri == null) {
          return false;
        }
        try {
          return await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
        } on Object {
          return false;
        }
      },
      onTapImage: (ImageMetadata image) {
        final String? url = image.sources.firstOrNull?.url;
        if (url == null || url.isEmpty) {
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => FullScreenImageViewer(imageUrl: url),
          ),
        );
      },
      customStylesBuilder: (dynamic element) {
        final String tag =
            (element.localName ?? '').toString().toLowerCase();
        switch (tag) {
          case 'blockquote':
            return <String, String>{
              'padding': '12px',
              'background': '#0F4C8114',
              'margin': '12px 0px',
            };
          case 'h2':
          case 'h3':
            return <String, String>{
              'margin-top': '24px',
              'margin-bottom': '10px',
            };
          case 'p':
            return <String, String>{'margin-bottom': '16px'};
          default:
            return null;
        }
      },
      onLoadingBuilder: (context, element, progress) => Padding(
        padding: const EdgeInsetsDirectional.symmetric(vertical: 24),
        child: CircularProgressIndicator.adaptive(
          value: progress,
        ),
      ),
    );
  }
}

/// لون هادئ مشتق من الثيم للاقتباسات.
Color quoteSurface(BuildContext context) =>
    AppTheme.customOf(context).adSurface;
