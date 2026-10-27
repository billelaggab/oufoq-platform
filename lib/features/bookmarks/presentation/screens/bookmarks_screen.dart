import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_failure.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/widgets/oufoq_empty_view.dart';
import '../../../../core/widgets/oufoq_error_view.dart';
import '../../../home/presentation/widgets/news_article_card.dart';
import '../providers/bookmarks_providers.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(bookmarksNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.bookmarksTitle)),
      body: bookmarksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (Object error, StackTrace _) => OufoqErrorView(
          failure: error is AppFailure ? error : null,
          onRetry: () => ref.invalidate(bookmarksNotifierProvider),
        ),
        data: (articles) {
          if (articles.isEmpty) {
            return OufoqEmptyView(
              icon: Icons.bookmarks_outlined,
              title: context.l10n.bookmarksEmptyTitle,
              body: context.l10n.bookmarksEmptyBody,
            );
          }
          // تعمل بالكامل بدون إنترنت من قاعدة SQLite المحلية.
          return ListView.builder(
            padding: const EdgeInsetsDirectional.symmetric(vertical: 8),
            itemCount: articles.length,
            itemBuilder: (BuildContext context, int index) =>
                NewsArticleCard(article: articles[index]),
          );
        },
      ),
    );
  }
}
