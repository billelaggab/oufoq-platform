import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_failure.dart';
import '../../../../core/widgets/oufoq_error_view.dart';
import '../../../../core/widgets/shimmer_skeletons.dart';
import '../../../ads/presentation/widgets/oufoq_banner_ad_slot.dart';
import '../../../home/presentation/widgets/news_article_card.dart';
import '../../domain/entities/category_entity.dart';
import '../providers/category_articles_notifier.dart';

/// شاشة مقالات قسم معيّن مع بنر سفلي ثابت وتصفح لانهائي.
class CategoryArticlesScreen extends ConsumerStatefulWidget {
  const CategoryArticlesScreen({
    super.key,
    required this.categoryId,
    this.category,
  });

  final int categoryId;
  final CategoryEntity? category;

  @override
  ConsumerState<CategoryArticlesScreen> createState() =>
      _CategoryArticlesScreenState();
}

class _CategoryArticlesScreenState
    extends ConsumerState<CategoryArticlesScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() => ref
        .read(categoryArticlesNotifierProvider.notifier)
        .loadCategory(widget.categoryId));
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<CategoryArticlesState> state =
        ref.watch(categoryArticlesNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category?.name ?? ''),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                if (notification.metrics.maxScrollExtent -
                        notification.metrics.pixels <=
                    300) {
                  ref
                      .read(categoryArticlesNotifierProvider.notifier)
                      .loadMore();
                }
                return false;
              },
              child: state.when(
                loading: () => ListView(
                  children: const <Widget>[
                    NewsCardSkeleton(),
                    NewsCardSkeleton(),
                    NewsCardSkeleton(),
                  ],
                ),
                error: (Object error, StackTrace _) => OufoqErrorView(
                  failure: error is AppFailure ? error : null,
                  onRetry: () => ref
                      .read(categoryArticlesNotifierProvider.notifier)
                      .loadCategory(widget.categoryId),
                ),
                data: (CategoryArticlesState data) => RefreshIndicator(
                  onRefresh: () => ref
                      .read(categoryArticlesNotifierProvider.notifier)
                      .loadCategory(widget.categoryId),
                  child: ListView.builder(
                    itemCount: data.articles.length +
                        (data.isLoadingMore ? 1 : 0),
                    itemBuilder: (BuildContext context, int index) {
                      if (index == data.articles.length) {
                        return const Padding(
                          padding: EdgeInsetsDirectional.all(20),
                          child: Center(
                            child: CircularProgressIndicator.adaptive(),
                          ),
                        );
                      }
                      return NewsArticleCard(article: data.articles[index]);
                    },
                  ),
                ),
              ),
            ),
          ),
          const OufoqBannerAdSlot(),
        ],
      ),
    );
  }
}
