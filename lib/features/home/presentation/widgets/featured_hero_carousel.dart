import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/oufoq_cached_image.dart';
import '../../../article/domain/entities/article_entity.dart';

/// سلايدر الأخبار البارزة بتدرج لوني ومؤشر نقاط.
class FeaturedHeroCarousel extends StatefulWidget {
  const FeaturedHeroCarousel({super.key, required this.articles});

  final List<ArticleEntity> articles;

  @override
  State<FeaturedHeroCarousel> createState() => _FeaturedHeroCarouselState();
}

class _FeaturedHeroCarouselState extends State<FeaturedHeroCarousel> {
  final PageController _controller = PageController();
  Timer? _autoAdvance;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _restartAutoAdvance();
  }

  @override
  void didUpdateWidget(covariant FeaturedHeroCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.articles, widget.articles)) {
      _restartAutoAdvance();
      if (widget.articles.isEmpty || _currentPage >= widget.articles.length) {
        _currentPage = 0;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _controller.hasClients && widget.articles.isNotEmpty) {
            _controller.jumpToPage(0);
          }
        });
      }
    }
  }

  void _restartAutoAdvance() {
    _autoAdvance?.cancel();
    _autoAdvance = null;
    if (widget.articles.length <= 1) {
      return;
    }
    _autoAdvance = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted || widget.articles.isEmpty || !_controller.hasClients) {
        return;
      }
      if (_currentPage >= widget.articles.length) {
        _currentPage = 0;
      }
      final int next = (_currentPage + 1) % widget.articles.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoAdvance?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.articles.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
            child: Text(
              context.l10n.featuredSection,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          SizedBox(
            height: 220,
            child: PageView.builder(
              controller: _controller,
              padEnds: false,
              itemCount: widget.articles.length,
              onPageChanged: (int index) => setState(() => _currentPage = index),
              itemBuilder: (BuildContext context, int index) =>
                  _HeroCard(article: widget.articles[index]),
            ),
          ),
          const SizedBox(height: 10),
          _DotsIndicator(count: widget.articles.length, activeIndex: _currentPage),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.article});

  final ArticleEntity article;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: 16,
        end: 16,
      ),
      child: GestureDetector(
        onTap: () => context.push(
          RouteNames.articlePath(article.id),
          extra: article,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              OufoqCachedImage(
                imageUrl: article.featuredImageFullUrl ??
                    article.featuredImageThumbUrl,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(20),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: AlignmentDirectional.topCenter,
                    end: AlignmentDirectional.bottomCenter,
                    colors: <Color>[
                      Color(0x00000000),
                      Color(0xCC000000),
                    ],
                    stops: <double>[0.45, 1],
                  ),
                ),
              ),
              PositionedDirectional(
                start: 16,
                end: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (article.primaryCategoryName != null)
                      Container(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        margin: const EdgeInsetsDirectional.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                              ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.formatArticleDate(article.publishedAt),
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({required this.count, required this.activeIndex});

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(count, (int index) {
        final bool active = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsetsDirectional.symmetric(horizontal: 3),
          width: active ? 18 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: active
                ? Theme.of(context).colorScheme.primary
                : AppTheme.customOf(context).textSecondary.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
