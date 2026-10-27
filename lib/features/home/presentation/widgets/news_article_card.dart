import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/oufoq_cached_image.dart';
import '../../../article/domain/entities/article_entity.dart';
import '../../../bookmarks/presentation/providers/bookmarks_providers.dart';

/// بطاقة خبر موحدة تُستخدم في الرئيسية والبحث والأقسام والمحفوظات.
class NewsArticleCard extends ConsumerWidget {
  const NewsArticleCard({super.key, required this.article});

  final ArticleEntity article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isBookmarked =
        ref.watch(isBookmarkedProvider(article.id));

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push(
            RouteNames.articlePath(article.id),
            extra: article,
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _CardThumbnail(article: article),
                const SizedBox(width: 12),
                Expanded(child: _CardBody(article: article, isBookmarked: isBookmarked)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardThumbnail extends StatelessWidget {
  const _CardThumbnail({required this.article});

  final ArticleEntity article;

  @override
  Widget build(BuildContext context) {
    return OufoqCachedImage(
      imageUrl: article.featuredImageThumbUrl,
      width: 110,
      height: 84,
      memCacheWidth: 300,
      borderRadius: BorderRadius.circular(12),
    );
  }
}

class _CardBody extends ConsumerWidget {
  const _CardBody({required this.article, required this.isBookmarked});

  final ArticleEntity article;
  final bool isBookmarked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            if (article.primaryCategoryName != null)
              Expanded(
                child: Text(
                  article.primaryCategoryName!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              )
            else
              const Spacer(),
            _BookmarkButton(article: article, isBookmarked: isBookmarked),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          article.title,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          _metaLine(context),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }

  String _metaLine(BuildContext context) {
    final String date = context.formatArticleDate(article.publishedAt);
    final String reading =
        context.l10n.readingTimeMinutes(article.readingTimeMinutes);
    return date.isEmpty ? reading : '$date  •  $reading';
  }
}

class _BookmarkButton extends ConsumerWidget {
  const _BookmarkButton({required this.article, required this.isBookmarked});

  final ArticleEntity article;
  final bool isBookmarked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkResponse(
      onTap: () => _onToggle(context, ref),
      radius: 22,
      child: Icon(
        isBookmarked ? Icons.bookmarks_rounded : Icons.bookmark_border_rounded,
        size: 22,
        color: isBookmarked
            ? AppTheme.customOf(context).accent
            : AppTheme.customOf(context).textSecondary,
      ),
    );
  }

  Future<void> _onToggle(BuildContext context, WidgetRef ref) async {
    final bool nowSaved =
        await ref.read(bookmarksNotifierProvider.notifier).toggle(article);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            nowSaved
                ? context.l10n.bookmarkAdded
                : context.l10n.bookmarkRemoved,
          ),
        ),
      );
  }
}
