import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/app_failure.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/oufoq_empty_view.dart';
import '../../../../core/widgets/oufoq_error_view.dart';
import '../../../../core/widgets/shimmer_skeletons.dart';
import '../../domain/entities/category_entity.dart';
import '../providers/categories_providers.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<CategoryEntity>> categories =
        ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.categoriesTitle)),
      body: categories.when(
        loading: () => const CategoriesGridSkeleton(),
        error: (Object error, StackTrace _) => OufoqErrorView(
          failure: error is AppFailure ? error : null,
          onRetry: () => ref.invalidate(categoriesProvider),
        ),
        data: (List<CategoryEntity> items) {
          if (items.isEmpty) {
            return const OufoqEmptyView(icon: Icons.grid_view_rounded);
          }
          return GridView.builder(
            padding: const EdgeInsetsDirectional.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) =>
                _CategoryCard(category: items[index]),
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category});

  final CategoryEntity category;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push(
          RouteNames.categoryPath(category.id),
          extra: category,
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Icon(
                Icons.folder_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 32,
              ),
              Text(
                category.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                context.l10n.articlesCount(category.count),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.customOf(context).textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
