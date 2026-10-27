import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_theme.dart';

/// هياكل تحميل عظمية متناسقة مع الثيم النشط.
class ShimmerSkeleton extends StatelessWidget {
  const ShimmerSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
      highlightColor:
          isDark ? const Color(0xFF273449) : const Color(0xFFF1F5F9),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              borderRadius ?? BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// هيكل عظمي للسلايدر الرئيسي.
class FeaturedCarouselSkeleton extends StatelessWidget {
  const FeaturedCarouselSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
      child: ShimmerSkeleton(
        height: 220,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

/// هيكل عظمي لبطاقة خبر في القائمة.
class NewsCardSkeleton extends StatelessWidget {
  const NewsCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsetsDirectional.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(12),
        child: Row(
          children: <Widget>[
            const ShimmerSkeleton(width: 110, height: 84),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const <Widget>[
                  ShimmerSkeleton(width: 80, height: 14),
                  SizedBox(height: 10),
                  ShimmerSkeleton(height: 16),
                  SizedBox(height: 8),
                  ShimmerSkeleton(width: 140, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// قائمة هياكل عظمية لتحميل الخبر.
class NewsFeedSkeletonList extends StatelessWidget {
  const NewsFeedSkeletonList({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: itemCount,
      itemBuilder: (BuildContext context, int index) =>
          const NewsCardSkeleton(),
    );
  }
}

/// شبكة هياكل عظمية لشاشة الأقسام.
class CategoriesGridSkeleton extends StatelessWidget {
  const CategoriesGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsetsDirectional.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: 6,
      itemBuilder: (BuildContext context, int index) =>
          const ShimmerSkeleton(),
    );
  }
}

/// لون خلفية هادئ مشتق من الثيم للحالات الخاصة.
Color quietSurface(BuildContext context) => AppTheme.customOf(context).adSurface;
