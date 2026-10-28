import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_constants.dart';
import '../../../../core/error/app_failure.dart';
import '../../../../core/storage/preferences_service.dart';
import '../../../article/domain/entities/article_entity.dart';
import '../../../home/presentation/providers/news_providers.dart';

class SearchState {
  const SearchState({
    this.query = '',
    this.results = const AsyncData<List<ArticleEntity>>(<ArticleEntity>[]),
    this.history = const <String>[],
    this.hasSearched = false,
  });

  final String query;
  final AsyncValue<List<ArticleEntity>> results;
  final List<String> history;
  final bool hasSearched;

  SearchState copyWith({
    String? query,
    AsyncValue<List<ArticleEntity>>? results,
    List<String>? history,
    bool? hasSearched,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      history: history ?? this.history,
      hasSearched: hasSearched ?? this.hasSearched,
    );
  }
}

class SearchNotifier extends Notifier<SearchState> {
  Timer? _debounce;

  /// رقم الطلب الحالي؛ أي نتيجة تحمل رقماً أقدم تُهمَل.
  int _requestId = 0;

  PreferencesService get _prefs => ref.read(preferencesServiceProvider);

  @override
  SearchState build() {
    ref.onDispose(() => _debounce?.cancel());
    return SearchState(history: _prefs.getStringList(PrefKeys.searchHistory));
  }

  /// إعادة ضبط الشاشة عند فتحها حتى لا تظهر نتائج جلسة سابقة.
  void reset() {
    _debounce?.cancel();
    _requestId++;
    state = SearchState(history: _prefs.getStringList(PrefKeys.searchHistory));
  }

  /// كتابة فورية مع Debounce 500ms.
  void onQueryChanged(String query) {
    _debounce?.cancel();
    // إبطال أي طلب جارٍ فور تغيير النص، حتى لا يكتب فوق النتائج الجديدة.
    _requestId++;
    state = state.copyWith(query: query);
    if (query.trim().isEmpty) {
      state = state.copyWith(
        results: const AsyncData<List<ArticleEntity>>(<ArticleEntity>[]),
        hasSearched: false,
      );
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () => runSearch(query));
  }

  Future<void> runSearch(String rawQuery) async {
    _debounce?.cancel();
    final String query = rawQuery.trim();
    if (query.isEmpty) {
      _requestId++;
      state = state.copyWith(
        query: '',
        results: const AsyncData<List<ArticleEntity>>(<ArticleEntity>[]),
        hasSearched: false,
      );
      return;
    }
    final int requestId = ++_requestId;
    state = state.copyWith(
      query: query,
      hasSearched: true,
      results: const AsyncLoading<List<ArticleEntity>>(),
    );
    final Result<PaginatedResult<ArticleEntity>> result =
        await ref.read(newsRepositoryProvider).getPosts(
              page: 1,
              searchQuery: query,
            );
    // تجاهل النتائج القديمة أو إن تغيّر نص البحث أثناء الانتظار.
    if (requestId != _requestId || state.query.trim() != query) {
      return;
    }
    switch (result) {
      case Ok<PaginatedResult<ArticleEntity>>(:final PaginatedResult<ArticleEntity> data):
        state = state.copyWith(
          results: AsyncData<List<ArticleEntity>>(data.items),
        );
        _pushHistory(query);
      case Err<dynamic>(:final AppFailure failure):
        state = state.copyWith(
          results: AsyncError<List<ArticleEntity>>(failure, StackTrace.current),
        );
    }
  }

  void _pushHistory(String query) {
    final List<String> updated = <String>[
      query,
      ...state.history.where((String item) => item != query),
    ];
    final List<String> trimmed = updated
        .take(AppConstants.maxSearchHistory)
        .toList(growable: false);
    _prefs.setStringList(PrefKeys.searchHistory, trimmed);
    state = state.copyWith(history: trimmed);
  }

  Future<void> clearHistory() async {
    await _prefs.remove(PrefKeys.searchHistory);
    state = state.copyWith(history: const <String>[]);
  }
}

final NotifierProvider<SearchNotifier, SearchState> searchNotifierProvider =
    NotifierProvider<SearchNotifier, SearchState>(SearchNotifier.new);
