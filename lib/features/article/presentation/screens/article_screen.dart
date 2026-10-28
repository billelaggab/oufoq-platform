import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/error/app_failure.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/oufoq_cached_image.dart';
import '../../../../core/widgets/oufoq_error_view.dart';
import '../../../../core/widgets/shimmer_skeletons.dart';
import '../../../ads/presentation/providers/interstitial_ad_controller.dart';
import '../../../bookmarks/presentation/providers/bookmarks_providers.dart';
import '../../domain/entities/article_entity.dart';
import '../providers/article_providers.dart';
import '../widgets/article_html_content.dart';
import '../widgets/font_scale_bottom_sheet.dart';
import '../widgets/related_articles_section.dart';

class ArticleScreen extends ConsumerStatefulWidget {
  const ArticleScreen({
    super.key,
    required this.articleId,
    this.initialArticle,
  });

  final int articleId;
  final ArticleEntity? initialArticle;

  @override
  ConsumerState<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends ConsumerState<ArticleScreen> {
  bool _interstitialCounted = false;

  void _countArticleRead() {
    if (_interstitialCounted) {
      return;
    }
    _interstitialCounted = true;
    // غير معطِّل للتجربة ويحترم الفاصل الزمني وعدّاد المقالات.
    ref.read(interstitialAdControllerProvider.notifier).onArticleRead();
  }

  @override
  Widget build(BuildContext context) {
    final ArticleEntity? initial = widget.initialArticle;
    // المحتوى الكامل (رابط عميق/مقال محفوظ) لا يحتاج طلباً إضافياً.
    if (initial != null && initial.htmlContent.trim().isNotEmpty) {
      return _ArticleScaffold(
        article: initial,
        onFirstFrame: _countArticleRead,
      );
    }

    // المقالات القادمة من القوائم لا تحمل `content`، لذا نجلب النسخة
    // الكاملة بالمعرّف بدلاً من عرض متن فارغ.
    final AsyncValue<ArticleEntity> articleAsync =
        ref.watch(articleByIdProvider(widget.articleId));
    return articleAsync.when(
      loading: (initial == null || initial.htmlContent.trim().isEmpty)
          ? _ArticleLoadingScaffold.new
          : () => _ArticleScaffold(
                article: initial,
                onFirstFrame: _countArticleRead,
              ),
      error: (Object error, StackTrace _) => Scaffold(
        appBar: AppBar(),
        body: OufoqErrorView(
          failure: error is AppFailure ? error : null,
          onRetry: () => ref.invalidate(articleByIdProvider(widget.articleId)),
        ),
      ),
      data: (ArticleEntity article) => _ArticleScaffold(
        article: article,
        onFirstFrame: _countArticleRead,
      ),
    );
  }
}

class _ArticleLoadingScaffold extends StatelessWidget {
  const _ArticleLoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsetsDirectional.all(16),
        children: const <Widget>[
          ShimmerSkeleton(height: 220),
          SizedBox(height: 16),
          ShimmerSkeleton(height: 28),
          SizedBox(height: 10),
          ShimmerSkeleton(height: 16, width: 180),
          SizedBox(height: 24),
          ShimmerSkeleton(height: 14),
          SizedBox(height: 8),
          ShimmerSkeleton(height: 14),
          SizedBox(height: 8),
          ShimmerSkeleton(height: 14, width: 240),
        ],
      ),
    );
  }
}

class _ArticleScaffold extends ConsumerWidget {
  const _ArticleScaffold({required this.article, required this.onFirstFrame});

  final ArticleEntity article;
  final VoidCallback onFirstFrame;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) => onFirstFrame());
    final bool isBookmarked = ref.watch(isBookmarkedProvider(article.id));

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            expandedHeight: article.hasFeaturedImage ? 240 : 0,
            // فتح رابط عميق مباشرة لا يوفّر زر رجوع، فنضيف طريقاً للرئيسية.
            leading: context.canPop()
                ? null
                : IconButton(
                    tooltip: context.l10n.navHome,
                    icon: const Icon(Icons.home_rounded),
                    onPressed: () => context.go(RouteNames.home),
                  ),
            actions: <Widget>[
              IconButton(
                tooltip: context.l10n.fontScaleTitle,
                icon: const Icon(Icons.text_fields_rounded),
                onPressed: () => FontScaleBottomSheet.show(context),
              ),
              IconButton(
                tooltip: isBookmarked
                    ? context.l10n.removeBookmark
                    : context.l10n.saveArticle,
                icon: Icon(
                  isBookmarked
                      ? Icons.bookmarks_rounded
                      : Icons.bookmark_border_rounded,
                ),
                color: isBookmarked
                    ? AppTheme.customOf(context).accent
                    : null,
                onPressed: () => _toggleBookmark(context, ref),
              ),
              IconButton(
                tooltip: context.l10n.shareArticle,
                icon: const Icon(Icons.share_outlined),
                onPressed: () => _shareArticle(),
              ),
            ],
            flexibleSpace: article.hasFeaturedImage
                ? FlexibleSpaceBar(
                    background: OufoqCachedImage(
                      imageUrl: article.featuredImageFullUrl ??
                          article.featuredImageThumbUrl,
                      borderRadius: BorderRadius.zero,
                    ),
                  )
                : null,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsetsDirectional.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (article.primaryCategoryName != null)
                    Container(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      margin: const EdgeInsetsDirectional.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadiusDirectional.circular(8),
                      ),
                      child: Text(
                        article.primaryCategoryName!,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: Colors.white),
                      ),
                    ),
                  Text(
                    article.title,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(_metaLine(context),
                      style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(height: 24),
                  ArticleHtmlContent(html: article.htmlContent),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          RelatedArticlesSection(article: article),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  String _metaLine(BuildContext context) {
    final String date = context.formatArticleDate(article.publishedAt);
    final String reading =
        context.l10n.readingTimeMinutes(article.readingTimeMinutes);
    final String author = article.authorName ?? '';
    final List<String> parts = <String>[
      if (author.isNotEmpty) author,
      if (date.isNotEmpty) date,
      reading,
    ];
    return parts.join('  •  ');
  }

  Future<void> _toggleBookmark(BuildContext context, WidgetRef ref) async {
    try {
      final bool saved =
          await ref.read(bookmarksNotifierProvider.notifier).toggle(article);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              saved ? context.l10n.bookmarkAdded : context.l10n.bookmarkRemoved,
            ),
          ),
        );
    } on Object {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(context.l10n.errorUnknown)));
    }
  }

  Future<void> _shareArticle() async {
    await SharePlus.instance.share(
      ShareParams(text: '${article.title}\n${article.link}'),
    );
  }
}
