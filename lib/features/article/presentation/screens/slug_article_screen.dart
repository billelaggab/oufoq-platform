import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/app_failure.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/oufoq_error_view.dart';
import '../../domain/entities/article_entity.dart';
import '../providers/article_providers.dart';
import 'article_screen.dart';

/// يعالج روابط ووردبريس العميقة التي تستخدم الـ slug بدل المعرّف الرقمي
/// (مثل `https://oufoq.com/my-article-slug`) ثم يعرض شاشة المقال.
class SlugArticleScreen extends ConsumerWidget {
  const SlugArticleScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ArticleEntity> article =
        ref.watch(articleBySlugProvider(slug));

    return article.when(
      loading: () => Scaffold(
        appBar: AppBar(
          leading: _HomeLeading(),
        ),
        body: const Center(child: CircularProgressIndicator.adaptive()),
      ),
      error: (Object error, StackTrace _) => Scaffold(
        appBar: AppBar(
          leading: _HomeLeading(),
        ),
        body: OufoqErrorView(
          failure: error is AppFailure ? error : null,
          onRetry: () => ref.invalidate(articleBySlugProvider(slug)),
        ),
      ),
      data: (ArticleEntity value) => ArticleScreen(
        articleId: value.id,
        initialArticle: value,
      ),
    );
  }
}

class _HomeLeading extends StatelessWidget {
  const _HomeLeading();

  @override
  Widget build(BuildContext context) {
    if (context.canPop()) {
      return const BackButton();
    }
    return IconButton(
      tooltip: context.l10n.navHome,
      icon: const Icon(Icons.home_rounded),
      onPressed: () => context.go(RouteNames.home),
    );
  }
}
