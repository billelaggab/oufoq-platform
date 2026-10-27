import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_failure.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/widgets/oufoq_empty_view.dart';
import '../../../../core/widgets/oufoq_error_view.dart';
import '../../../home/presentation/widgets/news_article_card.dart';
import '../providers/search_notifier.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SearchState state = ref.watch(searchNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          focusNode: _focusNode,
          textInputAction: TextInputAction.search,
          onChanged: (String value) =>
              ref.read(searchNotifierProvider.notifier).onQueryChanged(value),
          onSubmitted: (String value) =>
              ref.read(searchNotifierProvider.notifier).runSearch(value),
          decoration: InputDecoration(
            hintText: context.l10n.searchHint,
            border: InputBorder.none,
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (BuildContext context, TextEditingValue value, _) {
                if (value.text.isEmpty) {
                  return const Icon(Icons.search_rounded);
                }
                return IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    _controller.clear();
                    ref
                        .read(searchNotifierProvider.notifier)
                        .onQueryChanged('');
                  },
                );
              },
            ),
          ),
        ),
      ),
      body: _buildBody(context, state),
    );
  }

  Widget _buildBody(BuildContext context, SearchState state) {
    // قبل بدء البحث: سجل الكلمات السابقة.
    if (!state.hasSearched) {
      return _HistoryView(history: state.history);
    }
    return state.results.when(
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (Object error, StackTrace _) => OufoqErrorView(
        failure: error is AppFailure ? error : null,
      ),
      data: (articles) {
        if (articles.isEmpty) {
          return OufoqEmptyView(
            icon: Icons.search_off_rounded,
            title: context.l10n.searchEmptyTitle,
            body: context.l10n.searchEmptyBody,
          );
        }
        return ListView.builder(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          itemCount: articles.length,
          itemBuilder: (BuildContext context, int index) =>
              NewsArticleCard(article: articles[index]),
        );
      },
    );
  }
}

class _HistoryView extends ConsumerWidget {
  const _HistoryView({required this.history});

  final List<String> history;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (history.isEmpty) {
      return OufoqEmptyView(
        icon: Icons.manage_search_rounded,
        title: context.l10n.searchHint,
        body: context.l10n.searchEmptyBody,
      );
    }
    return ListView(
      padding: const EdgeInsetsDirectional.all(16),
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                context.l10n.searchHistoryTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            TextButton.icon(
              onPressed: () =>
                  ref.read(searchNotifierProvider.notifier).clearHistory(),
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: Text(context.l10n.clearHistory),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final String term in history)
              ActionChip(
                label: Text(term),
                avatar: const Icon(Icons.history_rounded, size: 16),
                onPressed: () =>
                    ref.read(searchNotifierProvider.notifier).runSearch(term),
              ),
          ],
        ),
      ],
    );
  }
}
