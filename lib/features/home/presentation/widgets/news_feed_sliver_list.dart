import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../ads/presentation/providers/ad_config_provider.dart';
import '../../../ads/presentation/utils/feed_ad_slot_mapper.dart';
import '../../../ads/presentation/widgets/oufoq_native_ad_tile.dart';
import '../../../article/domain/entities/article_entity.dart';
import 'news_article_card.dart';

/// قائمة أخبار Sliver مع إدراج الإعلانات المدمجة بفواصل حسابية دقيقة.
class NewsFeedSliverList extends ConsumerWidget {
  const NewsFeedSliverList({super.key, required this.articles});

  final List<ArticleEntity> articles;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AdConfigLite config = _readConfig(ref);
    final int interval = config.nativeInterval;
    final bool adsEnabled = config.enabled && config.nativeEnabled;

    final int mergedCount = adsEnabled
        ? FeedAdSlotMapper.itemCount(articles.length, interval)
        : articles.length;

    return SliverList.builder(
      itemCount: mergedCount,
      itemBuilder: (BuildContext context, int mergedIndex) {
        final bool isAd =
            adsEnabled && FeedAdSlotMapper.isAdSlot(mergedIndex, interval);
        if (isAd) {
          return OufoqNativeAdTile(
            key: ValueKey<String>('native-ad-$mergedIndex'),
            compact: true,
          );
        }
        final int articleIndex = adsEnabled
            ? FeedAdSlotMapper.articleIndexAt(mergedIndex, interval)
            : mergedIndex;
        if (articleIndex < 0 || articleIndex >= articles.length) {
          return const SizedBox.shrink();
        }
        return NewsArticleCard(article: articles[articleIndex]);
      },
    );
  }

  AdConfigLite _readConfig(WidgetRef ref) {
    final config = ref.watch(adConfigProvider);
    return AdConfigLite(
      enabled: config.enabled,
      nativeEnabled: config.nativeEnabled,
      nativeInterval: config.nativeInterval,
    );
  }
}

/// نسخة خفيفة من الإعدادات لفصل منطق العرض.
class AdConfigLite {
  const AdConfigLite({
    required this.enabled,
    required this.nativeEnabled,
    required this.nativeInterval,
  });

  final bool enabled;
  final bool nativeEnabled;
  final int nativeInterval;
}

/// مؤشر تحميل المزيد أسفل القائمة.
class LoadMoreFooter extends StatelessWidget {
  const LoadMoreFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsetsDirectional.all(20),
        child: Center(child: CircularProgressIndicator.adaptive()),
      ),
    );
  }
}

/// عنوان قسم "أحدث الأخبار".
class LatestNewsHeader extends StatelessWidget {
  const LatestNewsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 8),
        child: Text(
          context.l10n.latestNews,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
