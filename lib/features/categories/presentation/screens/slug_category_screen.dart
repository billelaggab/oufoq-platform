import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/app_failure.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/oufoq_error_view.dart';
import '../../domain/entities/category_entity.dart';
import '../providers/categories_providers.dart';
import 'category_articles_screen.dart';

/// يعالج روابط الأقسام العميقة التي تستخدم الـ slug
/// (مثل `https://oufoq.com/category/politics`).
class SlugCategoryScreen extends ConsumerWidget {
  const SlugCategoryScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<CategoryEntity> category =
        ref.watch(categoryBySlugProvider(slug));

    return category.when(
      loading: () => Scaffold(
        appBar: AppBar(leading: const _HomeLeading()),
        body: const Center(child: CircularProgressIndicator.adaptive()),
      ),
      error: (Object error, StackTrace _) => Scaffold(
        appBar: AppBar(leading: const _HomeLeading()),
        body: OufoqErrorView(
          failure: error is AppFailure ? error : null,
          onRetry: () => ref.invalidate(categoryBySlugProvider(slug)),
        ),
      ),
      data: (CategoryEntity value) => CategoryArticlesScreen(
        categoryId: value.id,
        category: value,
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
