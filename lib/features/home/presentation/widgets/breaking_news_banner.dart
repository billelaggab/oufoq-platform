import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../article/domain/entities/article_entity.dart';

/// شريط الأخبار العاجلة مع شارة نابضة وتبديل تلقائي هادئ للعناوين.
class BreakingNewsBanner extends StatefulWidget {
  const BreakingNewsBanner({super.key, required this.articles});

  final List<ArticleEntity> articles;

  @override
  State<BreakingNewsBanner> createState() => _BreakingNewsBannerState();
}

class _BreakingNewsBannerState extends State<BreakingNewsBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  Timer? _cycleTimer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // لا تُنشأ أي مؤثرات حركية عند غياب الأخبار العاجلة.
    if (widget.articles.isEmpty) {
      _pulseController = AnimationController(vsync: this);
      return;
    }
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.55,
      upperBound: 1,
    )..repeat(reverse: true);
    if (widget.articles.length > 1) {
      _cycleTimer = Timer.periodic(const Duration(seconds: 4), (_) {
        if (!mounted) {
          return;
        }
        setState(() => _index = (_index + 1) % widget.articles.length);
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _cycleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.articles.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    final ArticleEntity article = widget.articles[_index % widget.articles.length];
    final OufoqCustomColors custom = AppTheme.customOf(context);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 4),
        child: Material(
          color: custom.breaking.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => context.push(
              RouteNames.articlePath(article.id),
              extra: article,
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              child: Row(
                children: <Widget>[
                  FadeTransition(
                    opacity: _pulseController,
                    child: Container(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: custom.breaking,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        context.l10n.breakingLabel,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: Text(
                        article.title,
                        key: ValueKey<String>('${article.id}-$_index'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: custom.breaking,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
