import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../providers/home_feed_notifier.dart';

/// شريط أفقي للفلترة السريعة حسب الأقسام.
class QuickCategoriesBar extends ConsumerWidget {
  const QuickCategoriesBar({super.key, required this.categories});

  final List<CategoryEntity> categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int? selectedId =
        ref.watch(homeFeedNotifierProvider).value?.selectedCategoryId;

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 48,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
          children: <Widget>[
            _CategoryChip(
              label: context.l10n.categoryAllChip,
              selected: selectedId == null,
              onSelected: () => ref
                  .read(homeFeedNotifierProvider.notifier)
                  .selectCategory(null),
            ),
            for (final CategoryEntity category in categories)
              _CategoryChip(
                label: category.name,
                selected: selectedId == category.id,
                onSelected: () => ref
                    .read(homeFeedNotifierProvider.notifier)
                    .selectCategory(category.id),
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}
