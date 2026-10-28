import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/app_failure.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/oufoq_empty_view.dart';
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
  bool _reloadScheduled = false;

  @override
  void initState() {
    super.initState();
    _scheduleReload();
  }

  /// يعيد تحميل القسم بعد أول إطار، أو بعد إبطال المزوّد (تغيير اللغة).
  void _scheduleReload() {
    if (_reloadScheduled) {
      return;
    }
    _reloadScheduled = true;
    Future<void>.microtask(() async {
      _reloadScheduled = false;
      if (!mounted) {
        return;
      }
      await ref
          .read(categoryArticlesNotifierProvider.notifier)
          .loadCategory(widget.categoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<CategoryArticlesState> state =
        ref.watch(categoryArticlesNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category?.name ?? ''),
        leading: context.canPop()
            ? null
            : IconButton(
                tooltip: context.l10n.navHome,
                icon: const Icon(Icons.home_rounded),
                onPressed: () => context.go(RouteNames.home),
              ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                // تجاهل تمرير أي قائمة أفقية داخلية.
                if (notification.depth != 0 ||
                    notification.metrics.axis != Axis.vertical) {
                  return false;
                }
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
                data: (CategoryArticlesState data) {
                  // بعد إبطال المزوّد تعود الحالة فارغة بلا معرّف قسم؛
                  // نعيد التحميل بدل إظهار «لا توجد مقالات» خطأً.
                  if (data.categoryId != widget.categoryId) {
                    _scheduleReload();
                    return ListView(
                      children: const <Widget>[
                        NewsCardSkeleton(),
                        NewsCardSkeleton(),
                        NewsCardSkeleton(),
                      ],
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () => ref
                        .read(categoryArticlesNotifierProvider.notifier)
                        .loadCategory(widget.categoryId),
                    child: data.articles.isEmpty
                        ? ListView(
                            children: <Widget>[
                              SizedBox(
                                height: 320,
                                child: OufoqEmptyView(
                                  icon: Icons.article_outlined,
                                  title: context.l10n.emptyDefaultTitle,
                                  body: context.l10n.emptyDefaultBody,
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
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
                              return NewsArticleCard(
                                article: data.articles[index],
                              );
                            },
                          ),
                  );
                },
              ),
            ),
          ),
          const OufoqBannerAdSlot(),
        ],
      ),
    );
  }
}
