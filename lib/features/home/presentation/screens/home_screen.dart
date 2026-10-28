import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/app_failure.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/network/connectivity_provider.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/oufoq_error_view.dart';
import '../../../../core/widgets/shimmer_skeletons.dart';
import '../providers/home_feed_notifier.dart';
import '../widgets/breaking_news_banner.dart';
import '../widgets/featured_hero_carousel.dart';
import '../widgets/news_feed_sliver_list.dart';
import '../widgets/quick_categories_bar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<HomeFeedState> feedState =
        ref.watch(homeFeedNotifierProvider);
    final bool offline = ref
            .watch(connectivityProvider)
            .value
            ?.contains(ConnectivityResult.none) ??
        false;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(homeFeedNotifierProvider.notifier).refresh(),
        child: feedState.when(
          loading: () => const CustomScrollView(
            slivers: <Widget>[
              _HomeAppBar(),
              SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverToBoxAdapter(child: FeaturedCarouselSkeleton()),
              NewsFeedSkeletonList(),
            ],
          ),
          error: (Object error, StackTrace stackTrace) => CustomScrollView(
            slivers: <Widget>[
              const _HomeAppBar(),
              SliverFillRemaining(
                child: OufoqErrorView(
                  failure: error is AppFailure ? error : null,
                  onRetry: () =>
                      ref.read(homeFeedNotifierProvider.notifier).refresh(),
                ),
              ),
            ],
          ),
          data: (HomeFeedState state) => _HomeContent(
            state: state,
            offline: offline,
          ),
        ),
      ),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent({required this.state, required this.offline});

  final HomeFeedState state;
  final bool offline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        // التمرير الأفقي لشريط الأقسام ليس تمريراً لقائمة الأخبار.
        if (notification.depth != 0 ||
            notification.metrics.axis != Axis.vertical) {
          return false;
        }
        final double maxScroll = notification.metrics.maxScrollExtent;
        final double current = notification.metrics.pixels;
        if (maxScroll - current <= 300) {
          ref.read(homeFeedNotifierProvider.notifier).loadMore();
        }
        return false;
      },
      child: CustomScrollView(
        slivers: <Widget>[
          const _HomeAppBar(),
          if (offline) const _OfflineBanner(),
          BreakingNewsBanner(articles: state.breaking),
          FeaturedHeroCarousel(articles: state.featured),
          QuickCategoriesBar(categories: state.categories),
          const LatestNewsHeader(),
          NewsFeedSliverList(articles: state.posts),
          if (state.isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsetsDirectional.all(20),
                child: Center(child: CircularProgressIndicator.adaptive()),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        color: AppTheme.customOf(context).breaking,
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        child: Row(
          children: <Widget>[
            const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.l10n.offlineBanner,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      title: Text(
        context.l10n.appTitle,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
      ),
      actions: <Widget>[
        IconButton(
          tooltip: context.l10n.searchButtonLabel,
          icon: const Icon(Icons.search_rounded),
          onPressed: () => context.push(RouteNames.search),
        ),
      ],
    );
  }
}
