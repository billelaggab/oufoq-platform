import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/oufoq_cached_image.dart';
import '../../../ads/presentation/widgets/oufoq_native_ad_tile.dart';
import '../../domain/entities/article_entity.dart';
import '../providers/article_providers.dart';

/// قسم المقالات ذات الصلة — يختفي بهدوء عند الفشل أو انقطاع الإنترنت.
class RelatedArticlesSection extends ConsumerWidget {
  const RelatedArticlesSection({super.key, required this.article});

  final ArticleEntity article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<ArticleEntity>> related =
        ref.watch(relatedArticlesProvider(article));

    return related.maybeWhen(
      data: (List<ArticleEntity> items) {
        if (items.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const OufoqNativeAdTile(),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
                child: Text(
                  context.l10n.relatedArticles,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              for (final ArticleEntity item in items)
                _RelatedTile(article: item),
            ],
          ),
        );
      },
      orElse: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
    );
  }
}

class _RelatedTile extends StatelessWidget {
  const _RelatedTile({required this.article});

  final ArticleEntity article;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 6),
      onTap: () => context.push(
        RouteNames.articlePath(article.id),
        extra: article,
      ),
      leading: OufoqCachedImage(
        imageUrl: article.featuredImageThumbUrl,
        width: 72,
        height: 72,
        memCacheWidth: 220,
      ),
      title: Text(
        article.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        context.formatArticleDate(article.publishedAt),
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}
