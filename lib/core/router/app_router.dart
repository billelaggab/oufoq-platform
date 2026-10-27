import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/article/domain/entities/article_entity.dart';
import '../../features/article/presentation/screens/article_screen.dart';
import '../../features/bookmarks/presentation/screens/bookmarks_screen.dart';
import '../../features/categories/domain/entities/category_entity.dart';
import '../../features/categories/presentation/screens/categories_screen.dart';
import '../../features/categories/presentation/screens/category_articles_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/settings/presentation/screens/about_screen.dart';
import '../../features/settings/presentation/screens/contact_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../l10n/l10n_extension.dart';
import 'route_names.dart';

/// الهيكل الرئيسي بشريط تنقل سفلي من 4 تبويبات.
class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (int index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: <NavigationDestination>[
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.grid_view_outlined),
            selectedIcon: const Icon(Icons.grid_view_rounded),
            label: l10n.navCategories,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bookmarks_outlined),
            selectedIcon: const Icon(Icons.bookmarks_rounded),
            label: l10n.navBookmarks,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings_rounded),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}

/// موجه التطبيق مع المسارات المستقلة والروابط العميقة.
final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.home,
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder: (
        BuildContext context,
        GoRouterState state,
        StatefulNavigationShell navigationShell,
      ) {
        return MainShellScreen(navigationShell: navigationShell);
      },
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: RouteNames.home,
              builder: (BuildContext context, GoRouterState state) =>
                  const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: RouteNames.categories,
              builder: (BuildContext context, GoRouterState state) =>
                  const CategoriesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: RouteNames.bookmarks,
              builder: (BuildContext context, GoRouterState state) =>
                  const BookmarksScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: RouteNames.settings,
              builder: (BuildContext context, GoRouterState state) =>
                  const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: RouteNames.article,
      builder: (BuildContext context, GoRouterState state) {
        final int id =
            int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        final Object? extra = state.extra;
        return ArticleScreen(
          articleId: id,
          initialArticle: extra is ArticleEntity ? extra : null,
        );
      },
    ),
    GoRoute(
      path: RouteNames.category,
      builder: (BuildContext context, GoRouterState state) {
        final int id =
            int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        final Object? extra = state.extra;
        return CategoryArticlesScreen(
          categoryId: id,
          category: extra is CategoryEntity ? extra : null,
        );
      },
    ),
    GoRoute(
      path: RouteNames.search,
      builder: (BuildContext context, GoRouterState state) =>
          const SearchScreen(),
    ),
    GoRoute(
      path: RouteNames.about,
      builder: (BuildContext context, GoRouterState state) =>
          const AboutScreen(),
    ),
    GoRoute(
      path: RouteNames.contact,
      builder: (BuildContext context, GoRouterState state) =>
          const ContactScreen(),
    ),
  ],
  errorBuilder: (BuildContext context, GoRouterState state) => Scaffold(
    appBar: AppBar(),
    body: Center(child: Text(context.l10n.articleNotFound)),
  ),
);
